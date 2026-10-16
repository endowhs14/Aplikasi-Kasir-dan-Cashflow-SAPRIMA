# PRODUCT REQUIREMENTS DOCUMENT (PRD)
## Aplikasi Kasir &amp; Manajemen Bisnis UMKM — Android &amp; iOS

**Versi:** 1.0  
**Tanggal:** 14 Oktober 2026  
**Status:** Draft untuk Validasi &amp; Pengembangan  
**Model Bisnis:** Software as a Service (SaaS) — Langganan Bulanan  
**Nama Produk:** Belum Ditentukan

---

# 1. Ringkasan Eksekutif

## 1.1 Gambaran Produk

Produk ini merupakan aplikasi mobile berbasis Android dan iOS untuk membantu pemilik usaha mikro dan kecil mengelola transaksi penjualan, katalog produk atau jasa, persediaan stok, arus kas, serta laporan bisnis dalam satu platform terintegrasi.

Aplikasi dirancang dengan kemampuan **online-offline**, sehingga transaksi kasir tetap dapat dilakukan saat koneksi internet tidak tersedia. Data transaksi yang tersimpan secara lokal akan disinkronkan dengan database cloud ketika koneksi kembali.

Produk menerapkan sistem langganan dengan harga mulai dari **Rp300.000 per bulan untuk satu cabang**, ditambah biaya untuk setiap cabang tambahan.

Setiap akun bisnis dapat memiliki beberapa pengguna dengan hak akses berbeda, termasuk pemilik, manajer, dan kasir.

Seluruh data penjualan disimpan secara terpusat. Sistem juga membuat laporan otomatis setiap bulan dan mengirimkan pemberitahuan beserta laporan melalui email terverifikasi milik pemilik bisnis.

## 1.2 Visi Produk

Menjadi platform manajemen bisnis yang mudah digunakan oleh UMKM Indonesia, sekaligus menyediakan infrastruktur yang dapat berkembang seiring pertumbuhan transaksi, karyawan, dan cabang usaha.

## 1.3 Tujuan Bisnis

1. Membantu UMKM beralih dari pencatatan manual ke sistem digital.
2. Mengurangi kesalahan transaksi, pencatatan stok, dan laporan keuangan.
3. Menyediakan pemantauan bisnis secara real-time.
4. Mendukung pengelolaan beberapa cabang dalam satu akun bisnis.
5. Menghasilkan pendapatan berulang melalui model subscription.
6. Membangun sistem yang mampu menangani jutaan transaksi per pelanggan.
7. Mendistribusikan aplikasi melalui Google Play Store dan Apple App Store.

# 2. Target Pengguna

## 2.1 Segmentasi Pengguna

| Segmentasi | Contoh Bisnis | Kebutuhan Utama |
|---|---|---|
| Usaha mikro | Warung, kios, stan, pedagang kecil | Kasir sederhana, pencatatan uang |
| Retail kecil | Kelontong, toko sembako, minimarket independen | Penjualan, harga, stok |
| F&amp;B | Kafe, kedai kopi, warung makan | Katalog menu, transaksi, cashflow |
| Jasa | Salon, barbershop, laundry | Katalog layanan, transaksi, laporan |
| Jasa otomotif | Bengkel motor/mobil | Produk suku cadang dan jasa servis |
| Usaha multi-cabang | Retail atau jasa dengan beberapa lokasi | Dashboard terpusat dan pengelolaan cabang |

## 2.2 Peran Pengguna

**Business Owner**

Memiliki akses penuh atas bisnis, seluruh cabang, staf, transaksi, laporan, pengaturan, dan langganan.

**Manajer**

Mengelola kegiatan operasional pada cabang yang ditugaskan, termasuk pemantauan kasir, stok, dan laporan cabang.

**Kasir/Karyawan**

Mengelola transaksi penjualan dan menjalankan aktivitas yang diizinkan oleh pemilik atau manajer.

## 2.3 Permasalahan Pengguna

- Pencatatan transaksi masih dilakukan secara manual.
- Kesulitan melacak stok barang dan selisih persediaan.
- Tidak mengetahui pemasukan, pengeluaran, dan keuntungan usaha secara akurat.
- Penyusunan laporan bulanan membutuhkan waktu.
- Sulit memantau aktivitas karyawan dan beberapa cabang sekaligus.
- Risiko kehilangan catatan akibat kerusakan atau kehilangan perangkat.

# 3. Ruang Lingkup Produk

## 3.1 Fitur Wajib MVP (P0)

MVP atau Minimum Viable Product merupakan versi pertama yang cukup lengkap untuk digunakan dan diuji oleh pelanggan berbayar.

| Modul | Fitur Wajib |
|---|---|
| Autentikasi | Signup, login, verifikasi email, reset password |
| Bisnis | Profil bisnis dan pengaturan cabang |
| Pengguna | Owner, manajer, kasir, hak akses |
| POS | Transaksi penjualan, keranjang, diskon, pembayaran |
| Katalog | Produk/jasa, kategori, harga, SKU |
| Inventori | Stok per cabang, penyesuaian, histori stok |
| Keuangan | Pemasukan, pengeluaran, cashflow |
| Dashboard | Penjualan, pengeluaran, metrik keuntungan |
| Laporan | Laporan harian, bulanan, PDF, XLSX/CSV |
| Otomatisasi | Laporan bulanan melalui email |
| Offline | Transaksi offline dan sinkronisasi |
| Subscription | Penagihan, aktivasi, renewal, kedaluwarsa |
| Multi-Cabang | Pengelolaan cabang dan laporan gabungan |
| Keamanan | Audit log, kontrol akses, backup |

