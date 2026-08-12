# Station Identity Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align backend and Flutter station names/public codes with the supplied KRL, MRT, and LRT PDFs without changing schematic geometry or route topology.

**Architecture:** Keep stable short names and internal node keys for compatibility, add exact official display names and operational codes to stations, and model public codes as a station-line relation independent from drawable nodes. Seed data remains the single catalog source; API DTOs expose official identities while accepting legacy aliases.

**Tech Stack:** TypeScript, Express, Prisma 5/PostgreSQL, Node test runner, Flutter/Dart.

**Repository note:** `C:\Users\riyadh\Downloads\timetable_backend` has no `.git` directory, so commit steps are intentionally omitted. Verification evidence replaces commit checkpoints.

---

## File map

- `prisma/schema.prisma`: station identity and public-code relations.
- `prisma/migrations/20260810000000_station_identity_contract/migration.sql`: additive database migration and public-code backfill.
- `prisma/networkData.ts`: official-name/public-code overlay plus node-less Gambir and Jatake records.
- `prisma/seed.ts`: stable slug-first matching, code seeding, and aliases.
- `src/domain/services/stationIdentity.ts`: one display-name/public-code policy.
- `src/presentation/controllers/stationController.ts`: station list/network DTOs and filters.
- `src/domain/services/routeService.ts`: boarding-safe identity resolution and official labels.
- `src/presentation/controllers/scheduleController.ts`: operational/public code lookup including pass-through stations.
- `tests/networkData.test.ts`: catalog and topology invariants.
- `tests/stationIdentity.test.ts`: pure identity helper tests.
- `lib/shared/widgets/schematic_map_painter.dart`: PDF-correct labels/codes only.
- `test/station_map_contract_test.dart`: Flutter catalog and unchanged-topology contract.

## Task 1: Lock catalog and topology invariants

**Files:**
- Modify: `tests/networkData.test.ts`

- [ ] **Step 1: Add failing official-code assertions**

Add a helper that reads a public-code override when present and otherwise uses the existing node key:

```ts
const publicCodeFor = (stationName: string, lineSlug: string) => {
  const station = networkData.stations.find((item) => item.name === stationName);
  const node = station?.nodes.find((item) => item.lineSlug === lineSlug);
  if (!node) return undefined;
  return 'publicCode' in node ? node.publicCode : node.code;
};
```

Assert exact corrections:

```ts
assert.equal(publicCodeFor('Jakarta Int. Stadium', 'tanjung_priok'), null);
assert.equal(publicCodeFor('Tanjung Priok', 'tanjung_priok'), 'TP04');
assert.equal(publicCodeFor('Parung Panjang', 'rangkasbitung'), 'R12');
assert.equal(publicCodeFor('Cilejit', 'rangkasbitung'), 'R14');
assert.equal(publicCodeFor('Daru', 'rangkasbitung'), 'R15');
assert.equal(publicCodeFor('Tenjo', 'rangkasbitung'), 'R16');
assert.equal(publicCodeFor('Tigaraksa', 'rangkasbitung'), 'R18');
assert.equal(publicCodeFor('Cikoya', 'rangkasbitung'), 'R19');
assert.equal(publicCodeFor('Maja', 'rangkasbitung'), 'R20');
assert.equal(publicCodeFor('Citeras', 'rangkasbitung'), 'R21');
assert.equal(publicCodeFor('Rangkasbitung', 'rangkasbitung'), 'R22');
assert.equal(publicCodeFor('Pondok Rajeg', 'bogor_nambo'), 'b23');
```

- [ ] **Step 2: Assert official names and non-visual operational stations**

```ts
const officialNameFor = (shortName: string) => {
  const station = networkData.stations.find((item) => item.name === shortName);
  return station && 'officialName' in station ? station.officialName : station?.name;
};

assert.equal(officialNameFor('ASEAN HQ'), 'ASEAN Headquarters');
assert.equal(officialNameFor('Lebak Bulus'), 'Lebak Bulus Bank Syariah Indonesia');
assert.equal(officialNameFor('Pancoran'), 'Pancoran bank bjb');
assert.equal(officialNameFor('Taman Mini'), 'TMII');
assert.deepEqual(
  networkData.stations.find((station) => station.name === 'Gambir')?.nodes,
  [],
);
assert.deepEqual(
  networkData.stations.find((station) => station.name === 'Jatake')?.nodes,
  [],
);
```

