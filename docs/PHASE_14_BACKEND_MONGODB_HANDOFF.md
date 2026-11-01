# English Udaan — Phase 14 Backend/MongoDB Handoff

## Implementation

### Summary

Phase 14 establishes a secure, testable MongoDB/Mongoose foundation for the existing Node.js/Express backend. The server can start safely with or without a real Atlas connection. When `MONGODB_URI` is absent the server logs a clear warning; when it is present it connects on startup and closes the connection cleanly on shutdown. All configuration validation, connection lifecycle, Mongoose schemas, health/readiness endpoints, and tests are in place.

**Live Atlas connection verified by owner on 2026-10-15.** The owner configured `backend/.env`, started the server with `npm run dev`, observed `Connected to MongoDB.` in logs, and confirmed `GET /health` returned `database.connected: true`. `GET /health/readiness` returned HTTP 200. No secrets were committed or logged.

### Files changed

| File | Change |
|---|---|
| `backend/package.json` | Added `mongoose` production dependency |
| `backend/package-lock.json` | Updated lockfile |
| `backend/.env.example` | Added `MONGODB_URI` placeholder with Atlas format comment |
| `backend/src/config/environment.js` | Added optional `MONGODB_URI` field to Zod schema |
| `backend/src/config/database.js` | **New** — `connectDatabase`, `disconnectDatabase`, `getConnectionStatus`, `isConnected` |
| `backend/src/models/image-ref.js` | **New** — `ImageRef` Mongoose schema (itemId, category, englishLabel, urduLabel, sourceType, assetPath/remoteUrl, attributionNote) |
| `backend/src/models/user-progress.js` | **New** — `UserProgress` Mongoose schema (deviceId, sections[], quizResults[], streaks, lastActivityDate) |
| `backend/src/routes/health.js` | Extended — `GET /health` includes `database.status` and `database.connected`; added `GET /health/readiness` |
| `backend/src/app.js` | Extended — `createApp` accepts optional `db` parameter |
| `backend/src/server.js` | Extended — connects to DB on startup (with warning if absent), SIGTERM/SIGINT graceful shutdown |
| `backend/test/database.test.js` | **New** — 8 tests for environment validation and database connection error handling |
| `backend/test/health.test.js` | Replaced — 7 tests covering health/readiness with and without DB, not-found route |
| `backend/test/models.test.js` | **New** — 12 tests for ImageRef and UserProgress schema validation |
| `docs/IMPLEMENTATION_MAP.md` | Updated phase status and backend description |
| `docs/PHASE_14_BACKEND_MONGODB_HANDOFF.md` | This document |

### Environment variable names

| Variable | Required | Description |
|---|---|---|
| `NODE_ENV` | Yes (defaulted) | `development` / `test` / `production` |
| `PORT` | Yes (defaulted to 3000) | TCP port the server listens on |
| `CORS_ORIGIN` | Yes (defaulted) | Allowed CORS origin |
| `MONGODB_URI` | No at start; needed for DB features | Full Atlas connection string |

**Backend environment file location:** `backend/.env` (ignored by Git via `.gitignore`)

### MongoDB connection lifecycle

- `connectDatabase(uri)` — connects via Mongoose; throws a clear actionable error if URI is empty/null/undefined; throws a connection error if the URI is invalid or the cluster is unreachable.
- `disconnectDatabase()` — closes the connection cleanly (called during shutdown).
- `getConnectionStatus()` — returns a human-readable state string (`disconnected`, `connected`, `connecting`, `disconnecting`, `uninitialized`, `unconfigured`).
- `isConnected()` — returns `true` only when `readyState === 1`.

### Mongoose schemas

**`ImageRef`** (collection: `image_refs`):
- Stores image references and metadata for picture-learning content.
- Fields: `itemId` (indexed), `category` (indexed), `englishLabel`, `urduLabel`, `sourceType` (`local` | `remote`), `assetPath` (required when local), `remoteUrl` (required when remote), `attributionNote`.
- Compound unique index: `{ category, itemId }`.
- Does **not** store image binaries.

**`UserProgress`** (collection: `user_progress`):
- Stores per-device learning progress pending Phase 15 per-user auth.
- Fields: `deviceId` (unique index), `sections[]` (section name from `VALID_SECTIONS` enum, `completed`, `completedAt`), `quizResults[]` (category, score, total, playedAt), `currentStreak`, `longestStreak`, `lastActivityDate`.
- `VALID_SECTIONS` covers all current learning sections (alphabet, vocabulary 2–5 letter, picture categories, sentences, grammar).

