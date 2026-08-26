import { ApiError } from '../../domain/errors/ApiError';

export interface CreatePaymentSessionInput {
  referenceId: string;
  amount: number;
  ticketId: string;
  publicCode: string;
  description: string;
  customerName?: string | null;
  customerEmail?: string | null;
  customerPhone?: string | null;
  expiresAt: Date;
}

export interface XenditPaymentSession {
  payment_session_id: string;
  reference_id: string;
  payment_link_url: string;
  status: 'ACTIVE' | 'COMPLETED' | 'EXPIRED' | 'CANCELED';
  amount: number;
  currency: string;
  expires_at: string;
}

const xenditApiUrl = () => process.env.XENDIT_API_URL || 'https://api.xendit.co';

export const isXenditConfigured = () =>
  Boolean(process.env.XENDIT_SECRET_KEY && process.env.XENDIT_SECRET_KEY!.length >= 20);

const cleanName = (value?: string | null) => {
  const cleaned = (value || 'Penumpang KAI').replace(/[^a-zA-Z0-9 ]/g, '').trim();
  return cleaned || 'Penumpang KAI';
};

const normalizedPhone = (value?: string | null) => {
  if (!value) return undefined;
  const compact = value.replace(/[\s()-]/g, '');
  if (compact.startsWith('+')) return compact;
  if (compact.startsWith('0')) return `+62${compact.slice(1)}`;
  return undefined;
};

export async function createPaymentSession(
  input: CreatePaymentSessionInput,
): Promise<XenditPaymentSession> {
  const secretKey = process.env.XENDIT_SECRET_KEY;
  if (!secretKey || secretKey.length < 20) {
    throw new ApiError(
      503,
      'Xendit is not configured',
      'PAYMENT_PROVIDER_NOT_CONFIGURED',
    );
  }

  const customerReference = `customer${input.ticketId.replace(/[^a-zA-Z0-9]/g, '')}`;
  const body: Record<string, unknown> = {
    reference_id: input.referenceId,
    session_type: 'PAY',
    mode: 'PAYMENT_LINK',
    amount: input.amount,
    currency: 'IDR',
    country: 'ID',
    locale: 'id',
    capture_method: 'AUTOMATIC',
    allow_save_payment_method: 'DISABLED',
    expires_at: input.expiresAt.toISOString(),
    description: input.description,
    customer: {
      reference_id: customerReference.slice(0, 255),
      type: 'INDIVIDUAL',
      ...(input.customerEmail ? { email: input.customerEmail.slice(0, 50) } : {}),
      ...(normalizedPhone(input.customerPhone)
        ? { mobile_number: normalizedPhone(input.customerPhone) }
        : {}),
      individual_detail: { given_names: cleanName(input.customerName).slice(0, 50) },
    },
    items: [
      {
        reference_id: input.publicCode,
        type: 'PHYSICAL_SERVICE',
        name: `Tiket ${input.publicCode}`,
        net_unit_amount: input.amount,
        quantity: 1,
        category: 'TRANSPORTATION',
      },
    ],
    metadata: { ticket_id: input.ticketId, public_code: input.publicCode },
  };
  if (process.env.XENDIT_SUCCESS_RETURN_URL) {
    body.success_return_url = process.env.XENDIT_SUCCESS_RETURN_URL;
  }
  if (process.env.XENDIT_CANCEL_RETURN_URL) {
    body.cancel_return_url = process.env.XENDIT_CANCEL_RETURN_URL;
  }

  const response = await fetch(`${xenditApiUrl()}/sessions`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${Buffer.from(`${secretKey}:`).toString('base64')}`,
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(15_000),
  });
  const payload = (await response.json().catch(() => ({}))) as Record<string, unknown>;
  if (!response.ok) {
    throw new ApiError(
      502,
      typeof payload.message === 'string' ? payload.message : 'Xendit session creation failed',
      typeof payload.error_code === 'string' ? payload.error_code : 'XENDIT_REQUEST_FAILED',
    );
  }
  if (
    typeof payload.payment_session_id !== 'string' ||
    typeof payload.payment_link_url !== 'string' ||
    typeof payload.reference_id !== 'string'
  ) {
    throw new ApiError(502, 'Invalid response from Xendit', 'INVALID_XENDIT_RESPONSE');
  }
  return payload as unknown as XenditPaymentSession;
}
