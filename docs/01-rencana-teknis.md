# Rencana teknis aplikasi kasir dan manajemen UMKM

Tanggal: 14 Oktober 2026 · Versi 0.1 · Berdasarkan PRD v1.0 pengguna.

Status: rancangan untuk review engineering. Dokumen ini belum merupakan aplikasi, migrasi database siap produksi, atau bukti bahwa target performa telah tercapai. Semua keputusan tambahan diberi status usulan; keputusan final PRD tetap menjadi acuan.

## Paket dokumen

1. Dokumen ini: arsitektur, keputusan teknis, operasi, dan batas MVP.
2. [Model data](02-model-data.md): entitas, relasi, constraint, indeks, dan konsistensi.
3. [Kontrak API dan sinkronisasi](03-api-dan-sinkronisasi.md): endpoint, payload, status, dan skenario kegagalan.
4. [Backlog dan validasi](04-backlog-dan-validasi.md): urutan pembangunan, dependensi, acceptance criteria, dan keputusan terbuka.

## 1. Rekomendasi utama

Gunakan Flutter untuk Android/iOS, NestJS sebagai backend modular dalam satu codebase, PostgreSQL terkelola sebagai pusat data, SQLite terenkripsi di perangkat, serta worker terpisah untuk laporan dan integrasi. Transaksi kasir tunai disimpan lokal terlebih dahulu, lalu disinkronkan menggunakan identitas transaksi yang tetap.

Bangun alur lengkap terkecil terlebih dahulu: owner terverifikasi → bisnis dan cabang → hak akses → katalog → penjualan tunai → stok → sinkronisasi → ringkasan. Billing produksi dan ekspor menyusul di atas fondasi tersebut, tetapi aturan entitlement dan pemisahan tenant sudah diterapkan sejak awal.

P0 tetap mencakup semua modul PRD. Integrasi penerimaan pembayaran pelanggan toko secara otomatis diusulkan sebagai tahapan lanjutan: MVP mencatat tunai, transfer, QRIS eksternal, dan metode lain. Pembayaran langganan yang memerlukan verifikasi penyedia tetap masuk P0. Perbedaan ruang lingkup ini perlu disetujui sebelum implementasi integrasi pembayaran.

## 2. Asumsi kerja yang perlu divalidasi

| Area | Usulan awal | Dampak |
|---|---|---|
| Mata uang | IDR, nominal hasil akhir berupa Rupiah bulat | Tidak ada konversi mata uang dalam MVP |
| Zona waktu | Zona IANA per bisnis; default Asia/Jakarta | Waktu UTC disimpan; batas laporan mengikuti zona bisnis |
| Kuantitas | Maksimal 3 desimal, satu satuan dasar per SKU | Mendukung kg/liter; konversi satuan belum masuk MVP |
| Varian | Setiap varian yang dijual memiliki SKU sendiri | Sederhana untuk stok, harga, dan histori |
| HPP | Biaya standar per SKU/cabang dengan versi dan snapshot | Laba merupakan estimasi; belum FIFO atau rata-rata tertimbang |
| Pajak/layanan | Dinonaktifkan secara default; tarif dapat dikonfigurasi | Tidak mengasumsikan pajak tertentu berlaku untuk semua usaha |
| Offline | Tunai saja, maksimum 24 jam dan tidak melewati paid-through | Refund, master data, cashflow manual, dan perubahan akses memerlukan online |
| Stok negatif | Penjualan offline sah tetap dicatat, selisih ditandai | Owner meninjau anomali; transaksi tidak hilang |
| Transaksi terlambat | Terima kiriman yang dibuat saat izin valid; karantina yang meragukan | Tidak memberi hak membuat transaksi baru setelah kedaluwarsa |
| Refund | Owner/manajer berizin, online, wajib alasan; parsial didukung | Retur uang dan barang dipisahkan |
| Trial/perangkat | Trial nonaktif di pilot; batas perangkat configurable, belum ditentukan | Tidak mengunci angka komersial yang belum disetujui |
| Rilis | Pengembangan Android/iOS sejak awal, pilot Android lebih dulu | Build dan pengujian iOS tetap berjalan selama pengembangan |

## 3. Arsitektur dan batas tanggung jawab

