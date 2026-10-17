# Log Percakapan: Final Project Sistem Booking

Tanggal sesi: 11 Oktober 2026
Project: `fin-pro/` (Full Stack Web Development, Dibimbing). Tema: **Sistem Booking dan Manajemen Layanan**

## Ringkasan yang sudah dikerjakan

1. **Analisa guideline** (`docs/Guideline Final Project FWD.docx`)
   - Scope: ERD & database, backend API + auth role-based (Admin & User), CRUD + validasi, frontend React + admin panel, deployment, dokumentasi API, PPT.
   - Rubrik terbesar: code readability, kesesuaian requirement, integrasi API, CRUD (masing-masing 15).
   - Guideline menyebut **Sanctum** (Laravel), sehingga di Express diganti **JWT** (access + refresh). Perlu dikonfirmasi ke mentor.
   - Ada kebijakan AI: nilai 0 bila 100% dikerjakan AI. Kode harus dipahami sendiri.
   - Deadline tertulis 22 Agustus 2026. Perlu dicek apakah masih berlaku untuk batch ini.
   - Guideline tidak mewajibkan ORM tertentu.

2. **Perancangan**: `docs/perancangan-sistem-booking.html`
   - Arsitektur: React SPA → Express REST API `/api/v1` → PostgreSQL.
   - 8 tabel: users, refresh_tokens, categories, services, schedules, bookings, payments, booking_status_logs.

3. **Implementasi backend**: folder `backend/`
   - Dibuat dulu dengan Prisma (`docs/implementasi-backend.html`), lalu **dipindah ke Sequelize** (`docs/migrasi-prisma-ke-sequelize.html`).
   - Kode, nama folder, dan pesan API berbahasa Inggris. Komentar satu baris dalam bahasa Inggris.
   - 8 modul, 38 endpoint, Swagger di `/api/docs`, Dockerfile + docker-compose, seeder data demo.
   - Pengujian: Jest 25/25, end-to-end 47/47 (memakai PostgreSQL sementara di port 55432, sudah dimatikan).

4. **Panduan git**: `docs/panduan-git-github.md` (belum dijalankan).
   - Repo tujuan: https://github.com/pratitisyohanes/final-project.git (saat dicek masih kosong).

## Artifact

| Dokumen | File lokal | Link |
| --- | --- | --- |
| Perancangan | `docs/perancangan-sistem-booking.html` | https://claude.ai/artifact/5Hx8szAVcwubAcM2VFqPUt |
| Implementasi backend (versi Prisma + banner) | `docs/implementasi-backend.html` | https://claude.ai/artifact/56a767FPua58goDLVcYh2n |
| Migrasi Prisma → Sequelize | `docs/migrasi-prisma-ke-sequelize.html` | https://claude.ai/artifact/8K5J68xngqYqhnUBYMA1ps |

## Kondisi terakhir

- Stack backend: Node 20+, Express 4, Sequelize 6 + sequelize-cli, PostgreSQL, Zod, JWT, bcryptjs, Jest + Supertest.
- `backend/.env` sudah berisi password PostgreSQL lokal milik user. Akhiran `?schema=public` sudah dihapus.
- Database `booking_db` di PostgreSQL lokal (port 5432) **belum** dimigrasi oleh Claude. User perlu menjalankan:
  ```
  cd backend
  createdb -U postgres booking_db      # bila belum ada
  npm run db:migrate
  npm run db:seed
  npm run dev
  ```
- Akun demo: `admin@booking.com / Admin12345`, `budi@example.com / User12345`, `siti@example.com / User12345`.
- Folder `fin-pro/` belum menjadi repo git.

## Peringatan keamanan

- `fin-pro/.env.local` adalah file `.env` dari project lain (Laravel "KM Online") dan berisi password database kantor. **Jangan sampai ter-commit.** Pindahkan keluar dari folder project, atau abaikan lewat `.gitignore` root (`.env.*`).
- `backend/.gitignore` berisi `/docs`. Baris ini hanya berlaku untuk `backend/docs`, bukan `fin-pro/docs`.

## Langkah berikutnya

