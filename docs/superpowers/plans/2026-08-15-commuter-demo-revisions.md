# Commuter Demo Revisions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkboxes for traceability. This run must use executing-plans inline because the user explicitly prohibited sub-agents.

**Goal:** Deliver the lecturer-requested Flutter demo revisions: truthful schedule-based status, a foreground “You are here” nearest-KRL-station flow, larger commuter lines/nodes without changing map geometry, and a visible top border on the bottom navigation.

**Architecture:** Keep the existing monorepo and API contract. Compute time status in the Flutter domain layer from the existing February 2026 schedule data, isolate GPS behind a small service, map coordinates to canonical schematic station IDs using a local KRL catalog, and limit painter changes to conditional styling plus a marker overlay. Backend and database schema remain unchanged.

**Tech Stack:** Flutter/Dart, `geolocator` 14.0.3, existing Express/Prisma backend, Flutter widget/unit tests.

---

## Task 1: Schedule status domain model

**Files:**

- Modify: `lib/features/timetable/domain/entities/train_schedule.dart`
- Modify: `lib/features/timetable/data/models/train_schedule_model.dart`
- Create: `lib/features/timetable/domain/services/schedule_status.dart`
- Create: `test/schedule_status_test.dart`

- [ ] Write failing tests for all status boundaries, including a next-day `dayOffset` schedule.
- [ ] Add optional `dayOffset` to `TrainSchedule` with a zero default.
- [ ] Parse `dayOffset` from the API model without breaking older payloads.
- [ ] Implement a pure status calculator returning label, kind, and whether the departure has passed.
- [ ] Run `flutter test test/schedule_status_test.dart`.
- [ ] Commit the focused change.

Status rules:

```dart
if (minutes > 5) return 'Berangkat $minutes menit lagi';
if (minutes > 1) return 'Segera berangkat';
if (minutes >= -1) return 'Berangkat sekarang';
return 'Jadwal lewat';
```

The service must combine the selected service date, `departureTime`, and `dayOffset`; it must not claim GPS train tracking.

## Task 2: Live-refreshing schedule UI

**Files:**

- Modify: `lib/features/timetable/presentation/pages/timetable_page.dart`
- Modify: `lib/features/timetable/presentation/widgets/schedule_card.dart`
- Create: `test/schedule_card_status_test.dart`

- [ ] Write failing widget tests for upcoming, now, and passed cards.
- [ ] Add a status chip/row to `ScheduleCard` and visually de-emphasize passed schedules.
- [ ] Add a `Timer.periodic` refresh every 30 seconds and cancel it in `dispose`.
- [ ] Pass a single page-level clock value into cards so one frame is internally consistent.
- [ ] Keep the list sorted chronologically and make the nearest upcoming item visually prominent.
- [ ] Add the source note `Berdasarkan jadwal resmi Februari 2026` near the schedule list.
- [ ] Run schedule unit/widget tests.
- [ ] Commit the focused change.

## Task 3: Local KRL station coordinate catalog and nearest-station logic

**Files:**

- Create: `lib/features/home/domain/entities/station_geo_point.dart`
- Create: `lib/features/home/domain/services/nearest_krl_station.dart`
- Create: `lib/features/home/data/krl_station_locations.dart`
- Create: `test/nearest_krl_station_test.dart`

- [ ] Write failing tests for nearest-station selection, empty input, and duplicate interchange aliases.
- [ ] Add a static coordinate catalog for physical stations on the seven KRL lines only.
- [ ] Key every entry to an existing canonical schematic station ID/name.
- [ ] Implement deterministic nearest-distance selection using an injectable distance function.
- [ ] Verify every catalog target exists in `transitLines` and belongs to a KRL line.
- [ ] Run the focused tests.
- [ ] Commit the focused change.

## Task 4: Foreground location service

**Files:**

- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `lib/features/home/data/services/user_location_service.dart`
- Create: `test/user_location_service_test.dart`

- [ ] Add `geolocator: ^14.0.3` and fetch dependencies.
- [ ] Add Android fine/coarse location permissions only; do not add background permission.
- [ ] Define small adapter/result types so permission branches are unit-testable.
- [ ] Implement: service check → permission check/request → current position with 10-second timeout → last-known fallback.
- [ ] Return distinct disabled, denied, permanently-denied, unavailable, and success outcomes.
- [ ] Run the focused service tests.
- [ ] Commit the focused change.

## Task 5: “You are here” map interaction

**Files:**

- Modify: `lib/features/home/presentation/pages/train_map_page.dart`
- Modify: `lib/features/home/presentation/widgets/map_widgets.dart`
- Modify: `lib/shared/widgets/schematic_map_painter.dart`
- Create: `test/train_map_location_test.dart`

- [ ] Write widget/painter tests for loading, successful nearest station, and denied permission feedback.
- [ ] Add a locate control near the existing zoom controls without changing the map layout.
- [ ] On success, set the selected station, center the existing `InteractiveViewer`, and retain the normal station-tap behavior.
- [ ] Draw a distinct blue location marker around the nearest schematic KRL station.
- [ ] Show `Anda berada di dekat Stasiun <name>` and clarify that the marker is the nearest station, not the exact map coordinate.
- [ ] Surface concise Indonesian messages for all service failure states.
- [ ] Run the focused tests.
- [ ] Commit the focused change.

## Task 6: Enlarge KRL lines and nodes without geometry drift

**Files:**

- Modify: `lib/shared/widgets/schematic_map_painter.dart`
- Modify: `test/station_map_contract_test.dart`

- [ ] Extend the geometry contract test to snapshot every station position/order, waypoint, canvas size, walking connection, and initial map scale.
- [ ] Confirm the test fails only if geometry changes, not for paint thickness.
- [ ] Set seven KRL line strokes from 6 to 8 while leaving MRT/LRT widths unchanged.
- [ ] Increase KRL node radii: coded 10→12, coded transit 12→15, uncoded 5.5→7, uncoded transit 8→10.
- [ ] Adjust only local label offsets where overlap is introduced; never change `StationData.position`.
- [ ] Run the map contract and painter tests.
- [ ] Commit the focused change.

## Task 7: Bottom navigation top border

**Files:**

- Modify: `lib/shared/widgets/bottom_nav_bar.dart`
- Modify: `test/bottom_nav_bar_test.dart`

- [ ] Add a failing test for a 1 px top border using `AppColors.cardBorder`.
- [ ] Add only the border decoration, preserving sizing, navigation behavior, and shadow.
- [ ] Run `flutter test test/bottom_nav_bar_test.dart`.
- [ ] Commit the focused change.

## Task 8: Integration verification and APK build

**Files:**

- Modify only if verification exposes an in-scope defect.

- [ ] Run `dart format` on touched Dart files.
- [ ] Run `flutter analyze`.
- [ ] Run the complete `flutter test` suite.
- [ ] Build a debug APK with `flutter build apk --debug`.
- [ ] Confirm the generated APK path and size.
- [ ] Inspect `git diff --check` and `git status --short`; leave the user-owned backup file untouched.
- [ ] Perform a final diff review against the approved design and report any remaining limitation honestly.

## Acceptance checklist

- [ ] Schedule status updates without re-fetching and is explicitly schedule-based.
- [ ] Location is requested only after the user taps the control.
- [ ] Nearest selection considers KRL physical stations only.
- [ ] The map’s established station topology and layout are unchanged.
- [ ] Only KRL strokes/nodes are enlarged; MRT/LRT styling stays intact.
- [ ] Bottom navigation has the requested top border.
- [ ] Backend/schema remain unchanged.
- [ ] Debug APK builds successfully for lecturer demo use.
