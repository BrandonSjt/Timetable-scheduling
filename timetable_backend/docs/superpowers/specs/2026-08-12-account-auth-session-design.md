# Account Authentication and Persistent Session Design

Date: 2026-08-12
Status: Approved design, awaiting written-spec review
Scope: Express/Prisma backend and Flutter mobile account integration

## 1. Objective

Add an optional account experience without restricting the existing guest
experience. Registered users remain signed in across application restarts,
while guests retain access to every core travel and payment feature.

The account feature is supplementary. It must not become a prerequisite for
station search, schedules, route planning, ticket purchase, Xendit checkout,
or opening locally retained guest tickets.

## 2. Confirmed Product Decisions

- Guest access remains the default when no registered-user session exists.
- Guests may search stations and schedules, plan routes, purchase tickets,
  complete Xendit payments, and open ticket QR codes.
- Phase one authentication uses email and password only.
- Registration requires name, email, password, and password confirmation in
  the mobile form. Phone number is optional.
- Password length remains at least eight characters.
- A successful registration signs the user in immediately.
- Registered users stay signed in while the application is used within the
  rolling 90-day refresh window, unless they explicitly log out or their
  refresh session is revoked for security.
- Guest tickets purchased before login are not automatically attached to the
  account in phase one.
- Logging out never deletes locally retained guest tickets, device language,
  or device accessibility preferences.
- Forgot-password, email verification, Google login, OTP login, and guest
  ticket claiming are excluded from phase one.

## 3. Recommended Architecture

Use short-lived JWT access tokens and opaque, rotating refresh tokens.

### 3.1 Access token

- JWT lifetime: 15 minutes.
- Contains the registered user ID, role, and a session identifier.
- Sent only to authenticated API routes using
  `Authorization: Bearer <access-token>`.
- Kept in application memory during normal use.
- A stolen access token has a limited useful lifetime.

### 3.2 Refresh token

- Opaque, cryptographically random value rather than a long-lived JWT.
- Sliding lifetime: 90 days from the latest successful refresh.
- Stored encrypted on the mobile device using platform-backed secure storage.
- Stored in PostgreSQL only as a one-way hash.
- Bound to one server-side device session.
- Rotated on every successful refresh. The previous token becomes invalid
  immediately.
- Never sent to ordinary resource endpoints; it is sent only to the refresh
  and logout endpoints.

### 3.3 Multiple devices

Each login creates an independent refresh session. Logging out revokes only the
current device session. Other logged-in devices remain active. The model must
support revoking all sessions later without making it part of the phase-one UI.

## 4. Backend Design

### 4.1 Prisma session entity

Add an authentication session entity with these responsibilities:

- Stable UUID primary key used as the access-token session identifier.
- Registered user relation with cascade deletion.
- Hash of the current refresh token; the raw token is never persisted.
- Expiration timestamp.
- Revocation timestamp or equivalent revoked state.
- Created, last-used, and updated timestamps.
- Optional device label or user-agent metadata for future session management.

Indexes must support lookup by refresh-token hash and listing active sessions
by user. Expired and revoked sessions must never issue new tokens.

### 4.2 Authentication endpoints

#### `POST /api/v1/auth/register`

Input:

- `name`: required, trimmed, 2-100 characters.
- `email`: required and normalized to lowercase.
- `password`: required, 8-100 characters.
- `phone`: optional, 8-20 characters.
- `deviceName`: optional metadata.

Output contains the public user profile, a 15-minute access token, and one
opaque refresh token. Passwords continue to use bcrypt with the existing work
factor.

#### `POST /api/v1/auth/login`

Input contains normalized email, password, and optional device metadata. A
successful login creates a new device session and returns the same session
envelope as registration. Invalid credentials use one generic response so the
endpoint does not disclose whether an email exists.

#### `POST /api/v1/auth/refresh`

