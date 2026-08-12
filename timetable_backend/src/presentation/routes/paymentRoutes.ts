import { Router } from 'express';
import { checkout, getPaymentStatus, xenditWebhook } from '../controllers/paymentController';

const router = Router();

/**
 * @swagger
 * /api/v1/payments/checkout:
 *   post:
 *     summary: Checkout and create Xendit invoice
 *     tags: [Payments]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               ticketId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Payment invoice created
 */
router.post('/checkout', checkout);
router.get('/status/:ticketId', getPaymentStatus);

/**
 * @swagger
 * /api/v1/payments/webhook/xendit:
 *   post:
 *     summary: Webhook for Xendit payment status
 *     tags: [Payments]
 *     responses:
 *       200:
 *         description: Webhook received
 */
router.post('/webhook/xendit', xenditWebhook);

export default router;
