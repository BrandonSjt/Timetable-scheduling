# Informative Route Timeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menghasilkan timeline rute dari Dijkstra backend yang membedakan perjalanan kereta, perpindahan peron, dan transit berjalan kaki, lalu menampilkannya dengan gaya UI mobile yang sudah ada serta membacakannya lewat TTS.

**Architecture:** `RouteService` tetap menjadi sumber fakta perjalanan dan memecah path Dijkstra menjadi leg sebelum membentuk langkah `board`, `transfer`, `continue`, dan `arrive`. Mobile memetakan kontrak itu ke enum domain dengan fallback respons lama, kemudian widget khusus hanya menangani presentasi rail dan card tanpa menyentuh painter peta.

**Tech Stack:** Node.js, TypeScript, Prisma, Node test runner, Flutter/Dart, Material, Flutter test.

---

### Task 1: Bentuk langkah perjalanan dari path Dijkstra

**Files:**
- Modify: `timetable_backend/src/domain/services/routeService.ts`
- Test: `timetable_backend/tests/routeService.test.ts`

- [ ] **Step 1: Tulis pengujian kontrak langkah yang gagal**

Tambahkan assertion bahwa rute transit berurutan `board -> transfer -> continue -> arrive`, dan transfer Cikoko memiliki `isWalking: true`:

```ts
assert.deepEqual(route.steps.map(({ kind }) => kind), [
  'board',
  'transfer',
  'continue',
  'arrive',
]);
assert.equal(walkingStep?.kind, 'transfer');
assert.equal(walkingStep?.isWalking, true);
assert.match(route.steps[2].text, /^Lanjut naik /);
```

- [ ] **Step 2: Jalankan test dan pastikan gagal karena `kind` belum tersedia**

Run: `rtk npm test -- --test-name-pattern="Dijkstra"`

Expected: TypeScript/test gagal pada property `kind` atau assertion urutan langkah.

- [ ] **Step 3: Tambahkan kontrak langkah eksplisit**

Ubah interface menjadi:

```ts
type RouteStepKind = 'board' | 'transfer' | 'continue' | 'arrive';

interface RouteStep {
  kind: RouteStepKind;
  isWalking: boolean;
  text: string;
  durationText: string;
  detailNote: string;
  icon: string;
  color: string;
  isHeader: boolean;
  isTransit: boolean;
  isDestination: boolean;
}
```

Buat helper yang membagi `path` pada connection `isTransfer`. Untuk setiap leg, jumlahkan `travelTime` edge layanan dan buat:

```ts
{
  kind: firstLeg ? 'board' : 'continue',
  isWalking: false,
  text: firstLeg
    ? `Naik dari ${startName}`
    : `Lanjut naik ${line.name}`,
  durationText: `${legMinutes} menit`,
  detailNote: firstLeg
    ? `${line.name} menuju ${endName}`
    : `Dari ${startName} menuju ${endName}`,
  icon: 'train',
  color: line.color,
  isHeader: firstLeg,
  isTransit: false,
  isDestination: false,
}
```

Untuk edge transfer gunakan `directions_walk` hanya jika station ID berbeda; transfer satu stasiun memakai `sync_alt` dan teks `Pindah peron di ...`. Tambahkan langkah akhir `arrive` dengan total durasi.

- [ ] **Step 4: Jalankan test backend terfokus**

Run: `rtk npm test -- --test-name-pattern="Dijkstra"`

Expected: seluruh test Dijkstra lulus dan transfer Cikoko tetap lima menit.

### Task 2: Petakan kontrak baru ke domain mobile dengan fallback lama

**Files:**
- Modify: `lib/features/route_result/domain/entities/route_plan.dart`
- Modify: `lib/features/route_result/data/models/route_plan_model.dart`
- Modify: `test/route_plan_model_test.dart`
- Modify: `test/helpers/route_test_data.dart`

- [ ] **Step 1: Tambahkan fixture baru dan test fallback lama**

Fixture utama memakai `kind` dan `isWalking`. Tambahkan test kedua yang menghapus `kind`, lalu memastikan `isHeader`, `isTransit`, dan `isDestination` lama tetap dipetakan ke enum yang benar.

```dart
expect(route.steps.map((step) => step.kind), [
  RouteStepKind.board,
  RouteStepKind.transfer,
  RouteStepKind.continueTrip,
  RouteStepKind.arrive,
]);
expect(route.steps.singleWhere((step) => step.isWalking).kind,
    RouteStepKind.transfer);
```

- [ ] **Step 2: Jalankan test model dan pastikan gagal**

Run: `rtk flutter test test/route_plan_model_test.dart`

Expected: gagal karena `RouteStepKind` dan `isWalking` belum ada.

- [ ] **Step 3: Tambahkan enum dan parser kompatibel**

Tambahkan:

