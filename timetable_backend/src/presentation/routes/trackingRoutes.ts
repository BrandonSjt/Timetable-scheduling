import { Router } from 'express';
import { getLiveTracking } from '../controllers/trackingController';

const router = Router();
router.get('/:trainNumber', getLiveTracking);
export default router;
