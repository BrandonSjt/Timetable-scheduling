import assert from 'node:assert/strict';
import test from 'node:test';
import { verifyXenditCallbackToken } from '../src/infrastructure/payments/xenditWebhook';

test('Xendit webhook callback token is required and compared exactly', () => {
  const previous = process.env.XENDIT_WEBHOOK_TOKEN;
  process.env.XENDIT_WEBHOOK_TOKEN = 'xendit-webhook-secret';
  try {
    assert.equal(verifyXenditCallbackToken(undefined), false);
    assert.equal(verifyXenditCallbackToken('wrong'), false);
    assert.equal(verifyXenditCallbackToken('xendit-webhook-secret'), true);
  } finally {
    if (previous === undefined) delete process.env.XENDIT_WEBHOOK_TOKEN;
    else process.env.XENDIT_WEBHOOK_TOKEN = previous;
  }
});
