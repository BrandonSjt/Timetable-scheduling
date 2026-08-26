import { ApiError } from '../domain/errors/ApiError';

export function getJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.length < 16) {
    throw new ApiError(500, 'JWT_SECRET must contain at least 16 characters', 'INVALID_SERVER_CONFIG');
  }
  return secret;
}
