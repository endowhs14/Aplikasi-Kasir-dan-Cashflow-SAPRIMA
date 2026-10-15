import 'package:flutter/material.dart';

import '../data/store.dart';
import '../domain/models.dart';
import '../domain/money.dart';
import 'app.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.store,
    required this.requestId,
    required this.lines,
    required this.discount,
    required this.cash,
  });
  final Store store;
  final String requestId, discount, cash;
  final List<CartLine> lines;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late List<CartLine> lines;
  late final TextEditingController discount, cash;
  bool saving = false;
  @override
  void initState() {
    super.initState();
    lines = [...widget.lines];
    discount = TextEditingController(text: widget.discount);
    cash = TextEditingController(text: widget.cash);
  }

  @override
  void dispose() {
    discount.dispose();
    cash.dispose();
    super.dispose();
  }

  int get gross => lines.fold(0, (s, l) => s + l.total);
  int? get total {
    try {
      return netTotal(lines.map((l) => l.total), parseRupiah(discount.text));
    } catch (_) {
      return null;
    }
  }

  int? get change {
    try {
      final t = total;
      return t == null ? null : parseRupiah(cash.text) - t;
    } catch (_) {
      return null;
    }
  }

  void persist() {
    widget.store.saveDraft(widget.requestId, lines, discount.text, cash.text);
  }

  void changed(String _) {
    try {
      persist();
      setState(() {});
    } catch (e) {
      showFailure(context, e);
    }
  }

  void changeLine(int index, int q) {
    try {
      if (q > 0) {
        final p = lines[index].product;
        lineTotal(p.price, q);
        if (!p.service && q > widget.store.product(p.id).stock) {
          throw const PosError('Jumlah melebihi stok tersedia.');
        }
      }
      final next = [...lines];
      if (q <= 0) {
        next.removeAt(index);
      } else {
        next[index] = CartLine(next[index].product, q);
      }
      widget.store.saveDraft(widget.requestId, next, discount.text, cash.text);
      setState(() => lines = next);
    } catch (e) {
      showFailure(context, e);
    }
  }

  Future<void> editQuantity(int index) async {
    final l = lines[index];
    final value = await showDialog<int>(
      context: context,
      builder: (_) => QuantityDialog(line: l),
    );
    if (value != null && mounted) changeLine(index, value);
  }

  Future<void> submit() async {
    if (saving) return;
    try {
      final d = parseRupiah(discount.text), c = parseRupiah(cash.text);
      final t = netTotal(lines.map((l) => l.total), d);
      if (lines.isEmpty) throw const PosError('Keranjang masih kosong.');
      if (c < t) throw const PosError('Uang diterima belum cukup.');
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Selesaikan pembayaran?'),
          content: Text(
            '${widget.store.demo ? 'NOTA CONTOH\n\n' : ''}Total ${rupiah(t)}\nTunai ${rupiah(c)}\nKembalian ${rupiah(c - t)}\n\nPastikan uang sudah diterima. Nota tersimpan tidak dapat dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Periksa lagi'),
            ),
            FilledButton(
              key: const Key('confirmPayment'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya, simpan nota'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      setState(() => saving = true);
      final sale = widget.store.checkout(
        requestId: widget.requestId,
        lines: lines,
        discount: d,
        cash: c,
      );
      if (mounted) Navigator.pop(context, sale);
    } catch (e) {
      if (mounted) {
        setState(() => saving = false);
        showFailure(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: Scaffold(
      appBar: AppBar(title: const Text('Keranjang & pembayaran')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.store.demo ? 'Transaksi contoh' : 'Transaksi toko',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Periksa jumlah, lalu catat pembayaran tunai.'),
            const SizedBox(height: 20),
            if (lines.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Keranjang kosong. Kembali untuk memilih produk.'),
              ),
            for (var i = 0; i < lines.length; i++) lineCard(i),
            const SizedBox(height: 16),
            metric('Subtotal', rupiah(gross)),
            const SizedBox(height: 12),
            amountField(
              fieldKey: const Key('discount'),
              controller: discount,
              label: 'Diskon nota (Rp)',
              helper: 'Nominal tetap, maksimal subtotal.',
              onChanged: changed,
            ),
            const SizedBox(height: 16),
            metric(
              'Total bayar',
              total == null ? 'Periksa diskon' : rupiah(total!),
            ),
            const Divider(height: 32),
            const Text(
              'Pembayaran tunai',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            amountField(
              fieldKey: const Key('cash'),
              controller: cash,
              label: 'Uang diterima (Rp)',
              helper: 'Contoh: 50000',
              onChanged: changed,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Uang pas'),
                  onPressed: total == null
                      ? null
                      : () {
                          cash.text = total.toString();
                          changed('');
                        },
                ),
                for (final amount in [20000, 50000, 100000])
                  ActionChip(
                    label: Text(rupiah(amount)),
                    onPressed: () {
                      cash.text = amount.toString();
                      changed('');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE1EFE5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: metric(
                change != null && change! < 0
                    ? 'Uang masih kurang'
                    : 'Kembalian',
                change == null ? '—' : rupiah(change!.abs()),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('pay'),
              onPressed: saving || lines.isEmpty ? null : submit,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(saving ? 'Menyimpan…' : 'Simpan pembayaran tunai'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nota dan stok disimpan bersama di perangkat ini. Belum tersinkron ke cloud.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
  Widget lineCard(int i) {
    final l = lines[i];
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus ${l.product.name}',
                  onPressed: () => changeLine(i, 0),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text('${rupiah(l.product.price)} / ${l.product.unit}'),
            Row(
              children: [
                IconButton(
                  tooltip: 'Kurangi ${l.product.name}',
                  onPressed: () => changeLine(i, l.quantity - 1000),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                TextButton(
                  onPressed: () => editQuantity(i),
                  child: Text('${quantityText(l.quantity)} ${l.product.unit}'),
                ),
                IconButton(
                  tooltip: 'Tambah ${l.product.name}',
                  onPressed: () => changeLine(i, l.quantity + 1000),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                Expanded(
                  child: Text(
                    rupiah(l.total),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityDialog extends StatefulWidget {
  const QuantityDialog({super.key, required this.line});
  final CartLine line;
  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  late final TextEditingController controller;
  String? error;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: quantityText(widget.line.quantity),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Jumlah ${widget.line.product.name}'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        amountField(
          fieldKey: const Key('quantity'),
          controller: controller,
          label: 'Jumlah (${widget.line.product.unit})',
          decimal: true,
          helper: 'Contoh: 0,500 atau 2',
        ),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      FilledButton(
        onPressed: () {
          try {
            Navigator.pop(context, parseQuantity(controller.text));
          } catch (e) {
            setState(() => error = e.toString());
          }
        },
        child: const Text('Ubah jumlah'),
      ),
    ],
  );
}
