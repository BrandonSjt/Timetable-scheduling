# Backend–Mobile Alignment Implementation Plan

> **For agentic workers:** Execute this plan task-by-task in the current workspace. Subagent dispatch is not used because the user did not request delegation.

**Goal:** Make the Express/Prisma backend expose the station topology and transaction contracts required by the KAIACCES Flutter mobile application, including secure Xendit Payment Sessions.

**Architecture:** Store a physical station once, model every line-specific map node separately, and derive graph edges from ordered line nodes. Keep controllers thin by moving topology, fare, ticket, and Xendit behavior into focused services; all client-controlled identifiers and prices are validated server-side.

**Tech Stack:** Node.js, TypeScript, Express 5, Prisma 5, PostgreSQL 16, Zod 4, Node test runner, Xendit REST Payment Sessions.

---

## File map

- `prisma/schema.prisma`: normalized topology, ticket lifecycle, payment-session persistence, and webhook idempotency.
- `prisma/networkData.ts`: canonical mobile-aligned physical stations, nodes, lines, aliases, and ordered topology.
- `prisma/seed.ts`: idempotent seed for network and sample schedules.
- `src/domain/services/routeService.ts`: graph routing over node edges without dummy fallback.
- `src/domain/services/fareService.ts`: server-side fare calculation.
- `src/infrastructure/payments/xenditClient.ts`: typed Xendit Payment Session HTTP client.
- `src/presentation/controllers/*.ts`: validated mobile-facing API contracts.
- `src/presentation/routes/*.ts`: station network, ticket history/status/cancel, payment status/webhook, reminder/report CRUD.
- `tests/*.test.ts`: unit and HTTP regression coverage.
- `.env.example`, `README.md`, `src/presentation/docs/swagger.ts`: deployment and API handoff.

### Task 1: Test harness and topology schema

- [ ] Add `node --import tsx --test tests/**/*.test.ts` as the test command.
- [ ] Add a topology regression test asserting 121 unique mobile station names, unique node codes, and graph edges for each ordered line.
- [ ] Run the test and confirm it fails because `networkData.ts` does not exist.
- [ ] Add `StationAlias`, `StationNode`, and foreign-keyed `RouteConnection`; add line slug/service type and map ordering fields.
- [ ] Generate Prisma Client and re-run the topology test.

### Task 2: Canonical network seed and station APIs

- [ ] Transcribe the canonical station/node/line records from `schematic_map_painter.dart`, merging repeated physical stations while preserving all line-specific codes.
- [ ] Seed lines, physical stations, aliases, nodes, line membership, and adjacent connections idempotently.
- [ ] Return stations ordered by name with `aliases`, `nodes`, and `lines`.
- [ ] Add `GET /api/v1/stations/network` returning lines and ordered nodes, and extend search with `service`, `accessible`, and alias matching.
- [ ] Assert station search finds both plain and sponsored names.

### Task 3: Route and schedule contracts

- [ ] Replace substring-based station resolution with exact code/name/alias resolution.
- [ ] Route over `StationNode` adjacency, add transfer edges between nodes belonging to the same physical station, and return actual station/node steps.
- [ ] Return 404 for unknown stations, 400 for equal endpoints, and 422 for disconnected routes; remove fabricated routes.
- [ ] Extend schedules with station UUID/code/name, train type, weekend, departure window, and pagination filters.
- [ ] Add route and schedule HTTP regression tests.

### Task 4: Booking and ticket lifecycle

- [ ] Extend `Ticket` with public code, origin/destination, travel time, passenger count, expiry, activation/completion timestamps, and cancellation reason.
- [ ] Add `TicketStatus` values `PAYMENT_PENDING`, `ACTIVE`, `USED`, `EXPIRED`, and retain safe cancellation semantics.
- [ ] Calculate fare in `fareService.ts`; ignore any client-supplied price.
- [ ] Validate schedule/origin/destination consistency and create a signed QR payload only after successful payment.
- [ ] Add authenticated-or-explicit-user list/history, detail, cancel, and validation endpoints.
- [ ] Add booking tests proving manipulated client prices cannot change the persisted amount.

### Task 5: Reminder, report, and account-support APIs

- [ ] Add list/update/delete reminder routes with ownership validation.
- [ ] Add list/detail/status-update report routes for user/admin workflows.
- [ ] Add user profile read/update and preference fields needed by language/accessibility settings.
- [ ] Add Zod validation and consistent `{ success, data|error }` envelopes.

### Task 6: Xendit Payment Session

- [ ] Add `xenditClient.ts` calling `POST https://api.xendit.co/sessions` with Basic authentication, IDR, country `ID`, `PAYMENT_LINK`, short expiry, and ticket metadata.
- [ ] Persist `referenceId`, `xenditSessionId`, checkout URL, expiry, and payment ID; reuse an active session to make checkout idempotent.
- [ ] Reject checkout when Xendit configuration is absent instead of returning a dummy URL.
- [ ] Verify `x-callback-token` with timing-safe comparison; validate event, reference, session ID, amount, and currency.
- [ ] Make duplicate completed/expired webhooks idempotent and activate/cancel tickets transactionally.
- [ ] Add payment tests using an injected fake Xendit client.

### Task 7: Migration, documentation, and verification

- [ ] Generate a Prisma migration SQL file and apply it to the development database.
- [ ] Run `rtk npx prisma validate` and `rtk npx prisma generate`.
- [ ] Run `rtk npm test` and confirm zero failures.
- [ ] Run `rtk npm run build` and confirm TypeScript exits successfully.
- [ ] Run an HTTP smoke test for health, stations/network, route planning, booking, and missing-Xendit configuration behavior.
- [ ] Document environment variables, response examples, migration/seed commands, Android base URL, and Xendit Dashboard webhook configuration.

## Self-review

- The plan covers topology, route planning, schedules, server-side booking price, ticket lifecycle, reminder/report/account support, Xendit Payment Session, documentation, and verification.
- All persistent identifiers are normalized: physical station UUID, line-specific node code, ticket public code, Xendit reference/session/payment IDs.
- External payment configuration fails closed; no dummy success path remains.