Input contains the current refresh token. The backend hashes it, finds the
active unexpired session, rotates the token atomically, extends the sliding
expiry to 90 days, and returns a new access/refresh token pair.

Concurrent refreshes for the same token must have a single winner. Reuse of an
already rotated token is rejected. The implementation should revoke the
affected session when token reuse indicates a possible credential leak.

#### `POST /api/v1/auth/logout`

Input contains the current refresh token. The matching session is revoked and
the response is idempotent. Mobile clears the active local account state even
if the network request cannot complete. In that case, it stores the token only
as an encrypted pending-revocation record that cannot be reused for login,
retries revocation when connectivity returns, and deletes the record after a
successful or definitively invalid response.

#### `POST /api/v1/auth/guest`

The existing guest endpoint remains available for backend operations that need
a guest role. Guest identity is not presented as a registered-user session and
must not block anonymous public endpoints or guest ticket purchase.

### 4.3 Profile endpoints

The existing authenticated endpoints remain:

- `GET /api/v1/profile`
- `PATCH /api/v1/profile`

The profile contract includes ID, email, name, phone, role, language,
accessibility preference, and notification preference. Email and password are
not changed by the phase-one profile endpoint.

### 4.4 Authorization boundaries

- Public travel endpoints remain usable without a registered account.
- Guest ticket ordering continues to accept contact email or contact phone.
- Tickets ordered after registered login include the authenticated `userId`.
- Ticket ownership must come from verified access-token identity, not a
  client-supplied user ID, once the mobile account integration is enabled.
- Xendit secret credentials remain exclusively in the backend.

## 5. Flutter Architecture

Follow the existing layered feature structure:

- Domain: account entity, authentication state, repository interface, and
  explicit failures.
- Data: JSON models, authentication remote data source, secure token store, and
  repository implementation.
- Presentation: a single application-scoped authentication controller plus
  login, registration, authenticated profile, and logout UI states.

### 5.1 Session bootstrap

At application startup:

1. Read the refresh token from secure storage.
2. If none exists, enter guest mode immediately.
3. If one exists, attempt refresh in the background.
4. A network failure enters an offline-authenticated state using the last safe
   cached profile; it does not silently convert the user to guest.
5. A definitive invalid/revoked refresh response clears credentials and shows
   a login-required state while preserving local tickets and preferences.

### 5.2 Authenticated HTTP client

Use one shared API client for account-protected requests:

- Adds the access-token Authorization header.
- On an authentication-expired response, coordinates one refresh operation
  even when several requests fail concurrently.
- Replays each failed request at most once after refresh.
- Never loops indefinitely on repeated authorization failures.
- Does not attach credentials to Xendit hosted-checkout URLs or other external
  domains.

### 5.3 Secure storage

Use a maintained Flutter secure-storage package backed by Android Keystore.
Persist the refresh token and minimal session metadata only. Do not store the
password. Access tokens remain in memory and are regenerated after restart.

## 6. Mobile UI Design

Retain the current indigo header, white card system, typography, spacing, and
rounded-corner visual language.

### 6.1 Guest account page

- Continue to show the guest identity card.
- Replace the placeholder interaction with a clear `Masuk atau Buat Akun`
  action.
- State explicitly that purchasing tickets remains available without login.
- Keep local ticket history, language, accessibility, and help-center entries.

### 6.2 Login page

- Email field with email keyboard and validation.
- Password field with show/hide control.
- Primary `Masuk` action with a non-duplicating loading state.
- `Belum punya akun? Daftar` navigation.
- Back navigation returns to guest mode without authentication pressure.
- Forgot-password is not shown as a working feature in phase one.

### 6.3 Registration page

- Required name, email, password, and password-confirmation fields.
- Optional phone field.
- Password show/hide control and inline validation.
- Primary `Buat Akun` action.
- Link back to login.
- A successful registration returns to the authenticated account page.

### 6.4 Authenticated account page

