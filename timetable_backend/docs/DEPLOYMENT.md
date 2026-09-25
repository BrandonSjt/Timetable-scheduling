# Deploy backend on a server with Docker Compose

Docker Compose runs PostgreSQL, initializes the database, then starts the API.
The API listens on port `3000` inside its container. The public host port is
`HOST_PORT=3000` by default; set `HOST_PORT=8080` to publish port 8080 instead.
`HOST_BIND_IP=0.0.0.0` binds that port on all host interfaces. PostgreSQL stays
bound to `127.0.0.1` on `DB_HOST_PORT=5433` by default.

## First deployment

1. Install Docker Engine with the Compose plugin. Copy this backend directory to
   the server and work from this directory.
2. Create `.env` and set three independent random values:

   ```sh
   cp .env.example .env
   openssl rand -hex 32  # POSTGRES_PASSWORD
   openssl rand -hex 32  # JWT_SECRET
   openssl rand -hex 32  # TICKET_QR_SECRET
   chmod 600 .env
   ```

   Put the generated values in their matching `.env` entries. Use a hex
   PostgreSQL password because Compose places it in a database URL. Set
   `HOST_PORT` if `3000` is unavailable. For browser clients, set `CORS_ORIGINS`
   to the real web origin(s). Optional Gemini, Xendit, and realtime-provider
   values may remain empty when those features are unused. Keep `.env` out of
   Git.

3. Deploy:

   ```sh
   docker compose up -d --build --wait --wait-timeout 300
   docker compose ps
   curl --fail http://127.0.0.1:3000/ready
   ```

   Change `3000` in the `curl` command if you set `HOST_PORT`. Compose waits
   for PostgreSQL to become healthy, applies pending Prisma migrations, seeds
   the station/network catalog, and imports the bundled February 2026
   timetable before starting the API. If that timetable version already exists,
   seed and import are skipped. A failed initialization prevents the API from
   starting. `/ready` checks the database and transit read models; `/health`
   checks only the HTTP process.

The API is reachable at `http://SERVER_IP:HOST_PORT` when the server firewall
allows that port. Put HTTPS in front of it before public use. A reverse proxy on
the same server can reach the published port; limit access to the proxy in the
firewall if clients should never use plain HTTP directly. For an external proxy,
allow the port only from that proxy. The mobile API base URL should be
`https://your-api.example.com/api/v1`. For Xendit payments, register
`https://your-api.example.com/api/v1/payments/webhook/xendit` as the webhook URL.

## Verify and update

From a machine with Node.js 20 or newer, run:

```sh
node scripts/smoke-production.mjs https://your-api.example.com/api/v1
```

The smoke check covers readiness, stations, the bundled timetable, routing, and
assistant behavior. For an on-server check before HTTPS, use
`node scripts/smoke-production.mjs http://127.0.0.1:3000/api/v1` (adjust port).

For updates, back up the database and then run the same deploy command:

```sh
docker compose up -d --build --wait --wait-timeout 300
docker compose ps
docker compose logs --tail=100 setup backend
```

Migrations run again; seed and import skip the already present bundled dataset.
Keep the same `POSTGRES_PASSWORD` while reusing the PostgreSQL volume. Changing
the variable does not change the existing database user's password. PostgreSQL
data lives in the named `pgdata` volume. `docker compose down` retains it;
`docker compose down -v` deletes it.

The bundled fare calculation is a product estimate. Obtain an official fare
source before accepting production ticket sales.
