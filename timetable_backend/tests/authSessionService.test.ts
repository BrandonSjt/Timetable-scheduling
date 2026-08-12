import assert from 'node:assert/strict';
import test from 'node:test';
import {
  AuthSessionRecord,
  AuthSessionService,
  AuthSessionStore,
} from '../src/domain/services/authSessionService';
import { hashRefreshToken, verifyAccessToken } from '../src/domain/services/authTokenService';

const previousSecret = process.env.JWT_SECRET;
process.env.JWT_SECRET = 'test-jwt-secret-with-at-least-32-characters';

test.after(() => {
  if (previousSecret === undefined) delete process.env.JWT_SECRET;
  else process.env.JWT_SECRET = previousSecret;
});

class MemorySessionStore implements AuthSessionStore {
  records = new Map<string, AuthSessionRecord>();
  sequence = 0;

  async create(input: Omit<AuthSessionRecord, 'id' | 'revokedAt'>) {
    const record: AuthSessionRecord = {
      ...input,
      id: `00000000-0000-4000-8000-${String(++this.sequence).padStart(12, '0')}`,
      revokedAt: null,
    };
    this.records.set(record.id, record);
    return record;
  }

  async findByHash(refreshTokenHash: string) {
    return [...this.records.values()].find(
      (record) => record.refreshTokenHash === refreshTokenHash,
    ) ?? null;
  }

  async rotate(id: string, currentHash: string, nextHash: string, expiresAt: Date, now: Date) {
    const record = this.records.get(id);
    if (!record || record.refreshTokenHash !== currentHash || record.revokedAt) return false;
    record.refreshTokenHash = nextHash;
    record.expiresAt = expiresAt;
    record.lastUsedAt = now;
    return true;
  }

  async revokeByHash(refreshTokenHash: string, revokedAt: Date) {
    const record = await this.findByHash(refreshTokenHash);
    if (record && !record.revokedAt) record.revokedAt = revokedAt;
  }
}

test('session creation and rotation invalidate the previous refresh token', async () => {
  const service = new AuthSessionService(new MemorySessionStore());
  const user = {
    id: '3f98079f-51f9-4422-9f65-b733150c29e7',
    role: 'REGISTERED' as const,
  };

  const first = await service.create(user, 'Pixel Emulator');
  const rotated = await service.refresh(first.refreshToken);

  assert.equal(verifyAccessToken(first.accessToken).sessionId, first.sessionId);
  assert.equal(verifyAccessToken(rotated.accessToken).sessionId, first.sessionId);
  assert.notEqual(rotated.refreshToken, first.refreshToken);
  await assert.rejects(
    () => service.refresh(first.refreshToken),
    (error: any) => error.code === 'INVALID_REFRESH_TOKEN',
  );
});

test('revoked and expired sessions cannot be refreshed', async () => {
  const store = new MemorySessionStore();
  const service = new AuthSessionService(store);
  const created = await service.create({
    id: '3f98079f-51f9-4422-9f65-b733150c29e7',
    role: 'REGISTERED',
  });

  await service.revoke(created.refreshToken);
  await service.revoke(created.refreshToken);
  await assert.rejects(
    () => service.refresh(created.refreshToken),
    (error: any) => error.code === 'INVALID_REFRESH_TOKEN',
  );

  const expired = await service.create({
    id: '3f98079f-51f9-4422-9f65-b733150c29e7',
    role: 'REGISTERED',
  });
  const record = await store.findByHash(hashRefreshToken(expired.refreshToken));
  record!.expiresAt = new Date(0);
  await assert.rejects(
    () => service.refresh(expired.refreshToken),
    (error: any) => error.code === 'INVALID_REFRESH_TOKEN',
  );
});
