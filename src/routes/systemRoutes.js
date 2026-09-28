import { Router } from 'express';
import { getSystemStatus } from '../controllers/systemController.js';
import { asyncHandler } from '../middleware/asyncHandler.js';

const router = Router();

// GET /api/system/status
router.get('/status', asyncHandler(getSystemStatus));

export default router;
