# SAPRIMA Kasir

Aplikasi kasir **Flutter Android** untuk milestone APK lokal 0.1.0. Nama SAPRIMA masih nama kerja. Ini belum seluruh MVP SaaS pada PRD dan belum untuk operasional produksi.

## Fitur APK awal

Katalog barang/jasa, SKU dan kategori; tambah/edit produk; pencarian; keranjang dengan kuantitas pecahan; diskon nominal; pembayaran tunai dan kembalian; nota yang dapat disalin; histori; stok awal/penyesuaian/ledger; ringkasan penjualan. Draft dan transaksi bertahan saat aplikasi dibuka ulang.

**Contoh / latihan** dan **Toko saya** memakai database terpisah. Tekan tombol mode pada bagian atas untuk berpindah. Toko saya dimulai kosong. Nota contoh tidak masuk ringkasan toko.

Uang menggunakan integer Rupiah, kuantitas integer per seribu. Nota, item, pembayaran, stok, kas, audit, sequence dan outbox disimpan dalam satu transaksi SQLite. SQLCipher mengenkripsi database; key acak disimpan melalui penyimpanan aman Android. Pengulangan ID/payload transaksi tidak menggandakan efek.

## Build dan pengujian

Toolchain yang digunakan: Flutter **3.47.7**, Dart **3.13.5**, JDK Temurin **21.0.12.1+1**, Android SDK **35/36**, build tools **36.0.0**, NDK **28.2.13676358**, CMake **3.22.1**. Android minimum API 24 (Android 7), target API 36.

Di cloud ini:

```bash
bash scripts/cloud-setup.sh
source scripts/cloud-env.sh
cd apps/mobile
flutter analyze
flutter test --reporter expanded
python3 tool/check_crash.py
cd ../..
bash scripts/build-apk.sh
```

Di komputer sendiri dengan Flutter/JDK/Android SDK yang sesuai, jalankan `flutter pub get --enforce-lockfile`, analyzer/test/build dari `apps/mobile`. Lockfile dikomit. Flutter membangkitkan Gradle wrapper bila belum ada. Toolchain/cache tidak disimpan di Git; skrip cloud memakai `/workspace/toolchains` dan proxy runtime yang tersedia. Verifikasi TLS/checksum tetap aktif.

Hasil default: `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`. Skrip build menyalin APK dan checksum ke `/workspace/deliverables`. Lihat [checkpoint](docs/PROGRESS.md) untuk hasil build yang benar-benar telah diverifikasi, bukan asumsi dari perintah di atas.

## Instal APK untuk uji coba

Salin APK debug ke Android 7 atau lebih baru, buka file dan izinkan instalasi dari aplikasi pengelola file tersebut bila diminta Android. Atau gunakan:

```bash
adb install -r saprima-kasir-0.1.0-debug.apk
```

Package/applicationId: `id.saprima.saprima_kasir`; versi `0.1.0`, versionCode `1`. APK debug ditandatangani key debug, bukan signing key produksi. Pembaruan hanya bisa mempertahankan data bila package/signing key cocok; jangan uninstall untuk mengatasi konflik signature jika data masih diperlukan.

## Batas dan keamanan uji coba

Belum ada login/RBAC, multi-cabang, sync/backend cloud, billing, refund, keuangan pengeluaran/HPP, ekspor laporan, email, printer, barcode, atau build iOS. Status “lokal” tidak berarti sudah terkirim ke cloud. Ringkasan adalah penjualan, **bukan laba atau saldo kas lengkap**.

Database terenkripsi tetapi aplikasi belum memiliki PIN/biometrik/login; orang yang bisa membuka perangkat bisa membuka kasir. APK debug memungkinkan debugging. Backup Android dinonaktifkan; belum ada backup/restore pengguna. Uninstall/hapus data atau kehilangan perangkat dapat menghilangkan data. Gunakan data uji dan catatan pendamping, bukan satu-satunya catatan usaha. Jangan memasukkan informasi pelanggan sensitif.

Rincian scope dan keputusan milestone: [MILESTONE-ANDROID.md](docs/MILESTONE-ANDROID.md). Catatan pengujian tidak sama dengan sertifikasi keamanan, kesiapan produksi, atau pengujian HP fisik.

## Konteks proyek

[PRD v1.0](docs/PRD-v1.0.md), [rencana teknis](docs/01-rencana-teknis.md), [model data](docs/02-model-data.md), [API/sinkronisasi](docs/03-api-dan-sinkronisasi.md), dan [backlog/validasi](docs/04-backlog-dan-validasi.md) disalin dari konteks pengguna; sumber lokal tidak dihapus. Dokumen tersebut merekam rancangan awal, bukan klaim semua fitur sudah dibangun. Progres aktual dan perintah resume ada di [PROGRESS.md](docs/PROGRESS.md).
