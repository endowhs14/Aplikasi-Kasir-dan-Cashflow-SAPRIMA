import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:saprima_kasir/data/store.dart';
import 'package:saprima_kasir/domain/models.dart';
import 'package:saprima_kasir/domain/money.dart';

const testKey =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
void main() {
  late Directory dir;
  late Store store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('saprima-test-');
    store = Store.open('${dir.path}/pos.sqlite', testKey, demo: false);
  });
  tearDown(() {
    store.close();
    dir.deleteSync(recursive: true);
  });
  Product goods({String sku = 'KOPI', int price = 20000, int stock = 10000}) =>
      store.saveProduct(
        name: 'Kopi',
        sku: sku,
        category: 'Minuman',
        unit: 'gelas',
        price: price,
        service: false,
        openingStock: stock,
      );
  int count(String table) =>
      store.db.select('SELECT count(*) AS n FROM $table').first['n'] as int;
  void invariant() {
    for (final p in store.products().where((p) => !p.service)) {
      expect(
        store.db.select(
          'SELECT coalesce(sum(delta),0) AS q FROM stock_movements WHERE product_id=?',
          [p.id],
        ).first['q'],
        p.stock,
      );
    }
    expect(store.db.select('PRAGMA integrity_check').first.values.first, 'ok');
    expect(store.db.select('PRAGMA foreign_key_check'), isEmpty);
  }

  test('nota, pembayaran, kas, stok, outbox atomik; replay 100 kali', () {
    final p = goods();
    final lines = [CartLine(p, 2000)];
    store.saveDraft('sale-1', lines, '2000', '50000');
    for (var i = 0; i < 100; i++) {
      final s = store.checkout(
        requestId: 'sale-1',
        lines: lines,
        discount: 2000,
        cash: 50000,
      );
      expect(s.total, 38000);
      expect(s.data['change_amount'], 12000);
    }
    for (final table in [
      'sales',
      'sale_items',
      'payments',
      'cash_entries',
      'outbox',
    ]) {
      expect(count(table), 1);
    }
    expect(count('stock_movements'), 2);
    expect(store.product(p.id).stock, 8000);
    expect(
      store.db.select('SELECT amount FROM cash_entries').first['amount'],
      38000,
    );
    expect(store.setting('sequence'), '1');
    expect(store.loadDraft(), null);
    invariant();
  });
  test('ID sama payload berubah ditolak tanpa efek uang/stok', () {
    final p = goods();
    store.checkout(
      requestId: 'same',
      lines: [CartLine(p, 1000)],
      discount: 0,
      cash: 20000,
    );
    expect(
      () => store.checkout(
        requestId: 'same',
        lines: [CartLine(p, 2000)],
        discount: 0,
        cash: 40000,
      ),
      throwsA(isA<PosError>()),
    );
    expect(count('sales'), 1);
    expect(store.product(p.id).stock, 9000);
    invariant();
  });
  test('jasa tidak memiliki ledger stok; diskon campuran benar', () {
    final p = goods();
    final s = store.saveProduct(
      name: 'Servis',
      sku: 'JASA',
      category: 'Jasa',
      unit: 'layanan',
      price: 35000,
      service: true,
    );
    final sale = store.checkout(
      requestId: 'mixed',
      lines: [CartLine(p, 1250), CartLine(s, 1000)],
      discount: 5000,
      cash: 100000,
    );
    expect(sale.total, 55000);
    expect(sale.data['change_amount'], 45000);
    expect(store.movements(s.id), isEmpty);
    expect(store.product(p.id).stock, 8750);
    invariant();
  });
  for (final stage in ['after_sale', 'after_stock', 'before_commit']) {
    test('fault $stage rollback seluruh efek dan mempertahankan draft', () {
      final p = goods();
      final lines = [CartLine(p, 1000)];
      store.saveDraft('fault', lines, '0', '20000');
      expect(
        () => store.checkout(
          requestId: 'fault',
          lines: lines,
          discount: 0,
          cash: 20000,
          fault: (s) {
            if (s == stage) throw StateError('simulated failure');
          },
        ),
        throwsStateError,
      );
      for (final table in [
        'sales',
        'sale_items',
        'payments',
        'cash_entries',
        'outbox',
      ]) {
        expect(count(table), 0);
      }
      expect(store.product(p.id).stock, 10000);
      expect(store.setting('sequence'), '0');
      expect(store.loadDraft(), isNotNull);
      invariant();
    });
  }
  test('restart mempertahankan nota, draft, saldo dan snapshot harga', () {
    final p = goods();
    final sale = store.checkout(
      requestId: 'restart',
      lines: [CartLine(p, 1000)],
      discount: 0,
      cash: 20000,
    );
    final updated = store.product(p.id);
    store.saveProduct(
      id: p.id,
      expectedVersion: updated.version,
      name: 'Nama baru',
      sku: p.sku,
      category: p.category,
      unit: p.unit,
      price: 99999,
      service: false,
    );
    store.saveDraft('next', [CartLine(store.product(p.id), 500)], '0', '');
    store.close();
    store = Store.open('${dir.path}/pos.sqlite', testKey, demo: false);
    expect(store.sale(sale.id).items.first['name'], 'Kopi');
    expect(store.sale(sale.id).items.first['price'], 20000);
    expect(store.product(p.id).stock, 9000);
    expect(store.loadDraft()!['id'], 'next');
    invariant();
  });
  test('database terenkripsi: header bukan SQLite, kunci salah ditolak', () {
    goods();
    store.db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
    final bytes = File('${dir.path}/pos.sqlite').readAsBytesSync();
    expect(
      utf8.decode(bytes.take(16).toList(), allowMalformed: true),
      isNot('SQLite format 3\u0000'),
    );
    expect(
      () => Store.open('${dir.path}/pos.sqlite', 'f' * 64, demo: false),
      throwsA(anything),
    );
    invariant();
  });
  test('validasi cash, stok, SKU dan versi usang', () {
    final p = goods(stock: 1000);
    expect(() => goods(sku: 'kopi'), throwsA(isA<PosError>()));
    expect(
      () => store.checkout(
        requestId: 'low',
        lines: [CartLine(p, 1000)],
        discount: 0,
        cash: 19999,
      ),
      throwsA(isA<PosError>()),
    );
    expect(
      () => store.checkout(
        requestId: 'stock',
        lines: [CartLine(p, 1001)],
        discount: 0,
        cash: 30000,
      ),
      throwsA(isA<PosError>()),
    );
    store.adjustStock(p.id, 1000, 'Belanja stok', p.version);
    expect(
      () => store.adjustStock(p.id, 1000, 'Usang', p.version),
      throwsA(isA<PosError>()),
    );
    expect(
      () => store.checkout(
        requestId: 'stale',
        lines: [CartLine(p, 1000)],
        discount: 0,
        cash: 20000,
      ),
      throwsA(isA<PosError>()),
    );
    expect(count('sales'), 0);
    expect(store.product(p.id).stock, 2000);
    invariant();
  });
  test('SKU duplikat dalam keranjang ditolak', () {
    final p = goods();
    expect(
      () => store.checkout(
        requestId: 'dup',
        lines: [CartLine(p, 1000), CartLine(p, 1000)],
        discount: 0,
        cash: 40000,
      ),
      throwsA(isA<PosError>()),
    );
    expect(count('sales'), 0);
    invariant();
  });
  test('dua koneksi menjual stok terakhir: hanya satu komit', () {
    final p = goods(stock: 1000);
    final second = Store.open('${dir.path}/pos.sqlite', testKey, demo: false);
    try {
      final stale = second.product(p.id);
      store.checkout(
        requestId: 'first',
        lines: [CartLine(p, 1000)],
        discount: 0,
        cash: 20000,
      );
      expect(
        () => second.checkout(
          requestId: 'second',
          lines: [CartLine(stale, 1000)],
          discount: 0,
          cash: 20000,
        ),
        throwsA(isA<PosError>()),
      );
      expect(count('sales'), 1);
      expect(store.product(p.id).stock, 0);
      invariant();
    } finally {
      second.close();
    }
  });
  test('mode contoh tidak mengisi toko; seed tidak menggandakan data', () {
    final demo = Store.open('${dir.path}/demo.sqlite', testKey, demo: true);
    try {
      demo.seedDemo();
      demo.seedDemo();
      expect(demo.products().length, 6);
      expect(store.products(), isEmpty);
      expect(store.summary()['total'], 0);
    } finally {
      demo.close();
    }
  });
}
