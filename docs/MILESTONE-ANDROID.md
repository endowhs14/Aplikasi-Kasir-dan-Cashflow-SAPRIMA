# APK lokal 0.1.0 — batas implementasi

Nama kerja: SAPRIMA Kasir. Ini milestone APK awal, bukan seluruh MVP berbayar PRD.

## Tersedia pada source
- Flutter native Android; UI Bahasa Indonesia, nominal IDR, waktu nota Asia/Jakarta.
- Katalog barang/jasa, SKU unik tanpa membedakan huruf besar/kecil, kategori, satuan, harga; tambah/edit/pencarian/filter.
- Keranjang persisten, kuantitas tiga desimal, diskon nota nominal Rupiah, tunai/kembalian, konfirmasi simpan, nota/detail/salin teks, histori bertahap.
- Stok awal, penyesuaian beralasan, ledger dan ringkasan penjualan hari ini/seluruh histori.
- Mode contoh dan Toko saya terpisah secara fisik. Data contoh ditandai dan tidak mengisi toko.
- SQLite/SQLCipher, key 256 bit acak di flutter_secure_storage (Android Keystore); WAL + synchronous FULL, FK, transaksi atomik.
- Komit nota/items/payment/stock/cash/outbox/audit/sequence dan pembersihan draft dalam satu transaksi. Replay ID sama dan payload sama mengembalikan nota lama; payload berbeda ditolak.
- Snapshot nama/SKU/unit/harga membuat nota lama tetap sama setelah katalog diedit.

## Aturan milestone
- Rupiah integer; kuantitas integer per seribu; bruto baris dibulatkan half-up sekali. Diskon nota nominal, tanpa pajak/layanan.
- Maksimum harga Rp1 miliar, total/tunai Rp1 triliun, jumlah 1 juta satuan dan 200 SKU per nota.
- Stok negatif ditolak untuk APK satu perangkat ini. Ini keputusan milestone lokal, bukan penyelesaian kebijakan konflik multi-device dalam PRD.
- Perubahan versi katalog/stok membuat keranjang lama harus diperiksa: hapus lalu tambahkan item yang berubah.
- Satu operator lokal dan satu cabang lokal, bukan autentikasi/RBAC produksi.
- Outbox disimpan untuk mempertahankan bukti lokal, berstatus `local_only`; belum ada pengiriman/sinkronisasi. UI tidak menyatakan sudah tersinkron.

## Belum tersedia
Login, verifikasi email, role, multi-cabang, backend NestJS/PostgreSQL, sync lintas perangkat, entitlement, langganan/billing/gateway, refund, cashflow pengeluaran, HPP/laba, ekspor PDF/XLSX/CSV, email bulanan, backup/restore cloud, printer, barcode dan build iOS.

## Keamanan dan batas uji
Database lokal memakai enkripsi nyata; aplikasi menolak engine tanpa SQLCipher dan kunci salah, tanpa fallback plaintext. Database lama tanpa key tidak dihapus otomatis. Android backup dinonaktifkan untuk menghindari restore database tanpa key.
APK debug dapat di-debug dan tidak layak produksi. Tidak ada akun/PIN/biometrik aplikasi; orang yang dapat membuka perangkat dapat membuka kasir. Uninstall/hapus data atau kehilangan perangkat dapat menghilangkan seluruh data karena backup belum tersedia. Gunakan data uji dan catatan pendamping selama evaluasi.
Jangan menganggap enkripsi sebagai bukti semua persyaratan keamanan/privasi PRD telah dipenuhi. Pengujian HP fisik, iOS, performa/aksesibilitas lintas perangkat, penetrasi, dan recovery kunci masih diperlukan.
