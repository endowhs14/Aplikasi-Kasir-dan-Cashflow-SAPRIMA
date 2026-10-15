# Backlog pengembangan dan rencana validasi

Tanggal: 14 Oktober 2026 · Versi 0.1 · Dasar: PRD pengguna dan [rencana teknis](01-rencana-teknis.md).

Urutan ini mempertahankan seluruh modul P0. Estimasi merupakan perkiraan perencanaan, bukan janji tanggal rilis. Implementasi belum dimulai dan pengujian berikut belum dijalankan.

## 1. Tim dan rentang waktu

Asumsi kapasitas: 2 engineer Flutter, 2 engineer backend, 1 QA; product/designer dan DevOps/security tersedia paruh waktu. Sprint dua minggu. Perkiraan MVP sampai pilot: 16–20 minggu; hardening dan persiapan rilis tambahan 4–6 minggu. Antrean review toko aplikasi dan keputusan komersial dapat memperpanjangnya.

Rentang 20–26 minggu bergantung pada spike enkripsi/offline, kanal billing, pengalaman tim, serta hasil pilot. Tidak termasuk seluruh fitur P1. Jika tim lebih kecil, jadwal harus dihitung ulang; jangan mengurangi pengujian uang, tenant, atau sinkronisasi agar sesuai tanggal.

| Tahap | Rentang indikatif | Hasil yang dapat didemokan | Gate |
|---|---|---|---|
| Discovery teknis | Minggu 1–2 | Lease offline, SQLite terenkripsi, draft kontrak dan billing decision | G0 |
| Fondasi | Minggu 3–4 | Login, bisnis, cabang, assignment, tenant isolation | G1 |
| Kasir inti | Minggu 5–6 | Katalog → tunai → nota → stock movement → histori | G2 |
| Offline dan refund | Minggu 7–10 | Restart/retry aman, konflik stok, refund parsial | G3 |
| Billing dan finance | Minggu 9–12, sebagian paralel | Entitlement dari provider sandbox, cashflow dan laba | G4 |
| Laporan dan ekspor | Minggu 13–16 | PDF/XLSX/CSV, email bulanan, laporan multi-cabang | G5 |
| Pilot | Minggu 17–20 | Pemakaian UMKM, telemetri, temuan dan perbaikan | G6 |
| Hardening/rilis | Tambahan 4–6 minggu | Recovery drill, release candidate, store submission | G7 |

Paralel di sini menjelaskan pembagian kerja tim pengembangan yang direncanakan, bukan pekerjaan agent yang telah dijalankan.

## 2. Backlog terurut

Ukuran relatif: S = satu pekerjaan kecil, M = beberapa hari engineering, L = perlu dipecah menjadi beberapa task. Ukuran belum menjadi estimasi kalender. Semua baris merupakan P0 atau prasyarat P0, kecuali yang ditandai perlu keputusan scope.

