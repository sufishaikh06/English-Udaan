const cors = require('cors');
const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const { loadEnvironment } = require('./config/environment');
const { initializeFirebase, getFirebaseAuth } = require('./config/firebase');
const { errorHandler, notFoundHandler } = require('./middleware/error-handler');
const { createAuthMiddleware } = require('./middleware/auth');
const { createHealthRouter } = require('./routes/health');
const { createProfileRouter } = require('./routes/profile');
const { createProgressRouter } = require('./routes/progress');
const { createDictionaryRouter } = require('./routes/dictionary');

// Rate limiter for auth-protected endpoints (100 req / 15 min per IP).
const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many requests. Please wait and try again.',
    },
  },
  skip: (req) => req.app.locals.skipRateLimit === true,
});

// Stricter rate limiter for the public dictionary endpoint (30 req / 15 min per IP).
const dictionaryRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message: 'Too many dictionary requests. Please wait and try again.',
    },
  },
  skip: (req) => req.app.locals.skipRateLimit === true,
});

function createApp({ environment = loadEnvironment(), db = null, firebaseAuth = null } = {}) {
  const app = express();

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors({ origin: environment.CORS_ORIGIN }));
  app.use(express.json({ limit: '100kb' }));

  if (environment.NODE_ENV !== 'test') {
    app.use(morgan('combined'));
  }

  // Resolve Firebase Auth: use the injected instance (for tests) or
  // initialize from FIREBASE_PROJECT_ID if available.
  let resolvedFirebaseAuth = firebaseAuth;
  if (!resolvedFirebaseAuth && environment.FIREBASE_PROJECT_ID) {
    try {
      resolvedFirebaseAuth = getFirebaseAuth(environment.FIREBASE_PROJECT_ID);
    } catch (initError) {
      // Non-fatal: auth routes will return 503 if Firebase is not configured.
      console.warn(`[firebase] Initialization skipped: ${initError.message}`);
    }
  }

  const authMiddleware = resolvedFirebaseAuth
    ? createAuthMiddleware(resolvedFirebaseAuth)
    : (_req, res) =>
        res.status(503).json({
          success: false,
          error: {
            code: 'AUTH_NOT_CONFIGURED',
            message:
              'Authentication is not configured on this server. ' +
              'Set FIREBASE_PROJECT_ID and configure Application Default Credentials.',
          },
        });

  app.use('/health', createHealthRouter({ environment, db }));
  app.use('/api/me', authRateLimiter, createProfileRouter({ authMiddleware }));
  app.use('/api/progress', authRateLimiter, createProgressRouter({ authMiddleware }));
  app.use('/api/dictionary', dictionaryRateLimiter, createDictionaryRouter({ environment }));

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

module.exports = { createApp };
