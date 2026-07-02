# Sistem Logistik IT - Front-End (Flutter Web)

Repositori ini berisi kode sumber aplikasi *Front-End* berbasis Flutter Web untuk memenuhi tugas akhir UAS Mata Kuliah Pemrograman Berorientasi Objek 2 (PBO2).

## Identitas Pengembang
* **Nama:** Muhammad Rafid Tsabitdly
* **NIM:** 241011701060
* **Program Studi:** Sistem Informasi

## Fitur Utama Aplikasi
1. **Sistem Autentikasi Keamanan:** Menggunakan Firebase Auth untuk modul Register & Login pengguna.
2. **Dashboard Analitik:** Menampilkan total jenis komponen, total unit stok, serta total nilai kalkulasi aset secara real-time.
3. **Cetak Laporan PDF (Web-Safe):** Fitur cetak laporan resmi yang mengunduh data inventaris langsung lewat browser Chrome tanpa terblokir pop-up.
4. **Manajemen CRUD Inventaris:** Mengelola data hardware terintegrasi dengan REST API Laravel, lengkap dengan fitur pencarian data (*Search*) dan pembaruan data (*Pull-to-Refresh*).
5. **Rute Distribusi & Simulasi IoT:** Peta pemantauan pengiriman logistik ke area Stasiun Serpong yang dilengkapi panel sensor ganda: sensor suhu kargo dan kapasitas *Smart Bin E-Waste* (Reverse Logistics).

## Panduan Menjalankan Proyek
1. Pastikan Flutter SDK sudah terinstal di komputer Anda.
2. Clone atau unduh repositori ini ke penyimpanan lokal Anda.
3. Buka terminal di dalam folder proyek ini, lalu jalankan perintah untuk mengambil dependensi paket:
   ```bash
   flutter pub get