## 3.2 Fitur Pengembangan Berikutnya (P1)

- Integrasi printer Bluetooth dan printer kasir.
- Pemindaian barcode melalui kamera.
- Transfer stok antar-cabang.
- Manajemen supplier dan pembelian.
- Pengelolaan bahan baku atau resep produk.
- Pelacakan piutang pelanggan.
- Integrasi Google Sheets.
- Notifikasi stok minimum.
- Dashboard analitik lanjutan.
- Integrasi sistem akuntansi eksternal.

## 3.3 Di Luar Cakupan MVP

Fitur penggajian, marketplace, pengantaran, reservasi salon, sistem antrean bengkel, dan pembukuan akuntansi penuh tidak termasuk MVP.

Fitur khusus industri tersebut dapat dikembangkan setelah produk inti tervalidasi.

# 4. Sistem Akun dan Hak Akses

## 4.1 Registrasi Pemilik Bisnis

Alur registrasi:

1. Pengguna membuka aplikasi.
2. Memilih menu Daftar.
3. Mengisi nama, email, dan password.
4. Sistem mengirim email verifikasi.
5. Pengguna memverifikasi email.
6. Pengguna membuat profil bisnis.
7. Memilih jumlah cabang.
8. Memilih dan menyelesaikan pembayaran langganan.
9. Sistem mengaktifkan akses.
10. Pemilik masuk ke dashboard bisnis.

**Data registrasi minimal:**

- Nama pemilik.
- Alamat email terverifikasi.
- Password atau kredensial metode autentikasi.
- Nama usaha.
- Jenis usaha.
- Zona waktu dan mata uang.
- Jumlah cabang awal.

Nomor telepon serta informasi alamat dapat dilengkapi melalui profil bisnis.

## 4.2 Hak Akses

| Aktivitas | Owner | Manajer | Kasir |
|---|---|---|---|
| Penjualan | Ya | Ya | Ya |
| Kelola katalog | Ya | Ya | Opsional |
| Kelola stok | Ya | Ya | Opsional |
| Lihat cashflow | Semua cabang | Cabang sendiri | Tidak |
| Lihat laporan | Semua cabang | Cabang sendiri | Terbatas |
| Kelola staf | Ya | Terbatas | Tidak |
| Tambah cabang | Ya | Tidak | Tidak |
| Kelola subscription | Ya | Tidak | Tidak |
| Ekspor seluruh data | Ya | Sesuai izin | Tidak |

Sistem menggunakan **Role-Based Access Control (RBAC)**. Setiap karyawan mempunyai identitas pengguna sendiri dan dapat ditugaskan ke satu atau beberapa cabang.

Semua permintaan data harus memverifikasi keanggotaan bisnis dan hak akses pengguna pada backend, bukan hanya menyembunyikan menu pada aplikasi.

# 5. Modul Kasir (Point of Sale)

## 5.1 Persyaratan Fungsional

**FR-POS-001 — Membuat Transaksi**

Kasir dapat memilih produk atau jasa dari katalog, memasukkannya ke keranjang, mengubah kuantitas, memberikan diskon jika diizinkan, lalu menyelesaikan transaksi.

**FR-POS-002 — Metode Pembayaran**

Sistem mendukung pencatatan transaksi tunai, transfer, QRIS, dan metode non-tunai lain.

Pembayaran digital yang terintegrasi dengan penyedia pembayaran hanya dinyatakan berhasil setelah menerima konfirmasi yang valid. Pembayaran tunai dapat dicatat tanpa internet.

**FR-POS-003 — Identitas Transaksi**

Setiap transaksi memiliki ID unik, nomor nota, cabang, kasir, waktu transaksi, item, harga, diskon, pajak jika berlaku, dan status pembayaran.

**FR-POS-004 — Refund dan Pembatalan**

Pengguna dengan izin yang sesuai dapat membatalkan atau mengembalikan transaksi. Perubahan harus dicatat dalam audit log dan tidak menghapus histori transaksi asli.

**FR-POS-005 — Bukti Pembayaran**

Sistem menyediakan bukti transaksi digital yang dapat ditampilkan dan dibagikan. Integrasi printer fisik dapat menjadi pengembangan berikutnya.

## 5.2 Aturan Bisnis

- Harga transaksi disimpan sebagai snapshot pada saat penjualan agar perubahan harga katalog tidak mengubah data historis.
- Transaksi yang diselesaikan memperbarui stok sesuai jenis item.
- Item jasa yang tidak memiliki stok tidak mengurangi persediaan.
- Semua transaksi memakai ID unik dan mekanisme idempotency untuk mencegah duplikasi saat sinkronisasi.
- Pajak dan biaya layanan dibuat dapat dikonfigurasi sesuai kondisi usaha.

# 6. Modul Katalog dan Stok

