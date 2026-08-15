# Commuter Demo Revisions Design

**Date:** 2026-08-15

**Status:** Approved in conversation; awaiting written-spec review

## Goal

Prepare the Flutter application for lecturer demonstration by adding schedule-relative status, locating the user's nearest KRL Commuter station, strengthening KRL line and node visuals without changing the existing schematic geometry, and adding a clear top border to the bottom navigation bar.

## Scope

The rail scope is limited to active KRL Commuter services represented by these internal line IDs:

- `bogor`
- `bogor_nambo`
- `cikarang_loop`
- `cikarang_east`
- `tangerang`
- `tanjung_priok`
- `rangkasbitung`

MRT, LRT, airport rail, BRT, Whoosh, intercity rail, and planned lines are not comparison criteria. Existing non-KRL lines remain visible and unchanged.

## Existing Data

The active `2026-02` timetable dataset is already imported from `Jadwal Commuter Line Jabodetabek Update Februari 2026.pdf`. The audited snapshot contains 1,145 train services and 19,328 stop calls. The backend schedule endpoint already reads the active normalized dataset, and the Flutter timetable feature already consumes that endpoint.

The FDTJ June 2026 integration map is a visual and topology reference only. It is not a source for operational status or live train positions.

## Schedule Status

Status is calculated inside the Flutter application from the scheduled departure time and the current device time. The application refreshes status presentation every 30 seconds without refetching the unchanged timetable solely for the timer tick.

The UI uses these states:

- More than five minutes before departure: `Berangkat N menit lagi`
- Between one and five minutes before departure: `Segera berangkat`
- From one minute before until one minute after departure: `Berangkat sekarang`
- More than one minute after departure: `Jadwal lewat`

The next departure receives visual focus. Past entries remain available but use muted styling. The timetable page displays `Berdasarkan jadwal resmi Februari 2026` so the presentation does not imply actual train tracking.

The application must not show `Tepat waktu`, `Terlambat`, actual disruption status, or actual train position because no official KAI operational feed is available.

The backend and database schema do not change for schedule status.

## Nearest KRL Station (You Are Here)

Location lookup is user initiated from a location button. The application requests foreground location only and does not track location in the background.

The app keeps a local catalog containing one geographic latitude/longitude pair and one canonical schematic station ID per physical KRL station. Shared or duplicated schematic nodes resolve to one canonical node. Coordinates are verified against the station identity used by the existing KRL map before release.

Location flow:

1. Check whether device location services are enabled.
2. Check and request foreground location permission.
3. Request current position with a 10-second timeout.
4. If current position times out, try the last known position.
5. Calculate distance to every KRL station in the local catalog.
6. Select the minimum-distance station.
7. Center the schematic viewport on its existing node.
8. Show a blue marker and a summary such as `Stasiun KRL terdekat: Manggarai - 850 m`.

The marker represents the nearest KRL station, not the user's exact point on the schematic map. If Android supplies only approximate location, the result is labeled as an estimate.

Failure behavior:

- Location service disabled: explain the problem and offer to open location settings.
- Permission denied: explain why foreground location is needed and allow retry.
- Permission permanently denied: offer to open application settings.
- Current and last-known locations unavailable: keep the map usable and show a non-blocking error.
- User outside Jabodetabek: still report the nearest KRL station and its distance.

Android declares coarse and fine foreground location permissions only. No background-location permission is added.

## KRL Map Visual Treatment

The existing schematic layout is protected. The following must remain unchanged:

- `StationData.position` values
- Line station order
- Waypoint positions
- Walking connections
- Merged-station relationships
- Canvas width and height
- Initial viewport scale of `1.05`
- Existing non-KRL line styling

Only visual primitives for KRL lines and stations change:

- KRL line stroke width increases from `6` to `8`.
- Coded KRL station radius increases from `10` to `12`.
- Coded KRL transit radius increases from `12` to `15`.
- Uncoded KRL station radius increases from `5.5` to `7`.
- Uncoded KRL transit radius increases from `8` to `10`.
- KRL node borders and station-code text scale proportionally enough to remain legible.
- Label gaps may increase locally when larger nodes cause overlap.

The first implementation pass does not move any station or waypoint. If visual review finds a collision, label offsets are adjusted first. Moving a node requires separate explicit approval.

Shared interchange nodes served by KRL receive the KRL node treatment. Non-KRL line strokes remain at their existing width.

## Bottom Navigation Border

The bottom navigation container receives a one-pixel top border using `AppColors.cardBorder`. Its existing shadow, height, item layout, routes, and safe-area padding remain unchanged.

## Architecture

The changes stay within existing Flutter layers:

- A small schedule-status value/calculator owns time classification.
- A location service owns Android permission and position retrieval.
- A local KRL station-coordinate catalog owns geographic station data.
- A nearest-station calculator owns distance comparison and is independent of platform permission code.
- Existing timetable widgets display calculated status.
- Existing map widgets center the viewport and pass the nearest-station marker to the painter.
- Existing painter data remains the source of schematic geometry.

No new backend endpoint or database migration is required.

## Validation

Automated checks cover:

- Each schedule-status boundary with a fixed clock.
- Cross-midnight `dayOffset` handling.
- Nearest-station selection with known coordinates.
- Permission denied, permanently denied, disabled-service, timeout, and last-known fallback states.
- Location marker and viewport-centering behavior.
- KRL-only line and node visual sizing.
- Bottom navigation top border.
- A deterministic geometry contract that fails if station positions, waypoint positions, or line station order change.

Visual QA covers:

- Full-canvas render before and after styling.
- Central interchange area and each KRL branch.
- Common Android phone viewport sizes.
- Labels, route badges, selected station, nearest-station marker, and zoom controls.

Final verification includes existing Flutter tests, backend timetable snapshot/import tests when the local database is available, static analysis, release APK build, and installation on a physical Android device.

## Out of Scope

- Actual live train position
- Actual delay or disruption status
- Background location tracking
- New rail or BRT lines
- Redrawing or globally rescaling the schematic map
- Backend hosting and APK distribution setup

## Execution Constraint

Implementation runs inline in the current task. No sub-agents are used.
