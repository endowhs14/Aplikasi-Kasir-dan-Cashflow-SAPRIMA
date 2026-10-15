import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import '../domain/money.dart';

/// One encrypted database per workspace (demo / local shop). No network adapter.
class Store {
  Store._(this.db, this.demo);
  final Database db;
  final bool demo;
  static const _uuid = Uuid();
  static String newId() => _uuid.v4();

  static Store open(String path, String key, {required bool demo}) {
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(key)) {
      throw const PosError('Kunci penyimpanan tidak valid.');
    }
    final db = sqlite3.open(path);
    try {
      db.execute('PRAGMA key = "x\'$key\'"');
      if (db.select('PRAGMA cipher_version').isEmpty) {
        throw const PosError('Enkripsi database tidak tersedia.');
      }
      db.select(
        'SELECT count(*) FROM sqlite_master',
      ); // Wrong key must fail closed.
      db.execute('PRAGMA foreign_keys=ON');
      db.execute('PRAGMA journal_mode=WAL');
      db.execute('PRAGMA synchronous=FULL');
      db.execute('PRAGMA busy_timeout=5000');
      final store = Store._(db, demo);
      store._migrate();
      return store;
    } catch (_) {
      db.close();
      rethrow;
    }
  }

  T atomic<T>(T Function() action) {
    db.execute('BEGIN IMMEDIATE');
    try {
      final result = action();
      db.execute('COMMIT');
      return result;
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  void _migrate() {
    final version = db.select('PRAGMA user_version').first.values.first as int;
    if (version > 1) {
      throw const PosError('Database berasal dari versi aplikasi lebih baru.');
    }
    if (version == 1) return;
    atomic(() {
      db.execute('''
CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE TABLE products(
 id TEXT PRIMARY KEY, name TEXT NOT NULL, sku TEXT NOT NULL UNIQUE COLLATE NOCASE,
 category TEXT NOT NULL, unit TEXT NOT NULL, price INTEGER NOT NULL CHECK(price>=0),
 service INTEGER NOT NULL CHECK(service IN(0,1)), stock INTEGER NOT NULL CHECK(stock>=0),
 version INTEGER NOT NULL DEFAULT 1);
CREATE TABLE sales(
 id TEXT PRIMARY KEY, receipt TEXT NOT NULL UNIQUE, payload_hash TEXT NOT NULL,
 tenant_id TEXT NOT NULL DEFAULT 'local', branch_id TEXT NOT NULL DEFAULT 'utama',
 actor TEXT NOT NULL DEFAULT 'Pemilik lokal', occurred_at TEXT NOT NULL,
 gross INTEGER NOT NULL CHECK(gross>=0), discount INTEGER NOT NULL CHECK(discount>=0 AND discount<=gross),
 total INTEGER NOT NULL CHECK(total=gross-discount), demo INTEGER NOT NULL,
 sync_status TEXT NOT NULL DEFAULT 'local_only');
CREATE TABLE sale_items(
 id TEXT PRIMARY KEY, sale_id TEXT NOT NULL REFERENCES sales(id),
 product_id TEXT NOT NULL REFERENCES products(id), name TEXT NOT NULL, sku TEXT NOT NULL,
 unit TEXT NOT NULL, price INTEGER NOT NULL, quantity INTEGER NOT NULL CHECK(quantity>0),
 total INTEGER NOT NULL CHECK(total>=0), service INTEGER NOT NULL,
 UNIQUE(sale_id,product_id));
CREATE TABLE payments(
 sale_id TEXT PRIMARY KEY REFERENCES sales(id), method TEXT NOT NULL CHECK(method='cash'),
 amount INTEGER NOT NULL CHECK(amount>=0), tendered INTEGER NOT NULL CHECK(tendered>=amount),
 change_amount INTEGER NOT NULL CHECK(change_amount=tendered-amount));
CREATE TABLE stock_movements(
 id TEXT PRIMARY KEY, product_id TEXT NOT NULL REFERENCES products(id),
 delta INTEGER NOT NULL CHECK(delta<>0), reason TEXT NOT NULL, occurred_at TEXT NOT NULL,
 sale_item_id TEXT UNIQUE REFERENCES sale_items(id), actor TEXT NOT NULL DEFAULT 'Pemilik lokal');
CREATE TABLE cash_entries(
 sale_id TEXT PRIMARY KEY REFERENCES sales(id), amount INTEGER NOT NULL CHECK(amount>=0));
CREATE TABLE outbox(
 sale_id TEXT PRIMARY KEY REFERENCES sales(id), payload TEXT NOT NULL,
 status TEXT NOT NULL DEFAULT 'local_only');
CREATE TABLE audit(
 id TEXT PRIMARY KEY, action TEXT NOT NULL, target_id TEXT NOT NULL,
 detail TEXT NOT NULL, occurred_at TEXT NOT NULL);
CREATE TABLE draft(id INTEGER PRIMARY KEY CHECK(id=1), payload TEXT NOT NULL);
CREATE INDEX sales_date ON sales(occurred_at DESC,id DESC);
CREATE INDEX stock_product ON stock_movements(product_id,occurred_at DESC);
PRAGMA user_version=1;
''');
      db.execute('INSERT INTO settings VALUES(?,?)', ['installation', newId()]);
      db.execute('INSERT INTO settings VALUES(?,?)', ['sequence', '0']);
    });
  }

  String? setting(String key) {
    final rows = db.select('SELECT value FROM settings WHERE key=?', [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  void setSetting(String key, String value) => db.execute(
    'INSERT INTO settings VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value',
    [key, value],
  );

  List<Product> products({String query = '', String? category}) {
    final all = db
        .select('SELECT * FROM products ORDER BY name COLLATE NOCASE')
        .map((r) => Product.fromMap(r))
        .toList();
    final q = query.toLowerCase().trim();
    return all
        .where(
          (p) =>
              (category == null || p.category == category) &&
              ('${p.name} ${p.sku}'.toLowerCase().contains(q)),
        )
        .toList();
  }

  Product product(String id) {
    final rows = db.select('SELECT * FROM products WHERE id=?', [id]);
    if (rows.isEmpty) throw const PosError('Produk tidak ditemukan.');
    return Product.fromMap(rows.first);
  }

  Product saveProduct({
    String? id,
    int? expectedVersion,
    required String name,
    required String sku,
    required String category,
    required String unit,
    required int price,
    required bool service,
    int openingStock = 0,
  }) {
    if (name.trim().isEmpty ||
        sku.trim().isEmpty ||
        category.trim().isEmpty ||
        unit.trim().isEmpty ||
        name.trim().length > 100 ||
        sku.trim().length > 40 ||
        category.trim().length > 60 ||
        unit.trim().length > 20) {
      throw const PosError(
        'Lengkapi nama, SKU, kategori, dan satuan sesuai batas panjang.',
      );
    }
    if (price < 0 ||
        price > maxPrice ||
        openingStock < 0 ||
        openingStock > maxQuantity) {
      throw const PosError('Harga atau stok di luar batas.');
    }
    final pid = id ?? newId();
    atomic(() {
      final duplicate = db.select(
        'SELECT id FROM products WHERE sku=? COLLATE NOCASE AND id<>?',
        [sku.trim(), pid],
      );
      if (duplicate.isNotEmpty) {
        throw const PosError('SKU sudah dipakai. Gunakan kode lain.');
      }
      if (id == null) {
        db.execute(
          'INSERT INTO products(id,name,sku,category,unit,price,service,stock) VALUES(?,?,?,?,?,?,?,?)',
          [
            pid,
            name.trim(),
            sku.trim().toUpperCase(),
            category.trim(),
            unit.trim(),
            price,
            service ? 1 : 0,
            service ? 0 : openingStock,
          ],
        );
        if (!service && openingStock > 0) {
          _movement(pid, openingStock, 'Stok awal');
        }
      } else {
        final old = product(pid);
        if (old.version != expectedVersion) {
          throw const PosError('Produk berubah. Buka ulang formulir.');
        }
        if (old.service != service) {
          throw const PosError(
            'Jenis produk tidak dapat diubah; buat SKU baru.',
          );
        }
        db.execute(
          'UPDATE products SET name=?,sku=?,category=?,unit=?,price=?,version=version+1 WHERE id=?',
          [
            name.trim(),
            sku.trim().toUpperCase(),
            category.trim(),
            unit.trim(),
            price,
            pid,
          ],
        );
      }
      _audit(
        id == null ? 'product.created' : 'product.updated',
        pid,
        jsonEncode({
          'name': name.trim(),
          'sku': sku.trim(),
          'price': price,
          'unit': unit.trim(),
        }),
      );
    });
    return product(pid);
  }

  void adjustStock(String id, int delta, String reason, int expectedVersion) {
    if (reason.trim().isEmpty || reason.length > 200 || delta == 0) {
      throw const PosError('Isi alasan dan perubahan stok bukan nol.');
    }
    atomic(() {
      final p = product(id);
      if (p.service) throw const PosError('Jasa tidak memiliki stok.');
      if (p.version != expectedVersion) {
        throw const PosError('Stok berubah. Buka ulang penyesuaian.');
      }
      if (p.stock + delta < 0 || p.stock + delta > maxQuantity) {
        throw const PosError(
          'Hasil stok tidak boleh negatif atau melebihi batas.',
        );
      }
      db.execute(
        'UPDATE products SET stock=stock+?,version=version+1 WHERE id=?',
        [delta, id],
      );
      _movement(id, delta, reason.trim());
      _audit(
        'stock.adjusted',
        id,
        jsonEncode({'delta': delta, 'reason': reason.trim()}),
      );
    });
  }

  void _movement(String id, int delta, String reason, {String? lineId}) =>
      db.execute(
        'INSERT INTO stock_movements(id,product_id,delta,reason,occurred_at,sale_item_id) VALUES(?,?,?,?,?,?)',
        [
          newId(),
          id,
          delta,
          reason,
          DateTime.now().toUtc().toIso8601String(),
          lineId,
        ],
      );
  void _audit(String action, String target, String detail) => db.execute(
    'INSERT INTO audit VALUES(?,?,?,?,?)',
    [newId(), action, target, detail, DateTime.now().toUtc().toIso8601String()],
  );

  void seedDemo() {
    if (!demo || setting('demo_seeded') != null) return;
    // Each product is a regular atomic write. Stable SKUs make an interrupted seed resumable.
    for (final row in [
      ['Kopi susu', 'DEMO-KOPI', 'Minuman', 'gelas', 18000, false, 50000],
      ['Teh melati', 'DEMO-TEH', 'Minuman', 'gelas', 8000, false, 40000],
      ['Roti cokelat', 'DEMO-ROTI', 'Makanan', 'buah', 12000, false, 25000],
      ['Beras premium', 'DEMO-BERAS', 'Sembako', 'kg', 16000, false, 30000],
      ['Air mineral', 'DEMO-AIR', 'Minuman', 'botol', 5000, false, 24000],
      ['Cuci sepatu', 'DEMO-CUCI', 'Jasa', 'pasang', 35000, true, 0],
    ]) {
      if (db.select('SELECT id FROM products WHERE sku=?', [row[1]]).isEmpty) {
        saveProduct(
          name: row[0] as String,
          sku: row[1] as String,
          category: row[2] as String,
          unit: row[3] as String,
          price: row[4] as int,
          service: row[5] as bool,
          openingStock: row[6] as int,
        );
      }
    }
    setSetting('demo_seeded', '1');
  }

  void saveDraft(
    String requestId,
    List<CartLine> lines,
    String discount,
    String cash,
  ) {
    final payload = jsonEncode({
      'id': requestId,
      'lines': lines.map((l) => l.toMap()).toList(),
      'discount': discount,
      'cash': cash,
    });
    db.execute(
      'INSERT INTO draft VALUES(1,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload',
      [payload],
    );
  }

  Json? loadDraft() {
    final r = db.select('SELECT payload FROM draft WHERE id=1');
    return r.isEmpty
        ? null
        : Map<String, Object?>.from(
            jsonDecode(r.first['payload'] as String) as Map,
          );
  }

  void clearDraft() => db.execute('DELETE FROM draft');

  Sale checkout({
    required String requestId,
    required List<CartLine> lines,
    required int discount,
    required int cash,
    void Function(String)? fault,
  }) {
    if (lines.isEmpty || lines.length > 200 || requestId.isEmpty) {
      throw const PosError('Isi keranjang terlebih dahulu (maksimal 200 SKU).');
    }
    final sorted = [...lines]
      ..sort((a, b) => a.product.id.compareTo(b.product.id));
    if (sorted.map((l) => l.product.id).toSet().length != sorted.length) {
      throw const PosError('Gabungkan jumlah SKU yang sama.');
    }
    final total = netTotal(sorted.map((l) => l.total), discount);
    if (cash < total || cash > maxMoney) {
      throw const PosError('Uang tunai belum cukup atau melebihi batas.');
    }
    final payload = jsonEncode({
      'id': requestId,
      'lines': sorted.map((l) => l.toMap()).toList(),
      'discount': discount,
      'cash': cash,
      'demo': demo,
    });
    final hash = sha256.convert(utf8.encode(payload)).toString();
    atomic(() {
      final existing = db.select('SELECT payload_hash FROM sales WHERE id=?', [
        requestId,
      ]);
      if (existing.isNotEmpty) {
        if (existing.first['payload_hash'] != hash) {
          throw const PosError(
            'ID transaksi sudah dipakai dengan isi berbeda.',
          );
        }
        return;
      }
      for (final l in sorted) {
        final latest = product(l.product.id);
        if (latest.version != l.product.version) {
          throw PosError(
            '${latest.name} berubah. Hapus dari keranjang lalu tambahkan kembali.',
          );
        }
        if (!latest.service && latest.stock < l.quantity) {
          throw PosError(
            'Stok ${latest.name} tidak cukup. Sesuaikan jumlah atau tambah stok.',
          );
        }
      }
      final sequence = int.parse(setting('sequence')!) + 1;
      final prefix = demo ? 'DEMO' : 'TOKO';
      final receipt =
          '$prefix-${setting('installation')!.substring(0, 8).toUpperCase()}-${sequence.toString().padLeft(6, '0')}';
      final now = DateTime.now().toUtc().toIso8601String();
      db.execute(
        'INSERT INTO sales(id,receipt,payload_hash,occurred_at,gross,discount,total,demo) VALUES(?,?,?,?,?,?,?,?)',
        [
          requestId,
          receipt,
          hash,
          now,
          total + discount,
          discount,
          total,
          demo ? 1 : 0,
        ],
      );
      fault?.call('after_sale');
      for (final l in sorted) {
        final p = l.product;
        final lineId = newId();
        db.execute('INSERT INTO sale_items VALUES(?,?,?,?,?,?,?,?,?,?)', [
          lineId,
          requestId,
          p.id,
          p.name,
          p.sku,
          p.unit,
          p.price,
          l.quantity,
          l.total,
          p.service ? 1 : 0,
        ]);
        if (!p.service) {
          db.execute(
            'UPDATE products SET stock=stock-?,version=version+1 WHERE id=?',
            [l.quantity, p.id],
          );
          _movement(p.id, -l.quantity, 'Penjualan $receipt', lineId: lineId);
        }
      }
      fault?.call('after_stock');
      db.execute('INSERT INTO payments VALUES(?,?,?,?,?)', [
        requestId,
        'cash',
        total,
        cash,
        cash - total,
      ]);
      db.execute('INSERT INTO cash_entries VALUES(?,?)', [requestId, total]);
      db.execute('INSERT INTO outbox(sale_id,payload) VALUES(?,?)', [
        requestId,
        payload,
      ]);
      setSetting('sequence', sequence.toString());
      _audit('sale.completed', requestId, receipt);
      clearDraft();
      fault?.call('before_commit');
    });
    fault?.call('after_commit');
    return sale(requestId);
  }

  Sale sale(String id) {
    final row = db.select(
      'SELECT s.*,p.tendered,p.change_amount FROM sales s JOIN payments p ON p.sale_id=s.id WHERE s.id=?',
      [id],
    );
    if (row.isEmpty) throw const PosError('Nota tidak ditemukan.');
    return Sale(
      Map<String, Object?>.from(row.first),
      db
          .select('SELECT * FROM sale_items WHERE sale_id=? ORDER BY name', [
            id,
          ])
          .map((r) => Map<String, Object?>.from(r))
          .toList(),
    );
  }

  List<Json> history({int limit = 50, int offset = 0}) => db
      .select(
        'SELECT * FROM sales ORDER BY occurred_at DESC,id DESC LIMIT ? OFFSET ?',
        [limit, offset],
      )
      .map((r) => Map<String, Object?>.from(r))
      .toList();
  List<Json> movements(String id) => db
      .select(
        'SELECT * FROM stock_movements WHERE product_id=? ORDER BY occurred_at DESC LIMIT 100',
        [id],
      )
      .map((r) => Map<String, Object?>.from(r))
      .toList();
  Json summary({bool today = false}) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final start = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(hours: 7)).toIso8601String();
    return Map<String, Object?>.from(
      db
          .select(
            'SELECT count(*) AS count, coalesce(sum(gross),0) AS gross, coalesce(sum(discount),0) AS discount, coalesce(sum(total),0) AS total FROM sales${today ? ' WHERE occurred_at>=?' : ''}',
            today ? [start] : [],
          )
          .first,
    );
  }

  void close() => db.close();
}
