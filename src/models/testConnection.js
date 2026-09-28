import { supabaseAdmin, isSupabaseConfigured } from '../config/supabase.js';

/**
 * Diagnostic script to verify Supabase PostgreSQL connection
 * Run via: node src/models/testConnection.js
 */
const testConnection = async () => {
  console.log('====================================================');
  console.log('🔍 Testing Supabase PostgreSQL Database Connection');
  console.log('====================================================');

  if (!isSupabaseConfigured() || !supabaseAdmin) {
    console.log('⚠️  Status: Supabase credentials are not configured or using placeholders in backend/.env');
    console.log('👉 Please set real SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in backend/.env');
    process.exit(0);
  }

  try {
    const { data, error } = await supabaseAdmin.from('categories').select('count', { count: 'exact' });

    if (error) {
      console.error('❌ Connection or Query Error:', error.message);
      console.log('💡 Tip: Make sure you ran schema.sql in the Supabase SQL Editor!');
      process.exit(1);
    }

    console.log('✅ Success! Successfully connected to Supabase PostgreSQL database.');
    console.log(`📊 Found ${data?.[0]?.count ?? 'initialized'} categories in the database.`);
    process.exit(0);
  } catch (err) {
    console.error('❌ Unexpected Connection Error:', err.message);
    process.exit(1);
  }
};

testConnection();
