import assert from 'node:assert/strict';
import test from 'node:test';
import {
  publicCodeForLine,
  stationDisplayName,
} from '../src/domain/services/stationIdentity';

test('stationDisplayName prefers a non-empty official name', () => {
  assert.equal(
    stationDisplayName({
      name: 'ASEAN HQ',
      officialName: 'ASEAN Headquarters',
    }),
    'ASEAN Headquarters',
  );
});

test('stationDisplayName falls back to the stable short name', () => {
  assert.equal(stationDisplayName({ name: 'Gambir', officialName: null }), 'Gambir');
  assert.equal(stationDisplayName({ name: 'TMII', officialName: '  ' }), 'TMII');
});

test('publicCodeForLine returns only the code assigned to that line', () => {
  const station = {
    publicCodes: [
      { lineId: 'line-bogor', code: 'B23' },
      { lineId: 'line-bogor-nambo', code: 'b23' },
    ],
  };

  assert.equal(publicCodeForLine(station, 'line-bogor'), 'B23');
  assert.equal(publicCodeForLine(station, 'line-bogor-nambo'), 'b23');
  assert.equal(publicCodeForLine(station, 'line-unknown'), null);
});
