import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../../domain/errors/ApiError';

export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
  console.error(err);

  const statusCode = err instanceof ApiError ? err.statusCode : 500;
  const message = err instanceof ApiError ? err.message : 'Internal Server Error';

  res.status(statusCode).json({
    success: false,
    error: {
      message,
      code: err instanceof ApiError ? err.code : 'INTERNAL_SERVER_ERROR',
      ...(err instanceof ApiError && err.details !== undefined
        ? { details: err.details }
        : {}),
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
  });
};
