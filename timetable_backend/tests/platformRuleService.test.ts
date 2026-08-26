import assert from 'node:assert/strict';
import { test } from 'node:test';
import { choosePlatformRule } from '../src/domain/services/platformRuleService';

test('platform resolver prefers destination-specific rule', () => {
  const result = choosePlatformRule(
    [
      { direction: 'JAKARTA_KOTA', destination: null, platform: '6/7' },
      { direction: 'JAKARTA_KOTA', destination: 'Jakarta Kota', platform: '10' },
    ],
    { direction: 'JAKARTA_KOTA', destination: 'Jakarta Kota' },
  );
  assert.equal(result?.platform, '10');
});

test('platform resolver falls back to direction rule', () => {
  const result = choosePlatformRule(
    [{ direction: 'RANGKASBITUNG', destination: null, platform: '5' }],
    { direction: 'RANGKASBITUNG', destination: 'Serpong' },
  );
  assert.equal(result?.platform, '5');
});

test('platform resolver uses ANY rule only as final fallback', () => {
  const result = choosePlatformRule(
    [{ direction: 'ANY', destination: null, platform: '2' }],
    { direction: 'JAKARTA_KOTA', destination: 'Jakarta Kota' },
  );
  assert.equal(result?.platform, '2');
});

test('platform resolver returns undefined when no rule exists', () => {
  assert.equal(
    choosePlatformRule([], { direction: 'JAKARTA_KOTA', destination: 'Bogor' }),
    undefined,
  );
});
