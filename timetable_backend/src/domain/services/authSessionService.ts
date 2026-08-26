import { Prisma } from '@prisma/client';
import { prisma } from '../../infrastructure/database/prismaClient';
import { ApiError } from '../errors/ApiError';
import {
  ACCESS_TOKEN_TTL_SECONDS,
  REFRESH_TOKEN_TTL_MS,
  createAccessToken,
  createRefreshToken,
  hashRefreshToken,
} from './authTokenService';

type RegisteredRole = 'REGISTERED' | 'ADMIN';

export interface AuthSessionRecord {
  id: string;
  userId: string;
  role: RegisteredRole;
  refreshTokenHash: string;
  deviceName: string | null;
  expiresAt: Date;
  revokedAt: Date | null;
  lastUsedAt: Date;
}

export interface AuthSessionStore {
  create(input: Omit<AuthSessionRecord, 'id' | 'revokedAt'>): Promise<AuthSessionRecord>;
  findByHash(refreshTokenHash: string): Promise<AuthSessionRecord | null>;
  rotate(
    id: string,
    currentHash: string,
    nextHash: string,
    expiresAt: Date,
    now: Date,
  ): Promise<boolean>;
  revokeByHash(refreshTokenHash: string, revokedAt: Date): Promise<void>;
}

export class PrismaAuthSessionStore implements AuthSessionStore {
  constructor(
    private readonly client: Pick<Prisma.TransactionClient, 'authSession'> = prisma,
  ) {}

  async create(input: Omit<AuthSessionRecord, 'id' | 'revokedAt'>) {
    const session = await this.client.authSession.create({
      data: {
        userId: input.userId,
        refreshTokenHash: input.refreshTokenHash,
        deviceName: input.deviceName,
        expiresAt: input.expiresAt,
        lastUsedAt: input.lastUsedAt,
      },
      include: { user: { select: { role: true } } },
    });
    return { ...session, role: session.user.role as RegisteredRole };
  }

  async findByHash(refreshTokenHash: string) {
    const session = await this.client.authSession.findUnique({
      where: { refreshTokenHash },
      include: { user: { select: { role: true } } },
    });
    return session
      ? { ...session, role: session.user.role as RegisteredRole }
      : null;
  }

  async rotate(
    id: string,
    currentHash: string,
    nextHash: string,
    expiresAt: Date,
    now: Date,
  ) {
    const result = await this.client.authSession.updateMany({
      where: {
        id,
        refreshTokenHash: currentHash,
        revokedAt: null,
        expiresAt: { gt: now },
      },
      data: { refreshTokenHash: nextHash, expiresAt, lastUsedAt: now },
    });
    return result.count === 1;
  }

  async revokeByHash(refreshTokenHash: string, revokedAt: Date) {
    await this.client.authSession.updateMany({
      where: { refreshTokenHash, revokedAt: null },
      data: { revokedAt },
    });
  }
}

export interface AuthTokenPair {
  sessionId: string;
  userId: string;
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresIn: number;
}

export class AuthSessionService {
  constructor(private readonly store: AuthSessionStore = new PrismaAuthSessionStore()) {}

  async create(
    user: { id: string; role: RegisteredRole },
    deviceName?: string | null,
  ): Promise<AuthTokenPair> {
    const now = new Date();
    const refreshToken = createRefreshToken();
    const session = await this.store.create({
      userId: user.id,
      role: user.role,
      refreshTokenHash: hashRefreshToken(refreshToken),
      deviceName: deviceName?.trim().slice(0, 100) || null,
      expiresAt: new Date(now.getTime() + REFRESH_TOKEN_TTL_MS),
      lastUsedAt: now,
    });
    return this.tokenPair(session, refreshToken);
  }

  async refresh(refreshToken: string): Promise<AuthTokenPair> {
    const currentHash = hashRefreshToken(refreshToken);
    const session = await this.store.findByHash(currentHash);
    const now = new Date();
    if (!session || session.revokedAt || session.expiresAt <= now) {
      throw this.invalidRefreshToken();
    }

    const nextToken = createRefreshToken();
    const expiresAt = new Date(now.getTime() + REFRESH_TOKEN_TTL_MS);
    if (!(await this.store.rotate(
      session.id,
      currentHash,
      hashRefreshToken(nextToken),
      expiresAt,
      now,
    ))) {
      throw this.invalidRefreshToken();
    }
    return this.tokenPair({ ...session, expiresAt, lastUsedAt: now }, nextToken);
  }

  async revoke(refreshToken: string) {
    await this.store.revokeByHash(hashRefreshToken(refreshToken), new Date());
  }

  private tokenPair(session: AuthSessionRecord, refreshToken: string): AuthTokenPair {
    return {
      sessionId: session.id,
      userId: session.userId,
      accessToken: createAccessToken({
        userId: session.userId,
        role: session.role,
        sessionId: session.id,
      }),
      refreshToken,
      accessTokenExpiresIn: ACCESS_TOKEN_TTL_SECONDS,
    };
  }

  private invalidRefreshToken() {
    return new ApiError(401, 'Invalid or expired refresh token', 'INVALID_REFRESH_TOKEN');
  }
}