## 6.1 Katalog Produk dan Jasa

Setiap item dapat mempunyai:

- Nama dan kategori.
- SKU atau kode produk.
- Jenis item: barang atau jasa.
- Harga jual.
- Harga modal/HPP apabila relevan.
- Satuan.
- Varian sederhana.
- Foto (opsional).
- Status aktif/nonaktif.

Katalog utama dimiliki oleh bisnis. Harga dan ketersediaan stok dapat berbeda pada setiap cabang.

## 6.2 Manajemen Inventori

Sistem menyediakan stok awal, pengurangan karena penjualan, penambahan persediaan, penyesuaian manual, serta histori pergerakan stok.

Setiap perubahan stok mencatat alasan, waktu, cabang, jumlah, dan pengguna yang bertanggung jawab.

Untuk transaksi offline, aplikasi memakai stok lokal terakhir yang diketahui. Jika perangkat lain menjual barang yang sama, sistem berpotensi mengalami konflik stok. Backend wajib merekonsiliasi transaksi dan menandai stok negatif atau selisih untuk ditinjau.

**Stok tidak boleh ditimpa begitu saja oleh salinan lokal yang lebih lama.** Perubahan diproses sebagai pergerakan stok yang dapat diaudit.

# 7. Modul Cashflow dan Keuangan

## 7.1 Pemasukan

Pemasukan mencakup pembayaran penjualan serta pemasukan non-penjualan yang dicatat pemilik sesuai kategori.

## 7.2 Pengeluaran

Pengguna berizin dapat mencatat pengeluaran seperti:

- Pembelian barang.
- Biaya listrik, air, dan internet.
- Sewa tempat.
- Operasional.
- Gaji.
- Pengeluaran lain.

Setiap pengeluaran memiliki nominal, kategori, tanggal, cabang, keterangan, dan pengguna pencatat.

## 7.3 Dashboard Keuangan

Sistem menampilkan:

- Total penjualan bruto.
- Diskon dan retur.
- Penjualan bersih.
- Total pengeluaran.
- Arus kas masuk dan keluar.
- Saldo kas operasional.
- Estimasi laba kotor berdasarkan HPP.
- Estimasi laba operasional apabila data biayanya memadai.

**Catatan akuntansi:** Cashflow tidak sama dengan laba. Pembelian persediaan, modal masuk, transfer antar-rekening, dan transaksi non-tunai harus diklasifikasikan secara tepat agar tidak menghasilkan perhitungan keuntungan yang menyesatkan.

Produk MVP menyediakan laporan manajemen sederhana, bukan menggantikan laporan keuangan formal yang disusun berdasarkan standar akuntansi.

# 8. Multi-Cabang

## 8.1 Kemampuan Utama

Owner dapat menambah, mengubah, menonaktifkan, dan mengelola cabang selama langganannya memenuhi jumlah cabang aktif.

Setiap cabang mempunyai:

- Nama dan alamat.
- Karyawan yang ditugaskan.
- Persediaan stok.
- Transaksi penjualan.
- Pemasukan dan pengeluaran.
- Laporan operasional.

Owner dapat memilih tampilan satu cabang atau gabungan seluruh cabang.

## 8.2 Pemisahan Data

Setiap transaksi harus dikaitkan dengan `tenant_id` dan `branch_id`.

Satu cabang tidak boleh dapat membaca data milik cabang lain tanpa hak akses yang sesuai.

Penonaktifan cabang tidak menghapus histori penjualan. Transaksi offline yang belum disinkronkan perlu diselesaikan terlebih dahulu sebelum penonaktifan efektif.

# 9. Sistem Berlangganan

## 9.1 Struktur Harga

**Rekomendasi komersial awal yang disetujui untuk rancangan produk:**

| Cabang Aktif | Harga Bulanan |
|---|---:|
| 1 | Rp300.000 |
| 2 | Rp450.000 |
| 3 | Rp600.000 |
| 4 | Rp750.000 |
| 5 | Rp900.000 |
| 10 | Rp1.650.000 |

**Rumus:**

Total = Rp300.000 + (jumlah cabang aktif − 1) × Rp150.000.

Harga tersebut belum menetapkan perlakuan pajak, biaya pemrosesan pembayaran, maupun komisi distribusi aplikasi. Komponen-komponen itu wajib ditentukan sebelum peluncuran komersial.

## 9.2 Model Hybrid

Aplikasi mendukung konsep dua jalur pembayaran:

**Pembayaran manual:** QRIS, virtual account, e-wallet, atau transfer melalui penyedia pembayaran yang didukung.

**Pembayaran berulang:** Metode pembayaran yang mendukung recurring billing, sesuai ketentuan penyedia layanan dan platform distribusi.

Implementasi akhir dapat menggunakan gateway seperti Midtrans atau Xendit untuk kanal yang diizinkan, serta sistem billing toko aplikasi apabila diwajibkan.

**Kepatuhan platform adalah syarat rilis.** Pembelian fitur digital atau langganan melalui aplikasi dapat tunduk pada ketentuan Apple App Store dan Google Play. Penggunaan QRIS, checkout web, tautan pembayaran eksternal, atau pembayaran langsung di aplikasi tidak boleh diasumsikan selalu diperbolehkan. Aturan terkini, kategori aplikasi, negara distribusi, dan program pengecualian harus diverifikasi sebelum implementasi final.

