import assert from 'node:assert/strict';
import test from 'node:test';
import {
  credentialsSchema,
  logoutSchema,
  refreshSchema,
  registerSchema,
} from '../src/presentation/controllers/authController';

const validCredentials = {
  email: 'riyadh@example.com',
  password: 'password-aman',
};

test('registration requires a name and accepts optional phone/device metadata', () => {
  assert.equal(registerSchema.safeParse(validCredentials).success, false);
  assert.equal(registerSchema.safeParse({
    ...validCredentials,
    name: 'Riyadh',
    phone: '081234567890',
    deviceName: 'Pixel Emulator',
  }).success, true);
});

test('login, refresh, and logout reject malformed credentials', () => {
  assert.equal(credentialsSchema.safeParse(validCredentials).success, true);
  assert.equal(credentialsSchema.safeParse({ ...validCredentials, password: 'short' }).success, false);
  assert.equal(refreshSchema.safeParse({ refreshToken: 'short' }).success, false);
  assert.equal(logoutSchema.safeParse({ refreshToken: 'x'.repeat(43) }).success, true);
});
