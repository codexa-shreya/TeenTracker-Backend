import rateLimit from 'express-rate-limit';
import { config } from '../config/env.js';

/**
 * General API Rate Limiter
 * Restricts excessive traffic across general API endpoints
 */
export const generalLimiter = rateLimit({
  windowMs: config.rateLimitWindowMs, // default 15 minutes
  max: config.rateLimitMax, // limit each IP to 100 requests per windowMs
  standardHeaders: true, // Return rate limit info in `RateLimit-*` headers
  legacyHeaders: false, // Disable `X-RateLimit-*` headers
  message: {
    success: false,
    message: 'Too many requests from this IP. Please try again after 15 minutes.',
    error: 'RATE_LIMIT_EXCEEDED'
  }
});

/**
 * Stricter Rate Limiter for Authentication endpoints
 * Protects against brute-force credential stuffing and password guessing
 */
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // Limit each IP to 10 login/register requests per 15 minutes
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many login or registration attempts. Please wait 15 minutes before trying again.',
    error: 'AUTH_RATE_LIMIT_EXCEEDED'
  }
});
