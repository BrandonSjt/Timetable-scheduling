# Pemandu Tunanetra dan Dummy Chat Petugas

## Tujuan

Perubahan ini mengganti menu Aksesibilitas di halaman Akun dengan akses langsung ke Pemandu Tunanetra. Pemandu tersebut memakai fitur Pemandu Kamera yang sudah ada dan mengaktifkan panduan suara ketika kamera siap. Perubahan ini juga mengisi alur chat petugas dengan contoh data yang sesuai untuk setiap topik.

## Ruang lingkup

- Hapus menu Aksesibilitas dari halaman Akun.
- Hapus jalur navigasi internal `/aksesibilitas` dan halaman pengaturan lama yang berisi pilihan teks besar serta pembacaan rute.
- Pertahankan field `accessibilityEnabled` pada model akun dan kontrak backend agar perubahan UI tidak merusak kompatibilitas data.
- Tambahkan menu `Pemandu Tunanetra` pada posisi menu Aksesibilitas sebelumnya.
- Arahkan menu baru ke Pemandu Kamera melalui jalur yang menandai bahwa pengguna datang dari halaman Akun.
- Aktifkan kamera dan ucapkan status awal secara otomatis setelah kamera siap.
- Tambahkan data contoh untuk chat tiket, jadwal, dan pembayaran.
- Jalankan aplikasi pada emulator Android Pixel 9 setelah analisis dan pengujian lulus.

## Navigasi Pemandu Tunanetra

Halaman Akun menampilkan menu `Pemandu Tunanetra` dengan ikon tunanetra dan keterangan singkat bahwa kamera serta panduan suara akan aktif otomatis. Ketukan pada menu membuka Pemandu Kamera yang sudah dipakai oleh halaman Asisten.

Navigasi dari halaman Akun membawa parameter khusus, misalnya `autoVoice=true`. Router meneruskan nilai tersebut kepada `CameraGuidePage`. Akses Pemandu Kamera dari halaman Asisten tetap memakai perilaku yang ada, sehingga perubahan ini hanya memperluas jalur dari Akun.

`CameraGuidePage` tetap memulai kamera saat halaman terbuka. Ketika controller mencapai status aktif, halaman meminta controller mengucapkan satu pengumuman awal, seperti `Pemandu kamera aktif. Arahkan kamera ke depan.` Pengumuman ini hanya berbunyi sekali untuk satu pembukaan halaman. Hasil deteksi objek berikutnya tetap memakai alur text-to-speech yang sudah ada.

Jika izin kamera ditolak atau kamera gagal dimulai, halaman menampilkan pesan kesalahan dan tombol coba lagi. Aplikasi tidak mengucapkan status aktif sebelum kamera benar-benar siap.

## Penghapusan Aksesibilitas Lama

Implementasi menghapus entri menu, import router, definisi rute `/aksesibilitas`, dan halaman `AccessibilityPage`. String lokalisasi lama boleh tetap berada di katalog untuk menghindari perubahan besar pada file hasil generate, tetapi tidak boleh tampil atau dapat dicapai dari UI.

## Dummy Data Chat Petugas

Setiap `SupportChatTopic` menyediakan satu sumber data contoh. Halaman pemilihan chat dan halaman percakapan membaca sumber yang sama agar isi `Data yang dikirim` selalu sama dengan pesan data yang diterima petugas.

Data contoh mengikuti topik:

- Tiket: kode tiket, rute, tanggal perjalanan, dan status tiket.
- Jadwal: stasiun keberangkatan, tujuan, nomor kereta, waktu keberangkatan, dan peron.
- Pembayaran: ID transaksi, metode pembayaran, nominal, waktu transaksi, dan status pembayaran.

Nilai contoh memakai format yang masuk akal untuk demo aplikasi. Contoh tiket dapat memakai rute Manggarai–Tanah Abang; contoh jadwal dapat memakai keberangkatan dari Manggarai menuju Jakarta Kota; contoh pembayaran dapat memakai nominal Rp7.800 melalui QRIS.

Saat percakapan dibuka, timeline menampilkan urutan berikut:

1. Pesan awal pengguna sesuai topik.
2. Sapaan petugas sesuai topik.
3. Pesan petugas berjudul `Data yang diterima` yang memuat data contoh persis seperti bagian `Data yang dikirim`.

Pengguna tetap dapat mengetik pesan lanjutan. Balasan dummy berbasis kata kunci yang sudah ada tetap berfungsi.

## Struktur Kode

- `ProfilePage` mengatur label, ikon, deskripsi, dan deep-link menu baru.
- Router membaca parameter aktivasi suara dan membuat `CameraGuidePage` dengan konfigurasi yang sesuai.
- `CameraGuidePage` mengatur pengumuman awal satu kali setelah controller aktif.
- `CameraGuideController` menyediakan operasi pengucapan yang dapat diuji tanpa menduplikasi logika TTS.
- `SupportChatTopic` menjadi sumber tunggal data contoh per topik.
- `HelpChatPage` menampilkan data contoh pada bagian `Data yang dikirim`.
- `SupportChatConversationPage` menambahkan data tersebut ke pesan awal petugas.

## Pengujian

Widget test memverifikasi bahwa halaman Akun tidak lagi menampilkan Aksesibilitas, menampilkan Pemandu Tunanetra, dan mengarah ke Pemandu Kamera dengan mode suara otomatis. Test controller atau widget kamera memverifikasi bahwa pengumuman awal hanya terjadi setelah kamera aktif dan hanya sekali.

Test chat memverifikasi data contoh untuk tiket, jadwal, dan pembayaran. Setiap test membandingkan teks pada `Data yang dikirim` dengan pesan data awal dalam percakapan. Test yang sudah ada harus tetap lulus.

Setelah perubahan, jalankan formatter, `flutter analyze`, test terarah, dan seluruh test suite. Terakhir, mulai emulator Pixel 9 dan jalankan aplikasi agar pengguna dapat meninjau hasilnya.

## Kriteria Selesai

- Halaman Akun tidak menampilkan atau membuka pengaturan Aksesibilitas lama.
- Menu Pemandu Tunanetra membuka Pemandu Kamera.
- Kamera mulai otomatis dan suara awal berbunyi setelah kamera siap saat dibuka dari Akun.
- Bagian `Data yang dikirim` berisi dummy data sesuai topik.
- Percakapan langsung menampilkan dummy data yang sama sebagai pesan petugas.
- Analisis dan pengujian lulus.
- Aplikasi berjalan pada emulator Android Pixel 9.
