# Backend-Mobile Transit Alignment Design

## Objective

Replace mobile dummy transit data with a versioned backend contract while preserving the existing schematic geometry. The February 2026 commuter timetable is the active schedule until a newer dataset is imported.

## Source authority

1. `Peta-Rute-Commuter-Line.pdf`, `Peta-Rute-MRT-Jakarta-Kabin-Jan26.pdf`, and `Peta-Rute-LRT-Jabodebek.pdf` own public station names and line codes.
2. `Jadwal Commuter Line Jabodetabek Update Februari 2026.pdf` owns operational station abbreviations, train numbers, calls, times, and operating calendars.
3. The Flutter schematic owns coordinates, waypoints, line shapes, and the current visual-only JIS node.

Public line codes and operational abbreviations are separate namespaces. A station can have multiple public codes because each line node has its own code, while one station has at most one operational timetable code.

## Station identity contract

The existing `Station.name` remains the stable short name used by slugs, seed matching, and legacy clients. `Station.officialName` stores the exact public name from the route map, and aliases contain both names plus prior sponsored or abbreviated spellings. `Station.code` remains the operational timetable code and is exposed as `operationalCode` in new responses.

`StationNode.code` remains the stable internal graph key so existing connections are not rewritten. `StationNode.publicCode` stores the official route-map code returned to clients. This separation is required for the existing JIS/Tanjung Priok conflict and for corrected Rangkasbitung codes without changing topology.

API station DTOs expose:

```json
{
  "name": "Dukuh Atas BNI",
  "shortName": "Dukuh Atas LRT",
  "officialName": "Dukuh Atas BNI",
  "operationalCode": null,
  "nodes": [{ "code": "BK01", "publicCode": "BK01", "graphKey": "BK01" }]
}
```

Legacy request identifiers continue resolving by ID, slug, short name, official name, aliases, operational code, public code, and graph key.

## Exceptional nodes

- Jakarta International Stadium stays at its existing coordinate and in the existing Tanjung Priok line path. It has no official public code because it is absent from the supplied official map.
- Tanjung Priok keeps its existing graph key but exposes official public code `TP04`.
- Gambir is added as a hidden, non-passenger KRL station with public code `B06` and operational code `GMR`. It is available to timetable calls but excluded from the drawable schematic and the current static route graph, so geometry does not change.

## Delivery phases

### Phase 1A - Station identity

Add the explicit identity fields, correct official names/public codes, preserve aliases and graph connectivity, update the mobile schematic labels, and add regression tests for the three official maps.

### Phase 1B - Versioned timetable

Introduce timetable dataset, train service, calendar, and ordered stop-time models. Import all February 2026 rows transactionally, validate counts and station mappings, and activate the dataset without deleting previous versions.

### Phase 1C - Schedule and route APIs

Add departures, train journey detail, origin-destination schedule search, and schedule-aware routing. Preserve the old flat schedule endpoint temporarily through a compatibility mapper.

### Phase 1D - Mobile integration

Add station/timetable/route repositories, explicit offline caching, and typed error states. Replace hardcoded search, next departures, departure details, and route calculations with API data.

Later phases cover authentication, tickets/Xendit, alarms, assistant tooling, support, reports, preferences, and provider-backed live tracking.

## Performance and safety

- Seed and import operations use database transactions and batch writes.
- Public and operational codes receive indexed lookups; stop times are indexed by station, dataset, service, and time.
- Route geometry is never derived again from PDFs.
- Import validation fails before activation on duplicate train numbers, unknown codes, invalid time order, incomplete station mappings, or count drift.
- Compatibility fields are removed only after the Flutter client no longer reads them.

## Verification

Phase 1A must keep the same drawable line paths and coordinates, return corrected official names/codes, resolve legacy identifiers, pass backend tests/build, and introduce no new Flutter analyzer findings. Existing unrelated Flutter test failures are recorded as baseline and are not hidden by this work.
