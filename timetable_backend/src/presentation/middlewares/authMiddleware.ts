import { NextFunction, Request, Response } from 'express';
import { ApiError } from '../../domain/errors/ApiError';
import { verifyAccessToken } from '../../domain/services/authTokenService';

function authenticate(req: Request) {
  const authorization = req.header('authorization');
  if (!authorization?.startsWith('Bearer ')) {
    throw new ApiError(401, 'Bearer token is required', 'AUTHENTICATION_REQUIRED');
  }
  req.auth = verifyAccessToken(authorization.slice('Bearer '.length));
}

export function requireAuth(req: Request, _res: Response, next: NextFunction) {
  try {
    authenticate(req);
    next();
  } catch (error) {
    next(error instanceof ApiError
      ? error
      : new ApiError(401, 'Invalid or expired access token', 'INVALID_ACCESS_TOKEN'));
  }
}

export function optionalAuth(req: Request, _res: Response, next: NextFunction) {
  if (!req.header('authorization')) return next();
  requireAuth(req, _res, next);
}

export function requireAdmin(req: Request, _res: Response, next: NextFunction) {
  if (req.auth?.role !== 'ADMIN') {
    next(new ApiError(403, 'Administrator access is required', 'ADMIN_REQUIRED'));
    return;
  }
  next();
}