```mermaid
flowchart TD
    UI[Flutter Android dan iOS] --&gt; REPO[Repository dan aturan lokal]
    REPO --&gt; LOCAL[SQLite terenkripsi dan antrean kirim]
    REPO --&gt; API[NestJS REST API]
    AUTH[Identity provider] --&gt; API
    API --&gt; PG[(PostgreSQL)]
    API --&gt; ENT[Penandatangan entitlement]
    PG --&gt; OUT[Outbox dispatcher]
    OUT --&gt; Q[Redis dan BullMQ]
    Q --&gt; WORK[Worker laporan dan integrasi]
    WORK --&gt; PG
    WORK --&gt; OBJ[Object storage privat]
    WORK --&gt; EMAIL[Email transaksional]
    BILL[Billing provider atau app store] --&gt; API
```

Panah menunjukkan aliran logis, bukan semua koneksi jaringan. Dispatcher membaca tabel outbox; database tidak memanggil Redis secara langsung.

| Komponen | Pilihan dan alasan | Batas tanggung jawab |
|---|---|---|
| Mobile | Flutter; pola UI → view model → repository | UI tidak menulis langsung ke API/database |
| Penyimpanan mobile | SQLite dengan engine enkripsi yang dibuktikan pada Android/iOS | Transaksi lokal, antrean, katalog terbatas; kunci di Keystore/Keychain |
| Backend | NestJS modular monolith, REST ber-versi | Seluruh otorisasi, perhitungan final, billing, dan komit data |
| Akses data | Driver PostgreSQL/SQL terparameterisasi; migrasi SQL versioned | Transaksi dan lock eksplisit untuk domain uang/stok |
| Database | PostgreSQL managed, private network | Sumber kebenaran cloud; ledger dan batas unik permanen |
| Queue | Redis + BullMQ, worker proses terpisah | Penjadwalan dan retry; data penting tetap di PostgreSQL |
| Autentikasi | Provider OIDC terkelola melalui adapter | Email terverifikasi, MFA, sesi; vendor dipilih setelah spike biaya/SDK |
| File/email | S3-compatible privat dan SES atau setara | File laporan, pengiriman, status bounce; bukan database transaksi |
| Observability | Log terstruktur, metrics, trace | ID korelasi; hindari token, isi nota, dan PII dalam log |

Dokumentasi Flutter mendukung repository yang menyatukan penyimpanan lokal dan remote. Background task juga harus mempertimbangkan batas perangkat; aplikasi tidak boleh menjanjikan sinkronisasi langsung ketika ditutup. [Flutter offline-first](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)

