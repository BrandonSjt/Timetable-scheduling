import { GoogleGenAI } from '@google/genai';
import { z } from 'zod';
import { AssistantProviderError } from './assistantService';

export const VISION_MODEL = process.env.GEMINI_VISION_MODEL ?? process.env.GEMINI_MODEL ?? 'gemini-3.5-flash-lite';

export const visionResponseSchema = z.object({
  spokenText: z.string().trim().min(1).max(300),
  hazardLevel: z.enum(['clear', 'caution', 'danger']),
  objects: z.array(z.string().trim().min(1).max(80)).max(8),
  direction: z.string().trim().max(80),
});

export type VisionResult = z.infer<typeof visionResponseSchema>;

const visionPrompt = `
Kamu membantu pemandu kamera untuk pengguna tunanetra di area stasiun KRL.
Analisis satu gambar kamera. Jangan menebak jika objek tidak jelas.
Balas HANYA JSON valid dengan bentuk:
{"spokenText":"...","hazardLevel":"clear|caution|danger","objects":["..."],"direction":"..."}
spokenText harus singkat dalam bahasa Indonesia dan aman untuk dibacakan TTS.
Sebutkan objek yang terlihat dan arah relatifnya jika jelas.
Gunakan hazardLevel danger hanya untuk bahaya yang benar-benar terlihat, caution untuk objek
yang perlu diwaspadai, dan clear jika tidak ada bahaya yang terlihat.
Jangan mengklaim posisi pengguna, jadwal, peron, keterlambatan, atau keselamatan mutlak.
`.trim();

export class VisionService {
  async analyzeJpeg(imageBytes: Buffer): Promise<VisionResult> {
    const apiKey = process.env.GEMINI_API_KEY?.trim();
    if (!apiKey || apiKey.length < 10) {
      throw new AssistantProviderError('AI_NOT_CONFIGURED', 'Layanan AI belum dikonfigurasi.');
    }
    if (imageBytes.length === 0 || imageBytes.length > 1_048_576) {
      throw new AssistantProviderError('AI_UNAVAILABLE', 'Ukuran gambar harus 1 byte sampai 1 MB.');
    }

    const ai = new GoogleGenAI({ apiKey });
    const request = ai.models.generateContent({
      model: VISION_MODEL,
      contents: [
        {
          role: 'user',
          parts: [
            { text: visionPrompt },
            { inlineData: { mimeType: 'image/jpeg', data: imageBytes.toString('base64') } },
          ],
        },
      ],
      config: { temperature: 0.1, maxOutputTokens: 256, responseMimeType: 'application/json' },
    });

    let response;
    try {
      response = await Promise.race([
        request,
        new Promise<never>((_, reject) =>
          setTimeout(() => reject(new AssistantProviderError('AI_TIMEOUT', 'Layanan AI timeout.')), 12_000),
        ),
      ]);
    } catch (error) {
      if (error instanceof AssistantProviderError) throw error;
      const text = String(error).toLowerCase();
      if (text.includes('quota') || text.includes('429')) {
        throw new AssistantProviderError('AI_QUOTA', 'Kuota AI sedang habis.');
      }
      throw new AssistantProviderError('AI_UNAVAILABLE', 'Layanan AI sedang tidak tersedia.');
    }

    const raw = response.text?.trim();
    if (!raw) throw new AssistantProviderError('AI_EMPTY_RESPONSE', 'AI tidak mengirim hasil deteksi.');
    try {
      return visionResponseSchema.parse(JSON.parse(raw));
    } catch {
      throw new AssistantProviderError('AI_EMPTY_RESPONSE', 'Format hasil deteksi AI tidak valid.');
    }
  }
}
