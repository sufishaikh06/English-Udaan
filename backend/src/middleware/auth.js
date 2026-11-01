/**
 * Firebase authentication middleware.
 *
 * Reads an Authorization: Bearer <Firebase ID token> header, verifies the
 * token using Firebase Admin, and attaches the verified UID to req.uid.
 *
 * All failure cases return a consistent 401 JSON response. The raw Firebase
 * error is never forwarded to the client; an safe error code is logged instead.
 */

const BEARER_PREFIX = 'Bearer ';

/**
 * Extract the raw token from the Authorization header.
 * Returns null when the header is absent or malformed.
 *
 * @param {import('express').Request} req
 * @returns {string|null}
 */
function extractBearerToken(req) {
  const header = req.headers['authorization'];
  if (typeof header !== 'string' || !header.startsWith(BEARER_PREFIX)) {
    return null;
  }
  const token = header.slice(BEARER_PREFIX.length).trim();
  return token.length > 0 ? token : null;
}

/**
 * Build the requireAuth middleware bound to a specific Firebase Auth client.
 *
 * @param {import('firebase-admin/auth').Auth} firebaseAuth
 * @returns {import('express').RequestHandler}
 */
function createAuthMiddleware(firebaseAuth) {
  return async function requireAuth(req, res, next) {
    const token = extractBearerToken(req);

    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'MISSING_AUTH_TOKEN',
          message: 'Authorization header with Bearer token is required.',
        },
      });
    }

    try {
      const decoded = await firebaseAuth.verifyIdToken(token, /* checkRevoked */ true);
      req.uid = decoded.uid;
      req.decodedToken = decoded;
      return next();
    } catch (error) {
      // Never expose raw Firebase error details to the client.
      const code = error.code || 'AUTH_ERROR';
      // Log the sanitized code for server-side diagnostics — not the token.
      console.warn(`[auth] Token verification failed: ${code}`);

      // Map Firebase error codes to user-facing messages.
      let message = 'Authentication failed. Provide a valid Firebase ID token.';
      if (
        code === 'auth/id-token-expired' ||
        code === 'auth/id-token-revoked' ||
        code === 'auth/session-cookie-expired'
      ) {
        message = 'Token has expired or been revoked. Sign in again to get a fresh token.';
      } else if (
        code === 'auth/argument-error' ||
        code === 'auth/invalid-id-token'
      ) {
        message = 'Token is malformed or invalid.';
      } else if (code === 'auth/user-not-found' || code === 'auth/user-disabled') {
        message = 'User account does not exist or has been disabled.';
      }

      return res.status(401).json({
        success: false,
        error: {
          code: 'INVALID_AUTH_TOKEN',
          message,
        },
      });
    }
  };
}

module.exports = { createAuthMiddleware, extractBearerToken };
