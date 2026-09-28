import { Router } from 'express';
import { getCategories } from '../controllers/categoryController.js';
import { asyncHandler } from '../middleware/asyncHandler.js';

const router = Router();

// GET /api/categories
router.get('/', asyncHandler(getCategories));

export default router;
