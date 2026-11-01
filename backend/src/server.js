const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const { loadEnvironment } = require('./config/environment');
const { connectDatabase, disconnectDatabase, getConnectionStatus, isConnected } = require('./config/database');
const { initializeFirebase } = require('./config/firebase');
const { createApp } = require('./app');

const environment = loadEnvironment();
const db = { getConnectionStatus, isConnected };

console.info(
  `[config] port=${environment.PORT} database=${environment.MONGODB_DATABASE} ` +
  `firebase_project_configured=${Boolean(environment.FIREBASE_PROJECT_ID)} ` +
  `ai_provider=${environment.AI_PROVIDER || 'none'} ` +
  `ai_key_configured=${Boolean(environment.AI_API_KEY)} ` +
  `ai_model=${environment.AI_MODEL || 'provider-default'}`,
);

// Initialize Firebase Admin if project ID is configured.
// Credentials are resolved automatically via Application Default Credentials
// or the GOOGLE_APPLICATION_CREDENTIALS environment variable.
if (environment.FIREBASE_PROJECT_ID) {
  try {
    initializeFirebase(environment.FIREBASE_PROJECT_ID);
    console.info(`Firebase Admin initialized for project: ${environment.FIREBASE_PROJECT_ID}`);
  } catch (firebaseError) {
    console.error(`Failed to initialize Firebase Admin: ${firebaseError.message}`);
    console.error('Auth endpoints will be unavailable. Configure FIREBASE_PROJECT_ID and ADC credentials.');
  }
} else {
  console.warn('FIREBASE_PROJECT_ID is not set. Auth endpoints are unavailable. See .env.example.');
}

const app = createApp({ environment, db });

const server = app.listen(environment.PORT, () => {
  console.info(`English Udaan API listening on port ${environment.PORT}.`);
});

async function shutdown(signal) {
  console.info(`${signal} received — shutting down gracefully.`);
  server.close(async () => {
    try {
      await disconnectDatabase();
      console.info('Database connection closed.');
    } catch (error) {
      console.error('Error closing database connection:', error.message);
    }
    process.exit(0);
  });
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

if (environment.MONGODB_URI) {
    connectDatabase(environment.MONGODB_URI, environment.MONGODB_DATABASE).then(() => {
     console.info(`Connected to MongoDB database: ${environment.MONGODB_DATABASE}.`);
  }).catch((error) => {
    console.error(`Failed to connect to MongoDB: ${error.message}`);
    console.error('The server is running without a database connection. Set MONGODB_URI in .env to enable database features.');
  });
} else {
  console.warn('MONGODB_URI is not set. Database features are unavailable. See .env.example for setup instructions.');
}
