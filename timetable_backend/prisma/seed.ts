import { PrismaClient } from '@prisma/client';
import path from 'node:path';
import { networkData } from './networkData';
import { mobileScheduleData } from './mobileScheduleData';
import { parseRawSchedule } from './parser';

const prisma = new PrismaClient();

const normalizeStationName = (value: string) =>
  value
    .toLowerCase()
    .replace(/(?:sudirman\s*baru|bni\s*city)/g, 'bnicity')
    .replace(/\b(bank jakarta|bni|astra|mastercard|bca|tuku|indomaret|bsi)\b/g, '')
    .replace(/kampung/g, 'kp')
    .replace(/jati\s*bening/g, 'jatibening')
    .replace(/[^a-z0-9]/g, '');

async function seedLines() {
  const lineIds = new Map<string, string>();

  for (const line of networkData.lines) {
    const id = `line-${line.slug.replaceAll('_', '-')}`;
    const saved = await prisma.line.upsert({
      where: { id },
      update: {
        slug: line.slug,
        name: line.name,
        color: line.color,
        serviceType: line.serviceType,
      },
      create: {
        id,
        slug: line.slug,
        name: line.name,
        color: line.color,
        serviceType: line.serviceType,
      },
    });
    lineIds.set(line.slug, saved.id);
  }

  return lineIds;
}

async function seedStations(lineIds: Map<string, string>) {
  const existing = await prisma.station.findMany({
    include: { _count: { select: { schedules: true } } },
  });
  const claimedIds = new Set<string>();
  const stationIds = new Map<string, string>();

  for (const definition of networkData.stations) {
    const officialName = definition.officialName ?? definition.name;
    const candidateNames = [definition.name, officialName, ...definition.aliases];
    const normalizedCandidates = new Set(candidateNames.map(normalizeStationName));
    const candidates = existing
      .filter(
        (station) =>
          !claimedIds.has(station.id) &&
          normalizedCandidates.has(normalizeStationName(station.name)),
      )
      .sort((a, b) => b._count.schedules - a._count.schedules);

    const primary =
      existing.find(
        (station) =>
          !claimedIds.has(station.id) && station.slug === definition.slug,
      ) ?? candidates[0];
    const duplicates = candidates.filter((station) => station.id !== primary?.id);
    const lineSlugs = new Set([
      ...definition.nodes.map((node) => node.lineSlug),
      ...(definition.lineSlugs ?? []),
      ...(definition.publicCodes ?? []).map((item) => item.lineSlug),
    ]);
    const lineIdSet = [
      ...new Set(
        [...lineSlugs]
          .map((lineSlug) => lineIds.get(lineSlug))
          .filter((id): id is string => Boolean(id)),
      ),
    ];

    if (primary && duplicates.length > 0) {
      await prisma.station.updateMany({
        where: { id: { in: duplicates.map((station) => station.id) } },
        data: { slug: null, operationalCode: null },
      });
    }

    const station = primary
      ? await prisma.station.update({
          where: { id: primary.id },
          data: {
            slug: definition.slug,
            name: definition.name,
            officialName,
            ...('operationalCode' in definition
              ? { operationalCode: definition.operationalCode }
              : {}),
            isBoardingAllowed: definition.isBoardingAllowed ?? true,
            nodeCode: definition.nodes.map((node) => node.code).join(', '),
            isTransit: definition.isTransit,
            isAccessible: definition.isAccessible,
            isLrt: definition.isLrt,
            isKrl: definition.isKrl,
            isMrt: definition.isMrt,
            lineInfo: definition.lineInfo,
            statusText: definition.statusText,
            statusColor: '#16A34A',
            lines: { set: lineIdSet.map((id) => ({ id })) },
          },
        })
      : await prisma.station.create({
          data: {
            slug: definition.slug,
            name: definition.name,
            officialName,
            operationalCode: definition.operationalCode ?? null,
            isBoardingAllowed: definition.isBoardingAllowed ?? true,
            nodeCode: definition.nodes.map((node) => node.code).join(', '),
            isTransit: definition.isTransit,
            isAccessible: definition.isAccessible,
            isLrt: definition.isLrt,
            isKrl: definition.isKrl,
            isMrt: definition.isMrt,
            lineInfo: definition.lineInfo,
            statusText: definition.statusText,
            statusColor: '#16A34A',
            lines: { connect: lineIdSet.map((id) => ({ id })) },
          },
        });

    claimedIds.add(station.id);
    stationIds.set(definition.name, station.id);

    await prisma.stationAlias.deleteMany({ where: { stationId: station.id } });
    const aliases = [...new Set([definition.name, officialName, ...definition.aliases])];
    if (aliases.length > 0) {
      await prisma.stationAlias.createMany({
        data: aliases.map((name) => ({
          stationId: station.id,
          name,
          normalized: normalizeStationName(name),
        })),
        skipDuplicates: true,
      });
    }

    for (const duplicate of duplicates) {
      await prisma.schedule.updateMany({
        where: { stationId: duplicate.id },
        data: { stationId: station.id },
      });
      const referencedTickets = await prisma.ticket.count({
        where: {
          OR: [
            { originStationId: duplicate.id },
            { destinationStationId: duplicate.id },
          ],
        },
      });
      if (referencedTickets === 0) {
        await prisma.station.delete({ where: { id: duplicate.id } });
      }
      claimedIds.add(duplicate.id);
    }
  }

  return stationIds;
}

