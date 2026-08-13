import assert from 'node:assert/strict';
import test from 'node:test';
import { orderSchema, resolveTicketOwner } from '../src/presentation/controllers/ticketController';

const baseOrder = {
  origin: 'bogor',
  destination: 'jakarta-kota',
  travelDate: '2026-08-13T09:00:00+07:00',
};

test('guest ticket ordering remains available with contact information', () => {
  const input = orderSchema.parse({ ...baseOrder, contactEmail: 'guest@example.com' });
  assert.equal(resolveTicketOwner(undefined, input), null);
});

test('registered ticket ownership is derived from verified access identity', () => {
  const input = orderSchema.parse(baseOrder);
  assert.equal(resolveTicketOwner({
    userId: '3f98079f-51f9-4422-9f65-b733150c29e7',
    role: 'REGISTERED',
    sessionId: '86c97d13-e769-43da-aef3-91f8ab0ad40c',
  }, input), '3f98079f-51f9-4422-9f65-b733150c29e7');
});

test('client-supplied userId is rejected as an ownership authority', () => {
  assert.equal(orderSchema.safeParse({
    ...baseOrder,
    contactEmail: 'guest@example.com',
    userId: '3f98079f-51f9-4422-9f65-b733150c29e7',
  }).success, false);
});
