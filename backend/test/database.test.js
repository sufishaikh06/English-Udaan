const assert = require('node:assert/strict');
const test = require('node:test');

const { loadEnvironment } = require('../src/config/environment');
const { connectDatabase } = require('../src/config/database');

test('loadEnvironment accepts valid environment without MONGODB_URI', () => {
  const env = loadEnvironment({
    NODE_ENV: 'test',
    PORT: '3000',
    CORS_ORIGIN: 'http://localhost:3000',
  });
  assert.equal(env.NODE_ENV, 'test');
  assert.equal(env.PORT, 3000);
  assert.equal(env.MONGODB_URI, undefined);
});

test('loadEnvironment accepts valid environment with MONGODB_URI', () => {
  const env = loadEnvironment({
    NODE_ENV: 'development',
    PORT: '3000',
    CORS_ORIGIN: 'http://localhost:3000',
    MONGODB_URI: 'mongodb+srv://user:pass@cluster.mongodb.net/english-udaan',
  });
  assert.equal(env.MONGODB_URI, 'mongodb+srv://user:pass@cluster.mongodb.net/english-udaan');
});

test('loadEnvironment throws on invalid NODE_ENV', () => {
  assert.throws(
    () =>
      loadEnvironment({
        NODE_ENV: 'staging',
        PORT: '3000',
      }),
    /Invalid environment configuration/,
  );
});

test('loadEnvironment throws on invalid PORT', () => {
  assert.throws(
    () =>
      loadEnvironment({
        NODE_ENV: 'development',
        PORT: '99999',
      }),
    /Invalid environment configuration/,
  );
});

test('connectDatabase throws actionable error when URI is empty string', async () => {
  await assert.rejects(() => connectDatabase(''), /MONGODB_URI is required/);
});

test('connectDatabase throws actionable error when URI is undefined', async () => {
  await assert.rejects(() => connectDatabase(undefined), /MONGODB_URI is required/);
});

test('connectDatabase throws actionable error when URI is null', async () => {
  await assert.rejects(() => connectDatabase(null), /MONGODB_URI is required/);
});

test('connectDatabase rejects with connection error for invalid URI (no real Atlas connection)', async () => {
  await assert.rejects(
    () => connectDatabase('mongodb+srv://invalid:invalid@nonexistent.example.mongodb.net/test'),
    (error) => {
      assert.ok(
        error instanceof Error,
        'Expected an Error instance from a bad connection attempt',
      );
      return true;
    },
  );
});
