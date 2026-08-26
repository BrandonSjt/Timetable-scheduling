import crypto from 'node:crypto';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { getJwtSecret } from '../../config/auth';
import { ApiError } from '../errors/ApiError';

export const ACCESS_TOKEN_TTL_SECONDS = 15 * 60;
export const REFRESH_TOKEN_TTL_MS = 90 * 24 * 60 * 60 * 1000;

const registeredClaimsSchema = z.object({
  tokenType: z.literal('access'),
  userId: z.string().uuid(),
  role: z.enum(['REGISTERED', 'ADMIN']),
  sessionId: z.string().uuid(),
});

const guestClaimsSchema = z.object({
  tokenType: z.literal('access'),
  role: z.literal('GUEST'),
});

const accessClaimsSchema = z.union([registeredClaimsSchema, guestClaimsSchema]);

export type RegisteredAccessClaims = z.infer<typeof registeredClaimsSchema>;
export type AccessClaims = z.infer<typeof accessClaimsSchema>;

export function createRefreshToken() {
  return crypto.randomBytes(32).toString('base64url');
}

export function hashRefreshToken(token: string) {
  return crypto.createHash('sha256').update(token, 'utf8').digest('hex');
}

export function createAccessToken(
  claims: Omit<RegisteredAccessClaims, 'tokenType'>,
) {
  return jwt.sign(
    { ...claims, tokenType: 'access' },
    getJwtSecret(),
    { expiresIn: ACCESS_TOKEN_TTL_SECONDS },
  );
}

export function createGuestAccessToken() {
  return jwt.sign(
    { tokenType: 'access', role: 'GUEST' },
    getJwtSecret(),
    { expiresIn: '1d' },
  );
}

export function verifyAccessToken(token: string): AccessClaims {
  const parsed = accessClaimsSchema.safeParse(jwt.verify(token, getJwtSecret()));
  if (!parsed.success) {
    throw new ApiError(401, 'Invalid access token', 'INVALID_ACCESS_TOKEN');
  }
  return parsed.data;
}
