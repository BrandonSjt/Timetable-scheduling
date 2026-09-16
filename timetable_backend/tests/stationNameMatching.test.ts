import assert from 'node:assert/strict';
import test from 'node:test';
import { networkData } from '../prisma/networkData';
import { matchStationIdentity } from '../src/domain/services/stationNameMatching';

const catalogue = networkData.stations.filter((station) => station.isKrl && station.isBoardingAllowed !== false).map((station) => ({
  ...station, id: station.slug,
  aliases: (station.aliases ?? []).map((name) => ({ name })),
}));

test('all boarding catalogue station names, slugs and prefixes resolve uniquely', () => {
  for (const station of catalogue) {
    for (const identity of [station.name, station.slug, `Stasiun ${station.name}`]) {
      assert.equal(matchStationIdentity(identity, catalogue)?.id, station.id, identity);
    }
  }
});
test('clear typos and spacing normalize across multiple lines', () => {
  for (const [text, expected] of [
    ['jruangmangu', 'jurangmangu'], ['Jurang Mangu', 'jurangmangu'],
    ['Manggaraii', 'manggarai'], ['Rangkasbitun', 'rangkasbitung'],
    ['Tanjung Priokk', 'tanjung-priok'], ['Jakarta Ktoa', 'jakarta-kota'],
  ]) assert.equal(matchStationIdentity(text, catalogue)?.id, expected, text);
});
test('areas, unknown/short codes and ambiguous candidates are not guessed', () => {
  for (const text of ['Bintaro', 'Bandung', 'R06x', 'abc', 'Gambir']) assert.equal(matchStationIdentity(text, catalogue), null, text);
  assert.equal(matchStationIdentity('sudirman', [
    { id: '1', name: 'Sudirman' }, { id: '2', name: 'Sudirman' },
  ]), null);
  assert.equal(matchStationIdentity('bekasim', [{ id: '1', name: 'Bekasia' }, { id: '2', name: 'Bekasib' }]), null);
});
