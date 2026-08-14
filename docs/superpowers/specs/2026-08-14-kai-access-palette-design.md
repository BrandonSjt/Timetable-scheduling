# KAI Access Palette Design

## Tujuan

Menyelaraskan seluruh antarmuka Flutter dengan palet KAI Access yang diberikan, tanpa mengubah warna resmi jalur transportasi atau makna warna status.

## Palet resmi

| Peran | Warna |
| --- | --- |
| Blue gradient | `#5A97EB` |
| Primary purple | `#7E4CDD` |
| Deep purple | `#6E42DE` |
| Magenta | `#C84DAE` |
| Pink accent | `#CD599D` |
| Surface | `#FFFFFF` |
| Text utama | `#303040` |
| Border | `#E5E6EE` |

Gradient utama memakai arah kiri-atas ke kanan-bawah dengan urutan `#5A97EB`, `#7E4CDD`, lalu `#C84DAE` dan stop `0`, `0.55`, `1`.

## Sistem peran warna

- Aksi utama dan kontrol terpilih memakai `#7E4CDD`; warna ini tetap memiliki kontras yang memadai terhadap teks putih.
- `#6E42DE` dipakai untuk pressed state atau penegasan aksi, bukan sebagai warna dekorasi tambahan.
- `#5A97EB` dipakai untuk focus, informasi, dan awal gradient.
- `#C84DAE` serta `#CD599D` dipakai sebagai aksen terbatas dan akhir gradient.
- Latar aplikasi memakai netral sangat terang; card tetap putih dengan border `#E5E6EE`.
- Teks utama memakai `#303040`. Teks sekunder dan hint tetap netral yang lebih ringan agar hierarki baca terjaga.
- Warna sukses, peringatan, error, dan aksesibilitas tetap semantik.

## Cakupan

1. Menambahkan token palet, gradient, dan semantic role ke `AppColors`.
2. Memperluas `AppTheme` untuk button, chip, navigation, progress, selection, focus, input, dan floating action controls.
3. Mengganti warna UI lama yang masih hardcoded dengan token tema pada layar tiket, profil, autentikasi, dan komponen bersama.
4. Memastikan navbar, tombol, chip aktif, header, input focus, dan state terpilih memakai sistem baru secara konsisten.
5. Menambahkan pengujian kontrak warna agar nilai palet resmi tidak berubah tanpa sengaja.

## Di luar cakupan

- Warna jalur KRL, MRT, LRT Jabodebek, dan LRT Jakarta.
- Warna badge yang merepresentasikan moda atau jalur transportasi.
- Struktur layout, data, navigasi, API, Dijkstra, dan backend.
- File backup `lib/shared/widgets/schematic_map_painter_backup.dart`.

## Kriteria penerimaan

- Semua delapan warna dari referensi tersedia sebagai token tunggal.
- Elemen aksi/selection tidak lagi memakai biru atau oranye lama secara langsung.
- Gradient utama tampil konsisten dan tidak dipakai sebagai latar setiap card.
- Warna resmi seluruh jalur dan overlay transit pejalan kaki tidak berubah.
- Teks putih hanya dipakai pada permukaan yang memiliki kontras memadai; gradient dipakai untuk aksen besar atau konten berukuran sesuai.
- `flutter analyze` dan pengujian tema serta widget terkait lulus.

