import { config } from '../config/env.js';
import { isSupabaseConfigured } from '../config/supabase.js';
import { sendSuccess } from '../utils/responseHandler.js';

/**
 * Controller to report comprehensive backend system and framework status
 */
export const getSystemStatus = (req, res) => {
  const memoryUsage = process.memoryUsage();

  const statusData = {
    application: 'TeenTrack — Teenager Expense Tracker Backend',
    version: '1.0.0',
    environment: config.nodeEnv,
    uptime: `${Math.floor(process.uptime())} seconds`,
    timestamp: new Date().toISOString(),
    security: {
      helmet: 'Enabled (Secure HTTP Headers)',
      cors: `Configured for ${config.clientUrl}`,
      rateLimiting: `Enabled (${config.rateLimitMax} reqs / ${config.rateLimitWindowMs / 60000} mins)`,
      validationEngine: 'Zod Schema Validator active'
    },
    database: {
      provider: 'Supabase PostgreSQL',
      configured: isSupabaseConfigured(),
      notice: isSupabaseConfigured()
        ? 'Supabase connection credentials detected'
        : 'Running in setup mode. Configure SUPABASE_URL and keys in Phase 3'
    },
    memory: {
      rss: `${Math.round(memoryUsage.rss / 1024 / 1024)} MB`,
      heapUsed: `${Math.round(memoryUsage.heapUsed / 1024 / 1024)} MB`,
      heapTotal: `${Math.round(memoryUsage.heapTotal / 1024 / 1024)} MB`
    }
  };

  return sendSuccess(res, 200, 'TeenTrack backend system status retrieved successfully', statusData);
};
