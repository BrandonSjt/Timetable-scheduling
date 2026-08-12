import assert from 'node:assert/strict';
import test from 'node:test';
import { FareService } from '../src/domain/services/fareService';

test('fare is calculated server-side per route band and passenger', () => {
  assert.deepEqual(FareService.quote(4, 2), {
    unitPrice: 3000,
    passengerCount: 2,
    totalPrice: 6000,
    currency: 'IDR',
  });
  assert.equal(FareService.quote(16, 1).unitPrice, 6000);
});

test('fare rejects invalid passenger counts', () => {
  assert.throws(() => FareService.quote(2, 0), /between 1 and 6/);
  assert.throws(() => FareService.quote(2, 7), /between 1 and 6/);
});
