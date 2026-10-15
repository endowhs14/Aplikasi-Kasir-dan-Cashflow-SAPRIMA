# Kontrak API dan sinkronisasi

Tanggal: 14 Oktober 2026 · Versi 0.1 · Rancangan kontrak untuk MVP.

Dokumen ini mendefinisikan kontrak awal dan contoh alur kritis. OpenAPI lengkap, generator client, validasi semua DTO, dan adapter provider menjadi keluaran backlog API-01; belum ada server yang diimplementasikan.

## 1. Konvensi

Base path `/v1`. Endpoint bisnis berawalan `/v1/tenants/{tenantId}` (disingkat `T` pada tabel). Semua request melalui TLS. Header `Authorization: Bearer …` harus diverifikasi issuer, audience, signature, expiry, dan revokasi yang relevan. Mutasi menerima `Idempotency-Key`; master-data update juga memakai `If-Match`/version.

Nominal IDR sebagai string integer, kuantitas string decimal maksimal tiga angka di belakang koma, waktu RFC 3339 UTC, tanggal bisnis `YYYY-MM-DD`. Input timezone menggunakan nama IANA. Parameter rentang tanggal selalu `from` inklusif dan `to` eksklusif.

Endpoint list memakai opaque cursor dan limit default 50, maksimum 200. Endpoint sync maksimum usulan 100 operasi/1 MB per batch dan 200 item delta per halaman; angka ini harus dikonfirmasi melalui benchmark perangkat.

Server mengambil actor, role, dan scope dari sesi tervalidasi. Tidak mempercayai `actor_id`, `tenant_id`, status lunas, nominal invoice, atau permission dari body. ID perangkat harus terikat pada sesi; perangkat bukan pengganti autentikasi user.

Status umum: `200` sukses/read/replay, `201` resource baru, `202` job diterima, `400` format salah, `401` perlu autentikasi, `403` tidak berizin/entitlement, `404` resource di luar scope atau tidak ada, `409` konflik state/hash/version, `422` validasi bisnis, `429` rate limit dengan Retry-After, `503` sementara tidak tersedia. Keberadaan resource tenant lain tidak boleh bocor melalui error.

```json
{
  "error": {
    "code": "ENTITLEMENT_EXPIRED",
    "message": "Langganan telah berakhir. Perpanjang untuk membuat transaksi baru.",
    "retryable": false,
    "request_id": "req_example_01",
    "details": {"paid_through": "2026-10-14T17:00:00Z"}
  }
}
```

API membuat penentuan akses dari waktu server, bukan jam perangkat. `GET` histori dan ekspor owner yang masih terautentikasi tetap tersedia ketika subscription expired, sesuai PRD dan kebijakan retensi yang kelak ditetapkan.

## 2. Endpoint P0

O = owner, M = manajer dalam scope cabang/izin, K = kasir dalam scope cabang/izin. Tabel adalah kebijakan minimum; default deny untuk aksi yang tidak diberikan.

### Akun dan bisnis

| Metode dan path | Akses | Kontrak utama |
|---|---|---|
| POST `/auth/signup` | Publik, rate-limited | nama/email/password via identity adapter; kirim verifikasi |
| POST `/auth/login`, `/auth/refresh`, `/auth/logout` | Sesuai sesi | Rotasi sesi; logout merevokasi sesi online |
| POST `/auth/email-verification/request`, `/auth/email-verification/confirm` | Sesi/token | Token sekali pakai; tidak membocorkan status akun |
| POST `/auth/password-reset/request`, `/auth/password-reset/confirm` | Publik/token | Respons generik; sesi lama dicabut sesuai kebijakan |
| POST `/auth/mfa/challenges`, `/auth/mfa/verify` | Sesi | Step-up untuk aksi sensitif; proof berumur pendek dan terikat aksi |
| GET `/me`, `/me/memberships` | User | Identitas dan daftar bisnis yang diizinkan |
| POST `/tenants` | User email terverifikasi | name, industry, timezone, currency; buat owner + bisnis pending |
| GET/PATCH `T` | O; read terbatas M/K | Profil; update dengan version |
| GET/POST `T/branches` | Read sesuai scope; create O | Membuat cabang pending bila slot belum tersedia |
| PATCH `T/branches/{id}` | O | Metadata/version; tidak mengganti tenant |
| POST `T/branches/{id}/deactivation` | O + MFA | Jadwal draining, status antrean, audit |
| GET/POST `T/staff/invitations` | O, M dengan izin terbatas | email, role, branch_ids; undangan bukan akses otomatis |
| POST `/staff/invitations/accept` | User terverifikasi | Token dan kecocokan email |
| GET/PATCH `T/memberships/{id}` | O; M terbatas | Role/assignment/status; cegah eskalasi dan owner terakhir hilang |
| POST `T/devices`, POST `T/devices/{id}/revoke` | Sesi terizin; revoke O | Daftar public key/instalasi; revoke diaudit |
| POST `T/report-recipient/verification`, `/confirmation` | O + step-up | Penerima lama aktif sampai alamat baru terverifikasi |

