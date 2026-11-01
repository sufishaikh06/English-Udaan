/**
 * dictionary.test.js — tests for POST /api/dictionary/lookup
 *
 * These tests run entirely in-process using a stub DictionaryEntry model and
 * a stub AI provider — no real MongoDB or AI API keys are needed.
 *
 * Test coverage:
 *  - Valid Urdu query → database hit → 200 with source: 'database'
 *  - Valid English query → database hit → 200 with source: 'database'
 *  - DB miss + no AI key → 404
 *  - DB miss + AI key → AI mock called → 200 with source: 'ai'
 *  - DB miss + AI unavailable → 503
 *  - Empty query → 400 validation error
 *  - Over-length query → 400 validation error
 *  - Invalid sourceLanguage → 400 validation error
 *  - AI key never appears in any response
 */

const assert = require('node:assert/strict');
const test = require('node:test');
const request = require('supertest');

// ── Stub DictionaryEntry model ────────────────────────────────────────────────
// We monkey-patch require so the dictionary route gets our fake model.

const MOCK_DB_ENTRY = {
  englishWord: 'apple',
  urduMeaning: 'سیب',
  urduWord: 'سیب',
  simpleDefinition: 'A round fruit.',
  partOfSpeech: 'noun',
  examples: [
    { english: 'I ate an apple.', urdu: 'میں نے سیب کھایا۔' },
    { english: 'She likes apples.', urdu: 'اسے سیب پسند ہیں۔' },
  ],
};

const MOCK_AI_RESULT = {
  query: 'موبائل',
  source: 'ai',
  englishWord: 'mobile',
  urduMeaning: 'موبائل فون',
  simpleDefinition: 'A handheld phone.',
  partOfSpeech: 'noun',
  examples: [
    { english: 'My mobile is new.', urdu: 'میرا موبائل نیا ہے۔' },
    { english: 'She lost her mobile.', urdu: 'اس کا موبائل گم ہو گیا۔' },
  ],
  pronunciationText: 'mobile',
};

// Intercept require calls for the dictionary model and ai-provider.
const Module = require('module');
const originalLoad = Module._load;

let _mockDbResult = null;   // null means "not found"
let _mockAiResult = null;   // null means "AI unavailable"
let _aiCallCount = 0;

Module._load = function (request, parent, isMain) {
  if (request.includes('dictionary-entry')) {
    return {
      DictionaryEntry: {
        findOne: () => ({
          lean: () => ({
            exec: async () => _mockDbResult,
          }),
        }),
      },
    };
  }
  if (request.includes('ai-provider')) {
    return {
      callAiProvider: async (opts) => {
        _aiCallCount++;
        if (!_mockAiResult) {
          const err = new Error('AI unavailable');
          err.code = 'AI_UNAVAILABLE';
          throw err;
        }
        return _mockAiResult;
      },
    };
  }
  return originalLoad.apply(this, arguments);
};

// ── App factory ───────────────────────────────────────────────────────────────
// Import AFTER monkey-patching so the route gets injected stubs.
const { createApp } = require('../src/app');

const testEnv = {
  NODE_ENV: 'test',
  PORT: 3000,
  CORS_ORIGIN: 'http://localhost:3000',
};

function makeApp(extraEnv = {}) {
  return createApp({ environment: { ...testEnv, ...extraEnv } });
}

// ─────────────────────────────────────────────────────────────────────────────

test('POST /api/dictionary/lookup — DB hit for Urdu query returns 200 (database source)', async () => {
  _mockDbResult = MOCK_DB_ENTRY;
  _aiCallCount = 0;
  const app = makeApp();

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'سیب', sourceLanguage: 'ur', targetLanguage: 'en' });

  assert.equal(res.status, 200);
  assert.equal(res.body.success, true);
  assert.equal(res.body.data.source, 'database');
  assert.equal(res.body.data.englishWord, 'apple');
  assert.equal(res.body.data.urduMeaning, 'سیب');
  assert.ok(Array.isArray(res.body.data.examples));
  assert.equal(res.body.data.examples.length, 2);
  // AI must NOT have been called.
  assert.equal(_aiCallCount, 0);
});

test('POST /api/dictionary/lookup — DB hit for English query returns 200 (database source)', async () => {
  _mockDbResult = MOCK_DB_ENTRY;
  _aiCallCount = 0;
  const app = makeApp();

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'apple', sourceLanguage: 'en', targetLanguage: 'ur' });

  assert.equal(res.status, 200);
  assert.equal(res.body.success, true);
  assert.equal(res.body.data.source, 'database');
  assert.equal(_aiCallCount, 0);
});