| ID | Pekerjaan dan keluaran | Dependensi | Ukuran / penanggung jawab | Acceptance utama |
|---|---|---|---|---|
| DISC-01 | ADR: offline, harga, HPP, pajak, refund, late upload | — | M / Product + Tech lead | Keputusan dan asumsi terbuka tercatat; tidak ada aturan uang tersembunyi |
| SPIKE-01 | Enkripsi SQLite Android/iOS, key storage, migrasi, crash/restart | — | L / Mobile | Database tidak terbaca tanpa key; pending sale pulih setelah force stop; hasil di perangkat nyata |
| SPIKE-02 | Anchor waktu, signed lease, signature payload Dart/TS | DISC-01 | L / Mobile + Backend | Fixture sama; rollback jam/reboot tidak memperpanjang hak offline |
| PAY-01 | Tentukan kanal subscription dan scope gateway POS | — | L / Product + Backend | Memo kebijakan storefront, katalog paket, prorata, recurring, cancel, dan sandbox disetujui |
| INF-01 | Repo, CI Android/iOS, environments, secret store, local services | — | M / Platform | Build bersih; secrets tidak masuk repo/log; staging terpisah |
| API-01 | OpenAPI lengkap, error codes, DTO, fixture, compatibility policy | DISC-01 | M / Backend | Client generation/contract check lulus; respons kasir tidak berisi HPP |
| DB-01 | Migrasi schema, composite FK, indeks, RLS, seed test | DISC-01 + INF-01 | L / Backend | Invalid tenant/branch FK ditolak; migrasi dicoba pada DB kosong dan versi sebelumnya |
| AUTH-01 | Signup, email verification, login/reset, refresh/revoke, MFA | INF-01 + API-01 | L / Backend + Mobile | Alur akun bekerja; verifikasi UI saja tidak cukup untuk aktivasi |
| TEN-01 | Business onboarding, cabang, status pending/draining/inactive | DB-01 + AUTH-01 | M / Full team | Cabang dan histori tetap terikat tenant; cabang baru mematuhi kapasitas |
| IAM-01 | Role/permission, invitation, branch assignment, DTO scope | TEN-01 | L / Backend + Mobile | Kasir ditolak dari finance; manajer tidak memperluas scope sendiri |
| ENT-01 | Evaluator paid-through dan lease signer | IAM-01 + SPIKE-02 | L / Backend | Expired menolak operasi baru; read/export historis tetap diizinkan |
| CAT-01 | Produk/jasa, kategori, SKU/varian, harga/HPP per cabang | IAM-01 + DB-01 | L / Full team | Harga versioned; jasa tanpa stok; arsip tidak merusak histori |
| INV-01 | Stock ledger, saldo, opening/replenish/adjust/count, audit | CAT-01 | L / Backend + Mobile | Total ledger = saldo; count stale tidak menimpa saldo baru |
| POS-01 | Keranjang, diskon/pajak, pembayaran tercatat, nota digital | CAT-01 + ENT-01 | L / Mobile + Backend | Rumus dan pembulatan lintas platform sama; tunai dan manual non-tunai jelas |
| POS-02 | Posting atomik, registry sale, idempotency, audit/outbox | POS-01 + INV-01 | L / Backend | Retry/crash tidak menduplikasi sale, stock movement, payment, cash entry |
| SYN-01 | Local database, snapshot/bootstrap, outbox, status UI | SPIKE-01 + POS-01 | L / Mobile | Tunai disimpan atomik; restart tidak kehilangan antrean |
| SYN-02 | Push/pull, feed/cursor, replay, backoff, watermark | POS-02 + SYN-01 | L / Backend + Mobile | Upload ulang, cursor reset, dan putus koneksi tidak menghilangkan perubahan |
| SYN-03 | Karantina, late upload, device revocation, branch draining | SYN-02 + ENT-01 | L / Full team | Bukti terjaga; resolusi diaudit; tidak mengaktifkan sale baru setelah expired |
| REF-01 | Refund parsial, retur stok selektif, reversal uang | POS-02 + INV-01 | L / Backend + Mobile | Dua refund bersamaan tidak melebihi nilai/qty asal; histori sale tetap ada |
| FIN-01 | Money accounts, pemasukan/pengeluaran, transfer/settlement | POS-02 + REF-01 | L / Full team | Transfer internal dan modal tidak menjadi pendapatan; kas sama dengan ledger |
| BILL-01 | Invoice/quote, checkout provider, webhook inbox, rekonsiliasi | PAY-01 + ENT-01 | L / Backend + Mobile | Callback palsu gagal; event berulang/terbalik tidak memperpanjang dua kali |
| BILL-02 | Upgrade/downgrade/cancel, slot cabang, pengingat | BILL-01 + TEN-01 | L / Full team | 2 cabang Rp450.000 sebelum komponen lain; prorata dan effective date benar |
| DASH-01 | Dashboard per cabang/gabungan, agregat idempotent | FIN-01 + SYN-02 | M / Full team | Filter scope benar; cutoff/lag dan cakupan HPP terlihat |
| REP-01 | Report API, snapshot/manifest, PDF/XLSX/CSV streaming | DASH-01 | L / Backend + Mobile | File sesuai scope, total konsisten; CSV aman dari formula injection |
| REP-02 | Scheduler timezone, monthly report, verified email, retry | REP-01 + AUTH-01 | L / Backend | Satu bundle/revisi per periode; file besar memakai unduhan berotorisasi |
| OPS-01 | Logging/metrics/tracing, alert, audit viewer, runbooks | INF-01; bertahap | L / Platform + Backend | Korelasi insiden bisa ditelusuri tanpa membocorkan PII/secrets |
| SEC-01 | Automated permission matrix dan threat tests | IAM-01, API-01; berulang | L / QA + Backend | UI, API, export, cache, worker, download lolos isolasi tenant/cabang |
| PERF-01 | Beban transaksi/sync/export dan pengukuran perangkat | SYN-03 + REP-02 | L / QA + Platform | Laporan P95/error/resource penggunaan dan rekomendasi kapasitas |
| DR-01 | Backup/PITR, restore drill, queue rebuild, deployment rollback | OPS-01 + POS-02 | M / Platform + QA | RPO/RTO aktual tercatat dan memenuhi target pilot/rilis |
| PILOT-01 | UAT dengan UMKM dan pencocokan buku kas/stok | G5 + SEC-01 | L / Product + QA | Temuan kritis selesai; owner mengonfirmasi laporan mudah dipahami |
| RELEASE-01 | Privacy/retention policy, store assets, signed builds, rollout | G6 + DR-01 + PAY-01 | L / Product + Full team | Gate rilis dipenuhi; monitoring/support aktif |

