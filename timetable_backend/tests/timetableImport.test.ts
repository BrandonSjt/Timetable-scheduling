import 'dotenv/config';
import assert from 'node:assert/strict';
import { after, test } from 'node:test';
import { PrismaClient } from '@prisma/client';
import { mobileScheduleData } from '../prisma/mobileScheduleData';

const prisma = new PrismaClient();
after(() => prisma.$disconnect());

test('active February 2026 dataset has audited normalized totals', async () => {
  const dataset = await prisma.timetableDataset.findFirstOrThrow({ where: { isActive: true } });
  const [activeDatasets, calendars, services, stops, passThrough, crossMidnight, weekday, fullRacket, legacy] =
    await Promise.all([
      prisma.timetableDataset.count({ where: { isActive: true } }),
      prisma.serviceCalendar.count({ where: { datasetId: dataset.id } }),
      prisma.trainService.count({ where: { datasetId: dataset.id } }),
      prisma.trainStopTime.count({ where: { service: { datasetId: dataset.id } } }),
      prisma.trainStopTime.count({ where: { service: { datasetId: dataset.id }, isPassThrough: true } }),
      prisma.trainService.count({
        where: { datasetId: dataset.id, stops: { some: { arrivalMinute: { gte: 1440 } } } },
      }),
      prisma.trainService.count({ where: { datasetId: dataset.id, calendar: { code: 'WEEKDAY' } } }),
      prisma.trainService.count({ where: { datasetId: dataset.id, isFullRacket: true } }),
      prisma.schedule.count(),
    ]);

  assert.equal(dataset.version, '2026-02');
  assert.match(dataset.sourceSha256, /^[a-f0-9]{64}$/);
  assert.deepEqual(
    { activeDatasets, calendars, services, stops, passThrough, crossMidnight, weekday, fullRacket, legacy },
    {
      activeDatasets: 1,
      calendars: 2,
      services: 1145,
      stops: 19328,
      passThrough: 343,
      crossMidnight: 21,
      weekday: 33,
      fullRacket: 160,
      legacy: mobileScheduleData.length,
    },
  );
});

test('service line totals stay separate from mobile geometry lines', async () => {
  const dataset = await prisma.timetableDataset.findFirstOrThrow({ where: { isActive: true } });
  const totals = await prisma.trainService.groupBy({
    by: ['lineSlug'],
    where: { datasetId: dataset.id },
    _count: { _all: true },
    orderBy: { lineSlug: 'asc' },
  });
  assert.deepEqual(
    Object.fromEntries(totals.map(({ lineSlug, _count }) => [lineSlug, _count._all])),
    { bogor: 392, cikarang: 365, rangkasbitung: 204, tangerang: 120, tanjung_priok: 64 },
  );
  assert.equal(await prisma.line.count({ where: { slug: 'cikarang' } }), 0);
  assert.equal(await prisma.line.count({ where: { slug: { in: ['cikarang_east', 'cikarang_loop'] } } }), 2);
});

test('Gambir and Jatake timetable calls resolve to stable station identities', async () => {
  for (const [stationCode, slug] of [
    ['GMR', 'gambir'],
    ['JTK', 'jatake'],
  ] as const) {
    const station = await prisma.station.findUniqueOrThrow({ where: { slug } });
    assert.equal(station.operationalCode, stationCode);
    assert.ok(
      await prisma.trainStopTime.count({ where: { stationId: station.id, stationCode } }),
      `${stationCode} has no imported timetable calls`,
    );
  }
});
