# Lebak Bulus and Sudirman Label Collision Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This run uses inline execution because the user requested no sub-agents.

**Goal:** Move only the Lebak Bulus and Sudirman labels away from nearby map components while preserving all schematic geometry and typography.

**Architecture:** Reuse the painter's existing station-specific position override map and opposite-side station-code placement. Expose the pure position lookup for contract testing, change two override values, and leave collision fallback, coordinates, sizes, and route drawing untouched.

**Tech Stack:** Flutter/Dart `CustomPainter`, Flutter unit tests.

---

### Task 1: Add failing label-position contract

**Files:**

- Modify: `test/station_map_contract_test.dart`
- Modify: `lib/shared/widgets/schematic_map_painter.dart:2528,2626,2825`

- [ ] **Step 1: Add the failing regression test**

```dart
test('reported station labels avoid nearby map components', () {
  final painter = SchematicMapPainter();

  expect(
    painter.stationLabelPositionFor(station('lebak_bulus')),
    LabelPos.top,
  );
  expect(
    painter.stationLabelPositionFor(station('sudirman')),
    LabelPos.right,
  );
});
```

- [ ] **Step 2: Run the test and confirm failure**

Run: `flutter test test/station_map_contract_test.dart --plain-name "reported station labels avoid nearby map components"`

Expected: FAIL because `stationLabelPositionFor` is not yet exposed.

### Task 2: Correct the two preferred positions

**Files:**

- Modify: `lib/shared/widgets/schematic_map_painter.dart:2528,2626,2825-2905`

- [ ] **Step 1: Expose the existing lookup for testing and internal reuse**

Rename:

```dart
LabelPos _getLabelPos(StationData station)
```

to:

```dart
@visibleForTesting
LabelPos stationLabelPositionFor(StationData station)
```

Update both internal callers from `_getLabelPos(station)` to `stationLabelPositionFor(station)`.

- [ ] **Step 2: Change only the reported overrides**

Use these exact entries:

```dart
'karet': LabelPos.bottom,
'sudirman': LabelPos.right,
```

and:

```dart
'fatmawati': LabelPos.top,
'lebak_bulus': LabelPos.top,
```

- [ ] **Step 3: Format and run the focused contract test**

Run: `dart format lib/shared/widgets/schematic_map_painter.dart test/station_map_contract_test.dart`

Run: `flutter test test/station_map_contract_test.dart`

Expected: all map contract tests pass, including geometry fingerprint `721664269`.

- [ ] **Step 4: Commit the focused fix**

```bash
git add lib/shared/widgets/schematic_map_painter.dart test/station_map_contract_test.dart
git commit -m "fix: separate overlapping station labels"
```

### Task 3: Verify and rebuild APK

**Files:**

- No source changes unless verification exposes an in-scope defect.

- [ ] **Step 1: Run static analysis**

Run: `flutter analyze`

Expected: `No issues found!`

- [ ] **Step 2: Run complete tests**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 3: Build debug APK**

Run: `flutter build apk --debug`

Expected: `build/app/outputs/flutter-apk/app-debug.apk` is created successfully.

- [ ] **Step 4: Verify artifact and worktree**

Run: `Get-FileHash build/app/outputs/flutter-apk/app-debug.apk -Algorithm SHA256`

Run: `git diff --check`

Run: `git status --short --branch`

Expected: APK hash is reported, no whitespace errors exist, and the pre-existing `lib/shared/widgets/schematic_map_painter_backup.dart` remains untouched and untracked.
