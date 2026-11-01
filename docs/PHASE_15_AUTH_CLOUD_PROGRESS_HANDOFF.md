# English Udaan — Phase 15 Auth/Cloud Progress APIs Handoff

## Implementation

### Summary

Phase 15 adds Firebase Authentication token verification and per-user cloud-progress APIs to the existing Node.js/Express backend. No Flutter packages, login UI, or MongoDB changes were required for this phase.

The approved decisions documented in `prompts.md` are:
- **Authentication provider:** Firebase Authentication.
- **Enabled methods:** Email/password and Google Sign-In (managed by Firebase console; no custom password hashing implemented — Firebase owns identity).
- **Backend:** existing Node.js/Express API.
- **Database:** existing MongoDB Atlas.
- **Guest lesson access and existing local learning progress remain available** — no breaking changes to the Flutter app.
- **Flutter client authentication UI and Firebase package integration belong to Phase 16.**

The Firebase project ID (`english-udaan`) was read from the existing `mobile/android/app/google-services.json`. No secret values were committed.

---

### Files changed

| File | Change |
|---|---|
| `backend/package.json` | Added `firebase-admin` and `express-rate-limit` production dependencies |
| `backend/package-lock.json` | Updated lockfile |
| `backend/.env.example` | **New** — documents all env vars including `FIREBASE_PROJECT_ID` and ADC credential options |
| `backend/.env` | Added `FIREBASE_PROJECT_ID=english-udaan` (non-secret); credential guidance added as comments |
| `backend/src/config/environment.js` | Added optional `FIREBASE_PROJECT_ID` field to Zod schema |
| `backend/src/config/firebase.js` | **New** — `initializeFirebase`, `getFirebaseAuth`, `verifyIdToken`, `_resetForTesting`; ADC-based credential resolution; no service-account key embedded |
| `backend/src/middleware/auth.js` | **New** — `createAuthMiddleware` (Bearer token → verified UID → `req.uid`), `extractBearerToken`; consistent 401 responses; raw Firebase error never forwarded |
| `backend/src/models/user-progress.js` | `firebaseUid` replaces `deviceId` as primary ownership key (unique index, required); `deviceId` retained as optional for backward compatibility; added section array uniqueness validation; added quizResults 500-entry cap |
| `backend/src/routes/profile.js` | **New** — `GET /api/me` — returns uid, email, emailVerified, displayName from decoded token; never exposes iat/exp/firebase internals |
| `backend/src/routes/progress.js` | **New** — `GET /api/progress` (read, returns empty structure when no document exists), `PUT /api/progress` (validated full overwrite); `validateProgressPayload`, `validateSectionEntry`, `validateQuizResultEntry` exported for unit testing |
| `backend/src/app.js` | Wired Firebase Auth resolution, `createAuthMiddleware`, rate limiter (100 req/15 min per IP), `/api/me` and `/api/progress` routes; 503 `AUTH_NOT_CONFIGURED` guard when Firebase is absent |
| `backend/src/server.js` | Firebase Admin initialization on startup using `FIREBASE_PROJECT_ID`; non-fatal warning when absent |
| `backend/test/auth.test.js` | **New** — 27 tests (see below) |
| `backend/test/models.test.js` | Updated 3 tests to use `firebaseUid` instead of `deviceId` |
| `docs/IMPLEMENTATION_MAP.md` | Updated phase status and backend description |
| `docs/PHASE_15_AUTH_CLOUD_PROGRESS_HANDOFF.md` | This document |

---

### Environment variables

