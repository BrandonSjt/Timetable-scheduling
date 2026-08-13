import { NextFunction, Request, Response } from 'express';
import { ApiError } from '../../domain/errors/ApiError';

export const getLiveTracking = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const trainNumber = Array.isArray(req.params.trainNumber)
      ? req.params.trainNumber[0]
      : req.params.trainNumber;
    const providerUrl = process.env.KAI_REALTIME_API_URL;
    if (!providerUrl) {
      throw new ApiError(
        503,
        'KAI realtime provider is not configured',
        'REALTIME_PROVIDER_NOT_CONFIGURED',
      );
    }
    const response = await fetch(
      `${providerUrl.replace(/\/$/, '')}/trains/${encodeURIComponent(trainNumber)}`,
      {
        headers: {
          Accept: 'application/json',
          ...(process.env.KAI_REALTIME_API_TOKEN
            ? { Authorization: `Bearer ${process.env.KAI_REALTIME_API_TOKEN}` }
            : {}),
        },
        signal: AbortSignal.timeout(10_000),
      },
    );
    if (!response.ok) {
      throw new ApiError(502, 'KAI realtime provider request failed', 'REALTIME_PROVIDER_FAILED');
    }
    res.json({ success: true, data: await response.json(), meta: { receivedAt: new Date() } });
  } catch (error) {
    next(error);
  }
};
