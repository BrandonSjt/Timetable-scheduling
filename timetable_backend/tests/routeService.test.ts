import 'dotenv/config';
import assert from 'node:assert/strict';
import { after, test } from 'node:test';
import { RouteService } from '../src/domain/services/routeService';
import { prisma } from '../src/infrastructure/database/prismaClient';

after(() => prisma.$disconnect());

test('priority-queue Dijkstra follows mobile nodes and supports transfers', async () => {
  const fastest = await RouteService.planRoute('Bogor', 'Tangerang', 1, 'FASTEST');
  const minimumTransfers = await RouteService.planRoute(
    'Bogor',
    'Tangerang',
    1,
    'MIN_TRANSFERS',
  );

  for (const route of [fastest, minimumTransfers]) {
    assert.equal(route.stationSequence[0].name, 'Bogor');
    assert.equal(route.stationSequence.at(-1)?.name, 'Tangerang');
    assert.equal(route.hasTransit, true);
    assert.ok(route.travelTime > 0);
    assert.ok(route.stationSequence.some(({ line }) => line.slug === 'tangerang'));
    assert.equal(route.transferCount, route.steps.filter(({ isTransit }) => isTransit).length);
  }
  assert.equal(fastest.preference, 'FASTEST');
  assert.equal(minimumTransfers.preference, 'MIN_TRANSFERS');
  assert.ok(minimumTransfers.transferCount <= fastest.transferCount);
  if (minimumTransfers.transferCount === fastest.transferCount) {
    assert.ok(minimumTransfers.travelTime >= fastest.travelTime);
  }
});