## 3. Syarat kelulusan setiap tahap

**G0 — keputusan dasar:** SDK enkripsi dan waktu offline terbukti pada kedua OS; kontrak aritmetika uang, identitas tenant, dan strategi billing terdokumentasi. Billing yang belum final boleh memakai sandbox adapter untuk pengembangan, tetapi tidak boleh mengaktifkan pelanggan produksi.

**G1 — identitas aman:** user bisnis A gagal membaca/mengubah bisnis B lewat ID yang ditebak; manajer/kasir hanya pada scope yang ditugaskan; verifikasi email/MFA/sesi teruji.

**G2 — penjualan konsisten:** satu nota menghasilkan stok dan uang yang tepat dalam komit atomik; harga historis tetap; jasa tidak mengurangi stok; nota mudah dibaca dan dibagikan melalui aksi pengguna.

**G3 — offline dapat dipulihkan:** crash sebelum/sesudah komit, respons hilang, duplicate upload, konflik SKU, rollback jam, lease expired, dan staf direvoke memiliki hasil deterministik. UI membedakan tersimpan lokal, terkirim, konflik, dan ditolak.

**G4 — tagihan dan keuangan benar:** event provider valid satu-satunya dasar grant; total dua cabang sesuai PRD; expired tidak menghapus histori; cashflow tidak disamakan dengan laba.

**G5 — laporan dapat diaudit:** hasil PDF dan data detail konsisten untuk cutoff yang sama; export &gt;batas sheet ditangani; laporan per zona waktu dan email terverifikasi berjalan; data offline terlambat menghasilkan revisi yang jelas.

**G6 — pilot selesai:** tidak ada bug kritis kehilangan/duplikasi uang/stok, kebocoran tenant, atau aktivasi palsu; hasil UAT, biaya per tenant, dan dukungan harian terdokumentasi.

**G7 — siap rilis:** target performa pada konfigurasi yang dinyatakan terpenuhi, restore berhasil, kebijakan retensi/billing sudah final, privacy/terms tersedia, proses incident/on-call dan rollback berjalan. Persetujuan store adalah ketergantungan eksternal, bukan hasil otomatis dari lolos test.

## 4. Pemetaan acceptance criteria PRD