```dart
enum RouteStepKind {
  board,
  transfer,
  continueTrip,
  arrive;

  static RouteStepKind fromApi(String? value, {
    required bool isHeader,
    required bool isTransit,
    required bool isDestination,
  }) => switch (value) {
    'board' => board,
    'transfer' => transfer,
    'continue' => continueTrip,
    'arrive' => arrive,
    _ when isDestination => arrive,
    _ when isTransit => transfer,
    _ when isHeader => board,
    _ => continueTrip,
  };
}
```

Tambahkan `kind` dan `isWalking` pada `RoutePlanStep`. Parser membaca boolean lama terlebih dahulu, lalu memanggil `RouteStepKind.fromApi`; `detailNote` aman dengan default string kosong.

- [ ] **Step 4: Jalankan test model**

Run: `rtk flutter test test/route_plan_model_test.dart`

Expected: mapping respons baru dan fallback lama lulus.

### Task 3: Tampilkan timeline rail tanpa merombak gaya halaman

**Files:**
- Create: `lib/features/route_result/presentation/widgets/route_journey_timeline.dart`
- Modify: `lib/features/route_result/presentation/pages/route_result_page.dart`
- Modify: `test/route_result_page_test.dart`

- [ ] **Step 1: Tulis widget test untuk langkah lanjut dan konektor berjalan**

Perbarui data test menjadi empat langkah dan tambahkan:

```dart
expect(find.text('Lanjut naik KRL Lin Tangerang'), findsOneWidget);
expect(find.byKey(const ValueKey('route-timeline-walk-1')), findsOneWidget);
expect(find.text('Urutan stasiun'), findsNothing);
```

- [ ] **Step 2: Jalankan widget test dan pastikan gagal**

Run: `rtk flutter test test/route_result_page_test.dart`

Expected: langkah lanjut atau key konektor belum ditemukan.

- [ ] **Step 3: Buat widget timeline terfokus**

`RouteJourneyTimeline` menerima `title` dan `List<RoutePlanStep>`. Card memakai padding, radius, border, font, dan alpha warna yang sama dengan implementasi lama. Leading rail menggunakan `CustomPainter`:

```dart
class RouteJourneyTimeline extends StatelessWidget {
  const RouteJourneyTimeline({
    required this.title,
    required this.steps,
    super.key,
  });

  final String title;
  final List<RoutePlanStep> steps;
}
```

Garis setelah langkah kereta solid memakai `step.color`. Jika langkah transfer memiliki `isWalking`, bagian menuju langkah berikutnya digambar putus-putus abu-abu dan diberi key `route-timeline-walk-{index}`. Transfer peron menggunakan garis netral solid serta ikon `sync_alt`, sehingga tidak diklaim sebagai berjalan kaki. Semantics memakai `text`, `detailNote`, dan `durationText`.

- [ ] **Step 4: Ganti mapping inline halaman dengan widget**

Pada `_timeline`, pertahankan container/dekorasi luar dan gunakan:

```dart
RouteJourneyTimeline(
  title: l10n.routeTimeline,
  steps: route.steps,
)
```

Hapus helper `_color` dan `_icon` dari page setelah tanggung jawab tersebut pindah ke widget.

- [ ] **Step 5: Format dan jalankan widget test**

Run: `rtk dart format lib/features/route_result test/route_result_page_test.dart test/helpers/route_test_data.dart`

Run: `rtk flutter test test/route_result_page_test.dart`

Expected: halaman menampilkan urutan empat langkah dan rail berjalan kaki tanpa overflow.

### Task 4: Sinkronkan TTS dan verifikasi lintas lapisan

**Files:**
- Modify: `lib/features/route_result/domain/services/route_speech_service.dart`
- Modify: `test/route_speech_service_test.dart`

- [ ] **Step 1: Tambahkan assertion narasi langkah lanjut dan berjalan**

```dart
expect(narration, contains('Lanjut naik KRL Lin Tangerang'));
expect(narration, contains('Berjalan'));
```

- [ ] **Step 2: Rapikan builder agar field kosong tidak menghasilkan titik ganda**

Bangun setiap instruksi dari field non-kosong:

```dart
final instruction = [step.text, step.detailNote, step.durationText]
    .where((part) => part.trim().isNotEmpty)
    .join('. ');
```

- [ ] **Step 3: Jalankan seluruh verifikasi terfokus**

Run backend: `rtk npm test`

Run backend build: `rtk npm run build`

Run Flutter: `rtk flutter test test/route_plan_model_test.dart test/route_result_page_test.dart test/route_speech_service_test.dart test/route_remote_data_source_test.dart test/route_controller_test.dart test/station_map_contract_test.dart`

Run analyzer: `rtk flutter analyze`

Expected: seluruh perintah lulus; kontrak map memastikan node, line, dan warna resmi tidak berubah.

- [ ] **Step 4: Periksa scope Git**

Run: `rtk git diff --check`

Run: `rtk git status --short`

Expected: hanya file timeline/backend terkait dan perubahan pengguna yang sebelumnya sudah ada; `schematic_map_painter_backup.dart` tetap tidak dilacak dan tidak tersentuh.
