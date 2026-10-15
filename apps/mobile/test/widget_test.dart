import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saprima_kasir/data/store.dart';
import 'package:saprima_kasir/ui/app.dart';

import 'store_test.dart' show testKey;

void main() {
  late Directory dir;
  late Store shop, demo;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('saprima-ui-');
    shop = Store.open('${dir.path}/shop', testKey, demo: false);
    demo = Store.open('${dir.path}/demo', testKey, demo: true)..seedDemo();
  });
  tearDown(() {
    shop.close();
    demo.close();
    dir.deleteSync(recursive: true);
  });
  Future<void> launch(WidgetTester t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(SaprimaApp(shop: shop, demo: demo));
    await t.pumpAndSettle();
  }

  testWidgets('kasir → diskon → tunai → nota → histori, toko tetap kosong', (
    t,
  ) async {
    await launch(t);
    await t.ensureVisible(find.byKey(const Key('product-DEMO-KOPI')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('product-DEMO-KOPI')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('openCart')));
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const Key('discount')));
    await t.enterText(find.byKey(const Key('discount')), '2000');
    await t.ensureVisible(find.byKey(const Key('cash')));
    await t.enterText(find.byKey(const Key('cash')), '50000');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const Key('pay')));
    await t.tap(find.byKey(const Key('pay')));
    await t.pumpAndSettle();
    expect(find.textContaining('Kembalian Rp34.000'), findsOneWidget);
    await t.tap(find.byKey(const Key('confirmPayment')));
    await t.pumpAndSettle();
    expect(find.text('Pembayaran tersimpan'), findsOneWidget);
    expect(demo.summary()['total'], 16000);
    expect(shop.summary()['total'], 0);
    expect(t.takeException(), isNull);
    await t.pageBack();
    await t.pumpAndSettle();
    await t.tap(find.text('Riwayat'));
    await t.pumpAndSettle();
    expect(find.textContaining('Rp16.000 • Tunai'), findsOneWidget);
  });
  testWidgets('toko kosong → tambah produk → pencarian SKU', (t) async {
    await launch(t);
    await t.tap(find.text('Contoh'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Mulai dengan katalog kosong'));
    await t.pumpAndSettle();
    expect(find.text('Katalog masih kosong'), findsOneWidget);
    await t.tap(find.text('Tambah produk pertama'));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('productName')), 'Sabun');
    await t.enterText(find.byKey(const Key('productSku')), 'SBN-01');
    await t.ensureVisible(find.byKey(const Key('productPrice')));
    await t.enterText(find.byKey(const Key('productPrice')), '7000');
    await t.ensureVisible(find.byKey(const Key('productStock')));
    await t.enterText(find.byKey(const Key('productStock')), '10');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const Key('saveProduct')));
    await t.tap(find.byKey(const Key('saveProduct')));
    await t.pumpAndSettle();
    expect(find.text('Sabun'), findsOneWidget);
    expect(shop.products().single.stock, 10000);
    await t.enterText(find.byType(TextField).first, 'SBN-01');
    await t.pumpAndSettle();
    expect(find.text('Sabun'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('layar ringkasan terbaca pada skala teks 1,5', (t) async {
    await launch(t);
    t.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await t.tap(find.text('Ringkasan'));
    await t.pumpAndSettle();
    expect(find.text('Usaha dalam angka'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