## 9.3 Status Langganan

| Status | Perilaku |
|---|---|
| Pending | Menunggu verifikasi pembayaran |
| Active | Akses operasional aktif |
| Past Due | Pembayaran perpanjangan gagal, akses mengikuti tanggal aktif yang masih tersisa |
| Expired | Akses operasional dinonaktifkan |
| Cancelled | Perpanjangan dibatalkan; akses sampai periode berbayar berakhir |

Tidak ada masa tenggang tambahan setelah tanggal kedaluwarsa pada konfigurasi awal.

Sistem harus tetap menyediakan akses terbatas untuk login, informasi langganan, pembayaran perpanjangan, dan pengambilan data historis milik pengguna yang telah terautentikasi. Pemilik tidak dapat membuat transaksi baru sampai langganannya kembali aktif.

## 9.4 Pengelolaan Cabang Berbayar

Saat menambahkan cabang di tengah siklus tagihan, sistem menghitung biaya prorata untuk sisa periode berjalan. Tagihan berikutnya menggunakan jumlah cabang aktif terbaru.

Pengurangan cabang dapat efektif pada periode penagihan berikutnya. Histori cabang tetap tersimpan sesuai kebijakan retensi.

Perubahan jumlah cabang harus diproses secara konsisten agar tidak menimbulkan tagihan ganda.

## 9.5 Pengingat

Sistem mengirimkan pengingat sebelum tanggal jatuh tempo, misalnya H-7, H-3, dan H-1. Jadwal ini dapat dikonfigurasi.

Pembayaran yang berhasil diverifikasi melalui webhook aman atau sistem billing resmi memperbarui entitlement pelanggan secara otomatis.

# 10. Mode Offline dan Sinkronisasi

## 10.1 Arsitektur Offline-First

Aplikasi menggunakan database lokal terenkripsi untuk menyimpan katalog, informasi cabang yang dibutuhkan, transaksi sementara, dan antrean sinkronisasi.

Ketika tidak memiliki internet, kasir tetap dapat:

- Membuka katalog yang sudah tersinkronisasi.
- Membuat transaksi tunai.
- Menghasilkan bukti transaksi lokal.
- Melihat riwayat transaksi yang tersedia di perangkat.
- Menyimpan transaksi dalam antrean sinkronisasi.

Fitur yang membutuhkan konfirmasi server, seperti aktivasi langganan, perubahan hak akses, atau verifikasi pembayaran gateway, memerlukan koneksi internet.

## 10.2 Mekanisme Sinkronisasi

1. Transaksi baru disimpan secara atomik ke database lokal.
2. Aplikasi memberi ID global unik.
3. Transaksi masuk antrean sinkronisasi.
4. Ketika online, transaksi dikirim ke backend melalui API yang aman.
5. Backend memvalidasi akun, cabang, transaksi, serta hak akses.
6. Sistem menyimpan transaksi dengan operasi idempotent.
7. Backend mengirim status berhasil atau gagal.
8. Aplikasi menandai transaksi berhasil disinkronkan dan menangani konflik jika terjadi.

Sinkronisasi harus tahan terhadap internet terputus, pengiriman ulang, dan restart aplikasi.

## 10.3 Ketentuan Masa Aktif Saat Offline

Kebutuhan bisnis mengharuskan langganan kedaluwarsa tidak dapat digunakan.

Karena perangkat offline tidak dapat menerima perubahan status terbaru dari server, aplikasi akan memakai entitlement yang ditandatangani server, berisi batas waktu langganan dan masa validasi offline yang pendek.

**Rekomendasi awal:** validasi online ulang maksimal setiap 24 jam, dengan masa izin offline tidak boleh melewati tanggal akhir langganan yang telah diketahui.

Aplikasi wajib memakai mekanisme waktu tepercaya sejauh memungkinkan dan mendeteksi manipulasi jam perangkat.

**Batasan teknis:** Pemblokiran jarak jauh secara seketika tidak dapat dijamin ketika perangkat benar-benar offline. Karena itu, batas masa izin offline, mitigasi manipulasi perangkat, dan risiko gangguan transaksi harus menjadi keputusan produk yang eksplisit.

# 11. Laporan dan Ekspor Otomatis

## 11.1 Laporan yang Tersedia

| Jenis Laporan | Isi |
|---|---|
| Penjualan | Total transaksi, item, nilai penjualan |
| Produk | Produk terlaris, kuantitas dan pendapatan |
| Stok | Stok awal, masuk, keluar, akhir |
| Keuangan | Cashflow masuk dan keluar |
| Keuntungan | Pendapatan bersih, HPP, estimasi laba |
| Karyawan | Jumlah dan nilai transaksi per kasir |
| Cabang | Perbandingan performa antar-cabang |

Owner dapat memilih rentang tanggal dan cabang.

## 11.2 Format Ekspor

**PDF:** Laporan ringkasan yang mudah dibaca, lengkap dengan tabel, total, dan informasi periode.

**XLSX:** Data terstruktur yang dapat dibuka menggunakan Microsoft Excel atau diimpor ke Google Sheets.

