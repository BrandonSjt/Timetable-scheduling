import { NextFunction, Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../../infrastructure/database/prismaClient';
import { ApiError } from '../../domain/errors/ApiError';
import { RouteService } from '../../domain/services/routeService';
import { TicketService } from '../../domain/services/ticketService';

export const orderSchema = z
  .object({
    contactEmail: z.string().email().optional(),
    contactPhone: z.string().trim().min(8).max(20).optional(),
    scheduleId: z.string().uuid().optional(),
    origin: z.string().trim().min(1),
    destination: z.string().trim().min(1),
    travelDate: z.coerce.date(),
    passengerCount: z.coerce.number().int().min(1).max(6).default(1),
    price: z.number().optional(),
  })
  .strict();

type TicketOrderInput = z.infer<typeof orderSchema>;
type RequestAuth = Request['auth'];

export function resolveTicketOwner(auth: RequestAuth, input: TicketOrderInput) {
  if (auth?.userId && auth.role !== 'GUEST') return auth.userId;
  if (input.contactEmail || input.contactPhone) return null;
  throw new ApiError(
    400,
    'contactEmail or contactPhone is required for guest checkout',
    'GUEST_CONTACT_REQUIRED',
  );
}

const ticketInclude = {
  originStation: { include: { nodes: true, lines: true } },
  destinationStation: { include: { nodes: true, lines: true } },
  schedule: true,
  payments: { orderBy: { createdAt: 'desc' as const } },
};

export const orderTicket = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = orderSchema.safeParse(req.body);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid booking request', 'VALIDATION_ERROR', parsed.error.issues);
    }
    const input = parsed.data;
    const userId = resolveTicketOwner(req.auth, input);
    const [origin, destination, route] = await Promise.all([
      RouteService.resolveStation(input.origin),
      RouteService.resolveStation(input.destination),
      RouteService.planRoute(input.origin, input.destination, input.passengerCount),
    ]);
    const schedule = input.scheduleId
      ? await prisma.schedule.findUnique({ where: { id: input.scheduleId } })
      : null;
    if (input.scheduleId && !schedule) {
      throw new ApiError(404, 'Schedule not found', 'SCHEDULE_NOT_FOUND');
    }
    if (schedule && schedule.stationId !== origin.id) {
      throw new ApiError(
        400,
        'Selected schedule does not depart from the origin station',
        'SCHEDULE_ORIGIN_MISMATCH',
      );
    }
    const ticket = await prisma.ticket.create({
      data: {
        publicCode: TicketService.createPublicCode(route.stationSequence[0]?.line.serviceType),
        userId,
        contactEmail: input.contactEmail,
        contactPhone: input.contactPhone,
        scheduleId: schedule?.id,
        originStationId: origin.id,
        destinationStationId: destination.id,
        passengerCount: input.passengerCount,
        unitPrice: route.unitFare,
        price: route.fare,
        status: 'PAYMENT_PENDING',
        travelDate: input.travelDate,
        departureTime: schedule?.departureTime,
        arrivalTime: schedule?.arrivalTime,
        expiresAt: new Date(Date.now() + 30 * 60 * 1000),
      },
      include: ticketInclude,
    });
    res.status(201).json({
      success: true,
      data: ticket,
      meta: { quotedRoute: route, clientPriceIgnored: input.price !== undefined },
    });
  } catch (error) {
    next(error);
  }
};

export const getTicket = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const identifier = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
    const ticket = await prisma.ticket.findFirst({
      where: { OR: [{ id: identifier }, { publicCode: identifier }] },
      include: ticketInclude,
    });
    if (!ticket) throw new ApiError(404, 'Ticket not found', 'TICKET_NOT_FOUND');
    res.json({ success: true, data: ticket });
  } catch (error) {
    next(error);
  }
};

const listSchema = z.object({
  contactEmail: z.string().email().optional(),
  status: z
    .enum(['PENDING', 'PAYMENT_PENDING', 'PAID', 'ACTIVE', 'USED', 'EXPIRED', 'CANCELLED'])
    .optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export const listTickets = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const parsed = listSchema.safeParse(req.query);
    if (!parsed.success) {
      throw new ApiError(400, 'Invalid ticket history query', 'VALIDATION_ERROR');
    }
    const { contactEmail, status, page, limit } = parsed.data;
    const userId = req.auth?.role !== 'GUEST' ? req.auth?.userId : undefined;
    if (!userId && !contactEmail) {
      throw new ApiError(400, 'contactEmail is required for guest history', 'VALIDATION_ERROR');
    }
    const where = { ...(userId ? { userId } : { contactEmail }), ...(status ? { status } : {}) };
    const [tickets, total] = await prisma.$transaction([
      prisma.ticket.findMany({
        where,
        include: ticketInclude,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.ticket.count({ where }),
    ]);
    res.json({ success: true, data: tickets, meta: { page, limit, total } });
  } catch (error) {
    next(error);
  }
};

export const cancelTicket = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body = z.object({ reason: z.string().trim().min(3).max(250) }).safeParse(req.body);
    if (!body.success) {
      throw new ApiError(400, 'Cancellation reason is required', 'VALIDATION_ERROR');
    }
    const ticketId = Array.isArray(req.params.id) ? req.params.id[0] : req.params.id;
    const ticket = await prisma.ticket.findUnique({ where: { id: ticketId } });
    if (!ticket) throw new ApiError(404, 'Ticket not found', 'TICKET_NOT_FOUND');
    if (!['PENDING', 'PAYMENT_PENDING'].includes(ticket.status)) {
      throw new ApiError(409, 'Paid or used ticket cannot be cancelled here', 'TICKET_NOT_CANCELLABLE');
    }
    const updated = await prisma.ticket.update({
      where: { id: ticket.id },
      data: {
        status: 'CANCELLED',
        cancelledAt: new Date(),
        cancellationReason: body.data.reason,
        payments: { updateMany: { where: { status: 'PENDING' }, data: { status: 'CANCELLED' } } },
      },
      include: ticketInclude,
    });
    res.json({ success: true, data: updated });
  } catch (error) {
    next(error);
  }
};

export const validateTicketQr = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const body = z.object({ qrCode: z.string().min(20), markUsed: z.boolean().default(false) }).safeParse(req.body);
    if (!body.success) throw new ApiError(400, 'Invalid QR payload', 'VALIDATION_ERROR');
    const verified = TicketService.verifyQrPayload(body.data.qrCode);
    if (!verified) throw new ApiError(400, 'QR signature is invalid', 'INVALID_QR_SIGNATURE');
    const ticket = await prisma.ticket.findUnique({ where: { publicCode: verified.publicCode } });
    if (!ticket || ticket.qrCode !== body.data.qrCode) {
      throw new ApiError(404, 'Ticket QR is not active', 'TICKET_NOT_FOUND');
    }
    if (!['ACTIVE', 'USED'].includes(ticket.status)) {
      throw new ApiError(409, `Ticket status is ${ticket.status}`, 'TICKET_NOT_ACTIVE');
    }
    const result = body.data.markUsed && ticket.status === 'ACTIVE'
      ? await prisma.ticket.update({ where: { id: ticket.id }, data: { status: 'USED', usedAt: new Date() } })
      : ticket;
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};