1. Jalankan migration dan seeder di database lokal, lalu coba Swagger.
2. Amankan `.env.local`, lalu ikuti `docs/panduan-git-github.md` untuk push ke GitHub. Di daftar commit bertahap, ganti `backend/prisma` dengan `backend/src/models backend/src/database`.
3. Konfirmasi ke mentor: penggantian Sanctum menjadi JWT, serta pemakaian Sequelize.
4. Bangun frontend React + Vite (`frontend/`) sesuai bagian 9 dokumen perancangan: halaman publik, user, dan admin panel. Catatan response API: `bookingCount`, `serviceCount`, tanggal slot `YYYY-MM-DD`, harga `"75000.00"`.
5. Deployment (Vercel untuk frontend, Railway/Render untuk backend, Neon/Supabase untuk DB, dengan `DB_SSL=true`), README root, Postman collection, PPT.

## Preferensi kerja

- Penjelasan dalam bahasa Indonesia, detail, dan step by step.
- Hasil penjelasan dibuat sebagai artifact **dan** disimpan di `docs/`.
- Kode dan struktur project dalam bahasa Inggris. Komentar satu baris dalam bahasa Inggris.

## Sesi 15 Oktober 2026: cek requirement

- Guideline dicek ulang terhadap kode `backend/`. Hasil + perancangan frontend + rules kerja disimpan di `rules/cek-requirement-dan-perancangan.html`.
- Artifact: https://claude.ai/artifact/AagjXEJZPvv3tPYU6UKwQ3
- Gap utama: frontend React (belum), deployment, git/README root, Postman, PPT. Caching belum (opsional). Sanctum → JWT perlu konfirmasi mentor.

## Sesi 15 Oktober 2026: implementasi frontend

