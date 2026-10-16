# Checkpoint implementasi

15 Oktober 2026 (Asia/Jakarta).

## Selesai
- Repository kosong diperiksa; akses baca GitHub berhasil.
- PRD dan empat rencana teknis disalin dari delegasi pengguna.
- Java 21 tersedia; Flutter stable 3.47.7 diunduh dari GitHub resmi.
- Android command-line tools 23.0 diunduh dari Google dan checksum SHA-1 resmi diverifikasi.
- Toolchain/cache dipisah di `/workspace/toolchains`; tidak masuk git.
- Draft domain jaringan Flutter/Android tersimpan; unduhan engine kini bekerja.

## Sedang dikerjakan
- Instalasi Flutter/Android dan implementasi aplikasi kasir SQLite.

## Berikutnya
- Uji domain uang/stok, rollback/restart SQLite, alur UI.
- Bangun dan verifikasi APK, simpan di `/workspace/deliverables`.
- Commit/push main, dokumentasikan cara build/install dan gap PRD.

## Perintah lingkungan
`source /workspace/toolchains/env.sh`

Belum ada APK atau hasil pengujian aplikasi. Jangan menandai PRD selesai.

## Checkpoint lanjutan — 16 Oktober 2026 (Asia/Jakarta)
- Implementasi Flutter tersedia: kasir, katalog/edit SKU, kategori/pencarian, keranjang persisten, diskon, tunai/kembalian, nota, histori, penyesuaian/ledger stok, ringkasan.
- Database SQLCipher terenkripsi; kunci dibuat acak dan disimpan melalui flutter_secure_storage; database demo dan toko terpisah.
- Analyzer bersih pada pemeriksaan sebelumnya. 17 tes domain/database lulus; 2 tes UI lulus; tes checkout sedang diperbaiki dengan menunggu scroll selesai sebelum tap.
- Uji proses crash/reopen/replay `python3 tool/check_crash.py` LULUS (7 fase): rollback sebelum komit, persistensi sesudah komit, replay tanpa duplikasi.
- Build APK belum terkonfirmasi. Gradle memerlukan konfigurasi proxy di `/workspace/toolchains/gradle/gradle.properties`, telah dibuat dari binding proxy runtime.
- Tidak ada klaim uji HP fisik/emulator atau backend/sync produksi.

### Resume
```bash
source /workspace/toolchains/env.sh
cd /workspace/Aplikasi-Kasir-dan-Cashflow-SAPRIMA/apps/mobile
flutter test --reporter expanded
flutter analyze
python3 tool/check_crash.py
flutter build apk --debug
```
Jika build gagal, baca pesan Gradle sebelum mengulang. Jangan hapus cache/progres. APK final harus diverifikasi, disalin ke `/workspace/deliverables`, lalu catat SHA-256/ukuran/version.

## Checkpoint build — 16 Oktober 2026
- Push source commit `c0078cf2ddb2f23438c35207d70f3c675ffbdaf5` ke main terverifikasi lewat `git ls-remote`.
- Tes UI kini 3/3 lulus. Perbaikan: tunggu scroll selesai, tekan BackButton langsung (helper pageBack tidak cocok label Indonesia).
- `flutter analyze` kembali bersih setelah perubahan.
- Penyebab build pertama: Java bawaan hanya JRE. JDK Temurin 21.0.12.1+1 diunduh dari release resmi, SHA-256 diverifikasi.
- SDK 35 tambahan dipasang untuk plugin JNI. JDK baru menggunakan trust store sistem `/etc/ssl/certs/java/cacerts`; verifikasi TLS tetap aktif.
- Build ulang sedang berjalan. Skrip reproducible ada di `scripts/cloud-setup.sh` dan `scripts/build-apk.sh`.
