import 'package:flutter/material.dart';

import '../data/store.dart';
import '../domain/models.dart';
import '../domain/money.dart';
import 'app.dart';

class ProductEditor extends StatefulWidget {
  const ProductEditor({super.key, required this.store, this.product});
  final Store store;
  final Product? product;
  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  late final TextEditingController name, sku, category, unit, price, stock;
  late bool service;
  Product? current;
  @override
  void initState() {
    super.initState();
    current = widget.product;
    final p = current;
    name = TextEditingController(text: p?.name ?? '');
    sku = TextEditingController(text: p?.sku ?? '');
    category = TextEditingController(text: p?.category ?? 'Umum');
    unit = TextEditingController(text: p?.unit ?? 'buah');
    price = TextEditingController(text: p?.price.toString() ?? '');
    stock = TextEditingController(text: quantityText(p?.stock ?? 0));
    service = p?.service ?? false;
  }

  @override
  void dispose() {
    for (final c in [name, sku, category, unit, price, stock]) {
      c.dispose();
    }
    super.dispose();
  }

  void save() {
    try {
      widget.store.saveProduct(
        id: current?.id,
        expectedVersion: current?.version,
        name: name.text,
        sku: sku.text,
        category: category.text,
        unit: unit.text,
        price: parseRupiah(price.text, max: maxPrice),
        service: service,
        openingStock: service || current != null
            ? 0
            : parseQuantity(stock.text, allowZero: true),
      );
      Navigator.pop(context);
    } catch (e) {
      showFailure(context, e);
    }
  }

  Future<void> adjust() async {
    final updated = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => StockEditor(store: widget.store, product: current!),
      ),
    );
    if (updated != null && mounted) setState(() => current = updated);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(current == null ? 'Tambah produk' : 'Edit produk'),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Informasi produk',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.store.demo
                ? 'Produk ini hanya untuk ruang contoh.'
                : 'Produk ini disimpan di katalog Toko saya.',
          ),
          const SizedBox(height: 24),
          TextField(
            key: const Key('productName'),
            controller: name,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'Nama produk / jasa'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('productSku'),
            controller: sku,
            maxLength: 40,
            decoration: const InputDecoration(
              labelText: 'SKU / kode unik',
              helperText: 'Contoh: KOPI-001',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: category,
            maxLength: 60,
            decoration: const InputDecoration(labelText: 'Kategori'),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Produk berupa jasa'),
            subtitle: Text(
              current == null
                  ? 'Jasa tidak mengurangi stok.'
                  : 'Jenis dikunci setelah produk dibuat.',
            ),
            value: service,
            onChanged: current != null
                ? null
                : (v) => setState(() => service = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: unit,
            maxLength: 20,
            decoration: const InputDecoration(
              labelText: 'Satuan',
              helperText: 'Misalnya buah, kg, gelas, atau layanan',
            ),
          ),
          const SizedBox(height: 12),
          amountField(
            fieldKey: const Key('productPrice'),
            controller: price,
            label: 'Harga jual (Rp)',
            helper: 'Rupiah bulat tanpa titik. Contoh: 18000',
          ),
          const SizedBox(height: 20),
          if (!service && current == null)
            amountField(
              fieldKey: const Key('productStock'),
              controller: stock,
              label: 'Stok awal',
              decimal: true,
              helper: 'Maksimal 3 desimal. Contoh: 10,500',
            ),
          if (!service && current != null)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stok saat ini: ${quantityText(current!.stock)} ${current!.unit}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: adjust,
                      icon: const Icon(Icons.swap_vert),
                      label: const Text('Sesuaikan stok & lihat histori'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),
          FilledButton(
            key: const Key('saveProduct'),
            onPressed: save,
            child: const Text('Simpan produk'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

class StockEditor extends StatefulWidget {
  const StockEditor({super.key, required this.store, required this.product});
  final Store store;
  final Product product;
  @override
  State<StockEditor> createState() => _StockEditorState();
}

class _StockEditorState extends State<StockEditor> {
  final quantity = TextEditingController(), reason = TextEditingController();
  bool adding = true;
  @override
  void dispose() {
    quantity.dispose();
    reason.dispose();
    super.dispose();
  }

  void save() {
    try {
      final q = parseQuantity(quantity.text) * (adding ? 1 : -1);
      widget.store.adjustStock(
        widget.product.id,
        q,
        reason.text,
        widget.product.version,
      );
      Navigator.pop(context, widget.store.product(widget.product.id));
    } catch (e) {
      showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pergerakan stok')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Stok: ${quantityText(widget.product.stock)} ${widget.product.unit}',
          ),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Tambah')),
              ButtonSegment(value: false, label: Text('Kurangi')),
            ],
            selected: {adding},
            onSelectionChanged: (s) => setState(() => adding = s.first),
          ),
          const SizedBox(height: 20),
          amountField(
            controller: quantity,
            label: 'Jumlah perubahan',
            decimal: true,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: reason,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Alasan wajib',
              hintText: 'Misalnya belanja stok atau barang rusak',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: save,
            child: const Text('Simpan penyesuaian'),
          ),
          const SizedBox(height: 32),
          const Text(
            'Histori terakhir (maks. 100)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ...widget.store
              .movements(widget.product.id)
              .map(
                (m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m['reason'] as String),
                  subtitle: Text(localDate(m['occurred_at'] as String)),
                  trailing: Text(
                    '${(m['delta'] as int) > 0 ? '+' : ''}${quantityText(m['delta'] as int)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
        ],
      ),
    ),
  );
}