Browser system/SDK identity provider dapat menangani login/MFA; path di atas adalah kontrak logis adapter aplikasi. Pilihan flow final tidak boleh membuat mobile menyimpan client secret.

### Katalog, inventori, dan kasir

| Metode dan path | Akses | Kontrak utama |
|---|---|---|
| GET/POST `T/categories`, PATCH `T/categories/{id}` | Read O/M/K; write O/M atau K berizin | Kategori versioned |
| GET/POST `T/products`, PATCH `T/products/{id}` | Read O/M/K; write sesuai izin | Produk barang/jasa; archive melalui PATCH |
| GET/POST `T/products/{id}/skus`, PATCH `T/skus/{id}` | Sesuai katalog | SKU dan varian; kode unik |
| GET/PUT `T/branches/{id}/offers/{skuId}` | Read sesuai scope; write O/M | Harga/ketersediaan; perubahan membuat versi baru |
| PUT `T/branches/{id}/costs/{skuId}` | O/M dengan cost.write | HPP standar; tidak masuk DTO kasir |
| GET `T/branches/{id}/inventory`, `/stock-movements` | O/M atau K berizin | Stok, watermark, histori paginated |
| POST `T/branches/{id}/stock-adjustments` | O/M atau K berizin | Delta atau hasil count + expected_version; alasan wajib |
| POST `T/branches/{id}/sales` | O/M/K + akses aktif | Jalur online; handler domain sama dengan sync |
| GET `T/branches/{id}/sales` | O/M; K histori sendiri sesuai izin | Cursor, rentang waktu; field finance dibatasi |
| GET `T/branches/{id}/sales/{saleId}` | Sesuai scope | Detail immutable, pembayaran, refund, status sinkron |
| GET `T/branches/{id}/sales/{saleId}/receipt` | Sesuai scope | Nota tanpa HPP; berbagi melalui aksi user |
| POST `T/branches/{id}/sales/{saleId}/refunds` | O/M + refund.write | item asal, qty, restock_qty, alasan, metode pengembalian |

### Keuangan, subscription, dan laporan

| Metode dan path | Akses | Kontrak utama |
|---|---|---|
| GET/POST `T/branches/{id}/money-accounts` | O/M sesuai izin | Akun kas/bank/clearing dan saldo awal |
| GET/POST `T/branches/{id}/cash-entries` | O/M | Kategori, nominal, akun, waktu, keterangan |
| POST `T/branches/{id}/cash-entries/{entryId}/reversal` | O/M berizin | Alasan dan referensi; bukan DELETE |
| POST `T/branches/{id}/account-transfers` | O/M | Rekonsiliasi clearing/bank dan transfer internal |
| GET `T/dashboard` | O semua; M scope; K ringkasan kasir | branch_ids, from, to; data_as_of dan HPP coverage |
| GET `T/subscription`, `T/invoices` | O | Status, paid-through, kapasitas, invoice |
| POST `T/subscription/quotes` | O | target_capacity; server menghitung jumlah dan expiry |
| POST `T/subscription/checkout-sessions` | O + MFA | quote_id, channel yang diizinkan; status pending |
| POST `T/subscription/cancellation`, `/scheduled-changes` | O + MFA | Berhenti perpanjangan/downgrade, efektif akhir periode |
| POST `/webhooks/billing/{provider}` | Signature provider | Raw body, event dedup; tidak memakai bearer user |
| POST `T/entitlements/offline-lease` | Sesi/perangkat terdaftar | branch_id; signed claims maksimum 24 jam |
| GET/POST `T/reports/jobs` | O/M export izin | report_type, branch_ids, from, to, format; 202 |
| GET `T/reports/jobs/{id}` | Pemilik scope yang masih berizin | Status/progress/revision/data_cutoff/error |
| POST `T/reports/files/{id}/download-url` | O/M berizin | Otorisasi ulang; URL singkat untuk file final |
| GET/PATCH `T/report-schedule` | O | Email terverifikasi, zona waktu, jadwal |
| GET `T/audit-logs`, `T/sync/conflicts` | O/M sesuai scope | Filter, status, aksi audit |
| POST `T/sync/conflicts/{id}/resolution` | O atau M berizin khusus | approve/reject, alasan, referensi bukti; tidak mengubah payload asal |

