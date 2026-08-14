import assert from 'node:assert/strict';
import test from 'node:test';
import { networkData } from '../prisma/networkData';

const stationFor = (name: string) =>
  networkData.stations.find((station) => station.name === name);

const publicCodeFor = (stationName: string, lineSlug: string) => {
  const node = stationFor(stationName)?.nodes.find(
    (item) => item.lineSlug === lineSlug,
  );
  if (!node) return undefined;
  return 'publicCode' in node ? node.publicCode : node.code;
};

const officialNameFor = (shortName: string) => {
  const station = stationFor(shortName);
  return station && 'officialName' in station ? station.officialName : station?.name;
};

test('mobile network snapshot keeps physical stations and line nodes unique', () => {
  assert.equal(networkData.stations.length, 124);
  assert.equal(
    networkData.stations.filter((station) => station.nodes.length > 0).length,
    122,
  );

  const stationNames = networkData.stations.map((station) => station.name);
  assert.equal(new Set(stationNames).size, stationNames.length);

  const nodeCodes = networkData.stations.flatMap((station) =>
    station.nodes.map((node) => node.code),
  );
  assert.equal(nodeCodes.length, 135);
  assert.equal(new Set(nodeCodes).size, nodeCodes.length);
});

test('public station codes follow the supplied maps without replacing node keys', () => {
  assert.equal(publicCodeFor('Jakarta Int. Stadium', 'tanjung_priok'), null);
  assert.equal(publicCodeFor('Tanjung Priok', 'tanjung_priok'), 'TP04');
  assert.equal(publicCodeFor('Parung Panjang', 'rangkasbitung'), 'R12');
  assert.equal(publicCodeFor('Cilejit', 'rangkasbitung'), 'R14');
  assert.equal(publicCodeFor('Daru', 'rangkasbitung'), 'R15');
  assert.equal(publicCodeFor('Tenjo', 'rangkasbitung'), 'R16');
  assert.equal(publicCodeFor('Tigaraksa', 'rangkasbitung'), 'R18');
  assert.equal(publicCodeFor('Cikoya', 'rangkasbitung'), 'R19');
  assert.equal(publicCodeFor('Maja', 'rangkasbitung'), 'R20');
  assert.equal(publicCodeFor('Citeras', 'rangkasbitung'), 'R21');
  assert.equal(publicCodeFor('Rangkasbitung', 'rangkasbitung'), 'R22');
  assert.equal(publicCodeFor('Pondok Rajeg', 'bogor_nambo'), 'b23');

  assert.equal(stationFor('Jakarta Int. Stadium')?.nodes[0]?.code, 'TP04');
  assert.equal(stationFor('Tanjung Priok')?.nodes[0]?.code, 'TP05');
  assert.ok(networkData.lines.find((line) => line.slug === 'tanjung_priok')?.nodeCodes.includes('TP05'));
  assert.ok(networkData.lines.find((line) => line.slug === 'rangkasbitung')?.nodeCodes.includes('R19'));
});

test('official names retain stable short names and aliases', () => {
  assert.equal(officialNameFor('ASEAN HQ'), 'ASEAN Headquarters');
  assert.equal(
    officialNameFor('Lebak Bulus'),
    'Lebak Bulus Bank Syariah Indonesia',
  );
  assert.equal(officialNameFor('Pancoran'), 'Pancoran bank bjb');
  assert.equal(
    officialNameFor('Dukuh Atas LRT'),
    'Dukuh Atas Bank Syariah Indonesia',
  );
  assert.equal(officialNameFor('Taman Mini'), 'TMII');
  assert.equal(officialNameFor('Kp. Bandan'), 'Kampung Bandan');
  assert.equal(officialNameFor('Univ. Indonesia'), 'Universitas Indonesia');
  assert.equal(
    officialNameFor('Metland Telagamurni'),
    'Metland Telaga Murni',
  );
  assert.ok(stationFor('Lebak Bulus')?.aliases.includes('Lebak Bulus BSI'));
  assert.ok(stationFor('Dukuh Atas LRT')?.aliases.includes('Dukuh Atas BNI'));
  assert.ok(stationFor('Pondok Rajeg')?.nodes.some((node) => node.code === 'b23'));
});

test('operational-only stations do not alter drawable topology', () => {
  const gambir = stationFor('Gambir');
  const jatake = stationFor('Jatake');

  assert.deepEqual(gambir?.nodes, []);
  assert.equal(gambir && 'operationalCode' in gambir ? gambir.operationalCode : undefined, 'GMR');
  assert.equal(gambir && 'isBoardingAllowed' in gambir ? gambir.isBoardingAllowed : undefined, false);
  assert.deepEqual(
    gambir && 'publicCodes' in gambir ? gambir.publicCodes : undefined,
    [{ lineSlug: 'bogor', code: 'B06' }],
  );
  assert.deepEqual(jatake?.nodes, []);
  assert.equal(jatake && 'operationalCode' in jatake ? jatake.operationalCode : undefined, 'JTK');
  assert.equal(jatake && 'isBoardingAllowed' in jatake ? jatake.isBoardingAllowed : undefined, true);
  assert.equal(jatake && 'publicCodes' in jatake ? jatake.publicCodes : undefined, undefined);
});

test('every ordered line references known nodes and forms at least one edge', () => {
  const knownCodes = new Set(
    networkData.stations.flatMap((station) =>
      station.nodes.map((node) => node.code),
    ),
  );

  assert.equal(networkData.lines.length, 11);
  for (const line of networkData.lines) {
    assert.ok(line.nodeCodes.length > 1, `${line.slug} must contain an edge`);
    for (const code of line.nodeCodes) {
      assert.ok(knownCodes.has(code), `${line.slug} references unknown node ${code}`);
    }
  }
});

test('interchange stations preserve all mobile node codes', () => {
  const nodesFor = (name: string) =>
    networkData.stations
      .find((station) => station.name === name)
      ?.nodes.map((node) => node.code)
      .sort();

  assert.deepEqual(nodesFor('Cawang'), ['B11']);
  assert.deepEqual(nodesFor('Cawang LRT'), ['BK08', 'CB08']);
  assert.deepEqual(nodesFor('Duri'), ['C09', 'T01']);
  assert.deepEqual(nodesFor('Jakarta Kota'), ['B01', 'TP01']);
  assert.deepEqual(nodesFor('Manggarai'), ['B09', 'C13']);
  assert.deepEqual(nodesFor('Tanah Abang'), ['C10', 'R01']);
});

test('Cikoko connects to KRL Cawang only through a five-minute walking transfer', () => {
  assert.deepEqual(
    networkData.transfers.find(({ from, to }) => from === 'Cikoko' && to === 'Cawang'),
    { from: 'Cikoko', to: 'Cawang', walkingTime: 5 },
  );
  assert.equal(
    networkData.transfers.some(
      ({ from, to }) =>
        (from === 'Cikoko' && to === 'Cawang LRT') ||
        (from === 'Cawang LRT' && to === 'Cikoko'),
    ),
    false,
  );
});
