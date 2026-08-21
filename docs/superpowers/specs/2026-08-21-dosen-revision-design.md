# Desain Revisi Progress Dosen

Tanggal: 21 Agustus 2026  
Target: APK demo Android dengan backend cloud dan database Neon  
Status dokumen: rancangan untuk ditinjau sebelum implementasi

## 1. Tujuan

Revisi ini menindaklanjuti seluruh notulen dosen:

1. jadwal dan status yang terus diperbarui;
2. map default yang lebih mudah dibaca;
3. preview line yang dipilih pengguna;
4. indikator **You Are Here**;
5. navbar yang batasnya lebih jelas;
6. integrasi AI;
7. panduan aksesibel untuk pengguna tunanetra;
8. kamera otomatis yang memberi panduan suara;
9. informasi **Peron**;
10. backend online dan APK yang dapat didemokan di perangkat Android.

Implementasi harus mempertahankan layout map existing. Perubahan map dibatasi pada skala, jarak, keterbacaan, dan penanda pilihan.

## 2. Kondisi Aplikasi Saat Ini

### Sudah tersedia

- Map skematik telah diperbesar tanpa mengganti struktur layout.
- Line, node, dan font nama stasiun telah diperbesar.
- Semua nama stasiun telah dibuat tebal dan beberapa tabrakan label telah diperbaiki, termasuk area Lebak Bulus dan Sudirman.
- Map telah memiliki state stasiun terpilih dan highlight node.
- Map telah memiliki filter beberapa line melalui `visibleLineIds`, tetapi belum memiliki mode fokus satu line yang mempertahankan konteks seluruh jaringan.
- Navbar telah memiliki border atas 1 px dan shadow tipis.
- Halaman jadwal menghitung status berdasarkan jam perangkat dan me-refresh tampilan setiap 30 detik.
- Jadwal Commuter Line Februari 2026 telah diimpor ke Neon: 1.145 perjalanan dan 19.328 pemberhentian.
- Backend Express, Prisma, autentikasi, routing, jadwal, dan endpoint chat dasar telah tersedia.
- Database Neon telah terhubung dan lima migrasi telah diterapkan.
- Profil pengguna telah memiliki preferensi aksesibilitas dasar.

### Belum tersedia atau belum selesai

- Highlight stasiun terpilih masih kurang menonjol sebagai **You Are Here**.
- Border navbar masih kurang tegas.
- Jadwal dari PDF tidak memiliki data peron per perjalanan; API KRL saat ini mengembalikan `platform: "-"`.
- Endpoint Gemini masih memakai SDK lama dan model `gemini-1.5-flash`.
- UI Asisten masih memakai percakapan dan suara simulasi, belum memanggil backend Gemini.
- Kamera, pendeteksian objek, text-to-speech nyata, permission kamera, dan panduan otomatis belum tersedia.
- Backend belum di-host ke URL publik untuk APK.
- Satu test backend masih mengharapkan 205 jadwal legacy, sedangkan fixture aktif berisi 28.

## 3. Keputusan Produk

### 3.1 Arti You Are Here

**You Are Here adalah stasiun yang dipilih pengguna pada map, bukan lokasi GPS perangkat.**

- Highlight dan pilihan stasiun yang sudah ada menjadi sumber state tunggal.
- Memilih stasiun lain memindahkan indikator.
- Fitur nearest-station berbasis GPS yang sudah ada tidak boleh mengganti arti indikator ini.
- Jika fitur GPS tetap ditampilkan, ia harus diberi nama terpisah seperti **Stasiun terdekat**, bukan **You Are Here**.

### 3.2 Arti status jadwal

Data Februari 2026 adalah jadwal terencana, bukan telemetri kereta langsung.

- Status dihitung berdasarkan waktu perangkat dan jadwal keberangkatan.
- Status yang diperbolehkan: **Akan datang**, **Segera**, **Sekarang**, dan **Telah berangkat**.
- Tampilan diperbarui setiap 30 detik.
- UI tidak boleh memakai klaim **real-time KAI**, **posisi aktual**, **terlambat**, atau **dibatalkan** tanpa sumber operasional langsung.
- Copy yang direkomendasikan: **Status jadwal diperbarui otomatis**.

### 3.3 Arti Peron

Istilah yang tampil kepada pengguna selalu **Peron**, bukan **Jalur** atau **Platform**.

