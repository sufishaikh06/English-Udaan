/**
 * Phase 15 — Auth middleware tests.
 *
 * Uses mocks for Firebase Admin so no real Firebase project or credentials
 * are needed. All tests run fully offline.
 */

const assert = require('node:assert/strict');
const test = require('node:test');
const request = require('supertest');

const { createApp } = require('../src/app');
const { extractBearerToken } = require('../src/middleware/auth');

// ---------------------------------------------------------------------------
// Test environment
// ---------------------------------------------------------------------------

const testEnvironment = {
  NODE_ENV: 'test',
  PORT: 3000,
  CORS_ORIGIN: 'http://localhost:3000',
  // FIREBASE_PROJECT_ID intentionally omitted — we inject firebaseAuth directly.
};

// ---------------------------------------------------------------------------
// Firebase Auth mock factory
// ---------------------------------------------------------------------------

/**
 * Build a minimal mock of firebase-admin Auth that passes or fails token
 * verification as instructed.
 *
 * @param {{ uid?: string, email?: string, name?: string, failWith?: Error }} opts
 */
function buildMockAuth({ uid = 'uid-test-123', email = 'test@example.com', name = 'Test User', failWith = null } = {}) {
  return {
    verifyIdToken: async (_token, _checkRevoked) => {
      if (failWith) throw failWith;
      return { uid, email, email_verified: true, name };
    },
  };
}

// ---------------------------------------------------------------------------
// extractBearerToken unit tests
// ---------------------------------------------------------------------------

test('extractBearerToken returns null when Authorization header is absent', () => {
  assert.equal(extractBearerToken({ headers: {} }), null);
});

test('extractBearerToken returns null when header is not Bearer', () => {
  assert.equal(extractBearerToken({ headers: { authorization: 'Basic abc123' } }), null);
});

test('extractBearerToken returns null when token part is empty', () => {
  assert.equal(extractBearerToken({ headers: { authorization: 'Bearer ' } }), null);
});

test('extractBearerToken returns the token string when valid', () => {
  const token = 'my.firebase.token';
  assert.equal(extractBearerToken({ headers: { authorization: `Bearer ${token}` } }), token);
});

// ---------------------------------------------------------------------------
// GET /api/me — auth middleware integration tests
// ---------------------------------------------------------------------------

test('GET /api/me returns 401 when Authorization header is absent', async () => {
  const app = createApp({ environment: testEnvironment, firebaseAuth: buildMockAuth() });
  const response = await request(app).get('/api/me');

  assert.equal(response.status, 401);
  assert.equal(response.body.success, false);
  assert.equal(response.body.error.code, 'MISSING_AUTH_TOKEN');
});

test('GET /api/me returns 401 when token verification fails with invalid-token error', async () => {
  const error = Object.assign(new Error('Token is invalid.'), { code: 'auth/invalid-id-token' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: buildMockAuth({ failWith: error }) });
  const response = await request(app)
    .get('/api/me')
    .set('Authorization', 'Bearer bad.token.here');

  assert.equal(response.status, 401);
  assert.equal(response.body.success, false);
  assert.equal(response.body.error.code, 'INVALID_AUTH_TOKEN');
  // Raw Firebase error message must NOT be forwarded.
  assert.ok(!response.body.error.message.includes('Token is invalid.'));
});

test('GET /api/me returns 401 when token has expired', async () => {
  const error = Object.assign(new Error('Token expired.'), { code: 'auth/id-token-expired' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: buildMockAuth({ failWith: error }) });
  const response = await request(app)
    .get('/api/me')
    .set('Authorization', 'Bearer expired.token');

  assert.equal(response.status, 401);
  assert.equal(response.body.error.code, 'INVALID_AUTH_TOKEN');
  assert.ok(response.body.error.message.toLowerCase().includes('expired'));
});

test('GET /api/me returns 401 when token has been revoked', async () => {
  const error = Object.assign(new Error('Token revoked.'), { code: 'auth/id-token-revoked' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: buildMockAuth({ failWith: error }) });
  const response = await request(app)
    .get('/api/me')
    .set('Authorization', 'Bearer revoked.token');

  assert.equal(response.status, 401);
  assert.equal(response.body.error.code, 'INVALID_AUTH_TOKEN');
});