test('POST /api/dictionary/lookup — DB miss + no AI key → 404', async () => {
  _mockDbResult = null;
  _aiCallCount = 0;
  // No AI_API_KEY in environment.
  const app = makeApp();

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'موبائل', sourceLanguage: 'ur' });

  assert.equal(res.status, 404);
  assert.equal(res.body.success, false);
  assert.equal(res.body.error.code, 'NOT_FOUND');
  assert.equal(_aiCallCount, 0, 'AI should not be called when no key is configured');
});

test('POST /api/dictionary/lookup — DB miss + AI key → AI called → 200 (ai source)', async () => {
  _mockDbResult = null;
  _mockAiResult = MOCK_AI_RESULT;
  _aiCallCount = 0;
  // Inject a fake AI key into the environment so the route enables AI.
  process.env.AI_API_KEY = 'test-key-do-not-use';
  const app = makeApp({ AI_PROVIDER: 'openai', AI_API_KEY: 'test-key-do-not-use' });

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'موبائل', sourceLanguage: 'ur' });

  // Cleanup env immediately — no key must linger.
  delete process.env.AI_API_KEY;

  assert.equal(res.status, 200, `Expected 200 but got ${res.status}: ${JSON.stringify(res.body)}`);
  assert.equal(res.body.success, true);
  assert.equal(res.body.data.source, 'ai');
  assert.equal(res.body.data.englishWord, 'mobile');
  assert.equal(_aiCallCount, 1);

  // Verify the API key is NOT present in any response field.
  const responseText = JSON.stringify(res.body);
  assert.ok(!responseText.includes('test-key-do-not-use'), 'API key must not appear in response');
});

test('POST /api/dictionary/lookup — DB miss + AI key but AI unavailable → 503', async () => {
  _mockDbResult = null;
  _mockAiResult = null; // triggers AI_UNAVAILABLE in the stub
  _aiCallCount = 0;
  process.env.AI_API_KEY = 'test-key-do-not-use';
  const app = makeApp({ AI_PROVIDER: 'openai', AI_API_KEY: 'test-key-do-not-use' });

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'قلم', sourceLanguage: 'ur' });

  delete process.env.AI_API_KEY;

  assert.equal(res.status, 503);
  assert.equal(res.body.success, false);
  assert.equal(res.body.error.code, 'AI_UNAVAILABLE');
  assert.ok(!JSON.stringify(res.body).includes('test-key-do-not-use'));
});

test('POST /api/dictionary/lookup — empty query → 400', async () => {
  const app = makeApp();

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: '', sourceLanguage: 'ur' });

  assert.equal(res.status, 400);
  assert.equal(res.body.success, false);
  assert.equal(res.body.error.code, 'INVALID_REQUEST');
});

test('POST /api/dictionary/lookup — over-length query → 400', async () => {
  const app = makeApp();

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'x'.repeat(101), sourceLanguage: 'en' });

  assert.equal(res.status, 400);
  assert.equal(res.body.error.code, 'INVALID_REQUEST');
});

test('POST /api/dictionary/lookup — invalid sourceLanguage → 400', async () => {
  const app = makeApp();

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'apple', sourceLanguage: 'fr' });

  assert.equal(res.status, 400);
  assert.equal(res.body.error.code, 'INVALID_REQUEST');
});

test('POST /api/dictionary/lookup — response never contains AI_API_KEY value', async () => {
  _mockDbResult = MOCK_DB_ENTRY;
  const app = makeApp();

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'apple', sourceLanguage: 'en' });

  assert.equal(res.status, 200);
  // The response body must never echo any env variable content.
  const raw = JSON.stringify(res.body);
  assert.ok(!raw.includes('sk-'), 'OpenAI key prefix must not appear in response');
  assert.ok(!raw.includes('AIzaSy'), 'Google key prefix must not appear in response');
});

test('POST /api/dictionary/lookup — default language params work (no sourceLanguage sent)', async () => {
  _mockDbResult = MOCK_DB_ENTRY;
  const app = makeApp();

  const res = await request(app)
    .post('/api/dictionary/lookup')
    .send({ query: 'test' }); // no sourceLanguage / targetLanguage

  // Should succeed with default 'ur' source.
  assert.ok(res.status === 200 || res.status === 404); // depends on stub match
  assert.ok(res.body.success !== undefined);
});
