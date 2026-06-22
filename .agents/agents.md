# Rancangan Arsitektur: Prototype Akademik Aplikasi Transportasi (KAI Access Prototype)

Dokumen ini berisi usulan arsitektur dan rencana implementasi awal untuk aplikasi *time table* dan perencanaan rute KRL, MRT, dan LRT. Rencana ini disusun untuk memastikan struktur proyek rapi dan meminimalisir kesalahan selama masa pengembangan 6 minggu ke depan.


## 1. Goal Description
Membangun MVP (Minimum Viable Product) aplikasi *mobile offline-first* untuk memandu perjalanan multimoda di Jakarta. Aplikasi berfokus pada pencarian rute, estimasi tarif, peta skematik, panduan aksesibilitas (VoiceOver/TalkBack, TTS), dan simulasi pembayaran QRIS lokal. Tidak ada integrasi backend (API/Database Cloud) pada fase MVP ini.

## 2. Open Questions & User Review Required

Mohon review dan berikan jawaban untuk beberapa poin berikut sebelum kita mulai membuat *codebase*:

1. **Repositori & Branch**: Anda menyebutkan `Timetable-scheduling` dan `Sistem-by-Access-KAI`. Apakah ini nama repositori GitHub yang akan digunakan, atau nama *branch*?
2. **Penyimpanan Data Awal**: Karena *offline-first*, apakah data *dummy* rute dan stasiun akan disimpan di aset JSON yang kemudian di-*load* ke SQLite/Drift saat aplikasi pertama kali dibuka?
3. **Nama Proyek Flutter**: Apakah ada nama spesifik untuk inisialisasi proyek Flutter (misal: `kai_access_prototype`), atau kita gunakan nama standar `transit_kita`?

## 3. Proposed Architecture & Folder Structure

Kita akan menggunakan pendekatan **Feature-First Architecture** yang sangat cocok dikombinasikan dengan **Riverpod** untuk memisahkan *logic*, *state*, dan UI.

### Tech Stack Utama
*   **Framework**: Flutter & Dart
*   **State Management & Dependency Injection**: `flutter_riverpod` (direkomendasikan menggunakan `riverpod_generator` dan `riverpod_annotation`).
*   **Routing**: `go_router` (mendukung *deep linking* dan navigasi berbasis *path*).
*   **Database Lokal**: `drift` (ORM SQLite tipe-aman untuk Dart).
*   **Peta Skematik**: `CustomPainter` + `InteractiveViewer` + `GestureDetector`.
*   **Aksesibilitas**: `flutter_tts` (Text-to-Speech) dan `Semantics` (TalkBack/VoiceOver).

### Struktur Folder (Draft)
```text
lib/
├── core/                       # Kode yang digunakan di seluruh fitur
│   ├── routing/                # Konfigurasi GoRouter (router.dart, routes.dart)
│   ├── database/               # Konfigurasi Drift SQLite (database.dart, tables.dart)
│   ├── theme/                  # Warna, Typography, ThemeData
│   ├── utils/                  # Helper functions, formatter tarif/waktu
│   └── services/               # Layanan eksternal (TTS Service, Haptic Service)
├── features/                   # Modul berdasarkan fitur (Feature-first)
│   ├── stations/               # Pencarian stasiun, daftar stasiun
│   │   ├── presentation/       # UI (Widgets, Screens)
│   │   ├── providers/          # Riverpod State/Controllers
│   │   └── data/               # Repository untuk stasiun (dari Drift)
│   ├── journey_planner/        # Logika Dijkstra/Pencarian rute multimoda
│   ├── map/                    # Peta Skematik (CustomPainter) & Interaksinya
│   ├── tickets/                # Simulasi QRIS, Mock Payment, Tiket lokal
│   └── settings/               # Pengaturan aksesibilitas (Guest mode, Voice settings)
├── shared/                     # UI components yang dipakai berulang (Buttons, Cards)
└── main.dart                   # Entry point aplikasi
```

## 4. Rencana Implementasi Bertahap

Jika arsitektur ini disetujui, kita akan mengeksekusi dengan urutan berikut:

1. **Inisialisasi Proyek**: Membuat proyek Flutter baru, mengatur `pubspec.yaml` dengan *dependencies* yang disepakati (Riverpod, GoRouter, Drift).
2. **Setup Core**: Konfigurasi `go_router` untuk navigasi dasar dan setup awal `drift` untuk database lokal.
3. **Data Seeder**: Membuat skema database dan fungsi untuk memuat data JSON stasiun/jalur dummy ke dalam SQLite saat *first run*.
4. **Pengembangan Fitur**:
   - Pencarian stasiun & rute.
   - Peta Skematik (menggambar line & node stasiun).
   - *Journey Details* dan integrasi `flutter_tts` & `Semantics`.
   - *Mock Payment* / Tiket lokal.

## 5. Verification Plan

*   **Pengecekan Build**: Memastikan aplikasi bisa di-*build* (Android APK/AppBundle) tanpa *error*.
*   **Test Aksesibilitas**: UI harus dirancang sejak awal menggunakan `Semantics` widget untuk mendukung navigasi *screen reader* (TalkBack/VoiceOver).
*   **Test Offline**: Memastikan rute dan *dummy* QRIS berfungsi normal dalam mode pesawat (tanpa internet).
*   **Pengecekan Arsitektur**: Memastikan tidak ada *business logic* yang tercampur di *UI layer*, semuanya dikelola oleh Riverpod *providers*.