- Peron ditentukan memakai pemetaan statis terverifikasi berdasarkan stasiun, line, arah, dan tujuan.
- Nomor peron bukan data operasional live dan dapat berubah.
- Jika aturan tidak ditemukan, tampilkan **Peron belum tersedia**.
- Setiap informasi peron disertai teks kecil **Cek papan informasi stasiun**.
- Aplikasi tidak boleh menebak nomor peron.

### 3.4 Kamera otomatis

Tidak ada tombol shutter atau tombol untuk mengambil gambar.

- Pengguna tetap harus mengizinkan permission kamera Android satu kali.
- Pengguna masuk melalui menu atau perintah suara **Buka pemandu kamera**.
- Setelah halaman terbuka dan permission tersedia, kamera serta analisis langsung berjalan otomatis.
- Tombol **Hentikan Pemandu** dan tombol kembali tetap wajib untuk privasi dan keselamatan.
- Saat aplikasi masuk background, kamera dan pengiriman frame harus berhenti.

## 4. Perubahan Map

### 4.1 Highlight You Are Here

Highlight ungu yang sudah ada diperjelas tanpa memindahkan node:

- diameter highlight sekitar 1,6 kali diameter node;
- ring putih di antara node dan highlight;
- border ungu lebih tebal;
- glow ungu tipis;
- pulse lambat dengan amplitudo kecil;
- nama stasiun terpilih diberi warna ungu, tetapi ukuran dan posisi label tetap;
- treatment harus konsisten untuk node biasa, node transit, dan node gabungan.

Animasi harus berhenti ketika halaman tidak aktif dan tidak boleh menyebabkan map terus melakukan repaint yang tidak perlu.

### 4.2 Batas perubahan map

- Tidak mengubah urutan stasiun.
- Tidak mengganti bentuk keseluruhan line.
- Tidak memindahkan layout yang sudah disetujui kecuali penyesuaian kecil untuk mencegah tabrakan.
- Posisi khusus nama Lebak Bulus dan Sudirman tetap dipertahankan.
- Perubahan harus diuji pada ukuran layar Android kecil dan besar.

### 4.3 Preview line terpilih

Preview line diakses dari halaman hasil/preview perjalanan, bukan menjadi kontrol utama pada halaman map.

- Setelah rute berhasil ditemukan, tampilkan `FloatingActionButton.extended` di kanan bawah dengan ikon map dan label **Lihat Line di Peta**.
- Floating button hanya tampil pada state hasil berhasil; tidak tampil saat loading, error, atau hasil kosong.
- Posisi tombol berada di atas navbar dengan safe margin sehingga tidak menutup isi perjalanan maupun navigasi bawah.
- Saat ditekan, tombol membuka map preview layar penuh memakai navigasi `push`; tombol kembali mengembalikan pengguna ke hasil perjalanan yang sama.
- Map preview memakai komponen dan koordinat map existing. Tidak membuat desain jaringan baru.
- Jika perjalanan memakai satu line, hanya line tersebut yang menjadi fokus.
- Jika perjalanan membutuhkan transit, semua line yang dipakai perjalanan tetap memakai warna aslinya agar seluruh perjalanan terbaca.

- Line perjalanan tetap memakai warna asli dan stroke sedikit lebih tebal.
- Semua line lain tetap digambar, tetapi memakai abu-abu netral dengan opacity rendah.
- Node dan nama stasiun pada perjalanan tetap penuh dan mudah dibaca.
- Node dan nama stasiun di luar perjalanan diredupkan, bukan dihilangkan.
- Stasiun asal menjadi pilihan awal dan mendapat indikator **You Are Here**.
- Stasiun transit dan tujuan perjalanan tetap ditampilkan penuh.
- Walking connection yang dipakai perjalanan tetap penuh; walking connection lain ikut diredupkan.
- Tombol/opsi **Semua Line** pada map preview mengembalikan warna seluruh jaringan tanpa menutup preview.
- Fokus perjalanan memakai satu state berdasarkan kumpulan ID line dari hasil rute, bukan kombinasi checkbox yang dapat menghasilkan map kosong.
- Untuk service yang memiliki lebih dari satu segmen geometri, satu line mengaktifkan seluruh segmennya. Contoh: Bogor mencakup `bogor` dan `bogor_nambo`; Cikarang mencakup `cikarang_loop` dan `cikarang_east`.

Mode preview tidak mengubah koordinat, urutan station, posisi label, zoom, atau layout map. Perubahan hanya memengaruhi warna, opacity, dan ketebalan visual.

## 5. Perubahan Navbar

Navbar existing tetap memakai lima menu dan ukuran yang sama.