- Folder baru `frontend/` (package `booking-service-web`): React 18 + Vite 6 + Tailwind 3, TanStack Query, Zustand, Axios, React Hook Form + Zod, Recharts.
- Penjelasan step by step: `docs/implementasi-frontend.html` (artifact https://claude.ai/artifact/8jW4QWCNTKgDUQdFV7BrJ4).
- Diuji di Chrome dengan backend + PostgreSQL sementara (port 55432, sudah dimatikan): alur pelanggan, admin, refresh token, guard role. Download CSV dan tampilan mobile belum dicek visual.
- `backend/docker-compose.yml` ditambah service `web` (port 8080).
- Berikutnya: migrate DB lokal, git init + push, deploy, README root, Postman, PPT.

## Sesi 15 Oktober 2026: panduan menjalankan

- `rules/panduan-menjalankan-dan-arsitektur.md` (sumber) + `.html` (artifact https://claude.ai/artifact/FLBpe7ytQnyyUg6dKAEKB1).
- Isi: cara menjalankan backend/frontend/Docker, analisa data + ERD, SQL (struktur + query), pola MVC backend, struktur frontend, alur booking end-to-end, 38 endpoint, troubleshooting.

## Sesi 16 Oktober 2026: cek VPS

- VPS 103.127.134.81 dicek dari luar: Nginx 1.18 (Ubuntu 20.04) di port 80 menyajikan halaman default Apache, HTTPS belum aktif, PostgreSQL terbuka ke publik di 5432, MySQL tidak terlihat dari luar, SSH hanya kunci (kunci id_ed25519 lokal ditolak untuk root/ubuntu).
- Panduan: `rules/vps/cara-cek-vps.md` + `.html` (artifact https://claude.ai/artifact/YbvEu6u2Bm6BhQNN9gB4DD).
- User login sebagai `pratitis-yohanes` dan mengonfirmasi `nginx 1.18.0` + `Apache 2.4.41` terpasang.
- Penjelasan sederhana: `rules/vps/nginx-vs-apache.md` + `.html` + `.pdf` (artifact https://claude.ai/artifact/1sAUBTwJEmQtaPMgio8SaW). `cara-cek-vps` juga dibuat PDF.

## Sesi 16 Oktober 2026: swap dan CI/CD

- VPS = Biznet NEO Lite XS 1.1 (1 vCPU, 1 GB RAM, 60 GB, Ubuntu 20.04). Domain pratitis.net sudah A → 103.127.134.81 (NeoDNS). Rencana subdomain booking.pratitis.net.
- File baru: `.github/workflows/deploy.yml` (test → build → rsync+SSH → migrate → pm2), `backend/ecosystem.config.js`, `deploy/nginx/booking.pratitis.net.conf`, `.gitignore` root.
- Panduan: `rules/vps/swap-dan-cicd.md` + `.html` + `.pdf` (artifact, lihat tabel di bawah). GitLab self-hosted tidak disarankan (butuh ≥4 GB RAM).
- Meniru alur kantor (GitLab MR + maintainer merge + OKD): `rules/vps/meniru-alur-kantor-okd.md` + `.html` + `.pdf`. OKD gratis (versi komunitas OpenShift) tetapi butuh ≥4 vCPU/16 GB RAM, tidak muat di VPS. Ditambah `.github/CODEOWNERS`. Semua PDF di `rules/vps/` dibuat ulang (diagram lebar tidak terpotong).
- Panduan gabungan setup VPS (Apache off + mask, MySQL tanpa Apache via SSH tunnel/phpMyAdmin+PHP-FPM, swap, UFW, DNS booking.pratitis.net, Nginx pratitis.net, certbot, GitHub deploy): `rules/vps/setup-vps-lengkap.md` + `.html` + `.pdf`. User dulu memasang Apache untuk kebutuhan MySQL (kemungkinan phpMyAdmin).
- User menjalankan tahap 1–2: Apache masked, Nginx active di :80, MySQL inactive+disabled, PostgreSQL masih 0.0.0.0:5432, belum ada 443. Halaman Apache masih tampil karena /var/www/html/index.html lama. Analisa: `rules/vps/analisa-nginx-halaman-apache.md` + `.html` + `.pdf`.
- Nginx sudah tampil "Welcome to nginx!" (index.html Apache sudah disingkirkan). Lembar kerja lanjutan dengan titik cek: `rules/vps/lanjutan-swap-domain-github.md` + `.html` + `.pdf`. Saat dicek: repo GitHub masih kosong, DNS `booking` belum ada, `.env.local` masih di folder project, folder belum git repo.
- Portal Biznet: subdomain ditambah lewat tombol **Manage DNS** (bukan Manage/Register Nameservers). Panduan: `rules/vps/tambah-subdomain-neo-dns.md` + `.html` + `.pdf`.

## Status akhir 16 Oktober 2026 (dilanjutkan besok)

### Sudah selesai di VPS 103.127.134.81 (user `pratitis-yohanes`)
- Apache: stop + disable + **masked**. Nginx `active` di :80.
- MySQL: inactive + disabled (nyalakan dengan `sudo systemctl start mysql` bila perlu).
- Swap 2 GB aktif (`/swapfile`, fstab), `vm.swappiness=10`, `vm.vfs_cache_pressure=50`. Peringatan sysctl `promote_secondaries` aman diabaikan.
- UFW aktif: hanya 22, 80, 443. Port 5432 sudah tertutup dari luar (dicek).
- DNS NeoDNS: record `A booking 103.127.134.81` ditambahkan; `@` A dan `www` CNAME tetap. `booking.pratitis.net` sudah resolve di Google/Cloudflare.
- Nginx site aktif: `pratitis.net.conf` (halaman /var/www/pratitis.net) dan `booking.pratitis.net.conf` (root /var/www/booking/frontend/dist, /api → 127.0.0.1:5000, halaman sementara "menunggu deploy"). `nginx -t` OK. Folder /var/www/booking milik user.
- `dpkg --configure -a` dijalankan; `python3-certbot-nginx` terpasang (certbot 0.40). Repo NodeSource node_20.x sudah ada di apt (cek `node -v`).

### Terhenti di sini: tahap 5 HTTPS
- `sudo certbot --nginx -d pratitis.net -d www.pratitis.net -d booking.pratitis.net` → pilih Expand (sudah ada sertifikat lama untuk pratitis.net + www) → **gagal: DNS problem SERVFAIL** looking up A/AAAA untuk ketiga domain.
- Diagnosa: DNSSEC tidak aktif (bukan penyebab), Google/Cloudflare resolve normal, **Let's Debug (http-01) untuk booking.pratitis.net: no problems found** → kemungkinan gangguan sesaat NeoDNS dari sisi Let's Encrypt.
- Batas Let's Encrypt: 5 gagal per domain per jam → uji dulu dengan dry-run.

### Langkah besok
1. `sudo certbot certonly --nginx --dry-run -d pratitis.net -d www.pratitis.net -d booking.pratitis.net`
2. Bila sukses: `sudo certbot --nginx -d pratitis.net -d www.pratitis.net -d booking.pratitis.net` → E → Redirect (2). Cek `sudo certbot certificates`, `ss -tlnp | grep :443`.
3. Bila tetap SERVFAIL: tunggu 30–60 menit / hubungi support Biznet (NeoDNS SERVFAIL untuk Let's Encrypt) / opsi terakhir pindah DNS ke Cloudflare.
4. Tahap 6: `node -v`, PM2 + `pm2 startup`, DB `booking_user`/`booking_db`, `/var/www/booking/backend/.env` produksi.
5. Tahap 7–8: kunci deploy `booking_deploy`, pindahkan `fin-pro/.env.local` keluar project, `git init` + push ke github.com/pratitisyohanes/final-project (repo masih kosong), 5 secrets, run workflow, seeder sekali.
- **Jangan jalankan `sudo apt autoremove`** dulu (daftar berisi paket node-* dan python3-docker; perlu dicek).

Panduan acuan: `rules/vps/lanjutan-swap-domain-github.md` (lembar kerja dengan titik cek), `rules/vps/setup-vps-lengkap.md`, `rules/vps/tambah-subdomain-neo-dns.md`.

## Sesi 18 Oktober 2026: audit kesesuaian guideline

- Backend dan frontend dicek ulang terhadap guideline: semua scope backend/frontend dan business flow tema booking **sesuai**. Unit test backend 15/15 lulus, build frontend sukses.
- Belum: deploy, git init + push, README root (ERD, tech stack, cara run), dokumentasi API yang bisa dibagikan (Postman/PDF), PPT. Sanctum → JWT perlu konfirmasi mentor.
- Laporan: `docs/analisa-kesesuaian-guideline.html` (artifact https://claude.ai/artifact/F2bgxVuFKj3Qvtywy4eWV3).

## Sesi 18 Oktober 2026: gaya .env seperti Laravel

- Backend menerima `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` (helper baru `backend/src/config/databaseUrl.js`, dipakai `env.js` dan `database.js`). `DATABASE_URL` tetap didukung dan menang bila diisi.
- `backend/.env.example`, `backend/.env`, `frontend/.env(.example)` ditulis ulang per bagian dengan komentar. Nilai lama `backend/.env` dipertahankan; cadangan di `backend/.env.backup`.
- Koneksi ke PostgreSQL lokal gagal `28P01` (password salah) — sudah terjadi juga dengan `.env` lama. Perbaiki `DB_PASSWORD` di `backend/.env`.

## Sesi 18 Oktober 2026: panduan deploy backend manual ke VPS

- `rules/vps/deploy-backend-vps.html` (artifact https://claude.ai/artifact/1cfhBf2ckZbREKkSSuyKoT): ganti password `postgres` (pernah terbuka publik), SQL `booking_user` + `booking_db` + `ALTER SCHEMA public OWNER`, Node 20 + PM2, upload tar+scp atau git clone, `.env` produksi gaya DB_* (DB_HOST=127.0.0.1), `npm ci --omit=dev`, migrate, seed sekali, `pm2 start/save/startup`, cek Nginx, build frontend `VITE_API_URL=/api/v1`.
- Tabel dibuat oleh migration, bukan SQL manual.

## Sesi 18 Oktober 2026: .gitignore + panduan push GitHub

- `.gitignore` root, `backend/.gitignore`, `frontend/.gitignore`, `backend/.dockerignore`: pola `.env`, `.env.*`, `*.env`, `!.env.example`. Diuji di repo percobaan: `.env.local`, `docs/.env`, `backend/.env`, `backend/.env.backup`, `frontend/.env` diabaikan; hanya `.env.example` yang ikut.
- Panduan: `docs/panduan-push-github.html` (artifact https://claude.ai/artifact/SQihe2K8NMRyW475pzRRGw). Folder belum `git init`; repo GitHub masih kosong.
