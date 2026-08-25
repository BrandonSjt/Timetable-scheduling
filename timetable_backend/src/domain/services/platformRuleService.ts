import { PrismaClient } from '@prisma/client';

export interface PlatformRuleLookup {
  stationId: string;
  lineSlug: string;
  direction: string;
  destination: string;
}

export interface PlatformRuleCandidate {
  direction: string;
  destination: string | null;
  platform: string;
}

const normalize = (value: string) => value.toLowerCase().replace(/[^a-z0-9]/g, '');

export function choosePlatformRule(
  rules: readonly PlatformRuleCandidate[],
  lookup: Pick<PlatformRuleLookup, 'direction' | 'destination'>,
) {
  const destination = normalize(lookup.destination);
  const exact = rules.find(
    (rule) =>
      rule.direction === lookup.direction &&
      rule.destination != null &&
      normalize(rule.destination) === destination,
  );
  if (exact) return exact;

  const direction = rules.find(
    (rule) => rule.direction === lookup.direction && rule.destination == null,
  );
  if (direction) return direction;

  return rules.find(
    (rule) =>
      rule.direction === 'ANY' &&
      (rule.destination == null || normalize(rule.destination) === destination),
  );
}

export async function resolvePlatformRule(
  prisma: Pick<PrismaClient, 'stationPlatformRule'>,
  lookup: PlatformRuleLookup,
) {
  const rules = await prisma.stationPlatformRule.findMany({
    where: {
      stationId: lookup.stationId,
      lineSlug: lookup.lineSlug,
      direction: { in: [lookup.direction, 'ANY'] },
      AND: [
        { OR: [{ validFrom: null }, { validFrom: { lte: new Date() } }] },
        { OR: [{ validTo: null }, { validTo: { gte: new Date() } }] },
      ],
    },
    select: { direction: true, destination: true, platform: true },
  });
  return choosePlatformRule(rules, lookup);
}