| PRD | Backlog | Bukti pengujian |
|---|---|---|
| AC-01 Signup | AUTH-01, BILL-01, ENT-01 | Akun unverified/pembayaran pending ditolak; verified + event sah aktif |
| AC-02 Multi-user | IAM-01, SEC-01 | Kasir gagal akses finance UI/API/download; payload/cache tidak memuat HPP |
| AC-03 Multi-cabang | TEN-01, DASH-01, REP-01 | Total konsolidasi sama dengan jumlah cabang sesuai scope |
| AC-04 Billing | BILL-02 | Quote 2 cabang satu bulan penuh = Rp450.000 sebelum pajak/fee |
| AC-05 Expired | ENT-01, SYN-03 | Boundary expiry menolak sale baru; histori dapat dibaca |
| AC-06 Offline | SYN-01 | Airplane mode + force stop: nota dan antrean tetap ada |
| AC-07 Sinkronisasi | POS-02, SYN-02 | Replay 100 kali menghasilkan satu sale dan satu set ledger |
| AC-08 Stok | INV-01, POS-02 | Setiap item barang menghasilkan movement bersumber sale item |
| AC-09 Refund | REF-01, FIN-01 | Refund parsial/full, jasa, barang rusak, dan concurrency benar |
| AC-10 Ekspor manual | REP-01 | PDF/XLSX/CSV dapat dibuka dan jumlahnya cocok dengan fixture |
| AC-11 Ekspor otomatis | REP-02 | Simulasi batas bulan tiga zona Indonesia dan retry email |
| AC-12 Skala besar | REP-01, PERF-01 | 1.048.575 dan 1.048.576 baris data: tidak terpotong; memori terkendali |
| AC-13 Isolasi tenant | DB-01, SEC-01 | IDOR, FK lintas tenant, cache, job, presigned download gagal lintas scope |
| AC-14 Payment | BILL-01, SEC-01 | Callback UI palsu, signature invalid, replay webhook tidak mengaktifkan akses |
| AC-15 Retention | ENT-01, RELEASE-01 | Expiry tidak menghapus sales; owner dapat mengambil histori |

## 5. Rencana pengujian NFR

| Target PRD | Metode validasi | Catatan |
|---|---|---|
| Availability ≥99,9%/bulan | SLI request sukses pada endpoint inti dan synthetic probe | Target operasional, tidak dapat dibuktikan hanya oleh load test satu hari |
| API transaksi P95 &lt;2 detik | Ukur di load generator hingga response committed, di profil jaringan tercatat | Pisahkan waktu menunggu penyedia pembayaran eksternal |
| Offline P95 &lt;1 detik | Ukur tap simpan → commit lokal dan nota siap | Gunakan Android kelas menengah serta iPhone tertua yang ditargetkan |
| Sync otomatis | Putus-sambung, captive portal, app resume, antrean 1.000 operasi/device | Target usulan drain setelah koneksi sehat; background OS tidak dijamin seketika |
| Tidak ada duplikasi retry | Fault injection pada sebelum/sesudah komit dan ACK | Verifikasi semua ledger, bukan hanya jumlah sale |
| ≥1 juta transaksi/bulan tenant besar | Dataset 1 juta sale × rata-rata 5 item, termasuk refund dan indeks | Dataset ukuran ini berbeda dari throughput bulanan |
| Profil beban awal | 50 sale/detik 30 menit; burst 200/detik 5 menit; 10% retry | Minimal satu tenant besar + tenant kecil untuk fairness; kalibrasi sesudah pilot |
| Ekspor besar | Dua job ekspor bersamaan dengan transaksi/sync; ukur RSS, DB I/O, durasi | Uji XLSX melewati batas dan CSV ZIP; concurrency configurable |
| RPO 15 menit/RTO 4 jam | Restore dari titik sebelum insiden dan ukur data terakhir pulih | Redis hilang harus bisa dibangun ulang dari PostgreSQL/outbox |
| Laporan ≤24 jam setelah penutupan | Simulasi scheduler, backlog, email gagal, upload terlambat | Pengiriman ke provider dan delivery/bounce dilaporkan terpisah |
| Isolasi tenant otomatis | Matriks role × tenant × cabang × endpoint/worker | Termasuk koneksi DB pool dipakai bergantian agar context tidak bocor |

Profil hardware, region, konfigurasi database, jumlah koneksi, versi build, dataset, dan biaya uji dicatat bersama hasil. Jangan memasarkan target sebagai capaian sebelum bukti tersedia.