**CSV:** Alternatif yang sesuai untuk jumlah baris sangat besar.

File laporan besar tidak boleh sepenuhnya diproses dalam memori aplikasi. Ekspor dilakukan melalui background job dan streaming data pada backend.

## 11.3 Ekspor Otomatis Bulanan

Setiap awal bulan, sistem membuat laporan bulan sebelumnya berdasarkan zona waktu bisnis.

**Rekomendasi jadwal:** pekerjaan dijadwalkan mulai tanggal 1 pukul 05.00 pada zona waktu bisnis, dengan mekanisme antrean untuk mengatur beban server.

Sistem menghasilkan:

1. PDF ringkasan penjualan dan keuangan.
2. XLSX atau CSV data penjualan detail.
3. Ringkasan data per cabang.
4. Informasi total transaksi, retur, diskon, dan nilai akhir.

Email dikirim ke alamat terverifikasi yang didaftarkan owner. Owner dapat mengubah alamat penerima laporan melalui proses verifikasi ulang.

## 11.4 Email dan Distribusi File

Untuk laporan berukuran kecil, sistem dapat mengirim PDF dan XLSX sebagai lampiran.

Untuk laporan besar, email berisi ringkasan dan tautan unduh aman yang memiliki masa berlaku tertentu, misalnya tujuh hari. Laporan tetap dapat diunduh ulang dari aplikasi sesuai kebijakan akses.

Jika email gagal dikirim, sistem mengulangi pengiriman dan memberi peringatan pada dashboard administrator.

Proses ekspor dan pengiriman harus idempotent agar satu periode tidak menghasilkan banyak laporan identik akibat retry.

## 11.5 Penanganan Jutaan Data

File XLSX memiliki batas maksimum **1.048.576 baris per worksheet**, termasuk baris header.

Karena itu, laporan dengan lebih dari 1.048.575 baris data harus dipisahkan menjadi beberapa worksheet atau file. Untuk volume sangat besar, sistem dapat menghasilkan sejumlah file CSV dan mengemasnya dalam ZIP.

PDF digunakan untuk ringkasan, bukan untuk mencetak jutaan baris transaksi.

# 12. Rekomendasi Arsitektur Teknologi

## 12.1 Stack Utama

| Komponen | Rekomendasi | Alasan |
|---|---|---|
| Mobile | Flutter (Dart) | Satu codebase Android dan iOS |
| Backend API | NestJS (TypeScript) | Struktur modular dan ekosistem kuat |
| Database utama | Managed PostgreSQL | Relasional, transaksi ACID, indeks dan partitioning |
| Database lokal | SQLite terenkripsi | Mendukung offline-first |
| Cache dan antrean | Redis + job queue | Sinkronisasi dan pekerjaan background |
| Penyimpanan file | S3-compatible Object Storage | Laporan, bukti, dan arsip |
| Email | Amazon SES atau penyedia setara | Pengiriman email transaksional |
| Infrastruktur | Managed cloud infrastructure | Monitoring, backup, dan skalabilitas |
| Monitoring | Logging, metrics, tracing, alerting | Pengamatan kondisi produksi |

Penyedia cloud dapat dipilih setelah estimasi biaya, kebutuhan data residency, dan lokasi mayoritas pelanggan diketahui.

## 12.2 Bentuk Arsitektur

**Aplikasi Flutter → API Backend → PostgreSQL**

Backend juga terhubung ke:

- Authentication service.
- Billing dan payment integrations.
- Redis/queue.
- Background workers.
- Object storage.
- Email delivery service.
- Monitoring dan audit logs.

Untuk fase pertama, **modular monolith** lebih direkomendasikan dibanding langsung memakai banyak microservice. Pendekatan ini mengurangi kompleksitas operasional dan tetap memungkinkan modul tertentu dipisahkan ketika beban meningkat.

# 13. Strategi Database Skala Besar

## 13.1 Rekomendasi Utama: PostgreSQL

PostgreSQL menjadi system of record untuk akun bisnis, pengguna, cabang, katalog, transaksi, pergerakan stok, catatan keuangan, dan status langganan.

Semua data tenant harus dipisahkan secara logis dan diamankan dengan kebijakan akses backend. Row-Level Security dapat digunakan sebagai lapisan pengamanan tambahan apabila desain akses mendukungnya.

## 13.2 Skema Data Inti

Entitas minimal:

- `tenants`
- `users`
- `memberships`
- `branches`
- `products`
- `product_prices`
- `inventory_balances`
- `stock_movements`
- `sales`
- `sale_items`
- `payments`
- `refunds`
- `cash_entries`
- `subscriptions`
- `invoices`
- `billing_events`
- `sync_events`
- `report_jobs`
- `report_files`
- `audit_logs`

Relasi penting:

- Satu tenant dapat memiliki banyak cabang.
- Satu tenant memiliki banyak membership pengguna.
- Satu cabang memiliki banyak transaksi.
- Setiap transaksi memiliki satu atau beberapa item.
- Stok terikat pada produk dan cabang.
- Satu tenant mempunyai hak langganan dan riwayat billing.

## 13.3 Pengelolaan Jutaan Data

**Strategi skalabilitas yang direkomendasikan:**

