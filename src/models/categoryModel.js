import { supabaseAdmin, isSupabaseConfigured } from '../config/supabase.js';

// Default static fallback categories for local offline/initial development
export const DEFAULT_FALLBACK_CATEGORIES = [
  { id: '1', name: 'Food', type: 'expense', icon: '🍔', is_default: true },
  { id: '2', name: 'Transport', type: 'expense', icon: '🚌', is_default: true },
  { id: '3', name: 'Education', type: 'expense', icon: '📚', is_default: true },
  { id: '4', name: 'Entertainment', type: 'expense', icon: '🎬', is_default: true },
  { id: '5', name: 'Shopping', type: 'expense', icon: '🛍️', is_default: true },
  { id: '6', name: 'Gaming', type: 'expense', icon: '🎮', is_default: true },
  { id: '7', name: 'Mobile/Internet', type: 'expense', icon: '📱', is_default: true },
  { id: '8', name: 'Sports', type: 'expense', icon: '⚽', is_default: true },
  { id: '9', name: 'Gifts', type: 'expense', icon: '🎁', is_default: true },
  { id: '10', name: 'Health', type: 'expense', icon: '💊', is_default: true },
  { id: '11', name: 'Other', type: 'expense', icon: '📦', is_default: true },
  { id: '12', name: 'Pocket Money', type: 'income', icon: '💵', is_default: true },
  { id: '13', name: 'Salary', type: 'income', icon: '💼', is_default: true },
  { id: '14', name: 'Gift', type: 'income', icon: '🎉', is_default: true },
  { id: '15', name: 'Scholarship', type: 'income', icon: '🎓', is_default: true },
  { id: '16', name: 'Freelance', type: 'income', icon: '💻', is_default: true },
  { id: '17', name: 'Other Income', type: 'income', icon: '🪙', is_default: true }
];

/**
 * Fetch default and optional user-specific categories
 *
 * @param {string | null} userId - Optional authenticated user ID
 * @param {'expense' | 'income' | null} type - Optional category type filter
 */
export const getCategories = async (userId = null, type = null) => {
  // If Supabase is connected, query the categories table
  if (isSupabaseConfigured() && supabaseAdmin) {
    let query = supabaseAdmin
      .from('categories')
      .select('*')
      .order('name', { ascending: true });

    if (userId) {
      query = query.or(`is_default.eq.true,user_id.eq.${userId}`);
    } else {
      query = query.eq('is_default', true);
    }

    if (type) {
      query = query.or(`type.eq.${type},type.eq.both`);
    }

    const { data, error } = await query;

    if (error) {
      console.error('Supabase getCategories error:', error.message);
      // Fallback to static if table not yet migrated
      return filterStaticCategories(type);
    }

    if (data && data.length > 0) {
      return data;
    }
  }

  // Return static fallback categories
  return filterStaticCategories(type);
};

const filterStaticCategories = (type) => {
  if (!type) return DEFAULT_FALLBACK_CATEGORIES;
  return DEFAULT_FALLBACK_CATEGORIES.filter(
    (cat) => cat.type === type || cat.type === 'both'
  );
};
