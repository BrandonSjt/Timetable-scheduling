import { Request, Response } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || 'dummy_key');

export const askAssistant = async (req: Request, res: Response): Promise<void> => {
  try {
    const { message } = req.body;
    if (!message) {
      res.status(400).json({ error: 'Message is required' });
      return;
    }

    if (!process.env.GEMINI_API_KEY || process.env.GEMINI_API_KEY.length < 10) {
      res.json({ reply: 'Halo! Saya adalah Asisten Perjalanan Anda. (Kunci API Gemini belum dikonfigurasi, ini adalah pesan otomatis).' });
      return;
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    const prompt = `Kamu adalah asisten perjalanan kereta KRL/LRT di Jabodetabek bernama KAI Metro Access.
Jawablah pertanyaan berikut dengan singkat, ramah, dan membantu:
Pertanyaan: ${message}`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    res.json({ reply: text });
  } catch (error) {
    console.error('Error generating AI response:', error);
    res.status(500).json({ error: 'Failed to communicate with AI Assistant' });
  }
};
