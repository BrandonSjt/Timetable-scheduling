# Account Authentication and Persistent Session Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional registered accounts with rotating 90-day refresh sessions while preserving complete guest access, including ticket purchase and Xendit checkout.

**Architecture:** Express issues 15-minute JWT access tokens and opaque rotating refresh tokens whose hashes are stored per device in PostgreSQL. Flutter keeps only the refresh token in Android-backed secure storage, restores the account silently, and exposes one application-scoped controller to guest/account UI. Public travel endpoints remain anonymous; authenticated ownership always comes from the verified access token.

**Tech Stack:** Node.js, Express 5, TypeScript, Prisma/PostgreSQL, JWT, bcrypt, Node crypto, Flutter/Dart, `http`, `flutter_secure_storage`, GoRouter, Flutter localization.

---

### Task 1: Backend token primitives

**Files:**
- Create: `tests/authTokenService.test.ts`
- Create: `src/domain/services/authTokenService.ts`
- Modify: `src/config/auth.ts`

- [ ] **Step 1: Write failing unit tests for refresh-token entropy, deterministic hashing, JWT claims, and expiry constants**

```ts
test('refresh tokens are opaque and hashes are deterministic', () => {
  const token = createRefreshToken();
  assert.match(token, /^[A-Za-z0-9_-]{43}$/);
  assert.equal(hashRefreshToken(token), hashRefreshToken(token));
  assert.notEqual(hashRefreshToken(token), token);
});

test('registered access token carries user, role, and session identity', () => {
  const token = createAccessToken({ userId, role: 'REGISTERED', sessionId });
  const payload = verifyAccessToken(token);
  assert.deepEqual(
    { userId: payload.userId, role: payload.role, sessionId: payload.sessionId },
    { userId, role: 'REGISTERED', sessionId },
  );
});
```

- [ ] **Step 2: Run `rtk npm test -- --test-name-pattern="refresh tokens|registered access"` and confirm failure because the service does not exist**

- [ ] **Step 3: Implement `createRefreshToken`, SHA-256 `hashRefreshToken`, 15-minute `createAccessToken`, `verifyAccessToken`, and exported 90-day duration constants using `node:crypto` and the existing JWT secret**

- [ ] **Step 4: Run the focused tests and `rtk npm run build`; expect zero failures**

### Task 2: Persist rotating device sessions

**Files:**
- Modify: `prisma/schema.prisma`
- Create: `prisma/migrations/20260812000000_auth_refresh_sessions/migration.sql`
- Create: `src/domain/services/authSessionService.ts`
- Create: `tests/authSessionService.test.ts`

- [ ] **Step 1: Add a failing service test using an injected in-memory session store**

```ts
const first = await service.create(user, 'Pixel Emulator');
const rotated = await service.refresh(first.refreshToken);
await assert.rejects(service.refresh(first.refreshToken), /INVALID_REFRESH_TOKEN/);
assert.equal(verifyAccessToken(rotated.accessToken).sessionId, first.sessionId);
await service.revoke(rotated.refreshToken);
await assert.rejects(service.refresh(rotated.refreshToken), /INVALID_REFRESH_TOKEN/);
```

- [ ] **Step 2: Add `AuthSession` with UUID ID, user relation, unique refresh-token hash, optional device name, expiry/revocation/last-used timestamps, indexes, and cascade delete**

- [ ] **Step 3: Write migration SQL that creates the table, foreign key, unique hash index, and active-user lookup index without modifying existing users or tickets**

- [ ] **Step 4: Implement creation, atomic rotation, expiry checks, and idempotent revocation behind a small `AuthSessionStore` interface; provide the Prisma store as the production adapter**

- [ ] **Step 5: Run `rtk npx prisma validate`, the focused service test, full backend tests, and TypeScript build**

### Task 3: Expose register, login, refresh, and logout contracts

**Files:**
- Modify: `src/presentation/controllers/authController.ts`
- Modify: `src/presentation/routes/authRoutes.ts`
- Modify: `src/presentation/middlewares/authMiddleware.ts`
- Modify: `src/types/express.d.ts`
- Create: `tests/authController.test.ts`

- [ ] **Step 1: Write failing controller/schema tests for required registration name, optional phone/device name, login, refresh, logout, and generic invalid credentials**

```ts
assert.equal(registerSchema.safeParse({ name: 'Riyadh', email, password }).success, true);
assert.equal(registerSchema.safeParse({ email, password }).success, false);
assert.equal(refreshSchema.safeParse({ refreshToken: 'short' }).success, false);
```

- [ ] **Step 2: Return `{ user, accessToken, refreshToken, accessTokenExpiresIn: 900 }` from register/login, create a device session, and keep password hashes out of every response**

- [ ] **Step 3: Add `POST /refresh` and `POST /logout`; refresh rotates atomically and logout is idempotent**

- [ ] **Step 4: Require `sessionId` for registered JWT payloads while preserving the existing guest-token shape**

- [ ] **Step 5: Add IP/email login and registration limits of 10 per 15 minutes plus refresh limit of 30 per 15 minutes using `express-rate-limit`**

- [ ] **Step 6: Run controller tests, all backend tests, and TypeScript build**

### Task 4: Derive authenticated ticket ownership server-side

**Files:**
- Modify: `src/presentation/controllers/ticketController.ts`
- Modify: `src/presentation/routes/ticketRoutes.ts`
- Modify: `src/presentation/middlewares/authMiddleware.ts`
- Create: `tests/ticketOrderAuth.test.ts`

