import assert from 'node:assert/strict';
import test from 'node:test';
import {
  ACCESS_TOKEN_TTL_SECONDS,
  REFRESH_TOKEN_TTL_MS,
  createAccessToken,
  createRefreshToken,
  hashRefreshToken,
  verifyAccessToken,
} from '../src/domain/services/authTokenService';

const previousSecret = process.env.JWT_SECRET;
process.env.JWT_SECRET = 'test-jwt-secret-with-at-least-32-characters';

test.after(() => {
  if (previousSecret === undefined) delete process.env.JWT_SECRET;
  else process.env.JWT_SECRET = previousSecret;
});

test('refresh tokens are opaque, random, and hashed deterministically', () => {
  const first = createRefreshToken();
  const second = createRefreshToken();

  assert.match(first, /^[A-Za-z0-9_-]{43}$/);
  assert.notEqual(first, second);
  assert.equal(hashRefreshToken(first), hashRefreshToken(first));
  assert.notEqual(hashRefreshToken(first), first);
  assert.equal(REFRESH_TOKEN_TTL_MS, 90 * 24 * 60 * 60 * 1000);
});

test('registered access token contains user, role, and session identity', () => {
  const claims = {
    userId: '3f98079f-51f9-4422-9f65-b733150c29e7',
    role: 'REGISTERED' as const,
    sessionId: '86c97d13-e769-43da-aef3-91f8ab0ad40c',
  };

  const payload = verifyAccessToken(createAccessToken(claims));

  assert.equal(payload.userId, claims.userId);
  assert.equal(payload.role, claims.role);
  assert.equal(payload.sessionId, claims.sessionId);
  assert.equal(ACCESS_TOKEN_TTL_SECONDS, 15 * 60);
});
