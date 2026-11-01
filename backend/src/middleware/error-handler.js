function notFoundHandler(request, response) {
  response.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `Route not found: ${request.method} ${request.originalUrl}`,
    },
  });
}

function errorHandler(error, request, response, next) {
  void next;
  const status = Number.isInteger(error.status) ? error.status : 500;
  const isProduction = process.env.NODE_ENV === 'production';

  if (status >= 500) {
    console.error(error);
  }

  response.status(status).json({
    success: false,
    error: {
      code: error.code || 'INTERNAL_SERVER_ERROR',
      message: status >= 500 && isProduction ? 'An unexpected error occurred.' : error.message,
    },
  });
}

module.exports = { errorHandler, notFoundHandler };
