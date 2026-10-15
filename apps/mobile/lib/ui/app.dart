import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../data/store.dart';
import '../domain/models.dart';
import '../domain/money.dart';
import 'product_editor.dart';
import 'checkout.dart';
import 'receipt.dart';

const ink = Color(0xFF153C38);
const teal = Color(0xFF167367);
const paper = Color(0xFFF5F7F3);

void showFailure(BuildContext context, Object error) {
  final text = error is PosError
      ? error.message
      : 'Data belum dapat disimpan. Coba lagi; jangan hapus data aplikasi.';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}

class SaprimaApp extends StatelessWidget {
  const SaprimaApp({super.key, required this.shop, required this.demo});
  final Store shop, demo;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SAPRIMA Kasir',
    debugShowCheckedModeBanner: false,
    locale: const Locale('id'),
    supportedLocales: const [Locale('id')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        primary: teal,
        surface: paper,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    ),
    home: Home(shop: shop, demo: demo),
  );
}

class Home extends StatefulWidget {
  const Home({super.key, required this.shop, required this.demo});
  final Store shop, demo;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0, historyLimit = 50;
  bool demoMode = true;
  String query = '';
  String? category;
  final search = TextEditingController();
  List<CartLine> cart = [];
  String requestId = Store.newId(), discount = '0', cash = '';
  Store get store => demoMode ? widget.demo : widget.shop;

