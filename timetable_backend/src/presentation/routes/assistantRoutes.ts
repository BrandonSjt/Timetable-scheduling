import { Router } from 'express';
import { askAssistant } from '../controllers/assistantController';

const router = Router();

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

export default router;