## 3. Payload penjualan tunai offline

Contoh menggunakan UUID ilustratif; seluruh harga pada penjualan ini berasal dari versi katalog yang pernah diterbitkan server. Hash dan signature berada pada envelope sync, bukan di sini.

```json
{
  "sale_id": "dc888008-c889-4bb1-94c7-cda414d14cc9",
  "branch_id": "11111111-1111-4111-8111-111111111111",
  "device_id": "22222222-2222-4222-8222-222222222222",
  "local_sequence": 417,
  "lease_id": "33333333-3333-4333-8333-333333333333",
  "occurred_at": "2026-10-14T07:30:00Z",
  "boot_id": "boot-example-17",
  "elapsed_since_anchor_ms": 3600000,
  "currency": "IDR",
  "items": [
    {
      "line_id": "44444444-4444-4444-8444-444444444444",
      "sku_id": "55555555-5555-4555-8555-555555555555",
      "price_version_id": "66666666-6666-4666-8666-666666666666",
      "quantity": "2.000",
      "unit_price": "20000",
      "line_discount": "2000"
    }
  ],
  "order_discount": "0",
  "tax": "0",
  "service_charge": "0",
  "total": "38000",
  "payment": {
    "method": "cash",
    "tendered_amount": "50000",
    "change_amount": "12000"
  }
}
```

Diskon contoh Rp2.000 adalah total diskon baris. Server memeriksa izin diskon pada lease, menghitung 2 × 20.000 − 2.000 = 38.000, kemudian mengesahkan snapshot. HPP diisi server dari referensi versi biaya; client kasir tidak perlu menerima nilai HPP. Jika versi harga/biaya lama tidak tersedia atau signature katalog tidak cocok, operasi dikarantina, bukan diberi harga baru secara diam-diam.

Respons setelah commit:

```json
{
  "sale_id": "dc888008-c889-4bb1-94c7-cda414d14cc9",
  "status": "completed",
  "sync_status": "committed",
  "replayed": false,
  "receipt_number": "CB01-INST000017-000417",
  "total": "38000",
  "inventory_revision": "982",
  "received_at": "2026-10-14T08:00:00Z"
}
```

`inventory_revision` menunjuk snapshot stok yang sudah mencakup transaksi ini; cursor change feed merupakan konsep terpisah. ID nota tidak diganti saat retry. Payload sama dengan sale_id sama mengembalikan hasil lama; payload berbeda menghasilkan `409 IDEMPOTENCY_PAYLOAD_MISMATCH`, tanpa efek tambahan.

## 4. Protokol sync

| Endpoint | Fungsi |
|---|---|
| POST `T/sync/bootstrap` | Buat snapshot scoped, lease, server time, config, cursor awal |
| GET `T/sync/bootstrap/{snapshotId}` | Halaman katalog/stok; token snapshot terikat actor/scope |
| POST `T/sync/push` | Batch operasi immutable, status per operasi |
| GET `T/sync/pull?cursor=…&amp;limit=200` | Delta server yang boleh dibaca beserta tombstone |
| GET `T/sync/status` | Antrean yang diketahui server, last_seen, konflik; bukan klaim semua data perangkat telah terkirim |

### Bootstrap dan pembacaan perubahan

Bootstrap dilakukan online setelah login, assignment, entitlement, dan registrasi perangkat valid. Snapshot harus konsisten dengan watermark feed; perubahan sesudah snapshot tersedia pada pull. Halaman snapshot memiliki masa berlaku. Bila snapshot kedaluwarsa, ulangi bootstrap tanpa menghapus outbox lokal.

Feed dipublikasikan melalui outbox setelah komit domain. Publisher per tenant menggunakan lock/counter transaksional untuk mengalokasikan nomor feed dan memasukkan barisnya dalam satu transaksi; nomor yang lebih tinggi tidak boleh menjadi terlihat sebelum nomor sebelumnya committed. Jangan menggunakan `bigserial` mentah pada transaksi domain sebagai cursor komit. Perubahan boleh terbit berulang, tetapi resource version mencegah rollback ke versi lama. Publisher tertunda dipantau.

Cursor terikat tenant, scope, dan permission version, ditandatangani server. Scope berubah atau cursor melewati retensi feed → `409 SYNC_REBOOTSTRAP_REQUIRED`. Client membersihkan cache yang tidak lagi boleh dibaca, lalu bootstrap ulang tanpa membuang transaksi pending.

