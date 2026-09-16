# Cakupan jadwal KRL dan asisten — 16 September 2026

## Status dan ruang lingkup

Implementasi pada branch `dev1-riyadh`, dengan publikasi GitHub mengikuti permintaan pengguna setelah verifikasi. Commit progres mencakup jadwal/asisten, voice, GPS, navbar, tes dan dokumentasi yang masih lokal. Publikasi repository bukan deployment backend teman: tidak ada penggantian `.env`, re-import, seed ulang, atau perubahan data Neon dalam pekerjaan ini. Dokumen memakai path relatif repository agar dapat digunakan di fork lain.

Tujuan: menghubungkan seluruh sumber jadwal KRL Februari 2026, bukan hardcode satu contoh Jurangmangu → Jakarta Kota. Ini bukan implementasi posisi kereta real-time. Data Februari belum diverifikasi sebagai jadwal operasional terbaru pada September 2026.

## Bukti audit sumber dan database

Sumber: `Jadwal Commuter Line Jabodetabek Update Februari 2026.pdf`. Seluruh tabel dari 13 halaman diekstrak kembali dalam memori dengan `timetable_backend/scripts/extract_commuter_timetable.py`, divalidasi, dan setiap objek service/stop dibandingkan dengan `timetable_backend/prisma/data/commuter-2026-02.json`.

SHA-256: `327fb2770786ca6935fe4b84a9ea23dbe8d799b822c7c12d83e257941f777dc5`.

- 1.145 service/perjalanan KA: Bogor 392, Cikarang 365, Rangkasbitung 204, Tangerang 120, Tanjung Priok 64.
- 19.328 catatan stop: 18.985 bertimestamp dan 343 pass-through. Ini bukan 19.328 perjalanan KA berbeda.
- 85 kode stasiun sumber, dengan 84 stasiun naik/turun. Gambir hanya dilintasi; jangan ditawarkan sebagai asal/tujuan naik KRL.
- 33 service khusus hari kerja; weekend menampilkan 1.112 service DAILY. Hari kerja menampilkan DAILY + WEEKDAY, 1.145 service.
- Nomor lanjutan, loop, 21 service lintas tengah malam, catatan full-racket, dan anomali sumber tetap disimpan, bukan dibuang atau diperbaiki dengan tebakan. Contoh anomali KA 5020A dipertahankan: waktu CKR 06:24 dan catatan 06:31.

Audit database membandingkan setiap field service, urutan stop, timestamp, pass-through, kode/slug stasiun, serta flag kalender. Hasil cocok seluruhnya. Audit graph memeriksa 7.056 kombinasi keterjangkauan terarah (84 × 84, termasuk diri sendiri); ini bukan 7.056 tes HTTP/jawaban chat.

## Penyebab jadwal terlihat sedikit

Database bukan kehabisan storage: dataset lengkap sudah ada. Repository Flutter sebelumnya mengembalikan contoh lokal saat filter Semua Stasiun dan memakai fallback contoh saat request gagal. Request per stasiun hanya mengambil halaman pertama, maksimal 100, serta mengabaikan `meta.total`. Picker menggunakan daftar stasiun pendek yang di-hardcode.

## Perubahan aplikasi/API

- `GET /api/v1/schedules` tanpa station/stationId sekarang menampilkan satu baris per service KRL, memakai pemberhentian awal bertimestamp. Filter satu stasiun menampilkan seluruh catatan bertimestamp di stasiun tersebut. Perbedaan cakupan ini dijelaskan di UI.
- Global API mempunyai pagination stabil, filter weekday/weekend, dan `meta.scope=services`, `meta.datasetVersion`, `meta.total`.
- ID baris global adalah service ID. ID baris per stasiun adalah stop-time ID: satu KA dapat melewati stasiun yang sama beberapa kali. Jangan deduplikasi menggunakan trainNumber/serviceId untuk catatan per stasiun.
- Flutter mengambil seluruh halaman dengan filter yang sama; menolak halaman gagal/kosong sebelum selesai, nomor halaman salah, ID duplikat, total berubah atau datasetVersion berubah. Tidak menampilkan hasil setengah lengkap sebagai hasil sukses.
- Tidak ada lagi fallback otomatis contoh lokal. Kegagalan server tetap error dengan retry, hasil kosong tetap kosong.
- Katalog stasiun juga mengikuti pagination. Picker memakai katalog server, menunggu load awal, memiliki error/retry dan menjaga Material ink serta inset navigasi sistem.
- Jadwal diurutkan `dayOffset`, kemudian waktu; list memakai builder lazily. Mengambil semua service kecil ini bukan menginstansiasi semua kartu sekaligus.

