import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'data/store.dart';
import 'ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final directory = await getApplicationDocumentsDirectory();
    const secure = FlutterSecureStorage();
    var key = await secure.read(key: 'saprima.database.key.v1');
    if (key == null) {
      if (File('${directory.path}/shop.sqlite').existsSync() ||
          File('${directory.path}/demo.sqlite').existsSync()) {
        throw StateError('Existing database without key');
      }
      final random = Random.secure();
      key = List.generate(
        32,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      await secure.write(key: 'saprima.database.key.v1', value: key);
    }
    final shop = Store.open('${directory.path}/shop.sqlite', key, demo: false);
    final demo = Store.open('${directory.path}/demo.sqlite', key, demo: true)
      ..seedDemo();
    runApp(SaprimaApp(shop: shop, demo: demo));
  } catch (_) {
    // Never log exceptions that could contain SQLCipher key statements.
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 56),
                  const SizedBox(height: 20),
                  const Text(
                    'Penyimpanan belum bisa dibuka',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tutup lalu buka kembali aplikasi. Jika tetap gagal, pertahankan data aplikasi dan hubungi pengembang. Jangan hapus data atau instal ulang jika ada nota penting. Tidak ada database yang dihapus otomatis.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
