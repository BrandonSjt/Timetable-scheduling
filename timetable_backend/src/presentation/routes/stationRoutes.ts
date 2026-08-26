import { Router } from 'express';
import { getNetwork, getStations, searchStation } from '../controllers/stationController';

const router = Router();

/**
 * @swagger
 * /api/v1/stations:
 *   get:
 *     summary: Retrieve a list of all stations
 *     responses:
 *       200:
 *         description: A list of stations.
 */
router.get('/', getStations);
router.get('/network', getNetwork);

/**
 * @swagger
 * /api/v1/stations/search:
 *   get:
 *     summary: Search for a station by name
 *     parameters:
 *       - in: query
 *         name: q
 *         schema:
 *           type: string
 *         required: true
 *         description: Name of the station to search
 *     responses:
 *       200:
 *         description: A list of matching stations.
 */
router.get('/search', searchStation);

export default router;
