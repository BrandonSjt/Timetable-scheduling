import assert from 'node:assert/strict';
import { test } from 'node:test';
import { visionResponseSchema, VisionService } from '../src/domain/services/visionService';

test('vision response accepts only safe structured fields', () => {
  const parsed = visionResponseSchema.safeParse({
    spokenText: 'Ada tiang di depan.',
    hazardLevel: 'caution',
    objects: ['tiang'],
    direction: 'depan',
  });
  assert.equal(parsed.success, true);
  assert.equal(
    visionResponseSchema.safeParse({
      spokenText: 'bahaya',
      hazardLevel: 'unknown',
      objects: [],
      direction: '',
    }).success,
    false,
  );
});

test('vision service fails before any provider call when AI is not configured', async () => {
  const previousKey = process.env.GEMINI_API_KEY;
  delete process.env.GEMINI_API_KEY;
  try {
    await assert.rejects(
      () => new VisionService().analyzeJpeg(Buffer.from([0xff, 0xd8, 0xff])),
      /belum dikonfigurasi/i,
    );
  } finally {
    if (previousKey === undefined) delete process.env.GEMINI_API_KEY;
    else process.env.GEMINI_API_KEY = previousKey;
  }
});