- [ ] **Step 3: Run the test and confirm it fails before data changes**

Run: `rtk npm test`

Expected: the new official-name/code assertions fail while the existing 7 tests remain otherwise healthy.

## Task 2: Extend the Prisma identity model safely

**Files:**
- Modify: `prisma/schema.prisma`
- Create: `prisma/migrations/20260810000000_station_identity_contract/migration.sql`

- [ ] **Step 1: Rename semantic Prisma properties without renaming existing columns**

Change station/node identity fields and add the relations:

```prisma
model Station {
  id                String    @id @default(uuid())
  slug              String?   @unique
  operationalCode   String?   @unique @map("code")
  nodeCode          String?
  name              String
  officialName      String?
  isBoardingAllowed Boolean   @default(true)
  publicCodes       StationPublicCode[]
  // existing fields and relations remain unchanged
}

model StationNode {
  id      String @id @default(uuid())
  nodeKey String @unique @map("code")
  // existing fields and relations remain unchanged
}

model StationPublicCode {
  id        String  @id @default(uuid())
  stationId String
  lineId    String
  code      String
  station   Station @relation(fields: [stationId], references: [id], onDelete: Cascade)
  line      Line    @relation(fields: [lineId], references: [id], onDelete: Cascade)

  @@unique([stationId, lineId])
  @@unique([lineId, code])
  @@index([code])
}
```

Add `publicCodes StationPublicCode[]` to `Line`.

- [ ] **Step 2: Add an additive SQL migration**

The migration adds `officialName`, `isBoardingAllowed`, and `StationPublicCode`; it does not rename the existing `Station.code` or `StationNode.code` columns because Prisma `@map` preserves them. Backfill every current node except `mapId='jis'`, correcting Tanjung Priok and Rangkasbitung with a SQL `CASE`. Use deterministic text IDs:

```sql
INSERT INTO "StationPublicCode" ("id", "stationId", "lineId", "code")
SELECT 'public-code-' || md5(n."id" || ':' || n."lineId"), n."stationId", n."lineId",
  CASE n."mapId"
    WHEN 'tanjung_priok' THEN 'TP04'
    WHEN 'parung_panjang' THEN 'R12'
    WHEN 'cilejit' THEN 'R14'
    WHEN 'daru' THEN 'R15'
    WHEN 'tenjo' THEN 'R16'
    WHEN 'tigaraksa' THEN 'R18'
    WHEN 'cikoya' THEN 'R19'
    WHEN 'maja' THEN 'R20'
    WHEN 'citeras' THEN 'R21'
    WHEN 'rangkasbitung' THEN 'R22'
    ELSE n."code"
  END
FROM "StationNode" n
WHERE n."mapId" <> 'jis';
```

- [ ] **Step 3: Validate and regenerate the client**

Run: `rtk npx prisma validate`

Expected: `The schema at prisma/schema.prisma is valid`.

Run: `rtk npx prisma generate`

Expected: Prisma Client generation succeeds.

## Task 3: Correct the master station catalog

**Files:**
- Modify: `prisma/networkData.ts`
- Modify: `tests/networkData.test.ts`

- [ ] **Step 1: Define compact optional overlays**

Use explicit catalog types so unchanged nodes do not repeat their code:

```ts
type NetworkNode = {
  mapId: string;
  code: string;
  publicCode?: string | null;
  lineSlug: string;
  sequence: number;
  x: number;
  y: number;
  isTransit: boolean;
};

type NetworkStation = {
  slug: string;
  name: string;
  officialName?: string;
  operationalCode?: string;
  isBoardingAllowed?: boolean;
  lineSlugs?: string[];
  publicCodes?: Array<{ lineSlug: string; code: string }>;
  aliases: string[];
  nodes: NetworkNode[];
  // retain the existing flags and display metadata
};
```

- [ ] **Step 2: Apply exact PDF names/codes**

Keep every `mapId`, `code` internal key, sequence, coordinate, line array, and `lines[].nodeCodes` unchanged. Add only `officialName` or `publicCode` overlays. Required corrections include:

