# Schedule Card Border Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Memperjelas border luar kartu jadwal tanpa mengubah komponen jadwal lainnya.

**Architecture:** Pertahankan `ScheduleCard` existing dan ubah satu `Border.all` pada container terluar. Tambahkan satu widget test kecil yang membaca `BoxDecoration` hasil render.

**Tech Stack:** Flutter, Dart, Flutter widget test.

---

### Task 1: Perkuat border luar ScheduleCard

**Files:**
- Create: `test/schedule_card_border_test.dart`
- Modify: `lib/features/timetable/presentation/widgets/schedule_card.dart`

- [ ] **Step 1: Tulis test border yang gagal**

Pump satu `ScheduleCard` melalui `localizedTestApp`, ambil container pertama di bawah card, lalu assert:

```dart
final container = tester.widget<Container>(
  find.descendant(
    of: find.byType(ScheduleCard),
    matching: find.byType(Container),
  ).first,
);
final border = (container.decoration! as BoxDecoration).border! as Border;
expect(border.top.width, 1.25);
expect(
  border.top.color,
  AppColors.primaryPurple.withValues(alpha: 0.24),
);
```

- [ ] **Step 2: Jalankan test dan pastikan gagal pada width 1**

Run: `rtk flutter test test/schedule_card_border_test.dart`

Expected: gagal karena border existing masih `AppColors.cardBorder` dengan width 1.

- [ ] **Step 3: Ubah satu deklarasi border**

```dart
border: Border.all(
  color: AppColors.primaryPurple.withValues(alpha: 0.24),
  width: 1.25,
),
```

Border platform dan `_TimeBlock` tidak disentuh.

- [ ] **Step 4: Format dan verifikasi**

Run: `rtk dart format lib/features/timetable/presentation/widgets/schedule_card.dart test/schedule_card_border_test.dart`

Run: `rtk flutter test test/schedule_card_border_test.dart`

Run: `rtk flutter analyze`

Expected: test dan analyzer lulus.

- [ ] **Step 5: Jalankan dan inspeksi emulator**

Run: `rtk flutter run -d emulator-5554 --debug --no-resident`

Expected: kartu jadwal terlihat lebih tegas tanpa perubahan layout.
