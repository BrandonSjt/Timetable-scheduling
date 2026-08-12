import assert from 'node:assert/strict';
import test from 'node:test';
import { planRouteSchema } from '../src/presentation/controllers/routeController';

test('route preference defaults to FASTEST and rejects unknown modes', () => {
  assert.equal(
    planRouteSchema.parse({ from: 'bogor', to: 'tangerang' }).preference,
    'FASTEST',
  );
  assert.equal(
    planRouteSchema.safeParse({
      from: 'bogor',
      to: 'tangerang',
      preference: 'CHEAPEST',
    }).success,
    false,
  );
});