File utama: `lib/features/timetable/data/datasources/timetable_remote_data_source.dart`, `lib/features/search_station/data/datasources/station_remote_data_source.dart`, `lib/features/timetable/data/repositories/timetable_repository_impl.dart`, `lib/features/timetable/presentation/pages/timetable_page.dart`, dan `timetable_backend/src/presentation/controllers/scheduleController.ts`.

## Perubahan asisten

- Resolver station dipakai bersama oleh rute dan jadwal. Lookup exact tetap didahulukan, kemudian pencocokan katalog yang konservatif untuk spasi, prefix Stasiun, serta typo yang jelas.
- Nama panjang minimal 6 karakter dapat dikoreksi jika hanya satu kandidat cukup dekat dengan margin jelas. Maksimal 1 edit untuk nama pendek atau 2 edit untuk nama minimal 9 karakter; transposisi huruf dihitung. Kode pendek tidak di-fuzzy-match. Kandidat ambigu tidak dipilih diam-diam.
- Nama kawasan seperti Bintaro tetap meminta pilihan stasiun. Tidak mengklaim Bintaro sebagai station, atau menganggap hint kawasan sebagai lokasi GPS paling dekat secara pasti.
- Jawaban route memakai langkah, tarif dan estimasi dari `RouteService`, dikemas hangat dengan emoji ringan dan nama stasiun canonical. Route yang sudah diketahui tidak membutuhkan request Gemini/API key. Gemini tetap dipakai untuk percakapan yang tidak memiliki fakta route/jadwal deterministik.
- Parsing mendukung urutan asal/tujuan terbalik, filler umum, jawaban nama stasiun setelah klarifikasi asal/tujuan, penggantian salah satu endpoint, dan follow-up jadwal. History berasal dari request Flutter, maksimal 6 turn; tidak disimpan sebagai sesi di Neon. Konteks di luar window itu belum dijamin bertahan.
- Jadwal asisten diambil dari dataset resmi aktif. Gangguan database tidak diubah menjadi contoh lokal atau dianggap jadwal kosong. Error lookup server tidak disamarkan menjadi stasiun tidak ditemukan.
- Untuk perjalanan transit, daftar jadwal diarahkan ke tujuan leg pertama dari route backend. Stop tujuan harus berada sesudah stop asal, bukan hanya ada di service. Catatan terminal yang tidak memiliki stop lanjutan tidak ditawarkan oleh asisten sebagai kereta untuk dinaiki.
- Jawaban jadwal adalah beberapa contoh waktu terjadwal PDF, bukan hasil kalkulasi kereta berikutnya saat ini. Header/footer menyatakan ini dan mengarahkan pengguna ke halaman Jadwal untuk daftar lengkap. Tidak menyimpulkan tidak ada service langsung hanya berdasarkan 5–6 contoh.
- Peron kosong tetap tidak diketahui. Tidak mengarang peron, keterlambatan, layanan normal live, atau kondisi perjalanan aman.

File utama: `timetable_backend/src/domain/services/stationNameMatching.ts`, `assistantService.ts`, `routeService.ts`.

## Jatake: perbaikan graph tanpa merusak schematic map

Jatake ada di sumber/Neon tetapi tidak mempunyai StationNode yang drawable. `timetable_backend/src/domain/services/timetableGraph.ts` menyuplai node routing sementara, tanpa menulis ke database atau mengarang koordinat peta.

Koneksi diturunkan hanya dari pasangan stop bertimestamp yang berurutan, pada line yang sama, dengan waktu positif. Median waktu observasi dipakai sebagai estimasi, bukan jaminan durasi aktual. Kedua arah harus benar-benar ada dalam sumber. Bypass graph lama Cicayur ↔ Parung Panjang disisihkan ketika sumber membuktikan stop Jatake di antaranya, sehingga stationSequence tidak melewatkan Jatake. Graph yang disimpan di DB tetap tidak diubah.

Jatake kini dapat menjadi asal, tujuan dan stop antara. Tetapi node/map highlight/penanda lokasi khusus Jatake BELUM tergambar. Jangan mengklaim preview map semua station sudah sempurna. Penambahan node drawable perlu pekerjaan tersendiri yang mempertahankan layout existing dan pengujian segment highlight.

## Verifikasi yang dijalankan

Dari folder backend:

