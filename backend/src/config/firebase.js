/**
 * Firebase Admin SDK initialization.
 *
 * Credential strategy (priority order):
 *  1. Application Default Credentials (ADC) — recommended for production and
 *     CI. Run `gcloud auth application-default login` locally, or use a
 *     Workload Identity / service account attached to the hosting environment.
 *  2. GOOGLE_APPLICATION_CREDENTIALS env var pointing to a service-account
 *     JSON file on disk — acceptable for local dev when ADC is not configured.
 *
 * NEVER commit a service-account private key into source control.
 * NEVER log credentials or include them in API responses.
 *
 * The FIREBASE_PROJECT_ID env var is required so the Admin SDK targets the
 * correct project without embedding the project ID in code.
 */

const admin = require('firebase-admin');
const { getAuth } = require('firebase-admin/auth');

let _app = null;

/**
 * Initialize Firebase Admin. Safe to call multiple times; subsequent calls
 * are no-ops when an app is already initialized.
 *
 * @param {string} projectId  Firebase project ID (from FIREBASE_PROJECT_ID env var)
 * @returns {import('firebase-admin').app.App}
 */
function initializeFirebase(projectId) {
  if (_app) return _app;

  if (!projectId) {
    throw new Error(
      'FIREBASE_PROJECT_ID is required. Set it in your .env file. ' +
        'See .env.example for setup instructions.',
    );
  }

  // firebase-admin resolves credentials automatically via ADC or
  // GOOGLE_APPLICATION_CREDENTIALS — no explicit credential object needed.
  _app = admin.initializeApp({
    projectId,
  });

  return _app;
}

/**
 * Returns the initialized Firebase Admin app. Throws when not yet initialized.
 */
function getFirebaseApp() {
  if (!_app) {
    throw new Error('Firebase Admin has not been initialized. Call initializeFirebase() first.');
  }
  return _app;
}

/**
 * Returns the Firebase Admin Auth service, initializing the app if needed.
 * @param {string} [projectId]
 */
function getFirebaseAuth(projectId) {
  if (!_app && projectId) initializeFirebase(projectId);
  return getAuth(getFirebaseApp());
}

/**
 * Verify a Firebase ID token string.
 * Throws an error (with `code` property) when:
 *  - token is missing or not a string
 *  - token is expired or revoked
 *  - token signature is invalid
 *  - Firebase project does not match
 *
 * @param {string} idToken
 * @param {import('firebase-admin/auth').Auth} authClient
 * @returns {Promise<import('firebase-admin/auth').DecodedIdToken>}
 */
async function verifyIdToken(idToken, authClient) {
  return authClient.verifyIdToken(idToken, /* checkRevoked */ true);
}

/**
 * Reset internal state for testing purposes only.
 * @internal
 */
function _resetForTesting() {
  _app = null;
  // Delete all initialized apps so admin.initializeApp() can be called again.
  for (const app of admin.apps) {
    void app.delete();
  }
}

module.exports = { initializeFirebase, getFirebaseApp, getFirebaseAuth, verifyIdToken, _resetForTesting };
