import { NextFunction, Request, Response } from 'express';
import { z } from 'zod';
import { ApiError } from '../../domain/errors/ApiError';
import {
  AssistantProviderError,
  AssistantService,
} from '../../domain/services/assistantService';

export const assistantMessageSchema = z.object({
  message: z.string().trim().min(1).max(1000),
});

const assistantService = new AssistantService();

export const askAssistant = async (
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> => {
  const parsed = assistantMessageSchema.safeParse(req.body);
  if (!parsed.success) {
    next(new ApiError(400, 'Message must contain 1-1000 characters.', 'VALIDATION_ERROR'));
    return;
  }

  try {
    const reply = await assistantService.reply(parsed.data.message);
    res.json({ success: true, data: { reply } });
  } catch (error) {
    if (error instanceof AssistantProviderError) {
      const status = error.code === 'AI_NOT_CONFIGURED' ? 503 : 502;
      next(new ApiError(status, error.message, error.code));
      return;
    }
    next(error);
  }
};
