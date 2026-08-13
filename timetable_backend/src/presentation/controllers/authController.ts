import { NextFunction, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { prisma } from '../../infrastructure/database/prismaClient';
import { ApiError } from '../../domain/errors/ApiError';
import {
  AuthSessionService,
  PrismaAuthSessionStore,
} from '../../domain/services/authSessionService';
import { createGuestAccessToken } from '../../domain/services/authTokenService';

export const credentialsSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(100),
  deviceName: z.string().trim().min(1).max(100).optional(),
});

export const registerSchema = credentialsSchema.extend({
  name: z.string().trim().min(2).max(100),
  phone: z.string().trim().min(8).max(20).optional(),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(40).max(200),
});

export const logoutSchema = refreshSchema;

const userSelect = {
  id: true,
  email: true,
  name: true,
  phone: true,
  role: true,
  language: true,
  accessibilityEnabled: true,
  notificationsEnabled: true,
} as const;

export const register = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = registerSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid registration data', 'VALIDATION_ERROR', parsed.error.issues);
    }
    const email = parsed.data.email.toLowerCase();
    if (await prisma.user.findUnique({ where: { email }, select: { id: true } })) {
      throw new ApiError(409, 'Email already in use', 'EMAIL_ALREADY_USED');
    }
    const password = await bcrypt.hash(parsed.data.password, 12);
    const { user, tokens } = await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          email,
          password,
          name: parsed.data.name,
          phone: parsed.data.phone,
          role: 'REGISTERED',
        },
        select: userSelect,
      });
      const sessions = new AuthSessionService(new PrismaAuthSessionStore(tx));
      const tokens = await sessions.create(
        { id: user.id, role: 'REGISTERED' },
        parsed.data.deviceName,
      );
      return { user, tokens };
    });
    res.status(201).json({ success: true, data: { user, ...tokens } });
  } catch (error) {
    next(error);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = credentialsSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid credentials format', 'VALIDATION_ERROR');
    }
    const user = await prisma.user.findUnique({
      where: { email: parsed.data.email.toLowerCase() },
    });
    if (
      !user?.password ||
      !['REGISTERED', 'ADMIN'].includes(user.role) ||
      !(await bcrypt.compare(parsed.data.password, user.password))
    ) {
      throw new ApiError(401, 'Invalid email or password', 'INVALID_CREDENTIALS');
    }
    const tokens = await new AuthSessionService().create(
      { id: user.id, role: user.role as 'REGISTERED' | 'ADMIN' },
      parsed.data.deviceName,
    );
    const { password: _password, ...publicUser } = user;
    res.json({ success: true, data: { user: publicUser, ...tokens } });
  } catch (error) {
    next(error);
  }
};

export const refresh = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = refreshSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid refresh request', 'VALIDATION_ERROR');
    }
    const tokens = await new AuthSessionService().refresh(parsed.data.refreshToken);
    const user = await prisma.user.findUnique({ where: { id: tokens.userId }, select: userSelect });
    if (!user) throw new ApiError(401, 'Invalid or expired refresh token', 'INVALID_REFRESH_TOKEN');
    res.json({ success: true, data: { user, ...tokens } });
  } catch (error) {
    next(error);
  }
};

export const logout = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = logoutSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid logout request', 'VALIDATION_ERROR');
    }
    await new AuthSessionService().revoke(parsed.data.refreshToken);
    res.json({ success: true, data: { revoked: true } });
  } catch (error) {
    next(error);
  }
};

export const guestToken = async (_req: Request, res: Response, next: NextFunction) => {
  try {
    res.json({ success: true, data: { token: createGuestAccessToken(), role: 'GUEST' } });
  } catch (error) {
    next(error);
  }
};
