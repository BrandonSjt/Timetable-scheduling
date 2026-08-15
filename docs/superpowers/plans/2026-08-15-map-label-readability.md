# Map Label Readability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This run uses inline execution because the user requested solo execution.

**Goal:** Increase map label, node, and non-KRL line readability without changing schematic geometry.

**Architecture:** Keep all geometry data untouched. Centralize visual sizes in small painter helpers/constants, use the actual node radius in collision occupancy, and apply one local Fatmawati label-position override.

**Tech Stack:** Flutter/Dart `CustomPainter`, Flutter unit and painter tests.

---

### Task 1: Lock readable visual sizes with tests

**Files:**

- Modify: `test/station_map_contract_test.dart`
- Modify: `lib/shared/widgets/schematic_map_painter.dart`

- [ ] Add failing assertions for label sizes 12/14, hub font 12, MRT/LRT line width 7, MRT/LRT coded node radii 12/14, and unchanged KRL sizes.
- [ ] Run `flutter test test/station_map_contract_test.dart` and confirm the size assertions fail while the geometry fingerprint remains unchanged.
- [ ] Add these exact constants/helpers:

```dart
const double kRegularStationLabelFontSize = 12;
const double kTransitStationLabelFontSize = 14;
const double kHubStationNameFontSize = 12;
const double kStationLabelOutlineWidth = 3;
const double kRegularStationLabelOffset = 24;
const double kTransitStationLabelOffset = 30;

double stationLabelFontSize(StationData station) =>
    station.isTransit ? kTransitStationLabelFontSize : kRegularStationLabelFontSize;
```

- [ ] Set MRT and all LRT `LineData.strokeWidth` values to 7; leave KRL at 8.
- [ ] Make non-KRL coded node radii match 12 regular / 14 transit; retain KRL 12 / 15.
- [ ] Run the focused contract test and confirm it passes.

### Task 2: Increase label clearance and fix the MRT collision

**Files:**

- Modify: `lib/shared/widgets/schematic_map_painter.dart`
- Modify: `test/station_map_contract_test.dart`

- [ ] Replace every regular/transit label offset with the 24/30 constants for normal and rotated labels.
- [ ] Replace fixed occupied node radii with `stationNodeRadius(station) + 4`.
- [ ] Change only the `fatmawati` label override from left to top; keep `lebak_bulus` left.
- [ ] Increase label outline width from 2.5 to 3 and hub-name font from 10 to 12.
- [ ] Run map contract and marker painter tests; geometry fingerprint must remain `721664269`.
- [ ] Commit the focused readability change.

### Task 3: Verify and rebuild APK

**Files:**

- No source changes unless verification exposes an in-scope defect.

- [ ] Run `dart format` on touched Dart files.
- [ ] Run `flutter analyze`.
- [ ] Run the complete `flutter test` suite.
- [ ] Run `flutter build apk --debug`.
- [ ] Verify APK path, size, SHA-256, `git diff --check`, and that the user-owned backup file remains untouched.