1. Partisi tabel transaksi besar berdasarkan waktu, misalnya bulanan, dengan mempertimbangkan tenant dan pola query.
2. Indeks komposit untuk `tenant_id`, `branch_id`, dan waktu transaksi sesuai kebutuhan query.
3. Simpan ringkasan harian/bulanan agar dashboard tidak terus menghitung dari seluruh transaksi historis.
4. Gunakan read replica ketika beban laporan mengganggu transaksi operasional.
5. Arsipkan data lama jika dibutuhkan tanpa menghilangkan kemampuan pemilik mengunduh histori.
6. Terapkan observability, perencanaan kapasitas, dan pengujian performa berkala.
7. Pertimbangkan sharding berdasarkan tenant apabila kapasitas satu klaster sudah tidak memadai.

**Prinsip produk:** Tidak menetapkan batas arbitrer jumlah transaksi historis per pelanggan pada paket berbayar.

**Batasan infrastruktur:** Tidak ada database atau cloud yang benar-benar tanpa batas. Jumlah data, throughput, penyimpanan, dan biaya memiliki batas fisik maupun komersial. Sistem harus menggunakan kapasitas yang dapat diperluas, pemantauan biaya, serta prosedur peningkatan kapasitas.

## 13.4 Data Retention dan Backup

- Data transaksi historis tetap terkait dengan pemilik bisnis.
- Backup otomatis dan point-in-time recovery bila didukung penyedia.
- Backup tersimpan terenkripsi.
- Proses restore harus diuji secara berkala.
- Masa retensi setelah penghentian langganan ditentukan oleh kebijakan yang diumumkan kepada pelanggan dan ketentuan hukum yang relevan.
- Penghapusan tenant harus mengikuti proses terkontrol, bukan penghapusan otomatis ketika gagal bayar.

# 14. Desain UI/UX

## 14.1 Navigasi Utama

Rekomendasi menu owner:

1. **Dashboard** — ringkasan performa bisnis.
2. **Kasir** — transaksi penjualan.
3. **Katalog &amp; Stok** — produk, jasa, harga, persediaan.
4. **Keuangan** — pemasukan, pengeluaran, cashflow.
5. **Laporan** — statistik dan ekspor data.
6. **Pengaturan** — staf, cabang, profil, dan subscription.

Menu ditampilkan sesuai izin pengguna.

## 14.2 Prinsip Antarmuka

- Ramah pengguna yang belum terbiasa dengan aplikasi kasir.
- Tombol transaksi besar dan mudah diakses.
- Proses pembayaran dengan langkah sesingkat mungkin.
- Indikator status koneksi dan sinkronisasi terlihat jelas.
- Pesan error sederhana dan menjelaskan tindakan berikutnya.
- Harga dan nominal menggunakan format Rupiah.
- Mendukung perangkat Android berkapasitas menengah.
- Mengutamakan aksesibilitas teks, kontras, dan area sentuh.

## 14.3 Layar Wajib

Splash, onboarding, signup, verifikasi email, login, reset password, pengaturan bisnis, pemilihan langganan, pembayaran, dashboard, kasir, detail transaksi, katalog, stok, cashflow, laporan, staf, cabang, status sinkronisasi, serta pengaturan akun.

# 15. Keamanan dan Privasi

## 15.1 Persyaratan Minimum

- TLS untuk komunikasi aplikasi dan backend.
- Enkripsi data sensitif saat tersimpan.
- Password hashing kuat atau penyedia autentikasi terkelola.
- Rotasi serta pencabutan token autentikasi.
- Verifikasi email owner.
- Perlindungan login dari brute force.
- Verifikasi akses tenant dan cabang pada setiap API.
- MFA untuk tindakan sensitif owner, terutama billing dan perubahan akun.
- Validasi webhook pembayaran.
- Audit log untuk refund, perubahan stok, perubahan role, dan billing.
- Pemisahan lingkungan development, staging, dan production.
- Manajemen secrets yang aman.

Aplikasi tidak menyimpan detail kartu pembayaran mentah. Pemrosesan kartu dilakukan oleh penyedia yang sesuai dengan kewajiban keamanan pembayaran.

## 15.2 Kepatuhan

Tim perlu melakukan penilaian terhadap UU Pelindungan Data Pribadi Indonesia, kewajiban retensi data, ketentuan pajak yang relevan, dan kebijakan distribusi aplikasi.

Dokumen ini merupakan spesifikasi produk, bukan pendapat hukum. Persyaratan legal dan aturan toko aplikasi harus diverifikasi sebelum peluncuran.

# 16. Non-Functional Requirements

| ID | Persyaratan | Target Awal |
|---|---|---|
| NFR-001 | Availability backend produksi | ≥99,9% per bulan |
| NFR-002 | Respons API transaksi online | P95 kurang dari 2 detik pada kondisi uji |
| NFR-003 | Respons transaksi kasir offline | P95 kurang dari 1 detik pada perangkat uji |
| NFR-004 | Sinkronisasi | Otomatis setelah koneksi stabil |
| NFR-005 | Duplikasi transaksi | Tidak boleh terjadi akibat retry yang menggunakan ID sama |
| NFR-006 | Skalabilitas | Uji beban hingga minimal 1 juta transaksi/bulan untuk tenant ber-volume tinggi |
| NFR-007 | Backup | Otomatis dan terenkripsi |
| NFR-008 | Recovery | Target awal RPO 15 menit, RTO 4 jam |
| NFR-009 | Laporan bulanan | Target pengiriman maksimal 24 jam setelah periode ditutup, dengan monitoring keterlambatan |
| NFR-010 | Privasi | Isolasi data tenant teruji secara otomatis |