test('GET /api/me returns verified profile when token is valid', async () => {
  const app = createApp({
    environment: testEnvironment,
    firebaseAuth: buildMockAuth({ uid: 'uid-abc', email: 'user@example.com', name: 'Alice' }),
  });
  const response = await request(app)
    .get('/api/me')
    .set('Authorization', 'Bearer valid.token');

  assert.equal(response.status, 200);
  assert.equal(response.body.success, true);
  assert.equal(response.body.data.uid, 'uid-abc');
  assert.equal(response.body.data.email, 'user@example.com');
  assert.equal(response.body.data.displayName, 'Alice');
  assert.equal(response.body.data.emailVerified, true);
  // Must NOT expose internal token fields.
  assert.equal(response.body.data.firebase, undefined);
});

test('GET /api/me does not expose raw decoded token internals', async () => {
  const app = createApp({
    environment: testEnvironment,
    firebaseAuth: buildMockAuth({ uid: 'uid-safe' }),
  });
  const response = await request(app)
    .get('/api/me')
    .set('Authorization', 'Bearer any.token');

  assert.equal(response.status, 200);
  const data = response.body.data;
  assert.equal(data.iat, undefined, 'iat must not be exposed');
  assert.equal(data.exp, undefined, 'exp must not be exposed');
  assert.equal(data.firebase, undefined, 'firebase internals must not be exposed');
});

// ---------------------------------------------------------------------------
// GET /api/progress — unauthorized and happy-path tests (using mocked DB)
// ---------------------------------------------------------------------------

test('GET /api/progress returns 401 when Authorization header is absent', async () => {
  const app = createApp({ environment: testEnvironment, firebaseAuth: buildMockAuth() });
  const response = await request(app).get('/api/progress');

  assert.equal(response.status, 401);
  assert.equal(response.body.error.code, 'MISSING_AUTH_TOKEN');
});

test('GET /api/progress returns 401 when token is invalid', async () => {
  const error = Object.assign(new Error('bad token'), { code: 'auth/invalid-id-token' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: buildMockAuth({ failWith: error }) });
  const response = await request(app)
    .get('/api/progress')
    .set('Authorization', 'Bearer bad.token');

  assert.equal(response.status, 401);
});

// ---------------------------------------------------------------------------
// PUT /api/progress — validation tests (no real DB needed for 4xx responses)
// ---------------------------------------------------------------------------

test('PUT /api/progress returns 401 without auth token', async () => {
  const app = createApp({ environment: testEnvironment, firebaseAuth: buildMockAuth() });
  const response = await request(app)
    .put('/api/progress')
    .send({ sections: [], quizResults: [] });

  assert.equal(response.status, 401);
});

test('PUT /api/progress returns 400 for invalid section name', async () => {
  const auth = buildMockAuth({ uid: 'uid-validate' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: auth });

  const response = await request(app)
    .put('/api/progress')
    .set('Authorization', 'Bearer valid.token')
    .send({
      sections: [{ section: 'not-a-real-section', completed: false }],
      quizResults: [],
      currentStreak: 0,
      longestStreak: 0,
    });

  assert.equal(response.status, 400);
  assert.equal(response.body.success, false);
  assert.equal(response.body.error.code, 'INVALID_PROGRESS_PAYLOAD');
  assert.ok(response.body.error.message.includes('not-a-real-section'));
});

test('PUT /api/progress returns 400 when score exceeds total', async () => {
  const auth = buildMockAuth({ uid: 'uid-score-test' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: auth });

  const response = await request(app)
    .put('/api/progress')
    .set('Authorization', 'Bearer valid.token')
    .send({
      sections: [],
      quizResults: [{ category: 'vocabulary', score: 10, total: 5 }],
      currentStreak: 0,
      longestStreak: 0,
    });

  assert.equal(response.status, 400);
  assert.equal(response.body.error.code, 'INVALID_PROGRESS_PAYLOAD');
  assert.ok(response.body.error.message.includes('score cannot exceed total'));
});

test('PUT /api/progress returns 400 for negative streak', async () => {
  const auth = buildMockAuth({ uid: 'uid-streak-test' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: auth });

  const response = await request(app)
    .put('/api/progress')
    .set('Authorization', 'Bearer valid.token')
    .send({
      sections: [],
      quizResults: [],
      currentStreak: -1,
      longestStreak: 0,
    });

  assert.equal(response.status, 400);
  assert.equal(response.body.error.code, 'INVALID_PROGRESS_PAYLOAD');
});

