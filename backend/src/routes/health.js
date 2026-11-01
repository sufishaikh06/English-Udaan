const { Router } = require('express');

function createHealthRouter({ environment, db }) {
  const router = Router();

  router.get('/', (request, response) => {
    void request;
    const dbStatus = db ? db.getConnectionStatus() : 'unconfigured';
    const dbConnected = db ? db.isConnected() : false;

    response.status(200).json({
      success: true,
      data: {
        service: 'english-udaan-api',
        status: 'ok',
        environment: environment.NODE_ENV,
        database: {
          status: dbStatus,
          connected: dbConnected,
        },
      },
    });
  });

  router.get('/readiness', (request, response) => {
    void request;
    if (!db || !db.isConnected()) {
      return response.status(503).json({
        success: false,
        error: {
          code: 'DATABASE_NOT_READY',
          message: 'Database is not connected.',
        },
      });
    }

    response.status(200).json({
      success: true,
      data: {
        ready: true,
      },
    });
  });

  return router;
}

module.exports = { createHealthRouter };
