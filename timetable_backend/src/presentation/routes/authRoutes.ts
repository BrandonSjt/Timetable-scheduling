import { Request } from 'express';
import { ipKeyGenerator, rateLimit } from 'express-rate-limit';
import { Router } from 'express';
import { guestToken, login, logout, refresh, register } from '../controllers/authController';

const router = Router();
const windowMs = 15 * 60 * 1000;
const ip = (req: Request) => ipKeyGenerator(req.ip ?? '127.0.0.1');
const normalizedEmail = (req: Request) =>
  typeof req.body?.email === 'string' ? req.body.email.trim().toLowerCase() : '-';

const credentialsLimiter = rateLimit({
  windowMs,
  limit: 10,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => `${ip(req)}:${normalizedEmail(req)}`,
  message: { success: false, error: { code: 'AUTH_RATE_LIMITED', message: 'Too many authentication attempts' } },
});
const refreshLimiter = rateLimit({
  windowMs,
  limit: 30,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: ip,
  message: { success: false, error: { code: 'AUTH_RATE_LIMITED', message: 'Too many session attempts' } },
});

router.post('/register', credentialsLimiter, register);
router.post('/login', credentialsLimiter, login);
router.post('/refresh', refreshLimiter, refresh);
router.post('/logout', refreshLimiter, logout);
router.post('/guest', guestToken);

export default router;
