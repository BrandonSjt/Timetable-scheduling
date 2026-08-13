import crypto from 'node:crypto';

export class TicketService {
  static createPublicCode(service = 'KAI') {
    const date = new Date().toISOString().slice(2, 10).replaceAll('-', '');
    const suffix = crypto.randomBytes(4).toString('hex').toUpperCase();
    return `${service}-${date}-${suffix}`;
  }

  static createQrPayload(publicCode: string) {
    const secret = process.env.TICKET_QR_SECRET || process.env.JWT_SECRET;
    if (!secret || secret.length < 16) {
      throw new Error('TICKET_QR_SECRET or JWT_SECRET must contain at least 16 characters');
    }
    const issuedAt = Math.floor(Date.now() / 1000);
    const payload = `${publicCode}.${issuedAt}`;
    const signature = crypto.createHmac('sha256', secret).update(payload).digest('base64url');
    return `${payload}.${signature}`;
  }

  static verifyQrPayload(value: string) {
    const secret = process.env.TICKET_QR_SECRET || process.env.JWT_SECRET;
    if (!secret || secret.length < 16) return null;
    const [publicCode, issuedAt, suppliedSignature] = value.split('.');
    if (!publicCode || !issuedAt || !suppliedSignature) return null;
    const expected = crypto
      .createHmac('sha256', secret)
      .update(`${publicCode}.${issuedAt}`)
      .digest('base64url');
    const suppliedBuffer = Buffer.from(suppliedSignature);
    const expectedBuffer = Buffer.from(expected);
    if (
      suppliedBuffer.length !== expectedBuffer.length ||
      !crypto.timingSafeEqual(suppliedBuffer, expectedBuffer)
    ) {
      return null;
    }
    return { publicCode, issuedAt: Number(issuedAt) };
  }
}