- Border atas dinaikkan dari 1 px menjadi 2 px.
- Warna border memakai warna tema yang lebih kontras.
- Shadow ke atas tetap tipis agar navbar terpisah dari konten.
- Ikon dan teks aktif tetap memakai warna utama dan bobot lebih tebal.
- Tinggi, urutan menu, route, dan safe-area tidak berubah.

## 6. Data dan Resolusi Peron

### 6.1 Model database

Tambahkan tabel `StationPlatformRule` di Prisma/Neon dengan data minimum:

- `id`;
- `stationId`;
- `lineSlug`;
- `direction`;
- `destination` opsional;
- `platform`;
- `sourceName`;
- `sourceUrl`;
- `validFrom` opsional;
- `validTo` opsional;
- `verifiedAt`;
- `createdAt` dan `updatedAt`.

Aturan harus memiliki indeks untuk pencarian berdasarkan stasiun, line, dan arah. Nomor peron disimpan sebagai string agar nilai seperti `5/6` tetap dapat direpresentasikan.

### 6.2 Prioritas data demo

Tahap pertama hanya mengisi stasiun transit utama yang sumbernya dapat diverifikasi:

1. Manggarai;
2. Tanah Abang;
3. Duri;
4. Kampung Bandan;
5. Bekasi;
6. Jakarta Kota.

Perluasan ke semua stasiun dilakukan setelah demo dan setelah sumber mutakhir tersedia.

### 6.3 Resolver backend

Urutan pencarian aturan:

1. stasiun + line + tujuan spesifik;
2. stasiun + line + arah;
3. tidak ditemukan.

API jadwal tetap memakai field `platform` agar model Flutter existing tidak pecah. Nilai API:

- nomor/string peron jika aturan ditemukan;
- string kosong jika tidak tersedia.

UI menerjemahkan string kosong menjadi **Peron belum tersedia**. Respons dapat menambahkan metadata `platformSource` dan `platformVerifiedAt`, tetapi tidak wajib ditampilkan di kartu utama.

## 7. Integrasi AI Teks

### Backend

- Ganti `@google/generative-ai` dengan SDK `@google/genai`.
- Ganti model lama menjadi `gemini-3.5-flash-lite`.
- `GEMINI_API_KEY` hanya berada pada environment backend.
- Endpoint `POST /api/v1/assistant/chat` tetap dipertahankan agar perubahan Flutter kecil.
- Tambahkan validasi panjang pesan, timeout, rate limit, respons fallback, dan error code yang konsisten.
- Prompt membatasi jawaban pada informasi perjalanan dan tidak boleh mengarang jadwal, peron, atau status operasional.

### Flutter

- Ganti respons percakapan simulasi dengan repository yang memanggil endpoint chat.
- State minimal: siap, mengirim, berhasil, gagal, dan coba lagi.
- Pertahankan command lokal yang tidak membutuhkan AI, seperti membuka jadwal atau alarm.
- Jawaban backend dibacakan memakai text-to-speech bila aksesibilitas aktif.
- API failure tidak boleh menghapus percakapan yang sudah tampil.

## 8. Pemandu Kamera untuk Tunanetra

### 8.1 Pendekatan hybrid

Gunakan dua lapisan:

1. **ML Kit Object Detection** berjalan di perangkat untuk deteksi dan tracking berkelanjutan tanpa biaya API.
2. **Gemini 3.5 Flash-Lite** menerima frame terpilih untuk menghasilkan deskripsi singkat dan lebih natural.

Pendekatan Gemini-only tidak dipilih karena tergantung internet, memiliki kuota free-tier, menambah latensi, dan akan mengirim terlalu banyak gambar.

### 8.2 Dependensi Flutter

Tambahkan dependensi minimum:

- `camera` untuk preview dan stream kamera;
- `google_mlkit_object_detection` untuk deteksi lokal;
- `flutter_tts` untuk suara;
- permission kamera pada Android manifest.

Plugin Flutter ML Kit adalah wrapper komunitas atas SDK native Google. Pemrosesan deteksi tetap dilakukan oleh API ML Kit native di Android/iOS.

### 8.3 Halaman kamera

Buat halaman khusus `/asisten/pemandu-kamera`.

Tata letak:

- preview kamera memenuhi layar;
- header transparan berisi tombol kembali, judul **Pemandu Kamera**, dan indikator **Aktif**;
- overlay bawah berupa panel gelap berkontras tinggi;
- panel menampilkan kalimat utama, arah relatif, dan status koneksi;
- tombol **Hentikan Pemandu** berada di bagian bawah dengan target sentuh besar;
- tidak ada tombol shutter;
- seluruh elemen memiliki label TalkBack dan urutan fokus yang logis.

