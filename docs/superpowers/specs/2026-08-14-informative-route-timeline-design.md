# Informative Route Timeline Design

## Tujuan

Membuat timeline hasil rute lebih mudah dipahami tanpa mengubah bahasa visual halaman yang sudah ada. Pengguna harus dapat membedakan perjalanan dengan kereta, perpindahan line, dan transit berjalan kaki. Informasi yang sama juga menjadi sumber narasi TTS.

## Batasan

- Pertahankan card, tipografi, radius, warna permukaan, dan spacing halaman hasil rute saat ini.
- Jangan mengubah geometri peta, hubungan node, atau warna resmi setiap line.
- Data timeline berasal dari hasil Dijkstra backend, bukan dirakit ulang dari data dummy mobile.
- Aplikasi tetap dapat membaca respons lama secara aman selama transisi kontrak API.

## Kontrak langkah perjalanan

Backend mengirim setiap langkah dengan `kind` yang eksplisit:

- `board`: naik dari stasiun awal menggunakan line tertentu.
- `transfer`: berpindah line, baik pada stasiun yang sama maupun berjalan ke stasiun lain.
- `continue`: melanjutkan perjalanan menggunakan line setelah transit.
- `arrive`: tiba di tujuan.

Setiap langkah tetap memiliki teks utama, detail, durasi, ikon, dan warna. Field boolean lama dipertahankan sementara agar kompatibel, sedangkan mobile memprioritaskan `kind` dan memiliki fallback dari field lama.

## Penyusunan rute backend

Hasil lintasan Dijkstra dipecah menjadi leg perjalanan berdasarkan edge transit:

1. Buat langkah `board` pada titik awal.
2. Jumlahkan durasi edge kereta sampai titik transit atau tujuan leg.
3. Buat langkah `transfer` untuk edge perpindahan:
   - Stasiun sama: `Pindah peron di {stasiun}`.
   - Stasiun berbeda: `Berjalan dari {asal} menuju Stasiun {tujuan}`.
4. Setelah transit, buat langkah `continue`: `Lanjut naik {nama line}` dengan tujuan leg berikutnya dan durasi perjalanan leg tersebut.
5. Akhiri dengan langkah `arrive` yang menampilkan total durasi rute.

Arah perjalanan ditulis sebagai `menuju {transit berikutnya atau tujuan akhir}`. Sistem tidak mengarang terminal atau headsign yang belum tersedia dari sumber data operasional.

## Tampilan mobile

Timeline menggunakan susunan card yang sekarang dengan rail vertikal di sebelah kiri:

- Segmen kereta: garis solid memakai warna resmi line.
- Transit berjalan kaki: garis putus-putus abu-abu dengan ikon berjalan.
- Transit pada stasiun yang sama: penanda transfer tanpa klaim berjalan antarstasiun.
- Titik naik, lanjut naik, dan tiba memiliki marker yang berbeda tetapi tetap mengikuti ukuran dan gaya UI sekarang.

Warna tidak menjadi satu-satunya pembeda. Nama line, teks aksi, ikon, dan pola garis tetap tersedia untuk aksesibilitas.

## TTS dan semantik

TTS membaca urutan langkah yang sama dengan tampilan:

- aksi pengguna;
- nama line;
- stasiun atau tujuan leg;
- durasi perjalanan atau waktu berjalan.

Label semantik setiap item juga menyatukan informasi tersebut agar dapat dibaca pembaca layar.

## Penanganan kegagalan

- Respons tanpa `kind` tetap dipetakan dari field boolean lama.
- Langkah dengan data opsional yang kosong tidak menggagalkan seluruh halaman.
- Kegagalan API tetap menggunakan pesan yang sudah disepakati: `Tidak dapat memuat rute. Periksa koneksi dan coba lagi.`

## Verifikasi

- Unit test backend untuk rute tanpa transit, transit satu stasiun, dan transit berjalan kaki.
- Unit test parsing model mobile untuk kontrak baru dan fallback lama.
- Widget test memastikan urutan board–transfer–continue–arrive serta jenis konektor.
- Test TTS memastikan narasi mengikuti langkah backend.
- `npm test`, build TypeScript, `flutter test` terfokus, dan `flutter analyze`.
- Snapshot/invariant peta memastikan line, node, koneksi, dan warna resmi tidak berubah.
