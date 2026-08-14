# Account Page KAI Access-Inspired Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mengubah halaman Akun menjadi layout KAI Access-inspired yang konsisten dengan palette dan fitur existing untuk state guest maupun pengguna login.

**Architecture:** `ProfilePage` tetap membaca `AuthScope` dan `LocaleScope`, tetapi presentasi dipecah menjadi header, identity card, quick actions, dan satu menu section. Seluruh route serta autentikasi existing dipakai langsung; tidak ada backend atau fitur fiktif baru.

**Tech Stack:** Flutter, Dart, Material 3, GoRouter, Flutter localization, Flutter widget tests.

---

### Task 1: Kunci kontrak UI guest dan login dengan widget test

**Files:**
- Modify: `test/account_pages_test.dart`

- [ ] **Step 1: Refactor repository test agar dapat mengembalikan guest atau user**

Gunakan repository dengan `AccountUser? user`, `offline`, dan `logoutCount`, sehingga `bootstrap()` mengembalikan state yang diminta tanpa jaringan.

```dart
class _AuthRepository implements AuthRepository {
  _AuthRepository({this.user, this.offline = false});

  final AccountUser? user;
  final bool offline;
  int logoutCount = 0;

  @override
  AccountUser? get currentUser => user;

  @override
  Future<AuthBootstrapResult> bootstrap() async =>
      AuthBootstrapResult(user: user, offline: offline);

  @override
  Future<void> logout() async => logoutCount++;
}
```

- [ ] **Step 2: Tambahkan test guest dan login yang gagal pada layout lama**

Guest harus menemukan CTA login, copy beli tiket, empat menu, dan tidak menemukan logout. Login harus menemukan inisial `MR`, nama, email, quick action profil/riwayat, dan logout.

```dart
expect(find.byKey(const ValueKey('account-identity-card')), findsOneWidget);
expect(find.text('Masuk atau Buat Akun'), findsOneWidget);
expect(find.byKey(const ValueKey('account-menu-section')), findsOneWidget);
expect(find.text('Keluar'), findsNothing);

expect(find.text('MR'), findsOneWidget);
expect(find.text('Muhammad Riyadh'), findsOneWidget);
expect(find.text('Edit profil'), findsOneWidget);
expect(find.byKey(const ValueKey('account-logout')), findsOneWidget);
```

- [ ] **Step 3: Jalankan test dan pastikan gagal pada key/struktur baru**

Run: `rtk flutter test test/account_pages_test.dart`

Expected: gagal karena identity card/menu section baru belum tersedia.

### Task 2: Implementasikan halaman Akun dengan gaya existing

**Files:**
- Modify: `lib/features/profile/presentation/pages/profile_page.dart`

- [ ] **Step 1: Muat craft floor sebelum mengedit UI**

Read: `C:/Users/riyadh/.agents/skills/impeccable/reference/craft-floor.md`

- [ ] **Step 2: Bangun header dan identity card yang overlap**

Gunakan `AppColors.primaryGradient`, `AppColors.background`, `AppColors.surface`, dan border existing. Header tetap menampilkan judul/status. Card memiliki key `account-identity-card`, avatar 56 dp, nama/email aman dengan ellipsis, serta badge aktif/offline.

- [ ] **Step 3: Implementasikan state guest dan signed-in**

Guest menggunakan copy dan CTA existing menuju `/masuk`. Signed-in menggunakan inisial dari dua kata pertama nama (fallback email), quick action `/profil-saya` dan `/riwayat-tiket`, serta tidak menaruh logout di identity card.

- [ ] **Step 4: Satukan menu menjadi satu section**

Buat satu surface dengan key `account-menu-section`. Isi baris route existing:

```dart
(
  icon: Icons.receipt_long_outlined,
  title: ticketHistoryTitle,
  subtitle: ticketHistorySubtitle,
  route: '/riwayat-tiket',
),
(
  icon: Icons.language_rounded,
  title: l10n.languagePageTitle,
  subtitle: currentLocale.localizedName(l10n),
  route: '/bahasa',
),
(
  icon: Icons.accessibility_new_rounded,
  title: l10n.profileAccessibility,
  subtitle: l10n.profileLargeText,
  route: '/aksesibilitas',
),
(
  icon: Icons.support_agent_rounded,
  title: l10n.profileHelpCenter,
  subtitle: l10n.profileContactOfficer,
  route: '/pusat-bantuan',
),
```

Untuk signed-in, tambahkan baris logout merah dengan key `account-logout` dan pertahankan dialog konfirmasi existing.

- [ ] **Step 5: Format dan jalankan test**

Run: `rtk dart format lib/features/profile/presentation/pages/profile_page.dart test/account_pages_test.dart`

Run: `rtk flutter test test/account_pages_test.dart`

Expected: state guest dan login lulus tanpa overflow.

### Task 3: Responsif, detector, dan build Android

**Files:**
- Modify: `test/account_pages_test.dart`

- [ ] **Step 1: Tambahkan test nama panjang dan text scale**

Pump halaman pada ukuran 360x800 dengan text scaler 1.3 dan user bernama panjang. Pastikan tidak ada exception dan navbar Akun tetap tersedia.

```dart
await tester.binding.setSurfaceSize(const Size(360, 800));
expect(tester.takeException(), isNull);
expect(find.text('Akun'), findsWidgets);
```

- [ ] **Step 2: Jalankan pengujian dan analyzer**

Run: `rtk flutter test test/account_pages_test.dart test/app_colors_test.dart`

Run: `rtk flutter analyze`

Expected: seluruh test terfokus lulus dan analyzer tidak menemukan issue.

- [ ] **Step 3: Jalankan detector UI sekali**

Run: `rtk node C:/Users/riyadh/.agents/skills/impeccable/scripts/detect.mjs --json --scope layout lib/features/profile/presentation/pages/profile_page.dart`

Expected: tidak ada temuan layout yang belum dijelaskan.

- [ ] **Step 4: Build APK debug**

Run: `rtk flutter build apk --debug`

Expected: APK tersedia pada `build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 5: Periksa scope Git**

Run: `rtk git diff --check`

Run: `rtk git status --short`

Expected: backup painter tetap untracked dan perubahan account tidak bercampur dengan perubahan lain.
