import { NextFunction, Request, Response } from 'express';
import { z } from 'zod';
import { ApiError } from '../../domain/errors/ApiError';
import { prisma } from '../../infrastructure/database/prismaClient';

const reminderSchema = z.object({
  userId: z.string().uuid(),
  scheduleId: z.string().uuid(),
  timeBefore: z.coerce.number().int().min(1).max(1440),
});

export const createReminder = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = reminderSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid reminder data', 'VALIDATION_ERROR', parsed.error.issues);
    }
    const reminder = await prisma.reminder.create({ data: parsed.data, include: { schedule: true } });
    res.status(201).json({ success: true, data: reminder });
  } catch (error) {
    next(error);
  }
};

export const listReminders = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = z.object({ userId: z.string().uuid() }).safeParse(req.query);
    if (!parsed.success) throw new ApiError(400, 'userId is required', 'VALIDATION_ERROR');
    const reminders = await prisma.reminder.findMany({
      where: { userId: parsed.data.userId },
      include: { schedule: { include: { station: true } } },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: reminders });
  } catch (error) {
    next(error);
  }
};

export const updateReminder = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = z
      .object({ timeBefore: z.coerce.number().int().min(1).max(1440).optional(), isActive: z.boolean().optional() })
      .refine((value) => value.timeBefore !== undefined || value.isActive !== undefined)
      .safeParse(req.body);
    if (!parsed.success) throw new ApiError(400, 'No valid reminder update supplied', 'VALIDATION_ERROR');
    const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
    const reminder = await prisma.reminder.update({ where: { id }, data: parsed.data });
    res.json({ success: true, data: reminder });
  } catch (error) {
    next(error);
  }
};

export const deleteReminder = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
    await prisma.reminder.delete({ where: { id } });
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

const reportSchema = z.object({
  userId: z.string().uuid(),
  category: z.enum(['STATION', 'SCHEDULE', 'ROUTE', 'TICKET', 'PAYMENT', 'OTHER']),
  description: z.string().trim().min(10).max(2000),
});

export const createReport = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = reportSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid report data', 'VALIDATION_ERROR', parsed.error.issues);
    }
    const report = await prisma.report.create({ data: parsed.data });
    res.status(201).json({ success: true, data: report });
  } catch (error) {
    next(error);
  }
};

export const listReports = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = z.object({ userId: z.string().uuid().optional(), status: z.string().optional() }).safeParse(req.query);
    if (!parsed.success) throw new ApiError(400, 'Invalid report filters', 'VALIDATION_ERROR');
    const reports = await prisma.report.findMany({
      where: {
        ...(parsed.data.userId ? { userId: parsed.data.userId } : {}),
        ...(parsed.data.status ? { status: parsed.data.status } : {}),
      },
      include: { user: { select: { id: true, name: true, email: true } } },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: reports });
  } catch (error) {
    next(error);
  }
};

export const updateReportStatus = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = z.object({ status: z.enum(['OPEN', 'IN_REVIEW', 'RESOLVED', 'REJECTED']) }).safeParse(req.body);
    if (!parsed.success) throw new ApiError(400, 'Invalid report status', 'VALIDATION_ERROR');
    const id = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
    const report = await prisma.report.update({ where: { id }, data: parsed.data });
    res.json({ success: true, data: report });
  } catch (error) {
    next(error);
  }
};
