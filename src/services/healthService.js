/**
 * Service to provide application health and status details
 */
export const getHealthStatus = () => {
  return {
    status: 'healthy',
    name: 'TeenTrack — Teenager Expense Tracker API',
    version: '1.0.0',
    uptimeSeconds: Math.floor(process.uptime()),
    timestamp: new Date().toISOString()
  };
};