| Variable | Required | Secret? | Description |
|---|---|---|---|
| `NODE_ENV` | Yes (defaulted) | No | `development` / `test` / `production` |
| `PORT` | Yes (defaulted 3000) | No | TCP listening port |
| `CORS_ORIGIN` | Yes (defaulted) | No | Allowed CORS origin |
| `MONGODB_URI` | No at start | **Yes** | Full Atlas connection string |
| `FIREBASE_PROJECT_ID` | No at start; needed for auth | No | Firebase project ID (`english-udaan`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | No; needed for real token verification | **Yes (path)** | Absolute path to service-account JSON (never commit the JSON file) |

**`GOOGLE_APPLICATION_CREDENTIALS` or Application Default Credentials must be configured for live Firebase token verification to work.** Tests use mocks and do not require credentials.

---

### API endpoints and request contracts

#### `GET /api/me`

**Auth:** `Authorization: Bearer <Firebase ID token>` (required)

**Response 200:**
```json
{
  "success": true,
  "data": {
    "uid": "firebase-uid-string",
    "email": "user@example.com",
    "emailVerified": true,
    "displayName": "User Name"
  }
}
```

**Response 401 (missing token):**
```json
{
  "success": false,
  "error": { "code": "MISSING_AUTH_TOKEN", "message": "..." }
}
```

**Response 401 (invalid/expired/revoked token):**
```json
{
  "success": false,
  "error": { "code": "INVALID_AUTH_TOKEN", "message": "..." }
}
```

**Response 503 (Firebase not configured):**
```json
{
  "success": false,
  "error": { "code": "AUTH_NOT_CONFIGURED", "message": "..." }
}
```

---

#### `GET /api/progress`

**Auth:** `Authorization: Bearer <Firebase ID token>` (required)

Returns the cloud progress for the authenticated user. Returns an empty structure (HTTP 200) when no document exists — does not create a record automatically.

**Response 200:**
```json
{
  "success": true,
  "data": {
    "firebaseUid": "...",
    "sections": [
      { "section": "alphabet", "completed": true, "completedAt": "2026-10-01T..." }
    ],
    "quizResults": [
      { "category": "vocabulary", "score": 8, "total": 10, "playedAt": "..." }
    ],
    "currentStreak": 3,
    "longestStreak": 7,
    "lastActivityDate": "2026-10-21T...",
    "updatedAt": "2026-10-22T..."
  }
}
```

---

#### `PUT /api/progress`

**Auth:** `Authorization: Bearer <Firebase ID token>` (required)

Overwrites the authenticated user's cloud progress document. The UID is taken from the verified token — never from the request body.

**Request body:**
```json
{
  "sections": [
    { "section": "alphabet", "completed": true, "completedAt": "2026-10-01T..." }
  ],
  "quizResults": [
    { "category": "vocabulary", "score": 8, "total": 10, "playedAt": "..." }
  ],
  "currentStreak": 3,
  "longestStreak": 7,
  "lastActivityDate": "2026-10-21T..."
}
```

Validation rules:
- `sections`: array of valid section names (see `VALID_SECTIONS`); no duplicates; max 16 entries.
- `quizResults`: max 500 entries; `score ≤ total`; `total ≥ 1`.
- `currentStreak`, `longestStreak`: non-negative integers.
- `lastActivityDate`: ISO date string or null/omitted.

**Response 200:** same shape as GET.

**Response 400 (`INVALID_PROGRESS_PAYLOAD`):** input validation failure with descriptive message.

---

### Credential setup — local development

**Recommended (Application Default Credentials):**

1. Install Google Cloud SDK: https://cloud.google.com/sdk/docs/install
2. Run: `gcloud auth application-default login`
3. No further configuration needed — Firebase Admin resolves ADC automatically.
4. Add to `backend/.env`:
   ```
   FIREBASE_PROJECT_ID=english-udaan
   ```

**Alternative (service account key file — never commit):**

1. Firebase Console → Project Settings → Service accounts → Generate new private key.
2. Save the downloaded JSON file **outside** the repository (e.g. `~/secrets/english-udaan-sa.json`).
3. Add to `backend/.env`:
   ```
   FIREBASE_PROJECT_ID=english-udaan
   GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/english-udaan-sa.json
   ```

**`google-services.json` is a client credential for the Flutter app only. It is not a server credential and must not be passed to Firebase Admin.**

---

### Rate limiting

Auth-protected routes (`/api/me`, `/api/progress`) are rate-limited to **100 requests per 15 minutes per IP address**. Responses include standard `RateLimit-*` headers. Tests set `app.locals.skipRateLimit = true` internally via the middleware skip function.

---

### Progress document conflict / merge semantics (Phase 15)

`PUT /api/progress` performs a **full overwrite** (`findOneAndUpdate` with `$set` on all progress fields). This is intentional for Phase 15:

- Simple to implement and test.
- Prevents partial-write corruption.
- Acknowledged limitation: if both local and cloud have newer data, the last `PUT` wins.

**Phase 16** will introduce field-level merge with optimistic concurrency (`updatedAt` comparison) when the Flutter API client is integrated. This is documented, not deferred silently.

---

### Ownership isolation

**One account cannot read or write another account's progress:**

- `GET /api/progress` queries `{ firebaseUid: req.uid }` — `req.uid` is set only by the auth middleware from the verified token.
- `PUT /api/progress` always upserts with `firebaseUid: req.uid` — the `$set` enforces the key regardless of request body content.
- The request body UID field (if present) is ignored entirely for authorization.

---

### User lifecycle

- **Deleted Firebase account:** Firebase SDK will return `auth/user-not-found` during `verifyIdToken`. The middleware returns a generic 401 `INVALID_AUTH_TOKEN` response.
- **Disabled Firebase account:** Firebase SDK returns `auth/user-disabled`. Same 401 response; the user's progress document is left intact in MongoDB for potential account restoration.
- **No second password system:** Firebase owns identity; the backend does not store passwords or issue its own JWTs.

---

## Validation

### Commands executed

```
npm test
```

### Actual test results

```
✔ extractBearerToken returns null when Authorization header is absent
✔ extractBearerToken returns null when header is not Bearer
✔ extractBearerToken returns null when token part is empty
✔ extractBearerToken returns the token string when valid
✔ GET /api/me returns 401 when Authorization header is absent
✔ GET /api/me returns 401 when token verification fails with invalid-token error
✔ GET /api/me returns 401 when token has expired
✔ GET /api/me returns 401 when token has been revoked
✔ GET /api/me returns verified profile when token is valid
✔ GET /api/me does not expose raw decoded token internals
✔ GET /api/progress returns 401 when Authorization header is absent
✔ GET /api/progress returns 401 when token is invalid
✔ PUT /api/progress returns 401 without auth token
✔ PUT /api/progress returns 400 for invalid section name
✔ PUT /api/progress returns 400 when score exceeds total
✔ PUT /api/progress returns 400 for negative streak
✔ PUT /api/progress returns 400 for duplicate section names
✔ PUT /api/progress returns 400 for invalid date in lastActivityDate
✔ validateProgressPayload rejects non-object body
✔ validateProgressPayload rejects unknown section
✔ validateProgressPayload rejects quizResults exceeding 500 entries
✔ validateProgressPayload accepts a minimal valid payload
✔ validateProgressPayload accepts all valid sections
✔ validateProgressPayload accepts valid quizResult with all fields
✔ GET /api/me returns 503 when Firebase is not configured
✔ GET /api/progress returns 503 when Firebase is not configured
✔ loadEnvironment accepts valid environment without MONGODB_URI
✔ loadEnvironment accepts valid environment with MONGODB_URI
✔ loadEnvironment throws on invalid NODE_ENV
✔ loadEnvironment throws on invalid PORT
✔ connectDatabase throws actionable error when URI is empty string
✔ connectDatabase throws actionable error when URI is undefined
✔ connectDatabase throws actionable error when URI is null
✔ connectDatabase rejects with connection error for invalid URI (no real Atlas connection)
✔ GET /health without db returns unconfigured database status
✔ GET /health with disconnected db returns disconnected status
✔ GET /health with connected db returns connected status
✔ GET /health/readiness returns 503 when database not connected
✔ GET /health/readiness returns 200 when database is connected
✔ GET /health/readiness returns 503 when db is not provided
✔ unknown routes return a consistent not-found response
✔ VALID_SECTIONS contains expected section names
✔ ImageRef schema requires itemId
✔ ImageRef schema requires category
✔ ImageRef schema requires englishLabel
✔ ImageRef schema requires sourceType and rejects unknown values
✔ ImageRef schema accepts valid local document
✔ ImageRef schema accepts valid remote document
✔ UserProgress schema requires firebaseUid (Phase 15 ownership key)
✔ UserProgress schema accepts valid document with firebaseUid and defaults
✔ UserProgress rejects invalid section name
✔ UserProgress accepts valid section progress
✔ UserProgress rejects negative streak

tests 53 | pass 53 | fail 0
```

### Real Firebase token verification

Real Firebase ID token verification (with a live Firebase project issuing tokens to a real app) was **not tested** during this implementation. It requires:

1. A configured ADC credential or service-account key.
2. A Firebase-authenticated client (Phase 16) issuing real ID tokens.

All middleware, profile, and progress tests use offline Firebase Admin mocks. The mock faithfully simulates the `verifyIdToken` return shape and error codes documented by Firebase Admin SDK.

### Flutter tests

No Flutter code was changed in Phase 15. Existing Flutter test state is documented in the Phase 13 handoff.

---

## Security considerations

1. **No secrets committed:** `GOOGLE_APPLICATION_CREDENTIALS` path and its target file are excluded from version control. `backend/.env` is git-ignored. The Firebase project ID in `.env` is not a secret.
2. **No raw Firebase errors forwarded:** The `createAuthMiddleware` catches all Firebase exceptions and returns a sanitized 401 with a safe code string. The Firebase error code is logged server-side only.
3. **Credential separation:** `google-services.json` is a Flutter client credential only; it is never read by the backend.
4. **No UID from request body:** The ownership key `firebaseUid` is always set from `req.uid` (middleware-injected from verified token), never from `req.body` or `req.params`.
5. **Rate limiting:** 100 requests/15 min per IP on all auth-protected routes prevents credential-stuffing and brute-force abuse.
6. **Request size limit:** `express.json({ limit: '100kb' })` inherited from Phase 14.
7. **Token revocation checked:** `verifyIdToken(token, true)` — the `checkRevoked` flag is `true`, so revoked tokens are rejected during the network round-trip to Firebase.

---

## Known issues and remaining items

| Item | Status |
|---|---|
| Real Firebase token verification | **Not tested** — requires live credentials (Phase 16 integration) |
| Flutter auth UI (login/register/session) | Phase 16 scope; not started |
| Progress field-level merge / conflict resolution | Phase 16 scope; documented in progress route |
| nodemon 3 dev-dependency audit warnings | Pre-existing; not related to Phase 15 |
| Urdu content review in Flutter learning features | Pre-existing; deferred |
| Physical-device TTS | Not retested; no Flutter changes in Phase 15 |

---

## Regression

- No Flutter code was changed. All existing Phase 6–14 Flutter functionality remains intact.
- All 26 Phase 14 tests continue to pass (53 total: 27 new + 26 existing).
- The `UserProgress` Mongoose schema change (`deviceId` → `firebaseUid` as primary key) is backward-incompatible with Phase 14 documents stored in Atlas using `deviceId` as the unique field. Phase 14 explicitly documented that `deviceId` was a placeholder "pending Phase 15 per-user auth." Existing Phase 14 documents will remain in the collection but will not be linked to Firebase UIDs until Phase 16 client integration provides real UIDs. The `deviceId` field is retained in the schema as optional for this reason.

---

## Next step

Per `PHASE_INSTRUCTIONS.md`, the next task is **Phase 16 — Flutter/backend integration.**

Phase 16 scope:
- Install Flutter Firebase packages (`firebase_core`, `firebase_auth`).
- Implement API client (`http` or `dio`) with secure token storage.
- Wire authentication state into the app shell (login required for cloud features; guest access retained for learning content).
- Integrate `GET /api/me`, `GET /api/progress`, `PUT /api/progress` into Flutter repositories.
- Implement online/offline/retry/sync states.
- Keep local JSON content working without a network connection.
