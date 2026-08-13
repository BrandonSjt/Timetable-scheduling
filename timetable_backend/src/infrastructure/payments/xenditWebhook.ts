import crypto from 'node:crypto';

export function verifyXenditCallbackToken(suppliedToken: string | undefined) {
  const expectedToken = process.env.XENDIT_WEBHOOK_TOKEN;
  if (!expectedToken || !suppliedToken) return false;
  const expected = Buffer.from(expectedToken);
  const supplied = Buffer.from(suppliedToken);
  return expected.length === supplied.length && crypto.timingSafeEqual(expected, supplied);
}
