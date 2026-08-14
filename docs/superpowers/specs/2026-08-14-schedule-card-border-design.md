# Schedule Card Border Design

## Tujuan

Memperjelas batas setiap kartu jadwal tanpa mengubah layout, warna resmi jalur, atau hierarchy komponen lain.

## Perubahan

- Hanya border luar `ScheduleCard` yang diperkuat.
- Warna memakai tint ungu yang selaras dengan palette existing.
- Ketebalan border berubah dari 1 menjadi 1.25 dp.
- Border kotak waktu, pencarian, filter, dan platform tetap seperti sekarang.
- Shadow, radius, spacing, serta isi kartu tidak berubah.

## Implementasi

Perubahan dilakukan langsung pada `lib/features/timetable/presentation/widgets/schedule_card.dart` tanpa dependency, abstraction, atau token global baru.

## Verifikasi

- Widget test memastikan border luar memakai warna dan ketebalan baru.
- `flutter analyze` dan test timetable terkait harus lulus.
- Halaman dijalankan pada emulator untuk inspeksi visual.
