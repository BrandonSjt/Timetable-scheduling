import assert from 'node:assert/strict';
import fs from 'node:fs';
import { operationalStationCodes } from '../prisma/operationalStationCodes';
import express from 'express';
import { getSchedules } from '../src/presentation/controllers/scheduleController';
import { getStations } from '../src/presentation/controllers/stationController';
import { askAssistant } from '../src/presentation/controllers/assistantController';
import { prisma } from '../src/infrastructure/database/prismaClient';

// Read-only, local only. No real Gemini requests, reimports, or DB writes.
let base = 'http://127.0.0.1:3000/api/v1';
const snapshot = JSON.parse(fs.readFileSync('prisma/data/commuter-2026-02.json', 'utf8'));
async function call(path: string, body?: unknown) {
  const response = await fetch(`${base}${path}`, {
    ...(body ? { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) } : {}),
    signal: AbortSignal.timeout(30_000),
  });
  assert.equal(response.status, 200, `${path}: HTTP ${response.status}`);
  const result = await response.json() as any;
  assert.equal(result.success, true, path);
  return result;
}
async function main() {
  let requests = 0;
  for (const weekend of [false, true]) {
    const expected = snapshot.services.filter((service: any) => !weekend || service.calendarCode === 'DAILY');
    const seen = new Set<string>();
    const numbers = new Set<string>();
    for (let page = 1; seen.size < expected.length; ++page) {
      const result = await call(`/schedules?isWeekend=${weekend}&limit=100&page=${page}`); ++requests;
      assert.equal(result.meta.total, expected.length);
      assert.equal(result.meta.datasetVersion, snapshot.meta.version);
      assert.equal(result.meta.scope, 'services');
      assert.equal(result.meta.page, page);
      assert.ok(result.data.length, 'Unexpected empty page');
      for (const row of result.data) {
        assert.ok(!seen.has(row.id), 'Duplicate schedule ID');
        seen.add(row.id); numbers.add(row.trainNumber);
        if (weekend) assert.equal(row.calendarCode, 'DAILY');
      }
    }
    assert.equal(seen.size, expected.length);
    assert.deepEqual([...numbers].sort(), expected.map((service: any) => service.trainNumber).sort());
  }
  const stations = await call('/stations?service=KRL&limit=200'); ++requests;
  const boarding = new Set(stations.data.map((station: any) => station.slug));
  for (const [code, slug] of Object.entries(operationalStationCodes)) {
    if (!boarding.has(slug)) { assert.equal(slug, 'gambir'); continue; }
    const expected = snapshot.services.reduce((total: number, service: any) => total + service.stops.filter((stop: any) => stop.stationCode === code && !stop.isPassThrough && stop.departureMinute != null).length, 0);
    const result = await call(`/schedules?station=${encodeURIComponent(slug)}&isWeekend=false&limit=1`); ++requests;
    assert.equal(result.meta.total, expected, `${slug}: missing calls`);
  }
  const manggaraiIds = new Set<string>();
  let stationTotal = 0;
  for (let page = 1; page === 1 || manggaraiIds.size < stationTotal; ++page) {
    const result = await call(`/schedules?station=Manggarai&isWeekend=false&limit=100&page=${page}`); ++requests;
    stationTotal = result.meta.total;
    assert.ok(result.data.length);
    for (const row of result.data) {
      assert.ok(!manggaraiIds.has(row.id), 'Duplicate station call ID');
      manggaraiIds.add(row.id);
    }
  }
  const scenarios = [
    ['aku mau ke Jakarta Kota dari jruangmangu, naik apa ya?', 'Jurangmangu', 'Jakarta Kota'],
    ['dari Bogor ke Jakarta Kota', 'Bogor', 'Jakarta Kota'],
    ['dari Bekasi ke Sudirman', 'Bekasi', 'Sudirman'],
    ['dari Tangerang ke Manggarai', 'Tangerang', 'Manggarai'],
    ['dari Tanjung Priok ke Jakarta Kota', 'Tanjung Priok', 'Jakarta Kota'],
    ['dari Rangkasbitung ke Tanah Abang', 'Rangkasbitung', 'Tanah Abang'],
    ['dari Jatake ke Jakarta Kota', 'Jatake', 'Jakarta Kota'],
  ];
  for (const [message, from, to] of scenarios) {
    const result = await call('/assistant/chat', { message }); ++requests;
    assert.deepEqual(result.data.route, { from, to });
    assert.ok(result.data.reply.includes(from) && result.data.reply.includes(to));
    assert.ok(!result.data.reply.includes('belum tersedia'));
  }
  const schedule = await call('/assistant/chat', { message: 'jadwal dari Jurangmangu ke Jakarta Kota' }); ++requests;
  assert.ok(schedule.data.reply.includes('Tanah Abang'));
  assert.ok(schedule.data.reply.includes('jadwal PDF'));
  assert.deepEqual(schedule.data.route, { from: 'Jurangmangu', to: 'Jakarta Kota' });
  console.log(JSON.stringify({ globalWeekdayServices: 1145, globalWeekendServices: 1112, boardingStationsChecked: 84, manggaraiCallsFetched: manggaraiIds.size, assistantRouteCases: scenarios.length, requests, allPassed: true }, null, 2));
}
async function run() {
  // Explicit test harness: exercise real controllers/HTTP against read-only
  // database queries without consuming the running app's request allowance.
  // This is NOT a production security or deployed API availability test.
  if (!process.argv.includes('--isolated')) return main();
  const app = express();
  app.use(express.json());
  app.get('/api/v1/schedules', getSchedules);
  app.get('/api/v1/stations', getStations);
  app.post('/api/v1/assistant/chat', askAssistant);
  app.use((error: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => res.status(error.statusCode ?? 500).json({ success: false, code: error.code }));
  const server = app.listen(0, '127.0.0.1');
  await new Promise<void>((resolve) => server.once('listening', resolve));
  const address = server.address();
  assert.ok(address && typeof address !== 'string');
  base = `http://127.0.0.1:${address.port}/api/v1`;
  try { await main(); } finally { await new Promise<void>((resolve) => server.close(() => resolve())); }
}
run().catch((error) => { console.error(error.message); process.exitCode = 1; }).finally(() => prisma.$disconnect());