Penerapan halaman delta dan penyimpanan cursor dilakukan atomik di SQLite. Tombstone menonaktifkan katalog lama; histori nota tetap memakai snapshot. Saldo stok server digabung dengan efek lokal yang belum tercakup watermark, bukan ditambahkan dua kali.

### Upload

Envelope setiap operasi berisi `operation_id`, `schema_version`, `kind=sale.recorded`, `payload`, `canonical_payload_hash`, `device_signature`, dan signed lease. Field mutable seperti jumlah retry tidak ikut hash. Skema canonical JSON dan library signature harus sama di Dart dan TypeScript, dibuktikan golden fixture.

Batch tidak atomik secara keseluruhan: masing-masing operasi atomik. Retry hanya operasi yang belum ACK. Urutan upload per perangkat dipertahankan, tetapi server tetap tahan pengiriman ulang dan sequence yang lompat. Efek transaksi baru tidak ditolak semata-mata karena ACK transaksi sebelumnya hilang.

Status per operasi:

| Status | Makna | Tindakan mobile |
|---|---|---|
| `committed` | Semua efek domain committed | Simpan ACK; tunggu snapshot stok terkait |
| `duplicate` | Sale sudah committed dengan payload sama | Perlakukan sebagai sukses |
| `quarantined` | Bukti diterima, perlu review | Pertahankan nota; tandai belum masuk laporan cloud |
| `rejected` | Payload/izin tidak sah | Tampilkan alasan; jangan retry otomatis atau hapus bukti |
| `retryable` | Gangguan sementara | Backoff dengan jitter dan key yang sama |

Retry usulan: 2 detik, 5 detik, 15 detik, 1 menit, kemudian maksimum 5 menit dengan jitter. Hormati Retry-After. Status 401 memerlukan refresh/login; 403/409/422 tidak diulang tanpa perubahan kondisi atau intervensi yang sesuai. Payload transaksi lama tidak ditulis ulang agar berhasil; koreksi memiliki command baru yang merujuk transaksi lama.

### Siklus lokal

```mermaid
stateDiagram-v2
    [*] --&gt; Draft
    Draft --&gt; Pending: commit lokal atomik
    Pending --&gt; Uploading: koneksi dan sesi valid
    Uploading --&gt; Pending: timeout atau crash
    Uploading --&gt; Synced: committed atau duplicate
    Uploading --&gt; NeedsReview: quarantined
    Uploading --&gt; Rejected: pelanggaran permanen
    NeedsReview --&gt; Synced: resolusi owner diposting
    NeedsReview --&gt; Rejected: resolusi ditolak
```

Saat restart, `Uploading` yang tidak memiliki ACK kembali menjadi `Pending`. Connectivity signal hanya pemicu percobaan; keberhasilan API yang membuktikan koneksi. Foreground/app resume dan tombol sinkronkan memicu pekerjaan; background bersifat best effort karena batas OS. [Flutter offline-first](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)

## 5. Lease, waktu, dan data terlambat

Usulan klaim signed lease: `iss`, `aud`, `kid`, `lease_id`, `tenant_id`, `branch_id`, `membership_id`, `device_id`, `permission_version`, `allowed_actions`, `issued_at`, `not_before`, `expires_at`, `subscription_paid_through`, `catalog_policy_version`, `clock_anchor`.

`expires_at = min(issued_at + 24 jam, paid_through)`. Lease hanya diterbitkan server setelah akses aktif diverifikasi. Private signing key tidak ada pada aplikasi; public keys untuk validasi dapat diputar dengan overlap. Lease tidak menggantikan access token untuk membaca API.

Saat online, catat waktu server dan monotonic clock perangkat pada boot yang sama. Saat offline, hitung waktu efektif dari anchor + elapsed. Jika wall clock mundur, reboot membuat anchor tidak dapat dipercaya, atau aplikasi tidak dapat memvalidasi waktu, minta validasi online sebelum transaksi baru. Perubahan jam tidak memperpanjang lease.

Usulan menerima transaksi yang baru diunggah setelah expiry bila lease asli valid pada waktu kejadian, actor/cabang/perangkat cocok, harga dan signature cocok, serta bukti waktu wajar. Nilai `occurred_at` yang diketik client saja tidak cukup. Signed lease dan signature perangkat membatasi pemalsuan, tetapi tidak memberi bukti waktu absolut pada perangkat kompromi; kasus meragukan dikarantina.

