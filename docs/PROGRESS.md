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

## APK berhasil — 16 Oktober 2026
- `flutter build apk --debug` berhasil setelah JDK, SDK 35, CMake 3.22.1 dan trust store disiapkan. Tidak ada verifikasi TLS/checksum yang dimatikan.
- APK: `/workspace/deliverables/saprima-kasir-0.1.0-debug.apk`.
- SHA-256: `15b009a2586e5eed6dccbd6923170b3d9aa1fa81c088495fdb9da0831d24ea66`.
- Ukuran: 177.542.491 byte; appId `id.saprima.saprima_kasir`; versi `0.1.0`, code `1`; minSdk 24, target 36; ARMv7/ARM64/x86_64.
- `apksigner verify --verbose`: valid, signature v2. `aapt dump badging`: identitas sesuai. ZIP integrity lulus; libsqlcipher.so tersedia pada ketiga ABI.
- Bukti tes: 12 database + 5 uang/domain lulus, 3 widget lulus setelah perbaikan, analyzer bersih, crash fixture 7 fase lulus. Log lokal di `/workspace/deliverables`.
- `bash scripts/cloud-setup.sh` dijalankan ulang berhasil; lockfile tidak berubah.
- `install_script` dan `start_skill` tersimpan di draft environment. Simpan/review pengaturan lalu publish environment untuk snapshot tugas berikutnya; belum mengklaim validasi restore tugas baru.
- Emulator software Android 35 tersedia, proses boot/install sedang diperiksa. Belum ada klaim uji HP nyata.

## Distribusi APK
- APK lokal sudah valid; upload ke draft GitHub Release gagal HTTP 401 pada uploads.github.com meskipun API/Git repo berfungsi. Tidak meminta/mengambil token mentah.
- Disiapkan workflow manual `.github/workflows/android-apk.yml` untuk build dan unggah dengan GITHUB_TOKEN bawaan runner; hanya runner standar repository publik, tidak membeli layanan.
- Draft release `v0.1.0-alpha.1` sudah dibuat tetapi belum dipublikasikan dan saat checkpoint ini belum memiliki asset.
- Keystore debug runner berbeda dari cloud lokal: checksum APK CI akan berbeda; metadata final harus diambil dari artifact yang benar-benar dibagikan.

## Kelanjutan distribusi — 18 Oktober 2026
- Main `d32075a` sudah tersimpan di GitHub. APK lokal asli tetap dipertahankan.
- Instal APK lokal melalui `adb install --no-streaming` berhasil pada emulator Android 35. Boot selesai dan `am start -W` menghasilkan Status ok; ini belum bukti seluruh alur UI native atau HP fisik.
- Run Actions `38862859350` gagal karena default setup-android mencoba paket SDK lama `tools` yang sudah tidak tersedia. Log arsip mengonfirmasi `Failed to find package 'tools'`; konfigurasi diperbaiki menjadi `packages: platform-tools`.
- Berikutnya: jalankan workflow yang diperbaiki, periksa tes/build/signature, unduh artifact, cocokkan SHA-256, unggah/publikasikan prerelease dan catat URL unduhan aktual. Jangan mengganti checksum lokal dengan checksum CI tanpa label.

### Run distribusi 39094136184
- Source build: `00234aebc8e193b1aa5a4ae3f0634558255a2747`, push main terverifikasi.
- Perbaikan paket SDK berhasil. Tahap locked dependencies/format/analyze/test/crash fixture lulus di GitHub Actions; kompilasi APK sedang berlangsung pada checkpoint ini.
- Pemeriksaan ulang APK lokal: SHA-256 sama, signature v2 valid, metadata cocok. Emulator membuat database toko dan demo, tetapi System UI mengalami ANR dan screenshot hitam; pengujian alur native belum dinyatakan lulus.
- Resume distribusi: `gh run view 39094136184`; bila sukses `gh run download 39094136184 -n saprima-android-debug -D /workspace/deliverables/ci-39094136184`. Verifikasi file yang diunduh dan perbarui catatan release sebelum mempublikasikan draft `v0.1.0-alpha.1`. APK CI mempunyai key/checksum sendiri; pertahankan APK lokal asli.
- Workflow berikutnya menjaga asset release yang sudah dipublikasikan; hasil build ulang tetap tersedia melalui artifact Actions.
