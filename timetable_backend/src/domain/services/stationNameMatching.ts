export type StationIdentityCandidate = {
  id: string; name: string; officialName?: string | null; slug?: string | null;
  operationalCode?: string | null; aliases?: Array<{ name?: string; normalized?: string }>;
  publicCodes?: Array<{ code: string }>;
};

const key = (text: string) => text.trim().replace(/^(?:stasiun|station)\s+/i, '').toLowerCase().replace(/[^a-z0-9]/g, '');

// Optimal-string-alignment distance includes one adjacent keyboard transposition.
export function stationNameDistance(a: string, b: string): number {
  const rows = Array.from({ length: a.length + 1 }, (_, i) => [i, ...Array(b.length).fill(0)]);
  for (let j = 0; j <= b.length; ++j) rows[0][j] = j;
  for (let i = 1; i <= a.length; ++i) {
    for (let j = 1; j <= b.length; ++j) {
      rows[i][j] = Math.min(rows[i - 1][j] + 1, rows[i][j - 1] + 1, rows[i - 1][j - 1] + Number(a[i - 1] !== b[j - 1]));
      if (i > 1 && j > 1 && a[i - 1] === b[j - 2] && a[i - 2] === b[j - 1]) rows[i][j] = Math.min(rows[i][j], rows[i - 2][j - 2] + 1);
    }
  }
  return rows[a.length][b.length];
}

export function matchStationIdentity<T extends StationIdentityCandidate>(text: string, stations: T[]): T | null {
  const input = key(text);
  const identities = stations.map((station) => ({
    station,
    names: [station.name, station.officialName, station.slug, ...(station.aliases ?? []).map((alias) => alias.name ?? alias.normalized)].filter((name): name is string => !!name).map(key),
    codes: [station.operationalCode, ...(station.publicCodes ?? []).map((code) => code.code)].filter((code): code is string => !!code).map(key),
  }));
  const exact = identities.filter((candidate) => [...candidate.names, ...candidate.codes].includes(input));
  if (exact.length === 1) return exact[0].station;
  if (exact.length > 1 || !/^[a-z]{6,}$/.test(input)) return null;
  const ranked = identities.map((candidate) => ({
    station: candidate.station,
    distance: Math.min(...candidate.names.filter((name) => Math.abs(name.length - input.length) <= 2).map((name) => stationNameDistance(input, name)), Infinity),
  })).sort((a, b) => a.distance - b.distance);
  const best = ranked[0];
  const ceiling = input.length >= 9 ? 2 : 1;
  if (!best || best.distance > ceiling || (ranked[1]?.distance ?? Infinity) < best.distance + 2) return null;
  return best.station;
}