NestJS menyediakan integrasi BullMQ. Pilihan worker di proses terpisah adalah keputusan rancangan ini agar ekspor tidak menghabiskan sumber daya API kasir. [NestJS queues](https://docs.nestjs.com/techniques/queues)

Versi dependency dipilih dari rilis stabil yang masih didukung saat kickoff, lalu dikunci melalui lockfile dan CI. Tidak perlu mengambil versi beta untuk memenuhi PRD. Kandidat library enkripsi wajib diuji untuk migrasi, recovery, lisensi, dan platform sebelum dipilih.

### Modul backend

| Modul | Pemilik data dan layanan |
|---|---|
| Identity &amp; Access | User lokal, membership, assignment cabang, perangkat, izin |
| Business | Tenant, cabang, preferensi, status penonaktifan |
| Catalog | Produk, SKU, kategori, versi harga/HPP/pajak |
| Sales | Penjualan, item, pencatatan pembayaran, refund |
| Inventory | Saldo dan ledger pergerakan stok |
| Finance | Akun uang, pemasukan/pengeluaran, klasifikasi dan saldo |
| Subscription | Invoice, event billing, paid-through, kapasitas cabang, entitlement |
| Sync | Inbox transaksi perangkat, upload, delta, konflik |
| Reporting | Agregat, job ekspor, manifest file, jadwal email |
| Audit &amp; Operations | Audit, outbox, rekonsiliasi, health, alat dukungan internal |

Modul memanggil layanan domain modul lain melalui interface. Komit penjualan, pembayaran tunai, stok, cash ledger, audit, dan outbox menggunakan satu transaksi PostgreSQL. Tidak memisahkan modul tersebut menjadi microservice pada MVP.

### Struktur repositori yang diusulkan

```text
apps/mobile/                Flutter, fitur dan repository lokal
apps/api/                   NestJS HTTP dan modul domain
apps/worker/                Entrypoint worker; memakai domain backend
packages/contracts/         OpenAPI, contoh payload, fixture lintas platform
packages/backend-domain/    Layanan dan aturan bersama API/worker
database/migrations/        SQL terurut dan rollback/forward-fix
infra/                      Infrastruktur sebagai kode, container, CI
tests/integration/          PostgreSQL/queue/integrasi nyata
tests/e2e/                  Alur mobile dan API
docs/adr/                   Catatan keputusan arsitektur
```

## 4. Aturan transaksi dan keuangan

### Penjualan

Satu SKU barang dapat memiliki stok; jasa tidak wajib memiliki stok. Nota menyimpan snapshot nama, SKU, unit, harga, diskon, pajak, layanan, dan HPP saat transaksi. Perubahan katalog tidak mengubah nota lama.

Nominal uang tidak menggunakan floating point. Di API, integer Rupiah dikirim sebagai string; kuantitas sebagai string desimal. Backend menghitung ulang berdasarkan versi harga yang disahkan server. Diskon manual hanya diterima jika izin dan batasnya valid.

Usulan kalkulasi MVP: bruto baris = pembulatan half-up(kuantitas × harga), lalu diskon baris, lalu alokasi diskon nota proporsional dengan sisa pembulatan dibagikan menurut urutan ID baris. Pajak eksklusif dihitung atas basis setelah diskon; biaya layanan dihitung terpisah atas basis tersebut, tidak dikenakan pajak lagi pada konfigurasi awal. Semua nilai nonnegatif, diskon tidak melebihi basisnya. Formula ini merupakan usulan produk dan perlu ditinjau terhadap kebutuhan usaha sebelum diaktifkan.

Untuk tunai, nilai pembayaran yang dicatat sebagai pemasukan adalah total nota; uang diterima dan kembalian adalah atribut terpisah. Nota Rp38.000 dibayar Rp50.000 menghasilkan pemasukan Rp38.000 dan kembalian Rp12.000.

### Refund dan pembatalan

Draft dapat dibatalkan tanpa ledger. Penjualan selesai tidak dihapus atau ditulis ulang; refund adalah dokumen baru yang merujuk item asal. Lock transaksi asal memastikan jumlah dan nominal refund kumulatif tidak melebihi penjualan. Retur stok hanya untuk kuantitas barang yang benar-benar dikembalikan dan layak masuk stok. Refund jasa tidak menciptakan stok.

MVP mensyaratkan refund online. Setelah langganan kedaluwarsa, refund operasional juga diblokir menurut usulan awal; dukungan pemulihan/penyelesaian kewajiban pelanggan perlu kebijakan tersendiri sebelum rilis. Ini tidak menghapus hak owner membaca/mengekspor histori.

### Cashflow dan laba

Pisahkan akun kas, bank, dan clearing pembayaran. Penjualan tunai masuk kas; transfer yang telah dikonfirmasi masuk bank; QRIS yang belum settlement masuk clearing. Pindah clearing → bank adalah transfer internal, bukan pendapatan baru. Rekonsiliasi settlement manual tersedia untuk pembayaran eksternal pada MVP.

Catatan finance memakai tipe: pendapatan penjualan, pendapatan lain, biaya operasional, pembelian persediaan, modal, penarikan pemilik, transfer internal, refund, dan saldo awal. Perubahan catatan yang sudah posted dilakukan dengan reversal dan catatan pengganti.

Penjualan bersih = bruto − diskon − retur (di luar pajak yang dipungut). Estimasi laba kotor = penjualan bersih − HPP neto. Estimasi laba operasional memperhitungkan pendapatan layanan yang relevan dan biaya operasional; pembelian stok tidak otomatis menjadi biaya laba pada tanggal pembelian. Metode biaya standar membuat hasil ini estimasi manajemen. Jika HPP belum diisi, tampilkan cakupan HPP dan tandai laba belum lengkap; jangan menganggap HPP kosong sebagai nol.

## 5. Pembayaran dan langganan

Pisahkan dua domain: pembayaran barang/jasa pelanggan toko dan pembelian hak menggunakan aplikasi SaaS. Aturan billing toko aplikasi untuk langganan digital tidak dapat disimpulkan dari dukungan QRIS pada transaksi toko. Kebijakan Apple memiliki kategori dan pengecualian tersendiri; Google juga membedakan pembelian digital dari barang/jasa fisik. Pilihan kanal SaaS wajib diverifikasi terhadap model distribusi dan storefront Indonesia sebelum tombol checkout dibuat. [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), [Google Play Payments](https://support.google.com/googleplay/android-developer/answer/9858738)

Usulan desain: `BillingAdapter` menerjemahkan event provider menjadi keadaan langganan internal. Sistem internal menghitung akses dari paid-through terverifikasi dan pembatasan administratif. Nilai dari callback UI tidak pernah mengaktifkan akses.

- Harga dasar PRD: 300.000 + (cabang − 1) × 150.000 Rupiah/bulan; minimal satu slot.
- Paket menyimpan versi harga; invoice menyimpan snapshot pajak, biaya, periode, dan jumlah slot.
- Upgrade: quote dari server dengan masa berlaku → bayar → verifikasi → tambah slot → aktifkan cabang secara atomik.
- Usulan prorata kanal yang mendukung: round-half-up(150.000 × slot tambahan × detik tersisa / detik periode). Contoh 15 hari tersisa dari periode 30 hari = Rp75.000 per slot tambahan, sebelum komponen lain.
- Untuk toko aplikasi, perubahan paket mengikuti kemampuan dan aturan providernya; rumus internal tidak dipaksakan menggantikan aturan provider. Kelayakan jumlah cabang dinamis perlu spike khusus.
- Downgrade dijadwalkan untuk periode berikutnya dan menyebut cabang yang akan dinonaktifkan. Cabang berhenti menerima transaksi baru pada waktu efektif; upload transaksi sah sebelumnya tetap bisa diselesaikan.
- `cancel_at_period_end` tidak mencabut masa aktif yang sudah dibayar. `past_due` tetap aktif sampai paid-through; tanpa grace tambahan.
- Pending/reversal/refund billing tidak menghapus histori. Pembatalan hak akibat refund/chargeback mengikuti kebijakan eksplisit dan dicatat.

Webhook diverifikasi memakai mekanisme resmi provider, diberi batas unik event, lalu disimpan sebelum di-ACK. Worker merekonsiliasi event yang datang ulang/terbalik dengan status resmi provider; jangan menambah satu bulan setiap webhook diterima. Gunakan periode layanan/provider transaction yang unik. Rekonsiliasi terjadwal menangani webhook yang hilang.

## 6. Keamanan dan akses

Setiap request mengautentikasi user, memvalidasi membership tenant, memeriksa assignment cabang dan permission, kemudian memeriksa entitlement untuk operasi yang memerlukannya. Path tenant/branch adalah input, bukan bukti akses. Kasir tidak menerima HPP, margin, atau data finance melalui response maupun cache lokal.

Gunakan PostgreSQL RLS sebagai lapisan tambahan: context tenant/actor disetel pada transaksi koneksi setelah validasi server, bukan dari nilai client tanpa pemeriksaan. Role API bukan owner tabel dan tidak memiliki `BYPASSRLS`. RLS tidak menggantikan pemeriksaan permission aplikasi. [PostgreSQL row security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)

Owner memakai MFA untuk perubahan akun, billing, dan hak akses sensitif. Undangan staf memakai token sekali pakai, kedaluwarsa, dan email terverifikasi. Manajer hanya dapat menugaskan kasir dalam cabangnya jika diberi izin; tidak dapat menaikkan role menjadi owner atau memperluas scope sendiri. Owner terakhir tidak dapat dinonaktifkan tanpa pemindahan kepemilikan.

Database mobile dipisahkan per tenant/user. Perangkat memiliki key pair dan identitas instalasi; reinstall membuat instalasi baru. Jangan menyimpan password offline. Sesi offline menggunakan izin server yang masih valid dan unlock lokal. Logout dengan transaksi pending harus mempertahankan antrean secara terenkripsi dan menyediakan alur pemulihan, tanpa membuka data bagi user berikutnya.

Hapus cache yang tidak lagi diizinkan setelah revokasi terdeteksi; upload terlambat dari staf yang dicabut aksesnya masuk jalur pemulihan owner. Jangan membuang bukti transaksi. Batas offline 24 jam membatasi keterlambatan revokasi, tetapi tidak menjamin ketahanan terhadap perangkat yang sepenuhnya dikompromikan.

## 7. Laporan, skala, dan operasi

Laporan bulanan mulai tanggal 1 pukul 05.00 di zona bisnis, dengan rentang setengah terbuka `[awal bulan, awal bulan berikutnya)`. Job menyimpan zona, periode UTC, revision, serta cutoff data. Data offline yang datang setelah cutoff memicu pemberitahuan dan revisi laporan, bukan perubahan diam-diam pada file lama.

PDF berisi ringkasan. XLSX/CSV diekspor worker secara streaming ke object storage, disertai checksum, jumlah baris, versi, dan status final. Batas 1.048.575 baris data per sheet mengikuti PRD; uji pemecahan pada batas ini. CSV melindungi sel teks yang dapat ditafsirkan sebagai formula spreadsheet. Batasi concurrency per tenant dan global agar ekspor tidak menghambat kasir.

Email hanya ke alamat yang sudah diverifikasi. Usulan tautan email tujuh hari membuka halaman yang memerlukan login owner, kemudian menerbitkan URL unduh berumur pendek setelah otorisasi ulang. File tetap privat. Deduplikasi job/report dan delivery record mengurangi email ganda; hasil pengiriman yang ambigu harus direkonsiliasi dengan provider, bukan diklaim pasti exactly-once.

Satu juta transaksi per 30 hari rata-rata sekitar 0,39 transaksi/detik; jumlah bulanan tidak menjelaskan burst, jumlah item, tenant bersamaan, atau beban ekspor. Uji awal diusulkan 50 transaksi/detik selama 30 menit dan burst 200/detik selama 5 menit pada dataset 1 juta sales + 5 juta items, disertai sync/retry dan ekspor. Ini profil validasi awal, bukan janji kapasitas.

Awali dengan tabel terindeks dan agregat harian. Partitioning bulanan baru diterapkan setelah benchmark menunjukkan manfaat. Unique key pada tabel PostgreSQL terpartisi harus mencakup partition key, sehingga partisi penjualan berdasarkan waktu memerlukan desain ulang constraint; registry identitas transaksi yang tidak dipartisi menjaga deduplikasi lintas periode. [PostgreSQL partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html)

### Infrastruktur awal

- Dev lokal: database, Redis, object storage, email sink; tidak memakai data pelanggan produksi.
- Staging: topologi menyerupai produksi, sandbox pembayaran, test tenant.
- Produksi: API redundant di belakang load balancer, PostgreSQL managed dengan failover/PITR, Redis managed, worker terpisah, storage terenkripsi. Ukuran instance ditentukan benchmark dan anggaran.
- CI: format/lint, unit domain, integration PostgreSQL, kontrak API, isolasi tenant, build Android/iOS, migrasi pada salinan staging. Runner macOS diperlukan untuk pipeline iOS.
- Rilis: migrasi expand-contract yang kompatibel dengan aplikasi versi lama; rollout bertahap, fitur dapat dinonaktifkan, rollback API tidak menghapus transaksi.
- Backup: PITR dan backup terenkripsi; latihan restore ke lingkungan terisolasi. RPO ≤15 menit dan RTO ≤4 jam adalah target yang harus diukur.

Alert prioritas: kegagalan checkout, umur antrean sync, outbox tertunda, webhook tidak terproses, lag agregat, ekspor gagal, email bounce, kapasitas disk/WAL, dan anomali akses lintas tenant. Runbook harus menjelaskan pemulihan, owner operasional, serta kapan menghentikan fitur yang bermasalah.

Biaya dihitung sebagai fixed platform + storage/index/WAL/backup + komputasi transaksi + ekspor/egress + email + auth + biaya pembayaran/store. Ukur biaya per tenant aktif dan per 1.000 transaksi saat pilot. Belum ada dasar untuk menyatakan harga Rp300.000 sudah menutup seluruh biaya.

## 8. Batas keputusan sebelum implementasi final

Arsitektur inti dapat mulai dibangun setelah review kontrak dan spike offline. Kanal billing/store, pajak/harga akhir, retensi setelah berhenti, aturan transaksi terlambat, batas perangkat, dan toleransi stok negatif merupakan keputusan produk yang belum final. Backlog mencantumkan gate agar keputusan tersebut tidak tersembunyi dalam implementasi.

Referensi teknis diakses pada 14 Oktober 2026. Rekomendasi desain di luar pernyataan dokumentasi resmi merupakan usulan engineering untuk PRD ini.
