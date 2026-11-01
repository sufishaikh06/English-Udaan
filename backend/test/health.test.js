const assert = require('node:assert/strict');
const test = require('node:test');
const request = require('supertest');

const { createApp } = require('../src/app');

const testEnvironment = {
  NODE_ENV: 'test',
  PORT: 3000,
  CORS_ORIGIN: 'http://localhost:3000',
};

test('GET /health without db returns unconfigured database status', async () => {
  const app = createApp({ environment: testEnvironment });
  const response = await request(app).get('/health');

  assert.equal(response.status, 200);
  assert.equal(response.body.success, true);
  assert.equal(response.body.data.service, 'english-udaan-api');
  assert.equal(response.body.data.status, 'ok');
  assert.equal(response.body.data.environment, 'test');
  assert.equal(response.body.data.database.status, 'unconfigured');
  assert.equal(response.body.data.database.connected, false);
});

test('GET /health with disconnected db returns disconnected status', async () => {
  const db = {
    getConnectionStatus: () => 'disconnected',
    isConnected: () => false,
  };
  const app = createApp({ environment: testEnvironment, db });
  const response = await request(app).get('/health');

  assert.equal(response.status, 200);
  assert.equal(response.body.data.database.status, 'disconnected');
  assert.equal(response.body.data.database.connected, false);
});

test('GET /health with connected db returns connected status', async () => {
  const db = {
    getConnectionStatus: () => 'connected',
    isConnected: () => true,
  };
  const app = createApp({ environment: testEnvironment, db });
  const response = await request(app).get('/health');

  assert.equal(response.status, 200);
  assert.equal(response.body.data.database.status, 'connected');
  assert.equal(response.body.data.database.connected, true);
});

test('GET /health/readiness returns 503 when database not connected', async () => {
  const db = {
    getConnectionStatus: () => 'disconnected',
    isConnected: () => false,
  };
  const app = createApp({ environment: testEnvironment, db });
  const response = await request(app).get('/health/readiness');

  assert.equal(response.status, 503);
  assert.equal(response.body.success, false);
  assert.equal(response.body.error.code, 'DATABASE_NOT_READY');
});

test('GET /health/readiness returns 200 when database is connected', async () => {
  const db = {
    getConnectionStatus: () => 'connected',
    isConnected: () => true,
  };
  const app = createApp({ environment: testEnvironment, db });
  const response = await request(app).get('/health/readiness');

  assert.equal(response.status, 200);
  assert.equal(response.body.success, true);
  assert.equal(response.body.data.ready, true);
});

test('GET /health/readiness returns 503 when db is not provided', async () => {
  const app = createApp({ environment: testEnvironment });
  const response = await request(app).get('/health/readiness');

  assert.equal(response.status, 503);
  assert.equal(response.body.success, false);
});

test('unknown routes return a consistent not-found response', async () => {
  const app = createApp({ environment: testEnvironment });
  const response = await request(app).get('/missing');

  assert.equal(response.status, 404);
  assert.equal(response.body.success, false);
  assert.equal(response.body.error.code, 'NOT_FOUND');
});