  @override
  void initState() {
    super.initState();
    demoMode = widget.shop.setting('selected_mode') != 'shop';
    restoreDraft();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void restoreDraft() {
    final draft = store.loadDraft();
    requestId = draft?['id'] as String? ?? Store.newId();
    discount = draft?['discount'] as String? ?? '0';
    cash = draft?['cash'] as String? ?? '';
    cart = draft == null
        ? []
        : (draft['lines'] as List)
              .map((l) => CartLine.fromMap(Map<String, Object?>.from(l as Map)))
              .toList();
  }

  void persist() => store.saveDraft(requestId, cart, discount, cash);

  Future<void> switchMode() async {
    final mode = await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pilih ruang kerja'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, true),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Contoh / latihan\nKatalog contoh, terpisah dari toko.',
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, false),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Toko saya\nMulai dengan katalog kosong milik Anda.'),
            ),
          ),
        ],
      ),
    );
    if (mode == null || mode == demoMode || !mounted) return;
    try {
      persist();
      widget.shop.setSetting('selected_mode', mode ? 'demo' : 'shop');
      setState(() {
        demoMode = mode;
        query = '';
        category = null;
        search.clear();
        historyLimit = 50;
        restoreDraft();
      });
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  void add(Product p) {
    try {
      final index = cart.indexWhere((l) => l.product.id == p.id);
      final previous = index < 0 ? 0 : cart[index].quantity;
      final available = p.stock - previous;
      if (!p.service && available <= 0) {
        throw const PosError(
          'Stok tidak cukup. Sesuaikan jumlah atau tambah stok.',
        );
      }
      final increment = p.service || available >= 1000 ? 1000 : available;
      final quantity = previous + increment;
      if (index >= 0 && cart[index].product.version != p.version) {
        throw const PosError(
          'Produk berubah. Hapus item lama di keranjang lalu tambahkan kembali.',
        );
      }
      lineTotal(p.price, quantity);
      final next = [...cart];
      if (index < 0) {
        next.add(CartLine(p, quantity));
      } else {
        next[index] = CartLine(p, quantity);
      }
      store.saveDraft(requestId, next, discount, cash);
      setState(() => cart = next);
    } catch (e) {
      showFailure(context, e);
    }
  }

  Future<void> edit([Product? p]) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ProductEditor(store: store, product: p),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> openCart() async {
    final result = await Navigator.push<Sale>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          store: store,
          requestId: requestId,
          lines: cart,
          discount: discount,
          cash: cash,
        ),
      ),
    );
    if (!mounted) return;
    setState(restoreDraft);
    if (result != null) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ReceiptScreen(sale: result, demo: demoMode),
        ),
      );
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SAPRIMA',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 21,
            ),
          ),
          Text(
            ['Kasir', 'Katalog & stok', 'Riwayat transaksi', 'Ringkasan'][tab],
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: switchMode,
          icon: Icon(
            demoMode ? Icons.science_outlined : Icons.storefront_outlined,
          ),
          label: Text(demoMode ? 'Contoh' : 'Toko saya'),
        ),
        IconButton(
          tooltip: 'Tentang aplikasi',
          onPressed: () => showAboutDialog(
            context: context,
            applicationName: 'SAPRIMA Kasir',
            applicationVersion: '0.1.0 • APK awal',
            children: const [
              Text(
                'Kasir lokal satu perangkat. Data terenkripsi dan disimpan di perangkat ini. Belum ada login, sinkronisasi, backup cloud, billing, atau refund. Jangan jadikan aplikasi ini satu-satunya catatan usaha selama uji coba.',
              ),
            ],
          ),
          icon: const Icon(Icons.info_outline),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: demoMode ? const Color(0xFFFFEDCC) : const Color(0xFFE0EEE8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              demoMode
                  ? 'MODE CONTOH • Semua nota di sini untuk latihan'
                  : 'LOKAL • Data toko tersimpan di perangkat ini',
              style: TextStyle(
                color: demoMode ? const Color(0xFF714A05) : ink,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: switch (tab) {
              0 => catalog(false),
              1 => catalog(true),
              2 => history(),
              _ => summary(),
            },
          ),
          if (tab == 0 && cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('openCart'),
                  onPressed: openCart,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(
                    'Keranjang (${cart.length})  •  ${rupiah(cart.fold(0, (v, l) => v + l.total))}',
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.point_of_sale_outlined),
          selectedIcon: Icon(Icons.point_of_sale),
          label: 'Kasir',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Katalog',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Riwayat',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Ringkasan',
        ),
      ],
    ),
  );

  Widget catalog(bool editing) {
    final all = store.products();
    final categories = all.map((p) => p.category).toSet().toList()..sort();
    final products = store.products(query: query, category: category);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  editing ? 'Katalog Anda' : 'Mau jual apa hari ini?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
              ),
              if (editing)
                IconButton.filled(
                  tooltip: 'Tambah produk',
                  onPressed: () => edit(),
                  icon: const Icon(Icons.add),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: search,
            decoration: InputDecoration(
              hintText: 'Cari nama atau SKU',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        search.clear();
                        setState(() => query = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
            onChanged: (s) => setState(() => query = s),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Semua'),
                selected: category == null,
                onSelected: (_) => setState(() => category = null),
              ),
              ...categories.map(
                (c) => ChoiceChip(
                  label: Text(c),
                  selected: category == c,
                  onSelected: (_) => setState(() => category = c),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: teal,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          all.isEmpty
                              ? 'Katalog masih kosong'
                              : 'Produk tidak ditemukan',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          all.isEmpty
                              ? 'Tambahkan barang atau jasa untuk memulai.'
                              : 'Coba nama, SKU, atau kategori lain.',
                          textAlign: TextAlign.center,
                        ),
                        if (all.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: FilledButton(
                              onPressed: () => edit(),
                              child: const Text('Tambah produk pertama'),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    final selected = cart
                        .where((l) => l.product.id == p.id)
                        .firstOrNull;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          key: Key('product-${p.sku}'),
                          borderRadius: BorderRadius.circular(18),
                          onTap: editing ? () => edit(p) : () => add(p),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF2EC),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    p.service
                                        ? Icons.handyman_outlined
                                        : Icons.inventory_2_outlined,
                                    color: teal,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${p.sku} • ${p.service ? 'Jasa' : 'Stok ${quantityText(p.stock)} ${p.unit}'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: !p.service && p.stock == 0
                                              ? Colors.red.shade800
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${rupiah(p.price)} / ${p.unit}',
                                        style: const TextStyle(
                                          color: teal,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (editing)
                                  const Icon(Icons.edit_outlined, size: 20)
                                else if (selected != null)
                                  Chip(
                                    label: Text(
                                      quantityText(selected.quantity),
                                    ),
                                    backgroundColor: const Color(0xFFD4ECE2),
                                  )
                                else
                                  const Icon(
                                    Icons.add_circle_outline,
                                    color: teal,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget history() {
    final rows = store.history(limit: historyLimit);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Nota tersimpan',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Buka nota untuk melihat rincian pembayaran.'),
        const SizedBox(height: 20),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text('Belum ada transaksi. Mulai dari menu Kasir.'),
            ),
          ),
        ...rows.map(
          (r) => Card(
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: const Icon(Icons.receipt_long, color: teal),
              title: Text(
                r['receipt'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                '${localDate(r['occurred_at'] as String)}\n${rupiah(r['total'] as int)} • Tunai',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ReceiptScreen(
                    sale: store.sale(r['id'] as String),
                    demo: demoMode,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (rows.length == historyLimit)
          TextButton(
            onPressed: () => setState(() => historyLimit += 50),
            child: const Text('Muat nota berikutnya'),
          ),
      ],
    );
  }

  Widget summary() {
    final day = store.summary(today: true), all = store.summary();
    final low = store
        .products()
        .where((p) => !p.service && p.stock <= 5000)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Usaha dalam angka',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Hari ini • zona waktu Jakarta'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ink,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PENJUALAN BERSIH HARI INI',
                style: TextStyle(
                  color: Color(0xFFBFDED0),
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                rupiah(day['total'] as int),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${day['count']} transaksi tunai',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        metric('Penjualan bruto hari ini', rupiah(day['gross'] as int)),
        metric('Diskon hari ini', rupiah(day['discount'] as int)),
        metric('Total penjualan tersimpan', rupiah(all['total'] as int)),
        metric('Seluruh nota', '${all['count']} transaksi'),
        const SizedBox(height: 12),
        const Text(
          'Angka ini adalah penjualan tunai, bukan laba atau saldo kas lengkap. Pengeluaran dan HPP belum dicatat.',
          style: TextStyle(color: Color(0xFF52635C)),
        ),
        const SizedBox(height: 28),
        const Text(
          'Perlu cek stok',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Barang dengan stok 5 satuan atau kurang.'),
        if (low.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Tidak ada barang di bawah batas ini.'),
          ),
        ...low.map(
          (p) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(p.name),
            subtitle: Text('${quantityText(p.stock)} ${p.unit}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => edit(p),
          ),
        ),
      ],
    );
  }
}

Widget metric(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: Text(label)),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  ),
);

Widget amountField({
  required TextEditingController controller,
  required String label,
  String? helper,
  bool decimal = false,
  ValueChanged<String>? onChanged,
  Key? fieldKey,
}) => TextFormField(
  key: fieldKey,
  controller: controller,
  keyboardType: TextInputType.numberWithOptions(decimal: decimal),
  inputFormatters: [
    FilteringTextInputFormatter.allow(
      decimal ? RegExp(r'[0-9,.]') : RegExp(r'[0-9]'),
    ),
  ],
  decoration: InputDecoration(labelText: label, helperText: helper),
  onChanged: onChanged,
);
