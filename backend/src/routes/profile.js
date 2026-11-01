/**
 * Profile routes — protected by Firebase auth middleware.
 *
 * GET /api/me — returns verified account details for the authenticated user.
 *
 * Only safe, non-sensitive fields from the decoded Firebase token are returned.
 * Raw token data (e.g. firebase.identities) is never forwarded to the client.
 */

const { Router } = require('express');

function createProfileRouter({ authMiddleware }) {
  const router = Router();

  /**
   * GET /api/me
   * Returns the authenticated user's profile derived from the Firebase token.
   * Requires: Authorization: Bearer <Firebase ID token>
   */
  router.get('/', authMiddleware, (req, res) => {
    const { uid, decodedToken } = req;

    res.status(200).json({
      success: true,
      data: {
        uid,
        email: decodedToken.email ?? null,
        emailVerified: decodedToken.email_verified ?? false,
        displayName: decodedToken.name ?? null,
        // Do not return: firebase.identities, firebase.sign_in_provider internals,
        // raw iat/exp timestamps, or any server-side secret.
      },
    });
  });

  return router;
}

module.exports = { createProfileRouter };
