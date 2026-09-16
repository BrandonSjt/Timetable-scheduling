import { prisma } from '../../infrastructure/database/prismaClient';

/** Route-only supplements for PDF boarding stations missing schematic nodes.
 * No database writes or invented map coordinates. Only observed adjacent timed
 * calls on the same line are used; pass-through stations cannot become stops.
 */
export async function loadTimetableGraph() {
  const connections = await prisma.routeConnection.findMany({
    include: {
      fromNode: { include: { station: { include: { publicCodes: true } }, line: true } },
      toNode: { include: { station: { include: { publicCodes: true } }, line: true } },
    },
  });
  const missing = await prisma.station.findMany({
    where: { isKrl: true, isBoardingAllowed: true, nodes: { none: {} } },
    select: { id: true },
  });
  if (!missing.length) return connections;
  const dataset = await prisma.timetableDataset.findFirst({ where: { isActive: true }, select: { id: true } });
  if (!dataset) return connections;
  const ids = new Set(missing.map((station) => station.id));
  const services = await prisma.trainService.findMany({
    where: { datasetId: dataset.id, stops: { some: { stationId: { in: [...ids] }, isPassThrough: false } } },
    include: { stops: { orderBy: { sequence: 'asc' }, include: { station: { include: { nodes: true, publicCodes: true } } } } },
  });
  const supplements = new Map<string, { connection: (typeof connections)[number]; minutes: number[] }>();
  const bypasses = new Set<string>();
  for (const service of services) {
    const template = connections.find((edge) => !edge.isTransfer && edge.fromNode.line.slug === service.lineSlug);
    if (!template) continue;
    const stops = service.stops.filter((stop) => !stop.isPassThrough && stop.station.isBoardingAllowed && stop.departureMinute != null);
    const nodes = stops.map((stop) => {
      const existing = stop.station.nodes.find((node) => node.lineId === template.fromNode.lineId);
      if (existing) return { ...existing, station: stop.station, line: template.fromNode.line };
      if (!ids.has(stop.stationId)) return null;
      return {
        ...template.fromNode, id: `timetable-${stop.stationId}-${template.fromNode.lineId}`,
        stationId: stop.stationId, station: stop.station, sequence: stop.sequence,
        nodeKey: stop.station.operationalCode ?? stop.stationId,
        mapId: `timetable-${stop.stationId}`, mapX: null, mapY: null,
      };
    });
    for (let i = 0; i < stops.length - 1; ++i) {
      const from = nodes[i], to = nodes[i + 1];
      if (!from || !to || (!ids.has(from.stationId) && !ids.has(to.stationId))) continue;
      const minutes = stops[i + 1].arrivalMinute! - stops[i].departureMinute!;
      if (!Number.isFinite(minutes) || minutes <= 0 || minutes > 120) continue;
      const key = `${from.id}|${to.id}`;
      const entry = supplements.get(key) ?? {
        connection: { ...template, id: `timetable-${key}`, fromNodeId: from.id, toNodeId: to.id, fromNode: from, toNode: to, isTransfer: false, serviceInfo: 'Estimasi dari jadwal PDF' },
        minutes: [],
      };
      entry.minutes.push(minutes);
      supplements.set(key, entry);
    }
    for (let i = 1; i < nodes.length - 1; ++i) {
      if (nodes[i] && ids.has(nodes[i]!.stationId) && nodes[i - 1] && nodes[i + 1]) {
        const left = `${nodes[i - 1]!.id}|${nodes[i]!.id}`;
        const right = `${nodes[i]!.id}|${nodes[i + 1]!.id}`;
        if (supplements.has(left) && supplements.has(right)) bypasses.add(`${nodes[i - 1]!.id}|${nodes[i + 1]!.id}`);
      }
    }
  }
  return [
    ...connections.filter((edge) => edge.isTransfer || !bypasses.has(`${edge.fromNodeId}|${edge.toNodeId}`)),
    ...[...supplements.values()].map(({ connection, minutes }) => ({ ...connection, travelTime: medianTravelMinutes(minutes) })),
  ];
}

export function medianTravelMinutes(minutes: number[]) {
  const sorted = [...minutes].sort((a, b) => a - b);
  return sorted[Math.floor(sorted.length / 2)];
}
