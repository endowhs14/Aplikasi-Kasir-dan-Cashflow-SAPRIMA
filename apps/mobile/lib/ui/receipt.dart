import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/models.dart';
import '../domain/money.dart';
import 'app.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.sale, required this.demo});
  final Sale sale;
  final bool demo;
  String get text => [
    'SAPRIMA Kasir${demo ? ' — NOTA CONTOH' : ''}',
    sale.number,
    localDate(sale.occurredAt),
    'Cabang lokal • Pemilik lokal',
    for (final l in sale.items)
      '${l['name']} (${l['sku']})\n${quantityText(l['quantity'] as int)} ${l['unit']} × ${rupiah(l['price'] as int)} = ${rupiah(l['total'] as int)}',
    'Subtotal: ${rupiah(sale.data['gross'] as int)}',
    'Diskon: ${rupiah(sale.data['discount'] as int)}',
    'Total: ${rupiah(sale.total)}',
    'Tunai: ${rupiah(sale.data['tendered'] as int)}',
    'Kembalian: ${rupiah(sale.data['change_amount'] as int)}',
    'LUNAS • Tersimpan lokal. Belum sinkron cloud.',
    'ID: ${sale.id}',
  ].join('\n');
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail nota')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.check_circle, size: 52, color: teal),
          const SizedBox(height: 12),
          const Text(
            'Pembayaran tersimpan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            demo ? 'NOTA CONTOH • Bukan penjualan toko' : 'LUNAS • Tunai',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SAPRIMA Kasir',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  sale.number,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(localDate(sale.occurredAt)),
                const Text('Cabang lokal • Pemilik lokal'),
                const Divider(height: 32),
                for (final l in sale.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          l['sku'] as String,
                          style: const TextStyle(fontSize: 12),
                        ),
                        metric(
                          '${quantityText(l['quantity'] as int)} ${l['unit']} × ${rupiah(l['price'] as int)}',
                          rupiah(l['total'] as int),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                metric('Subtotal', rupiah(sale.data['gross'] as int)),
                metric('Diskon', rupiah(sale.data['discount'] as int)),
                metric('Total', rupiah(sale.total)),
                const Divider(),
                metric('Tunai diterima', rupiah(sale.data['tendered'] as int)),
                metric('Kembalian', rupiah(sale.data['change_amount'] as int)),
                const Divider(height: 32),
                const Text(
                  'Tersimpan di perangkat ini.\nBelum sinkron ke cloud.',
                  style: TextStyle(color: teal),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  'ID: ${sale.id}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Nota disalin. Tempel ke aplikasi pesan untuk dibagikan.',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Salin nota'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
