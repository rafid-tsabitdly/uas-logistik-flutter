# 📦 Aplikasi Sistem Logistik IT Berbasis IoT

Aplikasi Sistem Logistik IT ini dirancang untuk manajemen inventaris perangkat keras dan pemantauan distribusi logistik secara *real-time*. Proyek ini dibangun menggunakan arsitektur *Client-Server* dengan **Flutter Web** sebagai antarmuka pengguna (*Front-End*) dan **Laravel REST API** sebagai penyedia data (*Back-End*).

## 👤 Identitas Pengembang
* **Nama:** Muhammad Rafid Tsabitdly
* **NIM:** 241011701060
* **Program Studi:** Sistem Informasi
* **Mata Kuliah:** Pemrograman Berorientasi Objek 2 (PBO2)

---

## 🛠️ Langkah-Langkah Instalasi Lengkap (Urutan Terstruktur)

### LANGKAH 1: Penyiapan Pangkalan Data (Database)
1. Aktifkan **Laragon** atau **XAMPP** di komputer Anda.
2. Buka alat manajemen database seperti **HeidiSQL** atau **phpMyAdmin**.
3. Cari file bernama **`db_logistik_it.sql`** yang terletak di dalam repositori back-end.
4. Lakukan **Import** file `.sql` tersebut ke dalam server database Anda. Skrip ini akan otomatis membuat struktur database bernama `db_logistik` beserta tabel dan data dummy inventaris di dalamnya.

### LANGKAH 2: Konfigurasi Server API (Back-End Laravel)
1. Letakkan folder proyek Laravel ini ke dalam direktori server lokal Anda (misalnya di `C:\laragon\www\rest-api`).
2. Buka terminal di dalam folder proyek Laravel tersebut, lalu jalankan perintah instalasi dependensi vendor:
   ```bash
   composer install
