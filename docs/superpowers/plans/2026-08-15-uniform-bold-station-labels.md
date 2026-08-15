# Uniform Bold Station Labels Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This run uses inline execution because the user requested no sub-agents.

**Goal:** Render every station label at 16 px bold while preserving transit-node styling and all schematic geometry.

**Architecture:** Keep transit semantics for node drawing and label clearance only. Centralize the uniform label weight and size in painter constants, then verify the visual contract without changing station coordinates, node sizes, or route widths.

**Tech Stack:** Flutter/Dart `CustomPainter`, Flutter unit tests.

---

### Task 1: Lock uniform typography contract

**Files:**

- Modify: `test/station_map_contract_test.dart:146-151`
- Modify: `lib/shared/widgets/schematic_map_painter.dart:91-96`

- [ ] **Step 1: Write failing visual-contract assertions**

```dart
expect(stationLabelFontSize(station('bogor')), 16);
expect(stationLabelFontSize(station('bekasi')), 16);
expect(kStationLabelFontWeight, FontWeight.w700);
expect(kHubStationNameFontSize, 14);
expect(kStationLabelOutlineWidth, 3.5);
expect(kRegularStationLabelOffset, 32);
expect(kTransitStationLabelOffset, 40);
```

- [ ] **Step 2: Run focused test and confirm failure**

Run: `flutter test test/station_map_contract_test.dart`

Expected: FAIL because current labels are 12/14, the uniform weight constant is absent, and spacing constants retain old values.

- [ ] **Step 3: Add minimal typography constants**

```dart
const double kStationLabelFontSize = 16.0;
const FontWeight kStationLabelFontWeight = FontWeight.w700;
const double kHubStationNameFontSize = 14.0;
const double kStationLabelOutlineWidth = 3.5;
const double kRegularStationLabelOffset = 32.0;
const double kTransitStationLabelOffset = 40.0;

double stationLabelFontSize(StationData station) => kStationLabelFontSize;
```

Keep the function parameter for existing call sites and contract tests. Do not change node-size helpers or route-width data.

- [ ] **Step 4: Run focused test and confirm pass**

Run: `flutter test test/station_map_contract_test.dart`

Expected: PASS, including unchanged geometry fingerprint `721664269`.

### Task 2: Apply bold weight to every station-label path

**Files:**

- Modify: `lib/shared/widgets/schematic_map_painter.dart:2625-2757`

- [ ] **Step 1: Remove conditional label weight**

Delete:

```dart
final bool isBold = station.isTransit || isSelected || isFrom;
```

Keep `isSelected` and `isFrom` because existing color treatment still uses them later in the method.

- [ ] **Step 2: Use uniform weight in all six text styles**

Replace each conditional expression:

```dart
fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
```

with:

```dart
fontWeight: kStationLabelFontWeight,
```

Apply to stroke and fill text for top-rotated, bottom-rotated, and normal labels.

- [ ] **Step 3: Format and run focused test**

Run: `dart format lib/shared/widgets/schematic_map_painter.dart test/station_map_contract_test.dart`

Run: `flutter test test/station_map_contract_test.dart`

Expected: formatter succeeds and test passes.

- [ ] **Step 4: Commit implementation**

```bash
git add lib/shared/widgets/schematic_map_painter.dart test/station_map_contract_test.dart
git commit -m "style: enlarge and bold station labels"
```

### Task 3: Verify geometry and rebuild APK

**Files:**

- No source changes unless verification exposes an in-scope defect.

- [ ] **Step 1: Confirm geometry contract**

Run: `flutter test test/station_map_contract_test.dart --plain-name "schematic geometry remains unchanged"`

Expected: PASS with fingerprint `721664269`.

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`

Expected: `No issues found!`

- [ ] **Step 3: Run complete test suite**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 4: Build debug APK**

Run: `flutter build apk --debug`

Expected: `build/app/outputs/flutter-apk/app-debug.apk` is created successfully.

- [ ] **Step 5: Verify artifact and worktree**

Run: `Get-FileHash build/app/outputs/flutter-apk/app-debug.apk -Algorithm SHA256`

Run: `git diff --check`

Run: `git status --short`

Expected: APK hash is reported, no whitespace errors exist, and `lib/shared/widgets/schematic_map_painter_backup.dart` remains untouched and untracked.
