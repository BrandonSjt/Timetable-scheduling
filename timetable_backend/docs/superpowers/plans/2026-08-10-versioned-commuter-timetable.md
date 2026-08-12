# Versioned Commuter Timetable Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Import the complete February 2026 commuter timetable into normalized, versioned PostgreSQL tables without removing the legacy flat schedule endpoint.

**Architecture:** Convert the supplied PDF once into a checked-in deterministic JSON snapshot, validate it against fixed source counts, then batch-import it transactionally. Public map codes remain separate from operational timetable abbreviations; a dedicated 85-code mapping resolves every stop to the stable station slug.

**Tech Stack:** Python 3/pdfplumber for offline extraction, TypeScript, Prisma 5/PostgreSQL, Node test runner.

**Repository note:** The workspace has no `.git` directory, so commit steps are omitted and each task ends with reproducible verification.

---

## Task 1: Lock operational station mappings and snapshot contract

**Files:**
- Create: `prisma/operationalStationCodes.ts`
- Create: `tests/timetableSnapshot.test.ts`

- [ ] Add the 85 unique PDF abbreviations mapped to existing stable station slugs, including `GMR -> gambir` and `JTK -> jatake`, and excluding mobile-only JIS/Gunung Putri.
- [ ] Write a failing snapshot test expecting 1,145 services, 1,147 individual train numbers, 18,985 timed calls, 343 pass-through calls, 21 cross-midnight services, 33 weekday-only services, 160 Full Racket services, and 85 station codes.
- [ ] Assert line totals: Bogor 392, Cikarang 365, Rangkasbitung 204, Tangerang 120, Tanjung Priok 64.
- [ ] Assert 80 continuation rows, with `6052B` and `5746` preserved as continuation-only identifiers.
- [ ] Assert KA `5020A` ends at CKR `06:24`; the trailing `06:31` remains notes metadata and never becomes a stop.

Run: `rtk node --import tsx --test tests/timetableSnapshot.test.ts`

Expected: FAIL because `prisma/data/commuter-2026-02.json` does not exist yet.

## Task 2: Build the deterministic PDF extractor

**Files:**
- Create: `scripts/extract_commuter_timetable.py`
- Create: `prisma/data/commuter-2026-02.json`

- [ ] Read all 13 pages with `pdfplumber` using `x_tolerance=2` and `y_tolerance=2`.
- [ ] Parse the station-code header on every page; pages 1-12 use one table and page 13 splits each extracted row into two four-stop services.
- [ ] Parse normal rows as source row, optional loop, primary number, optional `- continuation number`, one or two relation tokens, station values, then notes.
- [ ] Emit a stop only for `HH:mm` or `Ls`; blank cells remain absent. Store equal `arrivalMinute`/`departureMinute` for timed calls and `null` for pass-through calls.
- [ ] Add 1,440 minutes whenever a later timed call crosses midnight; reject a second rollover or a non-monotonic value not explained by midnight.
- [ ] Map `Sabtu/Minggu/Libur Nasional Batal` to calendar `WEEKDAY`; all others use `DAILY`. Preserve the complete notes string and a derived `isFullRacket` flag.
- [ ] Compute the source PDF SHA-256 and emit deterministic compact JSON ordered by page and source row.
- [ ] Fail extraction unless every Task 1 count matches exactly.

Run:

```text
rtk <bundled-python> scripts/extract_commuter_timetable.py "C:\Users\riyadh\Downloads\Jadwal Commuter Line Jabodetabek Update Februari 2026.pdf" prisma/data/commuter-2026-02.json
```

Expected: `Validated 1145 services, 19328 calls, 85 station codes.`

Run: `rtk node --import tsx --test tests/timetableSnapshot.test.ts`

Expected: all snapshot and mapping tests pass.

## Task 3: Add normalized timetable models

**Files:**
- Modify: `prisma/schema.prisma`
- Create: `prisma/migrations/20260810010000_versioned_timetable/migration.sql`

- [ ] Add `TimetableDataset` with version, source name/hash, timezone, validity, active flag, and import timestamps.
- [ ] Add `ServiceCalendar` with code, seven weekday booleans, and `excludesPublicHolidays`.
- [ ] Add `TrainService` with dataset/calendar/line relations, primary and continuation numbers, relation, direction, loop/source metadata, notes, and Full Racket flag.
- [ ] Add `TrainStopTime` with ordered station relation, source code, nullable arrival/departure absolute minutes, and pass-through flag.
- [ ] Add cascade relations from dataset to calendars/services and service to stops. Add unique constraints `[datasetId, trainNumber]`, `[datasetId, code]`, and `[serviceId, sequence]`; add indexes for continuation number and station/departure lookup.
- [ ] Add a PostgreSQL partial unique index allowing only one active dataset.

Run: `rtk npx prisma validate`, then `rtk npx prisma generate`.

Expected: schema validation and client generation succeed.

Run: `rtk npx prisma migrate deploy`.

Expected: migration `20260810010000_versioned_timetable` applies successfully.

## Task 4: Implement transactional batch import

**Files:**
- Create: `prisma/importTimetable.ts`
- Modify: `package.json`

- [ ] Validate snapshot metadata and all station codes before opening the write transaction.
- [ ] Resolve station slugs and line slugs in two queries; fail with the complete missing-code/slug list.
- [ ] Update all 85 `Station.operationalCode` values from the mapping without touching public codes.
- [ ] Rebuild only version `2026-02` inside one transaction, leaving older datasets intact.
- [ ] Create two calendars (`DAILY`, `WEEKDAY`), batch-create 1,145 services, query their IDs once, then batch-create 19,328 stop rows in chunks of 1,000.
- [ ] Deactivate the previous dataset only after all rows validate, then activate `2026-02`.
- [ ] Add `npm run timetable:import -- <snapshot-path>` using `tsx prisma/importTimetable.ts`.

Run: `rtk npm run timetable:import -- prisma/data/commuter-2026-02.json` twice.

Expected after both runs: one active dataset, 1,145 services, 19,328 stop rows, two calendars, unchanged legacy `Schedule` count, and no duplicates.

## Task 5: Add database verification and preserve legacy behavior

**Files:**
- Create: `tests/timetableImport.test.ts`
- Modify: `README.md`

- [ ] Add a database verification script/test that checks active dataset counts, service line totals, calendar totals, pass-through totals, cross-midnight totals, and exact Gambir/Jatake station resolution.
- [ ] Confirm all existing flat schedules and `/api/v1/schedules` behavior remain available.
- [ ] Document source precedence, extraction command, import command, idempotence, activation behavior, and rollback by selecting an older dataset.

Run separately: `rtk npm test`, `rtk npm run build`, `rtk npx prisma migrate status`.

Expected: all tests pass, TypeScript compiles, and database schema is current.
