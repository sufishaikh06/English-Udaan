const mongoose = require('mongoose');

const READY_STATES = {
  0: 'disconnected',
  1: 'connected',
  2: 'connecting',
  3: 'disconnecting',
  99: 'uninitialized',
};

function getConnectionStatus() {
  const state = mongoose.connection.readyState;
  return READY_STATES[state] ?? 'unknown';
}

function isConnected() {
  return mongoose.connection.readyState === 1;
}

async function connectDatabase(uri, databaseName = 'test') {
  if (!uri) {
    throw new Error(
      'MONGODB_URI is required. Set it in your .env file. See .env.example for the variable name.',
    );
  }

  await mongoose.connect(uri, {
    dbName: databaseName,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
  });
}

async function disconnectDatabase() {
  await mongoose.disconnect();
}

module.exports = { connectDatabase, disconnectDatabase, getConnectionStatus, isConnected };
