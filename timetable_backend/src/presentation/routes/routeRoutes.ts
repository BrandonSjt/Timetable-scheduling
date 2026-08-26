import { Router } from 'express';
import { planRoute } from '../controllers/routeController';

const router = Router();

/**
 * @swagger
 * /api/v1/routes/plan:
 *   post:
 *     summary: Plan a multimodal route
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               from:
 *                 type: string
 *               to:
 *                 type: string
 *               preference:
 *                 type: string
 *                 enum: [FASTEST, MIN_TRANSFERS]
 *                 default: FASTEST
 *     responses:
 *       200:
 *         description: The calculated route plan.
 */
router.post('/plan', planRoute);

export default router;
