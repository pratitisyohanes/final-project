# Panduan Publish ke GitHub

Repo tujuan: https://github.com/pratitisyohanes/final-project.git (saat dicek masih kosong)
Identitas git lokal: Yohanes Anom Pratitis / pratitisyohanes@gmail.com

## 0. Amankan file rahasia

`fin-pro/.env.local` berisi password database project lain (KM Online). Pindahkan keluar dari folder `fin-pro`, atau pastikan diabaikan lewat `.gitignore` di langkah 1.

Catatan: baris `/docs` di `backend/.gitignore` hanya berlaku untuk `backend/docs`, bukan `fin-pro/docs`.

## 1. Buat `fin-pro/.gitignore`

```gitignore
# Secrets
.env
.env.*
!.env.example

# Dependencies & build
node_modules/
dist/
coverage/

# OS / editor
.DS_Store
Thumbs.db
*.log

# Optional: bootcamp material
# docs/*.docx
```

## 2. Inisialisasi git

```powershell
cd C:\Users\PT.CTI\OneDrive\Pictures\dibimbing\final-project\fin-pro
git init
git branch -M main
```

## 3. Tambahkan file dan periksa

```powershell
git add .
git status
```

- Harus ada: `.gitignore`, `backend/src/...`, `backend/src/models/...`, `backend/src/database/...`, `backend/package.json`, `backend/package-lock.json`, `backend/.env.example`, `docs/*.html`
- Tidak boleh ada: `.env.local`, `backend/.env`, `backend/node_modules/`

Jika ada yang salah masuk: `git rm --cached <file>`, perbaiki `.gitignore`, lalu `git add .` lagi.

## 4. Commit (disarankan bertahap)

```powershell
git add .gitignore backend/package.json backend/package-lock.json backend/.env.example backend/.gitignore
git commit -m "chore: project setup"

git add backend/src/models backend/src/database backend/.sequelizerc
git commit -m "feat: sequelize models, migrations and seeder"

git add backend/src/config backend/src/utils backend/src/middlewares
git commit -m "feat: core config, utilities and middleware"

git add backend/src/modules/auth backend/src/modules/users
git commit -m "feat: authentication and user management"

git add backend/src/modules
git commit -m "feat: services, schedules, bookings, payments and reports modules"

git add .
git commit -m "feat: app wiring, swagger docs, docker, tests and documentation"
```

## 5. Hubungkan dan push

```powershell
git remote add origin https://github.com/pratitisyohanes/final-project.git
git push -u origin main
```

Push pertama membuka Git Credential Manager untuk login GitHub lewat browser.

## 6. Cek di GitHub

1. Folder `backend/` dan `docs/` muncul.
2. Tidak ada `.env.local` atau `backend/.env`. Jika sampai ter-upload, password harus diganti dan riwayat git perlu dibersihkan.
3. Tambahkan README di root: deskripsi, ERD, tech stack, cara run, link deployment.

## Alur kerja harian

```powershell
git add .
git status
git commit -m "feat: deskripsi perubahan"
git push
```
