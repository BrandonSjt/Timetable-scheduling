import assert from 'node:assert/strict';
import test from 'node:test';
import { TicketService } from '../src/domain/services/ticketService';

test('ticket QR payload is signed and rejects tampering', () => {
  const previous = process.env.TICKET_QR_SECRET;
  process.env.TICKET_QR_SECRET = 'test-secret-at-least-16-characters';
  try {
    const qr = TicketService.createQrPayload('KAI-260808-ABCDEF01');
    assert.equal(TicketService.verifyQrPayload(qr)?.publicCode, 'KAI-260808-ABCDEF01');
    assert.equal(TicketService.verifyQrPayload(`${qr}x`), null);
  } finally {
    if (previous === undefined) delete process.env.TICKET_QR_SECRET;
    else process.env.TICKET_QR_SECRET = previous;
  }
});