Angka-angka tersebut merupakan target engineering awal yang perlu diuji berdasarkan perangkat, infrastruktur, dan anggaran.

# 17. Alur Pengguna Utama

## 17.1 Owner Baru

Install aplikasi → daftar → verifikasi email → buat bisnis → tentukan cabang → pilih langganan → bayar → aktivasi → isi katalog → mulai transaksi.

## 17.2 Kasir

Login → pilih cabang yang ditugaskan → buka POS → pilih item → konfirmasi nominal → catat pembayaran → simpan transaksi → stok dan laporan diperbarui.

## 17.3 Transaksi Saat Offline

Koneksi hilang → aplikasi memakai data lokal → transaksi tunai dilakukan → data masuk antrean → koneksi kembali → sinkronisasi otomatis → server memperbarui transaksi dan stok → kasir melihat hasil sinkronisasi.

## 17.4 Perpanjangan Langganan

Sistem mengirim pengingat → pelanggan menyelesaikan pembayaran atau recurring charge berhasil → penyedia pembayaran memberikan konfirmasi → backend memperpanjang entitlement → akses berlanjut tanpa gangguan.

## 17.5 Laporan Bulanan

Bulan ditutup → pekerjaan ekspor masuk antrean → sistem membuat PDF dan spreadsheet → menyimpan file secara aman → mengirim email owner → mencatat status pengiriman → owner dapat mengunduh laporan.

# 18. Acceptance Criteria Utama

| ID | Skenario | Kriteria Diterima |
|---|---|---|
| AC-01 | Signup | Owner hanya dapat mengaktifkan bisnis setelah verifikasi email dan pembayaran valid |
| AC-02 | Multi-user | Kasir tidak dapat mengakses laporan keuangan owner melalui UI maupun API |
| AC-03 | Multi-cabang | Owner melihat laporan per cabang dan laporan konsolidasi |
| AC-04 | Billing | Dua cabang dikenakan Rp450.000 untuk satu periode bulanan penuh |
| AC-05 | Expired | Akses transaksi baru ditolak setelah entitlement berakhir |
| AC-06 | Offline | Penjualan tunai tetap tersimpan saat internet terputus |
| AC-07 | Sinkronisasi | Retry transaksi yang sama tidak membuat transaksi duplikat |
| AC-08 | Stok | Penjualan berhasil menghasilkan stock movement yang dapat diaudit |
| AC-09 | Refund | Retur menyesuaikan metrik penjualan dan stok sesuai aturan |
| AC-10 | Ekspor manual | Owner dapat mengunduh PDF, XLSX, atau CSV sesuai jenis laporan |
| AC-11 | Ekspor otomatis | Setiap periode bulanan menghasilkan laporan dan email kepada owner terverifikasi |
| AC-12 | Skala besar | Jumlah baris melebihi batas XLSX ditangani melalui pemecahan file |
| AC-13 | Pemisahan tenant | Pengguna dari bisnis A tidak dapat mengakses data bisnis B |
| AC-14 | Payment | Aktivasi tidak dapat dipalsukan hanya dengan memanipulasi hasil pembayaran di aplikasi |
| AC-15 | Data retention | Kedaluwarsa langganan tidak otomatis menghapus riwayat transaksi |

# 19. KPI Keberhasilan Produk

KPI awal untuk divalidasi saat pilot:

| KPI | Definisi |
|---|---|
| Activation Rate | Persentase pendaftar yang berhasil membuat bisnis dan transaksi pertama |
| Paid Conversion | Persentase pengguna prospektif yang menjadi pelanggan berbayar |
| Monthly Recurring Revenue | Pendapatan berulang bulanan aktif |
| Customer Churn | Persentase pelanggan yang berhenti berlangganan |
| Transaction Success Rate | Persentase transaksi yang berhasil diselesaikan |
| Sync Success Rate | Persentase transaksi lokal yang berhasil tersinkronisasi |
| Report Delivery Success | Persentase laporan bulanan yang berhasil dikirim |
| Gross Margin | Pendapatan langganan dikurangi biaya langsung layanan |
| Support Rate | Jumlah permintaan bantuan per pelanggan aktif |

Target numerik komersial ditentukan setelah pengujian pasar dan estimasi unit economics.

# 20. Roadmap Pengembangan

## Fase 1 — Product Discovery dan Validasi

- Validasi kebutuhan warung, retail, kafe, laundry, salon, dan bengkel.
- Uji penerimaan harga Rp300.000 per bulan.
- Analisis biaya infrastruktur untuk pelanggan ber-volume tinggi.
- Tinjau aturan distribusi dan pembayaran.
- Finalisasi alur inti MVP.

## Fase 2 — UX/UI dan Fondasi Backend