```ts
{ name: 'Jakarta Int. Stadium', nodes: [{ code: 'TP04', publicCode: null }] }
{ name: 'Tanjung Priok', nodes: [{ code: 'TP05', publicCode: 'TP04' }] }
{ name: 'Parung Panjang', nodes: [{ code: 'R11', publicCode: 'R12' }] }
{ name: 'Rangkasbitung', nodes: [{ code: 'R19', publicCode: 'R22' }] }
{ name: 'ASEAN HQ', officialName: 'ASEAN Headquarters' }
{ name: 'Lebak Bulus', officialName: 'Lebak Bulus Bank Syariah Indonesia' }
{ name: 'Pancoran', officialName: 'Pancoran bank bjb' }
{ name: 'Taman Mini', officialName: 'TMII' }
```

Preserve all previous short/sponsored variants in `aliases`. Do not change lowercase `b23`-`b26` on the Nambo branch.

- [ ] **Step 3: Add node-less operational records**

Add Gambir and Jatake with no nodes or coordinates:

```ts
{
  slug: 'gambir',
  name: 'Gambir',
  operationalCode: 'GMR',
  isBoardingAllowed: false,
  lineSlugs: ['bogor'],
  publicCodes: [{ lineSlug: 'bogor', code: 'B06' }],
  aliases: [],
  nodes: [],
  isTransit: false,
  isAccessible: false,
  isLrt: false,
  isKrl: true,
  isMrt: false,
  lineInfo: 'KRL Lin Bogor (lintas langsung)',
  statusText: 'Tidak melayani naik/turun'
}
```

Jatake uses `operationalCode: 'JTK'`, `isBoardingAllowed: true`, `lineSlugs: ['rangkasbitung']`, no inferred public code, and no node.

- [ ] **Step 4: Run catalog tests**

Run: `rtk npm test`

Expected: official mapping tests pass; drawable topology retains 121 stations, 135 nodes, 11 lines, and no orphan internal node keys.

## Task 4: Make seeding stable and idempotent

**Files:**
- Modify: `prisma/seed.ts`

- [ ] **Step 1: Prefer stable slugs before normalized names**

Select the existing primary station by slug first, then fall back to alias/name normalization:

```ts
const primary =
  existing.find((station) => station.slug === definition.slug) ??
  candidates[0];
```

- [ ] **Step 2: Seed exact station fields and aliases**

Both update/create branches set:

```ts
name: definition.name,
officialName: definition.officialName ?? definition.name,
operationalCode: definition.operationalCode ?? null,
isBoardingAllowed: definition.isBoardingAllowed ?? true,
```

Alias input is deduplicated from `name`, `officialName`, and existing aliases. Line membership is the union of node line slugs, explicit `lineSlugs`, and explicit public-code line slugs.

- [ ] **Step 3: Keep topology internal and seed public codes separately**

Upsert nodes by `nodeKey: node.code`. Build public-code definitions using `node.publicCode` when present, omit explicit `null`, default to `node.code`, and append station-level `publicCodes`. Replace public codes transactionally:

```ts
await prisma.$transaction(async (tx) => {
  await tx.stationPublicCode.deleteMany();
  await tx.stationPublicCode.createMany({ data: publicCodeRows });
});
```

- [ ] **Step 4: Verify idempotence against the configured database**

Run twice: `rtk npx prisma db seed`

Expected after each run: the same station/public-code/node counts, no unique violations, JIS has zero public codes, Tanjung Priok has `TP04`, Gambir has `B06/GMR`, and Jatake has `JTK` with boarding allowed.

## Task 5: Centralize identity DTO behavior

**Files:**
- Create: `src/domain/services/stationIdentity.ts`
- Create: `tests/stationIdentity.test.ts`

- [ ] **Step 1: Write failing pure helper tests**

Cover official-name preference, legacy fallback, line-specific public code, and case-sensitive `B23` versus `b23`.

- [ ] **Step 2: Implement small pure helpers**

```ts
export const stationDisplayName = (station: { name: string; officialName?: string | null }) =>
  station.officialName?.trim() || station.name;

export const publicCodeForLine = (
  station: { publicCodes: Array<{ lineId: string; code: string }> },
  lineId: string,
) => station.publicCodes.find((item) => item.lineId === lineId)?.code ?? null;
```

