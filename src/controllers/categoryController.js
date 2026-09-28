import * as categoryService from '../services/categoryService.js';
import { sendSuccess } from '../utils/responseHandler.js';

/**
 * Controller to handle listing expense and income categories
 * GET /api/categories?type=expense | income
 */
export const getCategories = async (req, res) => {
  const { type } = req.query;
  const userId = req.user?.id || null;

  const categories = await categoryService.listCategories(userId, type);

  return sendSuccess(
    res,
    200,
    'Categories retrieved successfully',
    categories,
    { total: categories.length }
  );
};
