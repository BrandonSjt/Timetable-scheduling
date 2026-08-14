# Account Page KAI Access-Inspired Design

## Tujuan

Merancang ulang halaman Akun agar memiliki hierarki seperti KAI Access tanpa mengubah identitas visual, autentikasi, navigasi, atau fitur yang sudah tersedia pada aplikasi.

## Prinsip

- Mengadaptasi struktur referensi, bukan menyalin tampilan atau menambahkan fitur palsu.
- Menggunakan `AppColors`, tipografi, radius, dan bottom navigation existing.
- Pembelian tiket tetap tersedia bagi guest; akun hanya fitur pendukung.
- Seluruh target sentuh minimal 48 dp dan konten tetap aman pada teks besar serta nama panjang.

## Struktur Halaman

1. Header gradient bermerek dengan judul Akun dan status guest/login.
2. Card identitas yang overlap dengan bagian bawah header.
3. Daftar menu pengaturan dan bantuan.
4. Tombol keluar khusus pengguna login.
5. `AppBottomNavBar` existing dengan indeks Akun tetap 4.

## Card Identitas

### Pengguna login

- Avatar berisi inisial nama; fallback menggunakan email.
- Nama dan email ditampilkan dengan ellipsis yang aman.
- Status akun aktif atau offline tetap terlihat.
- Dua quick action: `Lihat Profil` dan `Riwayat Tiket`.
- Logout tidak diletakkan di dalam identitas agar aksi destruktif tidak bercampur dengan aksi utama.

### Guest

- Avatar guest dan label `Tamu`.
- Copy existing menegaskan peta, jadwal, dan pembelian tiket tidak membutuhkan login.
- Tombol utama `Masuk atau Buat Akun` menuju route existing `/masuk`.
- Riwayat tiket lokal tetap dapat diakses dari daftar menu.

## Daftar Menu

Menu memakai satu surface putih seperti daftar KAI Access, dipisahkan divider tipis dan tidak menjadi card terpisah-pisah:

- Riwayat tiket: `/riwayat-tiket`.
- Bahasa: `/bahasa`.
- Aksesibilitas: `/aksesibilitas`.
- Pusat Bantuan: `/pusat-bantuan`.

Setiap baris memiliki ikon, judul, subtitle singkat existing, chevron, semantics button, dan area sentuh minimal 48 dp.

## Logout

Pengguna login melihat baris `Keluar` berwarna status merah pada bagian bawah daftar. Dialog konfirmasi dan perilaku logout existing dipertahankan. Guest tidak melihat baris ini.

## Responsif dan Aksesibilitas

- Halaman memakai satu `CustomScrollView`/`ListView`; navbar tetap berada di bawah.
- Nama panjang, email, dan status tidak menyebabkan overflow.
- Text scaling didukung melalui layout fleksibel dan quick action yang dapat membagi ruang secara merata.
- Informasi tidak hanya dibedakan lewat warna; ikon dan teks tetap tersedia.

## Batasan Scope

- Tidak menambah QR akun, premium membership, passenger list, face recognition, password change, atau payment method karena belum memiliki fitur/route production.
- Tidak mengubah backend, kontrak autentikasi, route aplikasi, atau bottom navigation.
- Tidak mengubah halaman lain selain penyesuaian test yang langsung memvalidasi halaman Akun.

## Verifikasi

- Widget test untuk state guest dan login.
- Widget test untuk quick action, menu existing, dan visibilitas logout.
- Test nama panjang dan ukuran layar mobile untuk memastikan tidak overflow.
- `flutter analyze`, test terfokus, dan debug APK build.
- Detector UI dijalankan satu kali setelah implementasi selesai.