```sh
npm run build
npm test
npm run timetable:audit
npm run timetable:audit-api -- --isolated
```

`timetable:audit` read-only. Harness API `--isolated` menjalankan controller sebenarnya di HTTP loopback port sementara, memakai database yang dikonfigurasi, tanpa mematikan limiter server aplikasi. Tidak menjalankan reimport atau request Gemini untuk route deterministik. Ini bukan pengujian auth/rate-limit atau availability production.

Hasil: build sukses, 85 tes backend lulus, audit semua record cocok. Harness 124 request lulus: seluruh halaman global weekday/weekend, total jadwal seluruh 84 stasiun boarding, seluruh 634 catatan Manggarai lintas 7 halaman, tujuh kasus route dari kelima line KRL, serta jadwal leg pertama Jurangmangu → Jakarta Kota. Audit HTTP massal terhadap server biasa sebelumnya mencapai HTTP 429; tidak dilakukan retry burst. Gunakan harness untuk audit massal, bukan endpoint produksi.

Dari root aplikasi: `flutter analyze` tanpa issue, `flutter test` 271 tes lulus. `git diff --check` bersih. Emulator yang sudah terbuka di-hot-restart; halaman jadwal dan picker katalog server diperiksa. Backend lokal tetap berjalan port 3000; deployment teman belum diubah.

Kasus route smoke: Jurangmangu (termasuk `jruangmangu`) → Jakarta Kota; Bogor → Jakarta Kota; Bekasi → Sudirman; Tangerang → Manggarai; Tanjung Priok → Jakarta Kota; Rangkasbitung → Tanah Abang; Jatake → Jakarta Kota. Unit test juga memakai seluruh nama/slug katalog boarding KRL, typo lintas line, ambiguity, unknown area/code, same-session replacement dan klarifikasi kawasan/bare station.

## Yang masih perlu dilanjutkan

1. Deploy backend ini bersama teman, lalu test ulang API yang benar-benar digunakan APK. Neon adalah database, bukan host Express. Jangan menganggap update lokal sudah mengubah layanan deployed.
2. Tambahkan Jatake ke drawable schematic node dengan review layout dan tes highlight per segmen. Node routing sementara bukan node map/GPS.
3. Bangun matriks ujaran manusia lebih luas: slang, ejaan STT, nama kawasan ambigu, jawaban satu kata, endpoint berubah berkali-kali, percakapan melewati 6 turn, serta pertanyaan beberapa tujuan sekaligus. Tes yang lulus saat ini tidak membuktikan semua bahasa percakapan manusia ditangani.
4. Pisahkan tampilan kedatangan terminal dan keberangkatan sebenarnya di halaman Jadwal. Sumber tabel memberi timestamp stasiun; saat ini akses seluruh catatan bertimestamp masih mencakup kedatangan terminal. Asisten sudah menolak menawarkan terminal tanpa stop lanjutan untuk dinaiki.
5. Jika perlu fitur “kereta berikutnya saat ini”, tambahkan kalkulasi tanggal/waktu WIB, kalender hari libur nasional yang terverifikasi, asal hari service lintas tengah malam dan cache invalidation. Filter weekday/weekend bukan kalender libur nasional lengkap. Jangan mengganti header contoh terjadwal menjadi “berikutnya” sebelum ini teruji.
6. Peron resmi belum lengkap; metadata/full-racket/catatan PDF belum seluruhnya ditampilkan di kartu. Jangan mengisi dengan tebakan. English reply route masih memakai teks langkah Indonesia dari backend; perlu formatter multibahasa yang tidak mengubah fakta.
7. Benchmark end-to-end sebelum mengklaim target 0,2 detik. Audit lokal memperlihatkan query jaringan/database dan pengambilan halaman dapat jauh lebih lama. Graph supplement saat ini dimuat dari sumber aktif saat route dihitung; belum dioptimalkan dengan cache versi/TTL. Semua halaman di-fetch berurutan; pagination UI/cache tervalidasi bisa menjadi optimasi berikutnya tanpa kehilangan data.
8. Mode LRT/MRT tetap memakai data legacy, bukan PDF commuter ini. Filter Semua global pada pekerjaan ini berarti dataset KRL PDF, bukan bukti kelengkapan semua moda.

Jangan memasukkan `.env`, API key, connection string, gambar kamera, atau riwayat lokasi pengguna dalam commit/dokumen. Jangan menjalankan seed/reimport destruktif hanya karena hitungan UI terlihat kecil.
