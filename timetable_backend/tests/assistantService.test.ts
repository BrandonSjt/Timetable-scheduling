import assert from 'node:assert/strict';
import { test } from 'node:test';
import { buildAssistantPrompt } from '../src/domain/services/assistantService';
import { assistantMessageSchema } from '../src/presentation/controllers/assistantController';

test('assistant prompt limits claims to known transit data', () => {
  const prompt = buildAssistantPrompt('Berapa peron di Manggarai?');
  assert.match(prompt, /Jangan mengarang jadwal/);
  assert.match(prompt, /papan informasi stasiun/);
  assert.match(prompt, /Berapa peron di Manggarai/);
});

test('assistant message validation rejects empty and oversized input', () => {
  assert.equal(assistantMessageSchema.safeParse({ message: '' }).success, false);
  assert.equal(
    assistantMessageSchema.safeParse({ message: 'x'.repeat(1001) }).success,
    false,
  );
  assert.equal(assistantMessageSchema.safeParse({ message: ' Halo ' }).success, true);
});
