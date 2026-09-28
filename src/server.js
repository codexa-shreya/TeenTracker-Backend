import app from './app.js';
import { config } from './config/env.js';

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('UNCAUGHT EXCEPTION! Shutting down gracefully...', err);
  process.exit(1);
});

const PORT = config.port;

const server = app.listen(PORT, () => {
  console.log('====================================================');
  console.log(`🚀 TeenTrack Backend Server running on port ${PORT}`);
  console.log(`📡 Environment: ${config.nodeEnv}`);
  console.log(`🌐 API Health Check: http://localhost:${PORT}/api/health`);
  console.log(`🔗 Allowed Client URL: ${config.clientUrl}`);
  console.log('====================================================');
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION! Shutting down gracefully...', err);
  server.close(() => {
    process.exit(1);
  });
});
