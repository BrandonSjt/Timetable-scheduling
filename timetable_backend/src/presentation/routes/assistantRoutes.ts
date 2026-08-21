import express, { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { analyzeVision, askAssistant } from '../controllers/assistantController';

const router = Router();
const visionLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * @swagger
 * /api/v1/assistant/chat:
 *   post:
 *     summary: Chat with Gemini AI Assistant
 *     tags: [Assistant]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               message:
 *                 type: string
 *     responses:
 *       200:
 *         description: AI Response
 */
router.post('/chat', askAssistant);

router.post(
  '/vision',
  visionLimiter,
  express.raw({ type: 'image/jpeg', limit: '1mb' }),
  analyzeVision,
);

export default router;