test('PUT /api/progress returns 400 for duplicate section names', async () => {
  const auth = buildMockAuth({ uid: 'uid-dup-test' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: auth });

  const response = await request(app)
    .put('/api/progress')
    .set('Authorization', 'Bearer valid.token')
    .send({
      sections: [
        { section: 'alphabet', completed: true },
        { section: 'alphabet', completed: false },
      ],
      quizResults: [],
      currentStreak: 0,
      longestStreak: 0,
    });

  assert.equal(response.status, 400);
  assert.equal(response.body.error.code, 'INVALID_PROGRESS_PAYLOAD');
});

test('PUT /api/progress returns 400 for invalid date in lastActivityDate', async () => {
  const auth = buildMockAuth({ uid: 'uid-date-test' });
  const app = createApp({ environment: testEnvironment, firebaseAuth: auth });

  const response = await request(app)
    .put('/api/progress')
    .set('Authorization', 'Bearer valid.token')
    .send({
      sections: [],
      quizResults: [],
      currentStreak: 0,
      longestStreak: 0,
      lastActivityDate: 'not-a-date',
    });

  assert.equal(response.status, 400);
  assert.equal(response.body.error.code, 'INVALID_PROGRESS_PAYLOAD');
});

// ---------------------------------------------------------------------------
// Ownership isolation — validateProgressPayload unit tests
// ---------------------------------------------------------------------------

const { validateProgressPayload } = require('../src/routes/progress');

test('validateProgressPayload rejects non-object body', () => {
  const result = validateProgressPayload('not an object');
  assert.equal(result.valid, false);
  assert.ok(result.error.includes('JSON object'));
});

test('validateProgressPayload rejects unknown section', () => {
  const result = validateProgressPayload({
    sections: [{ section: 'unknown-section', completed: false }],
    quizResults: [],
    currentStreak: 0,
    longestStreak: 0,
  });
  assert.equal(result.valid, false);
  assert.ok(result.error.includes('unknown-section'));
});

test('validateProgressPayload rejects quizResults exceeding 500 entries', () => {
  const quizResults = Array.from({ length: 501 }, (_, i) => ({
    category: 'vocab',
    score: 1,
    total: 10,
  }));
  const result = validateProgressPayload({ sections: [], quizResults, currentStreak: 0, longestStreak: 0 });
  assert.equal(result.valid, false);
  assert.ok(result.error.includes('500'));
});

test('validateProgressPayload accepts a minimal valid payload', () => {
  const result = validateProgressPayload({
    sections: [],
    quizResults: [],
    currentStreak: 0,
    longestStreak: 0,
  });
  assert.equal(result.valid, true);
  assert.deepEqual(result.data.sections, []);
  assert.deepEqual(result.data.quizResults, []);
  assert.equal(result.data.currentStreak, 0);
});

test('validateProgressPayload accepts all valid sections', () => {
  const { VALID_SECTIONS } = require('../src/models/user-progress');
  const sections = VALID_SECTIONS.map((s) => ({ section: s, completed: false }));
  const result = validateProgressPayload({
    sections,
    quizResults: [],
    currentStreak: 5,
    longestStreak: 10,
  });
  assert.equal(result.valid, true);
  assert.equal(result.data.sections.length, VALID_SECTIONS.length);
  assert.equal(result.data.currentStreak, 5);
  assert.equal(result.data.longestStreak, 10);
});

test('validateProgressPayload accepts valid quizResult with all fields', () => {
  const result = validateProgressPayload({
    sections: [],
    quizResults: [
      { category: 'grammar', score: 8, total: 10, playedAt: new Date().toISOString() },
    ],
    currentStreak: 1,
    longestStreak: 1,
    lastActivityDate: new Date().toISOString(),
  });
  assert.equal(result.valid, true);
  assert.equal(result.data.quizResults[0].category, 'grammar');
  assert.equal(result.data.quizResults[0].score, 8);
});

// ---------------------------------------------------------------------------
// Auth-not-configured path
// ---------------------------------------------------------------------------

test('GET /api/me returns 503 when Firebase is not configured', async () => {
  // No firebaseAuth injected and no FIREBASE_PROJECT_ID in environment.
  const app = createApp({ environment: testEnvironment });
  const response = await request(app)
    .get('/api/me')
    .set('Authorization', 'Bearer any.token');

  assert.equal(response.status, 503);
  assert.equal(response.body.error.code, 'AUTH_NOT_CONFIGURED');
});

test('GET /api/progress returns 503 when Firebase is not configured', async () => {
  const app = createApp({ environment: testEnvironment });
  const response = await request(app)
    .get('/api/progress')
    .set('Authorization', 'Bearer any.token');

  assert.equal(response.status, 503);
  assert.equal(response.body.error.code, 'AUTH_NOT_CONFIGURED');
});