Contoh pesan:

```text
Orang terdeteksi di depan
Sedikit ke arah kiri
```

### 8.4 Siklus analisis

- ML Kit memproses stream kamera menggunakan mode tracking.
- Hanya satu frame diproses pada satu waktu; frame lain dilewati saat detector sibuk.
- Gemini dipanggil saat komposisi objek berubah atau setelah interval minimum 5–10 detik.
- Frame diperkecil dan dikompresi menjadi JPEG sebelum dikirim.
- Hanya satu request Gemini aktif pada satu waktu.
- Hasil lama dibatalkan atau diabaikan jika halaman telah ditutup.
- Kalimat yang sama tidak dibacakan berulang.
- Text-to-speech memakai cooldown agar tidak saling menimpa.
- Getaran dipakai hanya untuk peringatan penting, bukan setiap objek.

### 8.5 Kontrak endpoint vision

Tambahkan endpoint:

```http
POST /api/v1/assistant/vision
Content-Type: image/jpeg
```

Konteks singkat seperti bahasa dan label lokal dapat dikirim lewat header atau query parameter yang dibatasi. Body berupa byte JPEG mentah untuk menghindari dependency multipart tambahan.

Respons:

```json
{
  "success": true,
  "data": {
    "spokenText": "Ada orang di depan, sedikit ke kiri.",
    "hazardLevel": "warning",
    "objects": ["person"],
    "direction": "left"
  }
}
```

Nilai `hazardLevel`: `info`, `warning`, atau `critical`. Nilai `direction`: `left`, `center`, `right`, atau `unknown`.

Backend harus:

- hanya menerima JPEG;
- membatasi body maksimal sekitar 1 MB;
- menerapkan rate limit per perangkat/IP;
- memakai structured output dan memvalidasi respons Gemini;
- membatasi output menjadi satu instruksi pendek;
- tidak mencatat isi gambar atau base64 ke log;
- mengembalikan error terstruktur untuk timeout, kuota, input invalid, dan Gemini unavailable.

### 8.6 Privasi dan keselamatan

- Frame kamera tidak disimpan di Neon atau filesystem backend.
- Hanya frame terpilih yang dikirim ke Gemini.
- Sebelum penggunaan pertama, jelaskan bahwa gambar akan diproses oleh layanan Google.
- Mode kamera tidak menyala diam-diam di background.
- Aplikasi tidak boleh berkata **aman untuk menyeberang** atau menjamin jalan bebas hambatan.
- Arah menggunakan istilah relatif: kiri, tengah, kanan.
- Jarak menggunakan kategori dekat/sedang/jauh, bukan meter presisi.
- Pesan tetap menyatakan bahwa fitur dapat keliru dan bukan pengganti tongkat, pendamping, petugas, atau alat bantu utama.

Jika internet atau kuota Gemini tidak tersedia, aplikasi tetap menjalankan ML Kit dan membacakan informasi lokal yang terbatas.

## 9. Hubungan Backend dan Neon

Neon adalah database, bukan tempat menjalankan Gemini atau server Express.

Alur akhir:

```text
APK Flutter
  -> backend Express HTTPS
      -> Neon untuk akun, stasiun, jadwal, peron, dan profil
      -> Gemini API untuk chat dan analisis frame terpilih
```

- Gambar kamera tidak masuk Neon.
- Preferensi aksesibilitas existing dapat dipakai untuk mengaktifkan pembacaan suara.
- API key Neon dan Gemini tidak pernah dimasukkan ke APK.
- Backend di-host pada layanan cloud gratis; target awal adalah Render atau layanan setara yang mendukung Node dan environment secret.
- APK memakai base URL HTTPS melalui konfigurasi build, bukan `localhost`.

## 10. Perbaikan Test Legacy

Test import Februari 2026 saat ini mencampur audit dataset normalized dengan jumlah `Schedule` legacy.

Perbaikannya:

- hapus `legacy` dari assertion audit dataset PDF;
- buat test terpisah untuk fixture fallback;
- jumlah fallback dibandingkan dengan `mobileScheduleData.length`, bukan angka hard-coded 205;
- jangan mengubah data PDF yang sudah lolos audit.

Tujuan perbaikan adalah membuat test merepresentasikan sumber data aktual, bukan sekadar mengganti 205 menjadi 28 tanpa konteks.

## 11. Urutan Implementasi

