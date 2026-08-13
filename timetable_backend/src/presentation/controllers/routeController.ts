import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { RouteService } from '../../domain/services/routeService';

export const planRouteSchema = z.object({
  from: z.string().trim().min(1),
  to: z.string().trim().min(1),
  passengerCount: z.coerce.number().int().min(1).max(6).default(1),
  preference: z.enum(['FASTEST', 'MIN_TRANSFERS']).default('FASTEST'),
});

export const planRoute = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parseResult = planRouteSchema.safeParse(req.body);
    if (!parseResult.success) {
      return res.status(400).json({ success: false, errors: parseResult.error.issues });
    }

    const { from, to, passengerCount, preference } = parseResult.data;

    // Use RouteService to handle dynamic route planning while keeping the exact frontend structure
    const routePlan = await RouteService.planRoute(from, to, passengerCount, preference);

    res.json({ success: true, data: routePlan });
  } catch (error) {
    next(error);
  }
};