- Header displays the registered user's name and email.
- Profile card replaces the guest card.
- Provide profile editing, account ticket history, language, accessibility,
  and help-center navigation.
- Place `Keluar dari Akun` as a deliberate secondary/destructive action near
  the bottom of the account content.
- Local guest tickets remain accessible separately and are not represented as
  account-owned tickets.

### 6.5 Accessibility

- All fields have semantic labels and error relationships.
- Password visibility controls expose correct accessibility state.
- Loading and error changes are announced to assistive technologies.
- Profile accessibility and language changes are persisted to the backend for
  registered users and remain locally available for guests/offline use.

## 7. Error and Offline Behavior

- Duplicate email, invalid credentials, malformed fields, and weak passwords
  map to stable user-facing messages.
- Network failures preserve the last known account state and provide retry.
- Access-token expiry is normally invisible because refresh happens
  automatically.
- A revoked/expired refresh session requires login again but never deletes
  device-owned guest data.
- Login/register buttons cannot submit twice while a request is active.
- Server error details, tokens, passwords, and authorization headers are never
  written to application logs or shown in UI messages.
- Logout clears local credentials even if server revocation is temporarily
  unreachable; the revocation request may be retried without restoring the
  local account state.

## 8. Ticket and Payment Interaction

- Guest checkout uses contact email or phone and no registered-user ID.
- Authenticated checkout derives the registered user from the access token.
- The client never supplies price as an authority; backend route and fare logic
  remains authoritative.
- Xendit checkout continues through the backend-created Payment Session and
  hosted payment URL.
- Authentication changes must not place the Xendit secret key in Flutter.
- Guest tickets created before login remain device/contact-based in phase one.

## 9. Security Requirements

- Refresh tokens use cryptographically secure random bytes with sufficient
  entropy and are stored only as hashes server-side.
- Refresh rotation is atomic and resistant to concurrent reuse.
- Access and refresh secrets are redacted from logs and error reporting.
- In addition to the global API limiter, login and registration allow at most
  10 attempts per 15 minutes per IP, with login also grouped by normalized
  email. Refresh allows at most 30 attempts per 15 minutes per IP and applies
  the one-time rotation rules independently of the limiter.
- Authentication responses use generic credential errors.
- All production traffic uses HTTPS.
- Mobile stores refresh credentials only in platform secure storage.
- Server authorization uses verified JWT identity and does not trust arbitrary
  client-provided ownership identifiers.

## 10. Testing and Acceptance Criteria

### Backend

- Register creates a user, session, and valid token pair.
- Duplicate email is rejected without leaking sensitive details.
- Login succeeds with correct credentials and fails generically otherwise.
- Refresh rotates the token, extends expiry, and invalidates the old token.
- Concurrent refresh allows only one successful rotation.
- Reused, revoked, expired, malformed, and unknown refresh tokens are rejected.
- Logout is idempotent and revokes only the current device session.
- Access tokens authorize profile endpoints and expire as configured.
- Guest travel and ticket APIs remain available according to their existing
  public/contact-based contracts.
- Authenticated ticket ownership is derived from access-token identity.

### Flutter

- App with no stored session opens in guest mode.
- Valid stored session refreshes without showing a login page.
- Network failure does not silently log the user out.
- Login and registration validation and loading states work correctly.
- Secure token storage never stores a password.
- Several simultaneous unauthorized requests trigger one refresh operation.
- Successful refresh retries each request once.
- Logout returns to guest mode while retaining local tickets and preferences.
- Guest users can still enter the ticket and Xendit checkout flow.
- Account and form UI remain usable with screen readers and large text.

## 11. Explicitly Out of Scope

- Forgot-password and password-reset email delivery.
- Email verification.
- Google, Apple, or other social login.
- SMS/WhatsApp OTP login.
- Moving or claiming historical guest tickets into an account.
- A user-facing list of all active devices or remote device logout.
- Administrative account management.
