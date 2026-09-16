import 'dotenv/config';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import { operationalStationCodes } from '../prisma/operationalStationCodes';
import { loadTimetableGraph } from '../src/domain/services/timetableGraph';
import { prisma } from '../src/infrastructure/database/prismaClient';

// Read-only: verify every imported field, not just aggregate row counts.
const snapshot = JSON.parse(fs.readFileSync('prisma/data/commuter-2026-02.json', 'utf8'));

async function main() {
  const dataset = await prisma.timetableDataset.findUnique({ where: { version: snapshot.meta.version } });
  assert.ok(dataset?.isActive, 'The audited dataset must be active');
  assert.equal(dataset.sourceSha256, snapshot.meta.sourceSha256, 'Source hash differs');
  const services = await prisma.trainService.findMany({
    where: { datasetId: dataset.id },
    include: {
      calendar: true,
      stops: { orderBy: { sequence: 'asc' }, include: { station: { select: { slug: true } } } },
    },
  });
  const indexed = new Map(services.map((service) => [service.trainNumber, service]));
  assert.equal(services.length, snapshot.services.length, 'Missing/extra services');
  let calls = 0;
  const totals: Record<string, number> = {};
  const scheduledStations = new Set<string>();
  for (const expected of snapshot.services) {
    const actual = indexed.get(expected.trainNumber);
    assert.ok(actual, `Missing KA ${expected.trainNumber}`);
    for (const key of [
      'lineSlug', 'direction', 'sourcePage', 'sourceRow', 'loopNumber',
      'trainNumber', 'continuationTrainNumber', 'relation', 'isFullRacket', 'notes',
    ] as const) {
      assert.equal(actual[key], expected[key], `KA ${expected.trainNumber}: ${key}`);
    }
    assert.equal(actual.calendar.code, expected.calendarCode, `KA ${expected.trainNumber}: calendar`);
    for (const weekday of ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'] as const) assert.equal(actual.calendar[weekday], true, `KA ${expected.trainNumber}: ${weekday}`);
    assert.equal(actual.calendar.saturday, expected.calendarCode === 'DAILY');
    assert.equal(actual.calendar.sunday, expected.calendarCode === 'DAILY');
    assert.equal(actual.calendar.excludesPublicHolidays, expected.calendarCode === 'WEEKDAY');
    assert.deepEqual(actual.stops.map((stop) => ({
      stationCode: stop.stationCode, sequence: stop.sequence,
      arrivalMinute: stop.arrivalMinute, departureMinute: stop.departureMinute,
      isPassThrough: stop.isPassThrough,
    })), expected.stops, `KA ${expected.trainNumber}: stop/time mismatch`);
    for (const stop of actual.stops) {
      assert.equal(stop.station.slug, operationalStationCodes[stop.stationCode], `Wrong station for ${stop.stationCode}`);
      if (!stop.isPassThrough && stop.departureMinute != null) scheduledStations.add(stop.station.slug!);
    }
    calls += actual.stops.length;
    totals[actual.lineSlug] = (totals[actual.lineSlug] ?? 0) + 1;
  }
  const stations = await prisma.station.findMany({
    where: { slug: { in: Object.values(operationalStationCodes) } }, include: { nodes: true },
  });
  assert.equal(stations.length, 85, 'PDF station catalogue incomplete');
  const edges = await loadTimetableGraph();
  const stationNodes = new Map<string, Set<string>>();
  for (const edge of edges) for (const node of [edge.fromNode, edge.toNode]) {
    const nodeIds = stationNodes.get(node.stationId) ?? new Set<string>();
    nodeIds.add(node.id); stationNodes.set(node.stationId, nodeIds);
  }
  const graph = new Map<string, string[]>();
  for (const edge of edges) graph.set(edge.fromNodeId, [...(graph.get(edge.fromNodeId) ?? []), edge.toNodeId]);
  const boardingStations = stations.filter((station) => station.isBoardingAllowed);
  for (const origin of boardingStations) {
    assert.ok(scheduledStations.has(origin.slug!), `${origin.slug}: no timed calls`);
    const reachable = new Set(stationNodes.get(origin.id) ?? []);
    const queue = [...reachable];
    for (let i = 0; i < queue.length; ++i) {
      for (const next of graph.get(queue[i]) ?? []) {
        if (!reachable.has(next)) { reachable.add(next); queue.push(next); }
      }
    }
    for (const destination of boardingStations) {
      assert.ok([...(stationNodes.get(destination.id) ?? [])].some((id) => reachable.has(id)), `Disconnected ${origin.slug} -> ${destination.slug}`);
    }
  }
  console.log(JSON.stringify({ version: dataset.version, services: services.length, calls, stations: stations.length, boardingStations: boardingStations.length, schematicNodesMissing: boardingStations.filter((station) => !station.nodes.length).map((station) => station.slug), passThroughOnlyStations: stations.filter((station) => !station.isBoardingAllowed).map((station) => station.slug), totals, directedStationPairsChecked: boardingStations.length ** 2, allRecordsMatch: true }, null, 2));
}

main().catch((error) => { console.error(error.message); process.exitCode = 1; }).finally(() => prisma.$disconnect());
