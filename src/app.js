import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import { config } from './config/env.js';
import apiRouter from './routes/index.js';
import { generalLimiter } from './middleware/rateLimiter.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';

const app = express();

// Security HTTP headers via Helmet
app.use(helmet());

// Request logging in development
if (config.nodeEnv === 'development') {
  app.use(morgan('dev'));
}

// CORS configuration
app.use(cors({
  origin: (origin, callback) => {
    // Allow non-browser requests (like curl, postman, server-to-server)
    if (!origin) return callback(null, true);

    const allowedOrigins = [
      config.clientUrl,
      'https://teen-tracker-frontend.vercel.app',
      'http://localhost:5173',
      'http://localhost:3000',
      'http://127.0.0.1:5173'
    ];

    if (allowedOrigins.indexOf(origin) !== -1 || config.nodeEnv === 'development') {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parsers with sensible size restrictions
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// Apply rate limiting across all API endpoints
app.use('/api', generalLimiter);

// Root welcome route
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to TeenTrack API — Teenager Expense Tracker',
    endpoints: {
      health: '/api/health',
      systemStatus: '/api/system/status'
    },
    version: '1.0.0'
  });
});

// Mount modular REST API
app.use('/api', apiRouter);

// Handle unmatched routes (404)
app.use(notFoundHandler);

// Centralized error handling
app.use(errorHandler);

export default app;
