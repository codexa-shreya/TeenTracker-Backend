import * as categoryModel from '../models/categoryModel.js';

/**
 * Fetch categories with optional filtering
 */
export const listCategories = async (userId = null, type = null) => {
  const categories = await categoryModel.getCategories(userId, type);
  return categories;
};
