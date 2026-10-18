# SAPRIMA Kasir 0.1.0 — APK awal Android

APK Flutter untuk uji coba kasir lokal. Belum seluruh MVP SaaS PRD dan belum untuk operasional produksi.

[Unduh APK](https://github.com/endowhs14/Aplikasi-Kasir-dan-Cashflow-SAPRIMA/releases/download/v0.1.0-alpha.1/saprima-kasir-0.1.0-debug.apk) · [Checksum](https://github.com/endowhs14/Aplikasi-Kasir-dan-Cashflow-SAPRIMA/releases/download/v0.1.0-alpha.1/SHA256SUMS) · [Metadata](https://github.com/endowhs14/Aplikasi-Kasir-dan-Cashflow-SAPRIMA/releases/download/v0.1.0-alpha.1/apk-metadata.json)

## Isi dan identitas

Katalog barang/jasa, SKU, kategori, pencarian, tambah/edit produk, keranjang persisten dengan kuantitas pecahan, diskon nominal, tunai/kembalian, nota, histori, stok/ledger dan ringkasan penjualan. Mode Contoh terpisah dari Toko saya. SQLite terenkripsi dengan SQLCipher; transaksi uang/stok disimpan atomik dan retry tidak menggandakan efek.

| Atribut | Nilai |
|---|---|
| Application ID | `id.saprima.saprima_kasir` |
| Versi | `0.1.0` (versionCode `1`) |
| Android | Minimum 7 / API 24; target API 36 |
| Arsitektur | ARMv7, ARM64, x86_64 |
| Jenis | Debug, tanda tangan v2 valid |
| Ukuran | 177.543.947 byte (169,32 MiB) |
| Source commit APK | `00234aebc8e193b1aa5a4ae3f0634558255a2747` |

SHA-256 APK **rilis unduhan**:

```text
da6e1c7565c7237061503c3d7e8d57ee3f9b4fd15bb0d0911be9ed16c623c5d6
```

## Bukti pemeriksaan

[GitHub Actions 39094136184](https://github.com/endowhs14/Aplikasi-Kasir-dan-Cashflow-SAPRIMA/actions/runs/39094136184) selesai sukses: dependency lockfile, format, analyzer, **20 tes** (5 uang, 12 database, 3 widget), fixture penghentian proses/reopen/replay **7 fase**, build dan unggah artefak. Tes mencakup replay 100 kali, rollback atomik, stok/jasa, snapshot nota, enkripsi/kunci salah, serta alur kasir UI. Error decrypt pada log tes kunci salah adalah hasil penolakan yang memang diuji.

Salinan APK diunduh kembali dari draft release dan diverifikasi: SHA256SUMS cocok, signature v2 valid, manifest/versi/ABI sesuai, integritas ZIP lulus, SQLCipher tersedia pada ketiga ABI.

APK lokal sebelumnya (source aplikasi sama, signing key debug berbeda) berhasil dipasang pada emulator Android 35 melalui `adb install --no-streaming`. Aktivitas dibuka, database toko/demo terbentuk, katalog dan keranjang Rp5.000 terkonfirmasi melalui hierarchy UI Android. Emulator software tanpa KVM mengalami System UI ANR dan screenshot hitam; alur checkout lengkap pada emulator **belum dinyatakan lulus**. APK CI unduhan belum diuji instal secara terpisah. **Belum diuji pada HP fisik.**

## Cara mencoba

Unduh APK, buka pada Android 7 atau lebih baru, lalu izinkan instalasi dari aplikasi pengunduh/pengelola file bila Android meminta. Atau:

```bash
adb install -r saprima-kasir-0.1.0-debug.apk
```

Mulai dari mode **Contoh** untuk latihan; pilih **Toko saya** untuk katalog kosong yang terpisah. APK debug memakai key uji, bukan signing produksi. Pembaruan memerlukan package dan key yang cocok. Jangan menghapus data/uninstall untuk mengatasi konflik signature apabila ada data penting; belum tersedia backup/restore pengguna.

## Batas demo

Belum ada login/PIN/RBAC, multi-cabang, sinkronisasi/backend, billing, refund, pengeluaran/HPP, ekspor laporan, email, printer, barcode, atau build iOS. Outbox lokal belum dikirim ke server. Ringkasan merupakan penjualan, bukan laba atau saldo kas lengkap.

Database terenkripsi, tetapi orang yang dapat membuka perangkat dapat membuka aplikasi. Debugging aktif; backup Android dinonaktifkan. Hapus data, uninstall, atau kehilangan perangkat dapat menghilangkan catatan. Gunakan data uji dan catatan pendamping.

APK lokal asli tetap disimpan di cloud dengan checksum `15b009a2586e5eed6dccbd6923170b3d9aa1fa81c088495fdb9da0831d24ea66` (177.542.491 byte). Checksum itu **bukan** checksum APK unduhan rilis ini.
