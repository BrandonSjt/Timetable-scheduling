import { Router } from 'express';
import { cancelTicket, getTicket, listTickets, orderTicket, validateTicketQr } from '../controllers/ticketController';
import { optionalAuth } from '../middlewares/authMiddleware';

const router = Router();

/**
 * @swagger
 * /api/v1/tickets/order:
 *   post:
 *     summary: Order a new ticket
 *     tags: [Tickets]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               contactEmail:
 *                 type: string
 *               contactPhone:
 *                 type: string
 *               scheduleId:
 *                 type: string
 *               price:
 *                 type: number
 *     responses:
 *       201:
 *         description: Ticket ordered successfully
 */
router.post('/order', optionalAuth, orderTicket);
router.get('/', optionalAuth, listTickets);
router.post('/validate', validateTicketQr);
router.post('/:id/cancel', cancelTicket);

/**
 * @swagger
 * /api/v1/tickets/{id}:
 *   get:
 *     summary: Get ticket by ID
 *     tags: [Tickets]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Ticket details
 */
router.get('/:id', getTicket);

export default router;
