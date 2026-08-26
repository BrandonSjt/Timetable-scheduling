import { NextFunction, Request, Response } from 'express';
import { z } from 'zod';
import { ApiError } from '../../domain/errors/ApiError';
import { prisma } from '../../infrastructure/database/prismaClient';

const profileSelect = {
  id: true,
  email: true,
  name: true,
  phone: true,
  role: true,
  language: true,
  accessibilityEnabled: true,
  notificationsEnabled: true,
  createdAt: true,
  updatedAt: true,
};

export const getProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.auth?.userId) throw new ApiError(401, 'Registered user is required', 'USER_REQUIRED');
    const user = await prisma.user.findUnique({ where: { id: req.auth.userId }, select: profileSelect });
    if (!user) throw new ApiError(404, 'User not found', 'USER_NOT_FOUND');
    res.json({ success: true, data: user });
  } catch (error) {
    next(error);
  }
};

export const updateProfileSchema = z.object({
  name: z.string().trim().min(2).max(100).optional(),
  phone: z.string().trim().min(8).max(20).nullable().optional(),
  language: z.enum(['id', 'en', 'zh-Hans', 'ar']).optional(),
  accessibilityEnabled: z.boolean().optional(),
  notificationsEnabled: z.boolean().optional(),
});

export const updateProfile = async (req: Request, res: Response, next: NextFunction) => {
  try {
    if (!req.auth?.userId) throw new ApiError(401, 'Registered user is required', 'USER_REQUIRED');
    const parsed = updateProfileSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid profile data', 'VALIDATION_ERROR', parsed.error.issues);
    }
    const user = await prisma.user.update({
      where: { id: req.auth.userId },
      data: parsed.data,
      select: profileSelect,
    });
    res.json({ success: true, data: user });
  } catch (error) {
    next(error);
  }
};
