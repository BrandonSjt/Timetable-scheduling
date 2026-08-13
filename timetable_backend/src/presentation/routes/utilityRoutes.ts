import { Router } from 'express';
import {
  createReminder,
  createReport,
  deleteReminder,
  listReminders,
  listReports,
  updateReminder,
  updateReportStatus,
} from '../controllers/utilityController';

const router = Router();
router.get('/reminders', listReminders);
router.post('/reminders', createReminder);
router.patch('/reminders/:id', updateReminder);
router.delete('/reminders/:id', deleteReminder);
router.get('/reports', listReports);
router.post('/reports', createReport);
router.patch('/reports/:id/status', updateReportStatus);

export default router;
