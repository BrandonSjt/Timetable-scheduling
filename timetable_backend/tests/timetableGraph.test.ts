import 'dotenv/config';
import assert from 'node:assert/strict';
import { after, test } from 'node:test';
import { loadTimetableGraph, medianTravelMinutes } from '../src/domain/services/timetableGraph';
import { prisma } from '../src/infrastructure/database/prismaClient';
import { RouteService } from '../src/domain/services/routeService';

after(() => prisma.$disconnect());

test('travel estimate uses median without modifying source samples', () => {
  const times = [3, 4, 20, 3, 4];
  assert.equal(medianTravelMinutes(times), 4);
  assert.deepEqual(times, [3, 4, 20, 3, 4]);
});

test('PDF missing-node supplement is timed, bidirectional, excludes Gambir and has no invented geometry', async () => {
  const graph = await loadTimetableGraph();
  const jatakeEdges = graph.filter((edge) => edge.fromNode.station.slug === 'jatake' || edge.toNode.station.slug === 'jatake');
  assert.equal(jatakeEdges.length, 4);
  for (const edge of jatakeEdges) {
    const node = edge.fromNode.station.slug === 'jatake' ? edge.fromNode : edge.toNode;
    assert.equal(node.mapX, null); assert.equal(node.mapY, null);
    assert.ok(edge.travelTime > 0); assert.equal(edge.isTransfer, false);
    assert.equal(edge.fromNode.line.slug, 'rangkasbitung');
  }
  assert.ok(!graph.some((edge) => edge.fromNode.station.slug === 'gambir' || edge.toNode.station.slug === 'gambir'));
  assert.ok(!graph.some((edge) => [edge.fromNode.station.slug, edge.toNode.station.slug].sort().join('|') === 'cicayur|parung-panjang'));
  assert.equal(await prisma.stationNode.count({ where: { station: { slug: 'jatake' } } }), 0);
});

test('Jatake routes work at either endpoint and remain present as an intermediate stop', async () => {
  for (const [from, to] of [['Jatake', 'Jakarta Kota'], ['Jakarta Kota', 'Jatake'], ['Cicayur', 'Parung Panjang']]) {
    const route = await RouteService.planRoute(from, to);
    assert.equal(route.from, from); assert.equal(route.to, to);
    assert.ok(route.stationSequence.some((station) => station.name === 'Jatake'));
  }
});