| Kondisi saat upload | Usulan perilaku |
|---|---|
| Transaksi dibuat dalam lease valid; subscription kini expired | Izinkan ingest historis melalui sesi sah; blok pembuatan sale baru |
| Timestamp di luar lease atau waktu meragukan | Karantina; owner dapat menyetujui pencatatan historis dengan alasan |
| Staf masih berizin tetapi cabang sudah inactive | Terima bukti pra-penonaktifan yang sah; jangan buka cabang kembali |
| Staf/perangkat dicabut karena alasan keamanan | Tolak jalur normal; simpan bukti lokal; pemulihan melalui owner terautentikasi |
| Katalog/harga berubah sejak offline | Gunakan versi lama yang pernah disahkan; jangan repricing nota |
| Stok cloud sudah habis | Catat sale offline sah dan delta; buat exception stok negatif |
| Sale telah tercatat sebelumnya | Kembalikan ACK lama setelah hash cocok |

Jalur pemulihan owner mengunggah envelope asli dan audit identitas operator pemulihan, tidak menyamar sebagai kasir lama. Persetujuan hanya memposting histori; tidak menerbitkan lease baru atau mengaktifkan langganan.

## 6. Idempotency dan keamanan retry

Key request dicakup oleh tenant, actor/operation scope, serta nama command. Server menyimpan hash request dan hasil/reference dalam transaksi yang sama dengan efek domain. Key sama + hash beda adalah conflict. Key baru + sale_id lama tetap dideduplikasi oleh registry sale permanen.

Usulan idempotency record request umum disimpan 30 hari; ini bukan batas deduplikasi transaksi. Registry sale dan identitas provider dipertahankan selama histori terkait ada. Scope export/refund/stock adjustment memiliki unique source key tersendiri.

Gunakan transactional outbox untuk efek eksternal dan inbox/dedup untuk event masuk. Queue dapat mengirim ulang; worker harus aman menjalankan ulang. Klaim efek database tepat satu kali tidak otomatis berarti email atau panggilan gateway dijamin tepat satu kali.

## 7. Kontrak laporan

```json
{
  "report_type": "sales_detail",
  "branch_ids": ["11111111-1111-4111-8111-111111111111"],
  "from": "2026-10-01",
  "to": "2026-11-01",
  "timezone": "Asia/Jakarta",
  "format": "xlsx"
}
```

Server memvalidasi scope semua cabang, zona bisnis, dan batas kerja yang wajar; tidak membatasi jumlah histori paket secara arbitrer. Respons `202` memberikan job_id dan status URL. File dihasilkan dari dataset dengan cutoff/revision yang konsisten; rerun revision yang sama tidak menghasilkan kumpulan data yang berubah karena upload baru.

Usulan snapshot ekspor: materialisasi ID dan versi event yang masuk lingkup laporan pada saat job dibuat, lalu stream data immutable berdasarkan manifest itu. Untuk laporan berbasis agregat mutable, simpan snapshot agregat dalam transaksi saat cutoff. Ukur overhead manifest pada skala besar; hindari transaksi database berjam-jam yang hanya menunggu streaming file.

Refund dilaporkan sebagai peristiwa pada tanggal refund, dengan referensi sale asal; analisis cohort penjualan dapat memberi tampilan terpisah. Laporan menyebut definisi tanggal, cutoff, dan apakah ada perangkat belum sinkron. Backend hanya mengetahui last_seen/ACK perangkat; tidak dapat menjamin laporan mencakup semua nota yang masih berada offline.

## 8. Skenario kegagalan wajib

| Skenario | Hasil yang harus terbukti |
|---|---|
| App mati setelah commit lokal | Nota dan outbox kembali setelah restart |
| Server commit tetapi ACK hilang | Retry tidak menambah stok/uang/sales dua kali |
| Dua kasir menjual stok terakhir | Online mengikuti kebijakan lock; offline direkonsiliasi dan ditandai |
| Payload diubah tetapi ID sama | Conflict, tanpa update histori |
| Dua refund bersamaan | Jumlah total tidak melebihi sisa refundable |
| Permission diturunkan saat offline | Berlaku sesuai lease sampai batasnya; setelah reconnect cache/scope diperbarui |
| Webhook sukses datang dua kali atau terbalik | Periode akses tidak berlipat atau mundur tanpa alasan sah |
| Subscription habis tepat sebelum checkout baru | Ditolak menurut waktu otoritatif; histori tetap tersedia |
| Pull terputus setelah apply sebagian | Transaksi lokal rollback; cursor tidak meloncat |
| Worker mati setelah file dibuat | Retry memverifikasi manifest/checksum; file parsial tidak dibagikan |
| Email timeout dengan hasil tak diketahui | Rekonsiliasi status provider; delivery tidak langsung dianggap berhasil |

Seluruh skenario adalah acceptance target; belum diuji pada implementasi.
