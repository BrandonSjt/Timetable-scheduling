FROM node:20-alpine AS builder

WORKDIR /app
RUN apk add --no-cache openssl
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx prisma generate
RUN npm run build

FROM node:20-alpine AS runner

WORKDIR /app
RUN apk add --no-cache openssl
COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/dist ./dist

# Refuse potentially destructive schema changes; production deployments should
# replace db push with versioned `prisma migrate deploy` once a baseline exists.
RUN echo '#!/bin/sh' > /app/entrypoint.sh && \
    echo 'npx prisma db push' >> /app/entrypoint.sh && \
    echo 'npx prisma db seed' >> /app/entrypoint.sh && \
    echo 'node dist/app.js' >> /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

EXPOSE 3000

CMD ["/app/entrypoint.sh"]
