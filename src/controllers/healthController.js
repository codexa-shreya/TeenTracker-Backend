import * as healthService from '../services/healthService.js';

/**
 * Controller to handle health check endpoint
 */
export const checkHealth = (req, res, next) => {
  try {
    const data = healthService.getHealthStatus();
    return res.status(200).json({
      success: true,
      message: 'TeenTrack Backend API is running smoothly',
      data
    });
  } catch (error) {
    next(error);
  }
};