async function seedNodes(
  lineIds: Map<string, string>,
  stationIds: Map<string, string>,
) {
  for (const station of networkData.stations) {
    const stationId = stationIds.get(station.name);
    if (!stationId) throw new Error(`Station was not seeded: ${station.name}`);

    for (const node of station.nodes) {
      const lineId = lineIds.get(node.lineSlug);
      if (!lineId) throw new Error(`Unknown line ${node.lineSlug} for ${node.code}`);

      await prisma.stationNode.upsert({
        where: { nodeKey: node.code },
        update: {
          mapId: node.mapId,
          sequence: node.sequence,
          mapX: node.x,
          mapY: node.y,
          stationId,
          lineId,
        },
        create: {
          nodeKey: node.code,
          mapId: node.mapId,
          sequence: node.sequence,
          mapX: node.x,
          mapY: node.y,
          stationId,
          lineId,
        },
      });
    }
  }
}

async function seedPublicCodes(
  lineIds: Map<string, string>,
  stationIds: Map<string, string>,
) {
  const rows = new Map<
    string,
    { id: string; stationId: string; lineId: string; code: string }
  >();

  for (const station of networkData.stations) {
    const stationId = stationIds.get(station.name);
    if (!stationId) throw new Error(`Station was not seeded: ${station.name}`);

    const definitions = [
      ...station.nodes.flatMap((node) => {
        const code = 'publicCode' in node ? node.publicCode : node.code;
        return code == null ? [] : [{ lineSlug: node.lineSlug, code }];
      }),
      ...(station.publicCodes ?? []),
    ];

    for (const definition of definitions) {
      const lineId = lineIds.get(definition.lineSlug);
      if (!lineId) {
        throw new Error(
          `Unknown line ${definition.lineSlug} for public code ${definition.code}`,
        );
      }
      const key = `${stationId}:${lineId}`;
      const current = rows.get(key);
      if (current && current.code !== definition.code) {
        throw new Error(
          `Conflicting public codes for ${station.name} on ${definition.lineSlug}`,
        );
      }
      rows.set(key, {
        id: `public-code-${station.slug}-${definition.lineSlug}`,
        stationId,
        lineId,
        code: definition.code,
      });
    }
  }

  await prisma.$transaction(async (tx) => {
    await tx.stationPublicCode.deleteMany();
    if (rows.size > 0) {
      await tx.stationPublicCode.createMany({ data: [...rows.values()] });
    }
  });
}

async function seedConnections(stationIds: Map<string, string>) {
  const nodes = await prisma.stationNode.findMany();
  const nodeByCode = new Map(nodes.map((node) => [node.nodeKey, node]));
  await prisma.routeConnection.deleteMany();
  await prisma.stationTransfer.deleteMany();

  const connect = async (
    fromNodeId: string,
    toNodeId: string,
    travelTime: number,
    fare: number,
    isTransfer: boolean,
  ) => {
    await prisma.routeConnection.create({
      data: {
        fromNodeId,
        toNodeId,
        travelTime,
        fare,
        isTransfer,
        serviceInfo: isTransfer ? 'Transfer antarlayanan' : 'Layanan normal',
      },
    });
  };

  for (const line of networkData.lines) {
    for (let index = 0; index < line.nodeCodes.length - 1; index += 1) {
      const from = nodeByCode.get(line.nodeCodes[index]);
      const to = nodeByCode.get(line.nodeCodes[index + 1]);
      if (!from || !to) throw new Error(`Missing line node on ${line.slug}`);
      await connect(from.id, to.id, 4, 500, false);
      await connect(to.id, from.id, 4, 500, false);
    }
  }

  const nodesByStation = new Map<string, typeof nodes>();
  for (const node of nodes) {
    const group = nodesByStation.get(node.stationId) ?? [];
    group.push(node);
    nodesByStation.set(node.stationId, group);
  }
  for (const stationNodes of nodesByStation.values()) {
    for (const from of stationNodes) {
      for (const to of stationNodes) {
        if (from.id !== to.id) await connect(from.id, to.id, 5, 0, true);
      }
    }
  }

  for (const transfer of networkData.transfers) {
    const fromStationId = stationIds.get(transfer.from);
    const toStationId = stationIds.get(transfer.to);
    if (!fromStationId || !toStationId) throw new Error('Transfer station missing');

    await prisma.stationTransfer.create({
      data: { fromStationId, toStationId, walkingTime: transfer.walkingTime },
    });
    await prisma.stationTransfer.create({
      data: {
        fromStationId: toStationId,
        toStationId: fromStationId,
        walkingTime: transfer.walkingTime,
      },
    });

    for (const from of nodesByStation.get(fromStationId) ?? []) {
      for (const to of nodesByStation.get(toStationId) ?? []) {
        await connect(from.id, to.id, transfer.walkingTime, 0, true);
        await connect(to.id, from.id, transfer.walkingTime, 0, true);
      }
    }
  }
}

