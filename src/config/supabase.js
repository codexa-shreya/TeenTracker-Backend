import { createClient } from '@supabase/supabase-js';
import { config } from './env.js';

const isConfigured = Boolean(
  config.supabaseUrl &&
  config.supabaseAnonKey &&
  !config.supabaseUrl.includes('placeholder') &&
  !config.supabaseAnonKey.includes('placeholder')
);

if (!isConfigured) {
  console.warn('⚠️  [Supabase Warning]: SUPABASE_URL or SUPABASE_ANON_KEY is not configured or using placeholders in backend/.env.');
  console.warn('ℹ️  You can configure your real credentials in Phase 3 when setting up the database.');
}

/**
 * Public Supabase client (Anon key)
 */
export const supabase = isConfigured
  ? createClient(config.supabaseUrl, config.supabaseAnonKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })
  : null;

/**
 * Administrative Supabase client (Service Role key - Backend only, never leak to client!)
 */
export const supabaseAdmin = (isConfigured && config.supabaseServiceRoleKey && !config.supabaseServiceRoleKey.includes('placeholder'))
  ? createClient(config.supabaseUrl, config.supabaseServiceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })
  : null;

/**
 * Check if Supabase connection credentials are validly supplied
 */
export const isSupabaseConfigured = () => isConfigured;
