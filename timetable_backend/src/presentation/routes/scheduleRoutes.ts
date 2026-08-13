import { Router } from 'express';
import { getSchedules } from '../controllers/scheduleController';

const router = Router();

/**
 * @swagger
 * /api/v1/schedules:
 *   get:
 *     summary: Get schedules by station ID
 *     parameters:
 *       - in: query
 *         name: stationId
 *         schema:
 *           type: string
 *         required: true
 *         description: ID of the station to fetch schedules for
 *     responses:
 *       200:
 *         description: A list of schedules for the station.
 */
router.get('/', getSchedules);

export default router;
