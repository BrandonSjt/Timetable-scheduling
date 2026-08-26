import assert from 'node:assert/strict';
import test from 'node:test';
import { updateProfileSchema } from '../src/presentation/controllers/profileController';

test('profile accepts every canonical mobile locale tag', () => {
  for (const language of ['id', 'en', 'zh-Hans', 'ar']) {
    assert.equal(
      updateProfileSchema.safeParse({ language }).success,
      true,
      `expected ${language} to be accepted`,
    );
  }
});

test('profile rejects unsupported locale tags', () => {
  for (const language of ['zh-Hant', 'fr', '']) {
    assert.equal(
      updateProfileSchema.safeParse({ language }).success,
      false,
      `expected ${language} to be rejected`,
    );
  }
});