1. Perbaiki test legacy agar baseline test bersih.
2. Tambahkan model, migrasi, seed, dan resolver Peron.
3. Hubungkan field Peron ke API dan kartu jadwal.
4. Tambahkan floating button pada hasil perjalanan dan map preview line perjalanan tanpa mengubah layout map.
5. Perjelas highlight You Are Here tanpa mengubah layout map.
6. Tebalkan border navbar.
7. Modernisasi endpoint Gemini chat dan hubungkan UI Asisten ke backend.
8. Tambahkan kamera, ML Kit, TTS, permission, dan halaman pemandu.
9. Tambahkan endpoint vision serta fallback error/kuota.
10. Terapkan migrasi dan seed ke Neon.
11. Deploy backend ke cloud dan pasang URL HTTPS pada build Flutter.
12. Jalankan pengujian backend, Flutter, dan perangkat Android nyata.
13. Build APK demo.

Urutan ini menjaga aplikasi tetap dapat diuji setelah setiap tahap dan mencegah fitur kamera menutupi masalah data atau koneksi backend.

## 12. Pengujian

### Backend

- seluruh migrasi Prisma berhasil pada database kosong;
- seed bersifat idempotent;
- resolver Peron memilih tujuan spesifik sebelum aturan arah;
- jadwal tanpa aturan mengembalikan peron kosong;
- endpoint chat menangani API key kosong, timeout, dan kuota;
- endpoint vision menolak MIME selain JPEG dan body terlalu besar;
- output Gemini invalid tidak diteruskan ke APK;
- gambar tidak tersimpan dan tidak tercetak di log;
- seluruh test backend lolos.

### Flutter

- highlight stasiun berpindah sesuai pilihan;
- treatment highlight konsisten pada semua jenis node;
- floating button hanya muncul pada hasil perjalanan yang berhasil dan tidak menutupi navbar;
- menekan floating button membuka map preview serta tombol kembali mempertahankan hasil perjalanan;
- line perjalanan tetap berwarna dan line lain berubah abu-abu tanpa menghilangkan konteks map;
- opsi Semua Line memulihkan seluruh warna;
- kelompok line Bogor dan Cikarang menyorot seluruh segmen geometrinya;
- navbar memiliki border 2 px tanpa mengubah tinggi;
- kartu jadwal menampilkan **Peron N** atau **Peron belum tersedia**;
- state chat berhasil, loading, error, dan retry dapat diuji tanpa API nyata;
- halaman kamera memiliki state permission ditolak, loading, aktif, offline, error, dan berhenti;
- TTS tidak mengulang kalimat yang sama;
- kamera berhenti saat halaman ditutup/background;
- seluruh widget penting memiliki semantics TalkBack;
- seluruh test Flutter lolos.

### Perangkat nyata

- permission kamera tampil satu kali dan dapat dipulihkan setelah ditolak;
- preview tidak terbalik dan orientasi benar;
- ML Kit berjalan pada kamera live;
- Gemini memberi respons melalui backend cloud;
- TTS bahasa Indonesia terdengar jelas;
- mode offline tetap memberi deteksi lokal terbatas;
- APK dapat dipasang dan dibuka tanpa komputer developer.

## 13. Kriteria Selesai

Revisi dianggap selesai untuk demo apabila:

- map tetap utuh dan stasiun terpilih memiliki highlight You Are Here yang jelas;
- pengguna dapat membuka preview line perjalanan melalui floating button pada halaman hasil perjalanan, sementara line lain tetap terlihat dalam warna abu-abu;
- navbar memiliki batas atas yang tegas;
- jadwal Februari 2026 terbaca dari Neon dengan status otomatis yang jujur;
- informasi Peron tampil untuk stasiun prioritas dan fallback benar untuk lainnya;
- chat Asisten memakai backend Gemini nyata, bukan simulasi;
- kamera mulai otomatis setelah mode dibuka, mendeteksi objek, dan membacakan panduan;
- API key hanya berada di backend;
- backend dapat diakses lewat HTTPS publik;
- semua test dan build berhasil;
- APK demo berhasil diuji pada perangkat Android nyata.

## 14. Di Luar Scope Demo

- klaim posisi kereta real-time tanpa API operasional resmi;
- penentuan peron live pada saat terjadi perubahan operasi;
- navigasi keselamatan yang menjamin pengguna bebas hambatan;
- penyimpanan atau histori foto kamera;
- pemetaan peron semua stasiun tanpa sumber terverifikasi;
- penggantian total layout map.