- [ ] **Step 1: Write failing tests showing guest contact checkout remains valid, registered ownership comes from `req.auth.userId`, and a body `userId` is ignored/rejected**

- [ ] **Step 2: Add `optionalAuth`: no Authorization header continues anonymously; a supplied invalid token is rejected rather than silently treated as guest**

- [ ] **Step 3: Remove client `userId` authority from the order schema, require contact email/phone only for guests, and derive `userId` from verified registered access**

- [ ] **Step 4: Run ticket/auth tests, all backend tests, and TypeScript build**

### Task 5: Build Flutter account data and secure credential layers

**Files:**
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/pubspec.yaml`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/domain/entities/account_user.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/domain/entities/auth_session.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/domain/repositories/auth_repository.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/data/models/auth_session_model.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/data/datasources/auth_remote_data_source.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/data/datasources/auth_secure_store.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/data/repositories/auth_repository_impl.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/test/auth_remote_data_source_test.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/test/auth_repository_test.dart`

- [ ] **Step 1: Add `flutter_secure_storage` and run `rtk proxy C:\src\flutter\bin\flutter.bat pub get`**

- [ ] **Step 2: Write failing JSON/HTTP tests for register, login, refresh, logout, profile parsing, stable error codes, and Authorization headers**

- [ ] **Step 3: Implement immutable account/session models and the repository contract**

- [ ] **Step 4: Implement API calls against `/auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout`, and `/profile`; never log request credentials**

- [ ] **Step 5: Implement secure-store keys for refresh token, cached public profile, and encrypted pending-revocation token; never persist password or access token**

- [ ] **Step 6: Implement repository bootstrap: no token returns guest, valid token refreshes, network failure returns cached offline account, invalid token clears session, and logout queues failed revocation**

- [ ] **Step 7: Run the focused Dart tests and `flutter analyze`**

### Task 6: Add application-scoped authentication state and single-flight refresh

**Files:**
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/presentation/controllers/auth_controller.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/presentation/widgets/auth_scope.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/core/network/authenticated_api_client.dart`
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/main.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/test/auth_controller_test.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/test/authenticated_api_client_test.dart`

- [ ] **Step 1: Write failing controller tests for guest bootstrap, silent restore, offline-authenticated restore, login, register, and manual logout**

- [ ] **Step 2: Write a failing client test where two simultaneous 401 responses share exactly one refresh Future and each request is retried once**

- [ ] **Step 3: Implement explicit restoring, guest, submitting, authenticated, offline-authenticated, and error states without using a third-party state-management package**

- [ ] **Step 4: Implement the authenticated API client with Bearer attachment, one shared refresh operation, one replay maximum, and no credentials for foreign hosts**

- [ ] **Step 5: Initialize the controller once in `MyApp`, expose it through `AuthScope`, call bootstrap after binding initialization, and dispose it with the application**

- [ ] **Step 6: Run focused tests and `flutter analyze`**

### Task 7: Implement login, registration, account profile, and logout UI

**Files:**
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/presentation/pages/login_page.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/presentation/pages/register_page.dart`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/account/presentation/pages/edit_profile_page.dart`
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/profile/presentation/pages/profile_page.dart`
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/profile/presentation/pages/language_page.dart`
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/features/profile/presentation/pages/accessibility_page.dart`
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/core/routing/router.dart`
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/l10n/app_id.arb`
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/lib/l10n/app_en.arb`
- Create: `C:/Users/riyadh/Downloads/KAIACCES/timetable/test/account_pages_test.dart`

- [ ] **Step 1: Write widget tests proving guest messaging says ticket purchase works without login and the login/register/profile states expose the approved controls**

- [ ] **Step 2: Add localized account strings in Indonesian and English and regenerate localization output through `flutter gen-l10n`**

- [ ] **Step 3: Build accessible login/register forms with inline validation, password visibility state, disabled loading buttons, back-to-guest navigation, and no fake forgot-password action**

- [ ] **Step 4: Make `ProfilePage` react to `AuthScope`: guest card and `Masuk atau Buat Akun` when guest; name/email, edit profile, account history, and logout when authenticated**

- [ ] **Step 5: Add `/masuk`, `/daftar`, and `/edit-profil` routes without redirecting guest users away from other application pages**

- [ ] **Step 6: Persist registered language/accessibility changes through `PATCH /profile`, retain local changes on network failure, and keep guest settings local**

- [ ] **Step 7: Run account widget tests, existing route/station tests, and `flutter analyze`**

### Task 8: Migration, end-to-end verification, and documentation

**Files:**
- Modify: `README.md`
- Modify: `C:/Users/riyadh/Downloads/KAIACCES/timetable/README.md`

- [ ] **Step 1: Generate Prisma Client, apply the auth-session migration to the configured development database, and verify the table/indexes through Prisma**

- [ ] **Step 2: Exercise register → profile → refresh → profile → logout with HTTP requests and confirm the rotated old refresh token is rejected**

- [ ] **Step 3: Verify guest route and guest ticket-order contracts still work without an account**

- [ ] **Step 4: Run `rtk npm test`, `rtk npm run build`, `rtk npx prisma validate`, focused/full relevant Flutter tests, `flutter analyze`, and the Gradle 9.1 debug APK build**

- [ ] **Step 5: Install the APK on the emulator and manually verify guest account, register, persistent restart, login, offline preservation, profile update, and logout**

- [ ] **Step 6: Document the token lifetimes, secure-storage behavior, new endpoints, guest invariants, migration command, and Android Studio test instructions without recording any secrets**