### Health/readiness endpoints

**`GET /health`** — Always returns 200; indicates server is up. Now includes:
```json
{
  "success": true,
  "data": {
    "service": "english-udaan-api",
    "status": "ok",
    "environment": "development",
    "database": {
      "status": "connected",
      "connected": true
    }
  }
}
```
`database.status` is `"unconfigured"` when no `db` module is passed, `"disconnected"` / `"connected"` based on Mongoose readyState otherwise.

**`GET /health/readiness`** — Returns 200 only when the database is connected; returns 503 otherwise. Use this endpoint for load-balancer or orchestrator readiness checks.

### Startup behavior

- If `MONGODB_URI` is set: connects on startup; logs success or non-fatal error (server keeps running).
- If `MONGODB_URI` is absent: logs a clear warning; server starts normally; database features are unavailable.
- Secrets are never logged or included in error responses.

### Graceful shutdown

Handles `SIGTERM` and `SIGINT`: closes the HTTP server, then closes the Mongoose connection before exiting.

---

## Validation

### Commands executed

```
npm test
```

### Actual test results

```
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
✔ UserProgress schema requires deviceId
✔ UserProgress schema accepts valid document with defaults
✔ UserProgress rejects invalid section name
✔ UserProgress accepts valid section progress
✔ UserProgress rejects negative streak

tests 27 | pass 27 | fail 0
```

### Known issues and notes

- **Live connection verified:** Live MongoDB Atlas connection verified successfully (`GET /health` reports `database.connected: true`, `GET /health/readiness` returns HTTP 200).
- **Environment security:** `backend/.env` is correctly ignored by Git (`.gitignore`); no secrets have been committed or logged.
- **nodemon audit warnings:** 3 high-severity vulnerabilities in `nodemon` (dev-only dependency, pre-existing). Not related to Phase 14 changes. Do not run `npm audit fix --force` as it would downgrade nodemon to a breaking version.
- **Flutter tests:** Not run in this phase — no Flutter code was changed. Existing Flutter test state is documented in Phase 13 handoff.

---

## Manual Atlas setup instructions

You will need to complete these steps to establish a real MongoDB Atlas connection:

1. **Create an Atlas account** at [cloud.mongodb.com](https://cloud.mongodb.com) if you don't have one.
2. **Create a new Project** (e.g. "English Udaan").
3. **Create a Cluster** — choose "M0 Free Tier" for development.
4. **Create a database user:**
   - Go to Database Access → Add New Database User.
   - Username: `english-udaan-dev` (or your choice).
   - Password: generate a strong password and save it securely.
   - Role: "Read and write to any database" for development.
5. **Set network access:**
   - Go to Network Access → Add IP Address.
   - For development: add your current IP or allow `0.0.0.0/0` (restrict for production).
6. **Get the connection string:**
   - Click "Connect" on your cluster → "Drivers" → Node.js.
   - Copy the connection string. It will look like:
     `mongodb+srv://english-udaan-dev:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority`
7. **Create `backend/.env`** (never commit this file):
   ```
   NODE_ENV=development
   PORT=3000
   CORS_ORIGIN=http://localhost:3000
   MONGODB_URI=mongodb+srv://english-udaan-dev:<password>@cluster0.xxxxx.mongodb.net/english-udaan?retryWrites=true&w=majority
   ```
   Replace `<password>` with your actual password and `cluster0.xxxxx` with your real cluster hostname.
8. **Start the server:** `npm run dev` — you should see `Connected to MongoDB.` in the logs.
9. **Verify:** `GET http://localhost:3000/health` should show `"database": { "status": "connected", "connected": true }`.
10. **Verify readiness:** `GET http://localhost:3000/health/readiness` should return 200.

---

## Regression

- No Flutter code was changed. All existing Phase 6–13 Flutter functionality remains intact.
- The existing `GET /health` basic test was extended (not weakened) — the response shape now includes a `database` field.

---

## Next step

Per `PHASE_INSTRUCTIONS.md`, the next task is **Phase 15 — Auth/cloud progress APIs**.

Phase 15 requires a decision on authentication method/provider (not yet approved). The approved decision must be obtained before Phase 15 implementation begins.

Phase 15 scope: registration, login, session management, password hashing, protected endpoints, per-user progress, validation/rate limits, and sync semantics.
