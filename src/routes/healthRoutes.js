import { Router } from 'express';
import * as healthController from '../controllers/healthController.js';

const router = Router();

// GET /api/health
router.get('/', healthController.checkHealth);

export default router;