## 6. Definisi selesai untuk satu fitur

Fitur dianggap selesai ketika acceptance bisnis terpenuhi, batas API/permission jelas, migrasi aman untuk upgrade, skenario error terlihat di UI, telemetri relevan tersedia, dan dokumentasi dukungan diperbarui. Pengujian dipilih berdasarkan risiko: unit untuk kalkulasi, integration untuk uang/tenant/stok, end-to-end untuk alur pengguna utama. Tidak perlu menambah test yang hanya meniru implementasi tanpa memeriksa perilaku penting.

Critical fixtures: pembulatan jumlah pecahan, diskon nota lintas item, refund terakhir dengan sisa pembulatan, HPP kosong, pergantian bulan/tahun/zona, hari periode langganan berbeda, dua perangkat offline, dan dua request idempotency bersamaan.

## 7. Register keputusan produk

| ID | Pertanyaan | Usulan sementara | Harus selesai sebelum |
|---|---|---|---|
| D01 | Nama dan identitas produk | Placeholder internal, belum dipublikasikan | UI final/store assets |
| D02 | Harga termasuk pajak/fee/store commission? | Simpan komponen terpisah; jangan tampilkan total final tanpa aturan | PAY-01/BILL-01 produksi |
| D03 | Batas perangkat dan user? | Configurable; angka belum ditetapkan | Pilot komersial |
| D04 | Trial gratis? | Nonaktif untuk alur awal | Onboarding komersial |
| D05 | Kanal langganan Android/iOS? | Billing adapter, keputusan per storefront | Implementasi checkout final |
| D06 | Printer/barcode masuk MVP? | Tetap P1 sesuai PRD | Scope freeze |
| D07 | Retensi setelah berhenti dan proses hapus akun? | Expired tidak menghapus data; periode retensi belum ditetapkan | Privacy/terms dan produksi |
| D08 | Late upload sesudah expired/revoked? | Terima bukti valid, karantina ambigu, pemulihan owner | SYN-03 |
| D09 | Stok negatif offline? | Catat + flag; online dapat menolak sesuai kebijakan | INV-01/SYN-03 |
| D10 | Android/iOS serentak? | Pilot Android dulu, iOS terus diuji | Jadwal pilot |
| D11 | Metode HPP? | Standard cost versioned; laba estimasi | FIN-01 dan label laporan |
| D12 | Pembayaran POS otomatis atau pencatatan? | Manual non-tunai terkonfirmasi operator; gateway POS terpisah | POS-01/PAY-01 |
| D13 | Formula pajak/layanan dan refund? | Tarif default nol; formula dalam rencana teknis | POS-01 |
| D14 | Refund setelah subscription expired? | Diblokir untuk operasi biasa; kebijakan penyelesaian melalui dukungan belum final | Pilot berbayar |
| D15 | Pilihan cloud/auth/email dan anggaran? | Managed service dengan adapter; putuskan setelah estimasi | Infrastruktur produksi |

D08/D09/D11/D12/D13 merupakan usulan perilaku yang dibuat untuk memperjelas implementasi, bukan keputusan baru yang telah disetujui pengguna. Pertanyaan yang tidak memengaruhi fondasi dapat ditunda sampai gate terkait.

## 8. P1 setelah pilot

Printer Bluetooth dan barcode mengikuti bukti kebutuhan pilot. Supplier/pembelian dan costing yang lebih canggih harus dikembangkan bersama aturan valuasi persediaan. Transfer stok antar-cabang membutuhkan ledger keluar/masuk dan status in-transit. Integrasi akuntansi, bahan baku/resep, piutang, Sheets, stok minimum, serta analitik lanjutan tidak dimasukkan diam-diam ke backlog P0.

## 9. Langkah pembangunan pertama

Sprint pertama menghasilkan spike Android/iOS, ADR offline/billing, model data yang ditinjau, kontrak penjualan, skeleton CI, dan demo commit lokal yang tahan restart. Setelah G0, implementasikan AUTH-01, DB-01, IAM-01, lalu satu alur penjualan lengkap sebelum memperluas seluruh layar.
