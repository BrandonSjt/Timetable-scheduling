declare global {
  namespace Express {
    interface Request {
      auth?: {
        userId?: string;
        role: 'GUEST' | 'REGISTERED' | 'ADMIN';
        sessionId?: string;
      };
    }
  }
}

export {};
