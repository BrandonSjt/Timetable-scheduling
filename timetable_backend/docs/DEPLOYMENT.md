# Demo deployment (HTTPS + Neon)

Target: Android APK demo without a developer machine. Backend runs on a free
Node host (Render or equivalent). Database is Neon PostgreSQL. Secrets never
enter the Flutter APK.

## 1. Neon

1. Create a Neon project and copy the pooled `DATABASE_URL`.
2. Keep SSL params from Neon as provided.

## 2. Backend environment

Set these on the host (not in git, not in Flutter):

| Variable | Required | Notes |
|---|---|---|
| `DATABASE_URL` | yes | Neon connection string |
| `JWT_SECRET` | yes | >= 32 random chars |
| `TICKET_QR_SECRET` | yes | independent secret |
| `PORT` | host-managed | usually injected |
| `CORS_ORIGINS` | recommended | app origins or `*` for demo only |
| `GEMINI_API_KEY` | for AI demo | omit only if chat/vision disabled |
| `GEMINI_MODEL` | optional | default `gemini-3.5-flash-lite` |
| `GEMINI_VISION_MODEL` | optional | defaults to `GEMINI_MODEL` |
| `XENDIT_*` | optional | payment demo only |

## 3. Deploy Express

### Docker (preferred)

```powershell
docker build -t kai-access-api .
docker run --env-file .env -p 3000:3000 kai-access-api
```

Entrypoint runs:

1. `npx prisma migrate deploy`
2. `npx prisma db seed`
3. `node dist/app.js`

### Render (or similar free Node host)

1. Connect the `timetable_backend` root as the service directory.
2. Build: `npm ci && npx prisma generate && npm run build`
3. Start: `npx prisma migrate deploy && npm start`
4. Attach the env vars above.
5. Enable HTTPS on the public URL.
6. From a trusted machine with dev dependencies, seed once:

```powershell
$env:DATABASE_URL="postgresql://..."
npx prisma db seed
npm run timetable:import -- prisma/data/commuter-2026-02.json
```

## 4. Timetable dataset

Seed loads catalog, network, platform rules, and legacy schedule fixtures.
The February 2026 commuter snapshot import is separate and idempotent for the
dataset version. Both commands use the same Neon `DATABASE_URL`.

## 5. Smoke checks

```text
GET  https://<host>/health
GET  https://<host>/api/v1/stations?limit=5
POST https://<host>/api/v1/routes/plan
GET  https://<host>/api/v1/schedules?station=Manggarai&limit=5
POST https://<host>/api/v1/assistant/chat
```

Expected:

- `/health` returns `{ "success": true, "data": { "status": "ok" } }`
- disconnected routes return structured errors (no dummy path)
- missing platform rules return empty `platform` (UI shows **Peron belum tersedia**)
- without `GEMINI_API_KEY`, chat/vision return structured AI-not-configured errors

## 6. Cold start

Free hosts may sleep. First request can take 15–30s. Mobile clients use a 25s
request timeout and show **Server sedang aktif** + **Coba Lagi**. Do not treat
timeout as an empty station/schedule list.

## 7. Release APK

From the Flutter project root:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://<host>/api/v1
```

Install the APK on a physical Android device with no USB debugging dependency.
Verify map, route preview, schedule/Peron copy, auth login/refresh, assistant
chat, and camera guide stop-on-background.
