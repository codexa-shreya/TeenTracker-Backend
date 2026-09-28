import { config } from '../config/env.js';
import { sendError } from '../utils/responseHandler.js';

/**
 * Custom application error class with status code and operational flag
 */
export class AppError extends Error {
  constructor(message, statusCode = 500, details = null) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Centralized Express Error Handling Middleware
 */
export const errorHandler = (err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  // Format Zod validation errors if caught here
  if (err.name === 'ZodError') {
    const details = err.errors.map((e) => ({
      field: e.path.join('.'),
      message: e.message
    }));
    return sendError(res, 400, 'Validation failed on input data', 'VALIDATION_ERROR', details);
  }

  // Handle CORS errors
  if (err.message === 'Not allowed by CORS') {
    return sendError(res, 403, 'CORS error: Request origin not allowed', 'CORS_ERROR');
  }

  return sendError(
    res,
    statusCode,
    message,
    err.isOperational ? err.name || 'OPERATIONAL_ERROR' : 'INTERNAL_SERVER_ERROR',
    config.nodeEnv === 'development' ? { stack: err.stack, ...(err.details && { details: err.details }) } : err.details
  );
};

/**
 * 404 Route Not Found Middleware
 */
export const notFoundHandler = (req, res, next) => {
  next(new AppError(`Cannot find ${req.method} ${req.originalUrl} on this server`, 404));
};