- Desain antarmuka.
- Sistem autentikasi.
- Model tenant, cabang, dan pengguna.
- Database PostgreSQL.
- Fondasi subscription dan entitlement.
- Infrastruktur cloud dan CI/CD.

## Fase 3 — Pengembangan MVP

- POS online/offline.
- Katalog dan stok.
- Cashflow.
- Manajemen multi-cabang.
- Dashboard laporan.
- Pembayaran langganan.
- Ekspor PDF/XLSX/CSV.
- Email laporan otomatis.

## Fase 4 — Quality Assurance dan Pilot

- Pengujian transaksi dan refund.
- Pengujian konflik offline.
- Security testing.
- Load testing database dan ekspor.
- Uji coba dengan sejumlah UMKM dari berbagai sektor.
- Perbaikan berdasarkan feedback.

## Fase 5 — Publikasi

- Persiapan akun developer dan listing toko aplikasi.
- Privacy policy dan terms of service.
- Peninjauan ketentuan billing.
- Distribusi terbatas.
- Peluncuran produksi Android dan iOS.
- Monitoring dan dukungan pelanggan.

## Fase 6 — Scale dan Pengembangan

- Integrasi printer.
- Barcode scanning.
- Inventory yang lebih canggih.
- Analitik lanjutan.
- Optimasi infrastruktur dan biaya.
- Pengembangan kebutuhan khusus sektor usaha.

# 21. Risiko dan Mitigasi

| Risiko | Mitigasi |
|---|---|
| Database semakin besar | Partitioning, indeks, arsip, kapasitas terukur |
| Biaya cloud meningkat | Observability dan pemantauan biaya per tenant |
| Transaksi offline terduplikasi | ID unik dan idempotency |
| Stok konflik antarperangkat | Stock movement ledger dan rekonsiliasi |
| Perangkat hilang sebelum sync | Backup/sinkronisasi sesering mungkin dan indikator transaksi pending |
| Langganan dipakai setelah expired | Entitlement server dan batas izin offline |
| Gateway pembayaran gagal | Retry aman, status pending, rekonsiliasi webhook |
| Email gagal | Queue, retry, monitoring, unduh melalui aplikasi |
| App Store menolak pembayaran | Validasi kebijakan sebelum implementasi dan rilis |
| Kebocoran data antar-tenant | Isolasi akses, pengujian keamanan, audit |
| Harga tidak menutup biaya | Uji unit economics dan margin per tenant |

# 22. Keputusan Produk yang Sudah Final untuk Draft

1. Aplikasi dikembangkan untuk Android dan iOS.
2. Target utamanya adalah pemilik usaha mikro dan kecil.
3. Fitur inti meliputi POS, katalog, stok, cashflow, dan laporan.
4. Sistem memiliki tiga peran: owner, manajer, dan kasir.
5. Produk mendukung beberapa cabang.
6. Kasir dapat beroperasi secara offline.
7. Data disinkronkan ke cloud ketika koneksi tersedia.
8. Harga dasar Rp300.000/bulan untuk satu cabang.
9. Rekomendasi tambahan cabang Rp150.000/bulan per cabang.
10. Pembayaran memakai konsep hybrid.
11. Akses operasional dibatasi otomatis setelah langganan berakhir.
12. Laporan dapat diekspor sebagai PDF dan spreadsheet.
13. Sistem mengirim laporan bulanan melalui email.
14. Database dirancang untuk menangani jutaan transaksi per pelanggan.
15. Aplikasi ditargetkan tersedia di Google Play dan App Store.

# 23. Keputusan yang Masih Perlu Divalidasi

Sebelum PRD dinyatakan siap untuk implementasi final, keputusan berikut perlu diselesaikan:

- Nama dan identitas produk.
- Apakah paket Rp300.000 sudah termasuk pajak.
- Jumlah maksimum perangkat aktif per pengguna.
- Apakah ada masa uji coba gratis.
- Detail integrasi pembayaran sesuai kebijakan toko aplikasi.
- Kebutuhan printer dan barcode untuk MVP.
- Kebijakan penyimpanan dan penghapusan data setelah pelanggan berhenti.
- Perlakuan transaksi yang belum tersinkron ketika subscription berakhir.
- Tingkat toleransi risiko stok negatif ketika offline.
- Prioritas peluncuran Android dan iOS secara bersamaan atau bertahap.

# 24. Kesimpulan

Produk ini dirancang sebagai **platform SaaS mobile untuk operasional UMKM**, bukan sekadar aplikasi pencatatan penjualan.

Keunggulan utamanya adalah integrasi kasir, stok, cashflow, laporan, multi-user, multi-cabang, transaksi offline, serta otomatisasi laporan bulanan.

Arsitektur Flutter, backend modular, managed PostgreSQL, database lokal terenkripsi, dan background job processing merupakan rekomendasi awal yang sesuai untuk mengembangkan MVP sekaligus menjaga jalur peningkatan kapasitas di masa depan.

Prioritas pengembangan harus menekankan tiga aspek utama: **keakuratan transaksi dan stok, keamanan data antar-bisnis, serta keandalan sistem langganan dan sinkronisasi.**

**Status akhir dokumen: PRD v1.0 — Draft Lengkap, Siap untuk Review Produk, Desain, dan Engineering.**