- [ ] **Step 3: Run focused tests**

Run: `rtk node --import tsx --test tests/stationIdentity.test.ts`

Expected: all helper tests pass.

## Task 6: Expose the corrected API contract

**Files:**
- Modify: `src/presentation/controllers/stationController.ts`
- Modify: `src/domain/services/routeService.ts`
- Modify: `src/presentation/controllers/scheduleController.ts`

- [ ] **Step 1: Update station lookup filters**

Search `name`, `officialName`, `operationalCode`, aliases, exact-case `publicCodes.code`, and legacy `nodes.nodeKey`. Default station list and route origins/destinations require `isBoardingAllowed: true`; schedule detail lookup does not.

- [ ] **Step 2: Return compatibility-safe station DTOs**

Station list items return official `name`, stable `shortName`, `officialName`, `operationalCode`, aliases, and public codes. Network nodes return:

```ts
{
  id: node.id,
  mapId: node.mapId,
  code: publicCodeForLine(node.station, node.lineId),
  publicCode: publicCodeForLine(node.station, node.lineId),
  sequence: node.sequence,
  mapX: node.mapX,
  mapY: node.mapY,
  station: {
    id: node.station.id,
    slug: node.station.slug,
    name: stationDisplayName(node.station),
    shortName: node.station.name
  }
}
```

Do not expose `nodeKey` as an official station code.

- [ ] **Step 3: Use official labels in routes without changing graph traversal**

Continue traversing `StationNode.id` and connection rows. Replace output-only names with `stationDisplayName`; emit the line-specific public code instead of the internal node key.

- [ ] **Step 4: Run backend verification**

Run: `rtk npm test`

Expected: all tests pass.

Run: `rtk npm run build`

Expected: TypeScript compilation succeeds.

## Task 7: Correct Flutter schematic labels without changing its shape

**Files:**
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/shared/widgets/schematic_map_painter.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/test/station_map_contract_test.dart`

- [ ] **Step 1: Write failing map-contract assertions**

Import the painter catalog and assert corrected labels/codes, including JIS empty code, Tanjung Priok `TP04`, Rangkas corrections, exact MRT/LRT official labels, and lowercase Nambo codes.

- [ ] **Step 2: Update only `name` and `code` arguments**

Do not alter any station `id`, `Offset`, `isWaypoint`, `lines`, `LineData.stationIds`, canvas dimension, or painter logic. Apply the same official names and public codes as Task 3. JIS uses `code: ''`.

- [ ] **Step 3: Verify topology checksum**

Run the deterministic geometry check from the design session.

Expected:

```text
stationEntries=177
geometrySha256=3431aa045b876116f0619029a109fb41ef948351e8c722c96e9d1c58a61ab30d
lineEntries=11
linePathSha256=4c5b6db1bfab706b7b1935a6727eec5a21f056f04d2a8376ac27bfb72bcad915
```

- [ ] **Step 4: Run focused Flutter test**

Run: `rtk flutter test test/station_map_contract_test.dart`

Expected: the station map contract passes.

- [ ] **Step 5: Run analyzer and compare with baseline**

Run: `rtk flutter analyze`

Expected: no new findings beyond the three pre-existing painter findings (`unused_element`, `curly_braces_in_flow_control_structures`, `unused_local_variable`).

## Task 8: Final cross-project verification

**Files:**
- Modify only if verification exposes a regression in the files listed above.

- [ ] **Step 1: Verify backend**

Run: `rtk npx prisma validate`, `rtk npm test`, and `rtk npm run build` as separate commands.

Expected: schema valid, all backend tests pass, TypeScript build passes.

- [ ] **Step 2: Verify mobile contract**

Run: `rtk flutter test test/station_map_contract_test.dart` and `rtk flutter analyze` as separate commands.

Expected: contract test passes and analyzer has no new findings.

- [ ] **Step 3: Record existing unrelated mobile failures**

Run: `rtk flutter test`.

Expected baseline context: the pre-change suite had 29 failures, primarily localization-dependent assistant/widget tests. Any changed failure count or new station-related failure is investigated; existing unrelated failures are not reported as caused by station alignment.