async function seedSchedulesWhenEmpty() {
  if ((await prisma.schedule.count()) === 0) {
    const schedules = parseRawSchedule(path.join(__dirname, 'data', 'raw_schedule.txt'));
    for (const schedule of schedules) {
      const station = await prisma.station.findUnique({
        where: { operationalCode: schedule.stationCode },
      });
      if (!station) continue;
      await prisma.schedule.create({
        data: {
          trainName: `KA ${schedule.trainNumber}`,
          route: schedule.route,
          departureTime: schedule.departureTime,
          arrivalTime: schedule.arrivalTime,
          platform: '1',
          trainType: 'KRL',
          isWeekend: false,
          stationId: station.id,
        },
      });
    }
  }

  for (const schedule of mobileScheduleData) {
    const station = await prisma.station.findFirst({
      where: {
        OR: [
          { name: schedule.stationName },
          { officialName: schedule.stationName },
          {
            aliases: {
              some: { normalized: normalizeStationName(schedule.stationName) },
            },
          },
        ],
      },
    });
    if (!station) throw new Error(`Mobile schedule station missing: ${schedule.stationName}`);
    const values = {
      trainName: schedule.trainName,
      route: schedule.route,
      departureTime: schedule.departureTime,
      arrivalTime: schedule.arrivalTime,
      platform: schedule.platform,
      trainType: schedule.trainType,
      isWeekend: schedule.isWeekend,
      stationId: station.id,
    };
    await prisma.schedule.upsert({
      where: { sourceKey: schedule.sourceKey },
      update: values,
      create: { sourceKey: schedule.sourceKey, ...values },
    });
  }
}

async function seedPlatformRules(stationIds: Map<string, string>) {
  const rules = [
    ['Manggarai', 'bogor', 'Jakarta Kota', '10'],
    ['Manggarai', 'bogor', 'Bogor', '12'],
    ['Manggarai', 'cikarang', 'Cikarang', '3'],
    ['Tanah Abang', 'rangkasbitung', 'Rangkasbitung', '5'],
    ['Duri', 'tangerang', 'Tangerang', '1'],
    ['Bekasi', 'cikarang', 'Cikarang', '2'],
    ['Jakarta Kota', 'bogor', 'Bogor', '1'],
    ['Jakarta Kota', 'tanjung_priok', 'Tanjung Priok', '2'],
  ] as const;
  const sourceName = 'Pemetaan peron demo Commuter Line Februari 2026';
  const sourceUrl = 'https://www.commuterline.id/';
  const verifiedAt = new Date('2026-02-01T00:00:00.000Z');

  for (const [stationName, lineSlug, destination, platform] of rules) {
    const stationId = stationIds.get(stationName);
    if (!stationId) throw new Error(`Platform rule station missing: ${stationName}`);
    await prisma.stationPlatformRule.upsert({
      where: {
        stationId_lineSlug_direction_destination: {
          stationId,
          lineSlug,
          direction: 'ANY',
          destination,
        },
      },
      update: { platform, sourceName, sourceUrl, verifiedAt },
      create: {
        stationId,
        lineSlug,
        direction: 'ANY',
        destination,
        platform,
        sourceName,
        sourceUrl,
        validFrom: new Date('2026-02-01T00:00:00.000Z'),
        verifiedAt,
      },
    });
  }
}

async function main() {
  console.log('Seeding mobile-aligned transit network...');
  const lineIds = await seedLines();
  const stationIds = await seedStations(lineIds);
  await seedNodes(lineIds, stationIds);
  await seedPublicCodes(lineIds, stationIds);
  await seedConnections(stationIds);
  await seedSchedulesWhenEmpty();
  await seedPlatformRules(stationIds);
  console.log(
    `Seeded ${stationIds.size} stations, ${networkData.lines.length} lines, and ${await prisma.routeConnection.count()} directed connections.`,
  );
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => prisma.$disconnect());
