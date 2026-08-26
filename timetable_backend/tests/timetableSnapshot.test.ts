import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import test from 'node:test';
import { networkData } from '../prisma/networkData';
import { operationalStationCodes } from '../prisma/operationalStationCodes';

type Snapshot = {
  meta: { version: string; sourceSha256: string };
  services: Array<{
    lineSlug: string;
    direction: string;
    sourcePage: number;
    sourceRow: number;
    loopNumber: number | null;
    trainNumber: string;
    continuationTrainNumber: string | null;
    relation: string;
    calendarCode: 'DAILY' | 'WEEKDAY';
    isFullRacket: boolean;
    notes: string;
    stops: Array<{
      stationCode: string;
      sequence: number;
      arrivalMinute: number | null;
      departureMinute: number | null;
      isPassThrough: boolean;
    }>;
  }>;
};

const snapshot = JSON.parse(
  fs.readFileSync(
    path.join(process.cwd(), 'prisma/data/commuter-2026-02.json'),
    'utf8',
  ),
) as Snapshot;

test('operational code mapping covers 85 existing station slugs', () => {
  assert.equal(Object.keys(operationalStationCodes).length, 85);
  const slugs = new Set(networkData.stations.map(({ slug }) => slug));
  for (const [code, slug] of Object.entries(operationalStationCodes)) {
    assert.ok(slugs.has(slug), `${code} references unknown station slug ${slug}`);
  }
});

test('February 2026 snapshot matches audited source totals', () => {
  const { services } = snapshot;
  const calls = services.flatMap(({ stops }) => stops);
  const primaryNumbers = new Set(services.map(({ trainNumber }) => trainNumber));
  const individualNumbers = new Set(primaryNumbers);
  for (const { continuationTrainNumber } of services) {
    if (continuationTrainNumber) individualNumbers.add(continuationTrainNumber);
  }

  assert.equal(snapshot.meta.version, '2026-02');
  assert.match(snapshot.meta.sourceSha256, /^[a-f0-9]{64}$/);
  assert.equal(services.length, 1145);
  assert.equal(individualNumbers.size, 1147);
  assert.equal(calls.filter(({ arrivalMinute }) => arrivalMinute != null).length, 18985);
  assert.equal(calls.filter(({ isPassThrough }) => isPassThrough).length, 343);
  assert.equal(
    services.filter(({ stops }) =>
      stops.some(({ arrivalMinute }) => (arrivalMinute ?? 0) >= 1440),
    ).length,
    21,
  );
  assert.equal(
    services.filter(({ calendarCode }) => calendarCode === 'WEEKDAY').length,
    33,
  );
  assert.equal(services.filter(({ isFullRacket }) => isFullRacket).length, 160);
  assert.equal(new Set(calls.map(({ stationCode }) => stationCode)).size, 85);
});

test('snapshot preserves line totals, continuations, and source anomaly', () => {
  const totals = snapshot.services.reduce<Record<string, number>>(
    (counts, { lineSlug }) => {
      counts[lineSlug] = (counts[lineSlug] ?? 0) + 1;
      return counts;
    },
    {},
  );
  assert.deepEqual(
    totals,
    {
      bogor: 392,
      cikarang: 365,
      rangkasbitung: 204,
      tangerang: 120,
      tanjung_priok: 64,
    },
  );

  const continuationRows = snapshot.services.filter(
    ({ continuationTrainNumber }) => continuationTrainNumber,
  );
  const primaryNumbers = new Set(snapshot.services.map(({ trainNumber }) => trainNumber));
  const continuationOnly = continuationRows
    .map(({ continuationTrainNumber }) => continuationTrainNumber!)
    .filter((number) => !primaryNumbers.has(number))
    .sort();
  assert.equal(continuationRows.length, 80);
  assert.deepEqual(continuationOnly, ['5746', '6052B']);

  const service5020A = snapshot.services.find(({ trainNumber }) => trainNumber === '5020A');
  assert.ok(service5020A);
  const cikarang = service5020A.stops.find(({ stationCode }) => stationCode === 'CKR');
  assert.equal(cikarang?.arrivalMinute, 6 * 60 + 24);
  assert.match(service5020A.notes, /06:31/);
});
