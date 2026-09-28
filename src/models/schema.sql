-- ====================================================================
-- TeenTrack — Teenager Expense Tracker Database Schema
-- Database: Supabase PostgreSQL
-- ====================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ====================================================================
-- 2. Clean Up Existing Objects (Optional for fresh setup)
-- ====================================================================
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS savings_goals CASCADE;
DROP TABLE IF EXISTS budget_categories CASCADE;
DROP TABLE IF EXISTS budgets CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;

-- ====================================================================
-- 3. Utility Trigger Function: Automatic updated_at Timestamps
-- ====================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ====================================================================
-- 4. Table: users
-- Core authentication table for bcrypt hashed credentials & identity
-- ====================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ====================================================================
-- 5. Table: profiles
-- User financial preferences, income targets, and profile metadata
-- ====================================================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    monthly_income_target NUMERIC(12, 2) DEFAULT 0.00 CHECK (monthly_income_target >= 0),
    currency VARCHAR(10) DEFAULT 'INR',
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ====================================================================
-- 6. Table: categories
-- Standardized and user-custom spending/income categories
-- ====================================================================
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('expense', 'income', 'both')),
    icon VARCHAR(50),
    is_default BOOLEAN NOT NULL DEFAULT TRUE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- NULL means global system category
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ====================================================================
-- 7. Table: transactions
-- Individual income and expense entries recorded by teenagers
-- ====================================================================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(10) NOT NULL CHECK (type IN ('expense', 'income')),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    source VARCHAR(100), -- Specific for income sources (e.g. Pocket Money, Freelance, Gift)
    description TEXT,
    payment_method VARCHAR(50) DEFAULT 'Cash' CHECK (payment_method IN ('Cash', 'UPI', 'Card', 'Bank', 'Other')),
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_transactions_updated_at
    BEFORE UPDATE ON transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ====================================================================
-- 8. Table: budgets
-- Monthly or period-specific total spending budgets set by the teenager
-- ====================================================================
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL CHECK (amount > 0),
    period VARCHAR(20) NOT NULL DEFAULT 'monthly' CHECK (period IN ('weekly', 'monthly', 'yearly')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT valid_budget_dates CHECK (end_date >= start_date)
);

CREATE TRIGGER update_budgets_updated_at
    BEFORE UPDATE ON budgets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ====================================================================
-- 9. Table: budget_categories
-- Category-level breakdown limits (e.g., Food: ₹1500, Gaming: ₹500)
-- ====================================================================
CREATE TABLE budget_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    budget_id UUID NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    limit_amount NUMERIC(12, 2) NOT NULL CHECK (limit_amount > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(budget_id, category_id)
);

-- ====================================================================
-- 10. Table: savings_goals
-- Gamified savings target tracking (e.g., New Headphones ₹5000)
-- ====================================================================
CREATE TABLE savings_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    target_amount NUMERIC(12, 2) NOT NULL CHECK (target_amount > 0),
    current_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (current_amount >= 0),
    target_date DATE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_savings_goals_updated_at
    BEFORE UPDATE ON savings_goals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ====================================================================
-- 11. Table: notifications
-- In-app alert notifications (budget threshold warnings, savings milestones)
-- ====================================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'info' CHECK (type IN ('budget_warning', 'budget_exceeded', 'goal_progress', 'spending_trend', 'info')),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ====================================================================
-- 12. Strategic Database Indexes for Fast Analytics & Filtering
-- ====================================================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);

CREATE INDEX idx_transactions_user_date ON transactions(user_id, transaction_date DESC);
CREATE INDEX idx_transactions_user_category ON transactions(user_id, category_id);
CREATE INDEX idx_transactions_user_type ON transactions(user_id, type);
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);

CREATE INDEX idx_budgets_user_id ON budgets(user_id);
CREATE INDEX idx_budget_categories_budget_id ON budget_categories(budget_id);
CREATE INDEX idx_savings_goals_user_id ON savings_goals(user_id);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read);

-- ====================================================================
-- 13. Row Level Security (RLS) Policies
-- ====================================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE savings_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Categories policy: anyone can read default categories or categories they own
CREATE POLICY "Allow read default categories and own categories"
    ON categories FOR SELECT
    USING (is_default = TRUE OR auth.uid()::text = user_id::text);

-- Profiles policy: users can only read and update their own profile
CREATE POLICY "Allow users to read own profile"
    ON profiles FOR SELECT
    USING (auth.uid()::text = user_id::text);

CREATE POLICY "Allow users to update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid()::text = user_id::text);

-- Transactions policy: users can only view and manage their own transactions
CREATE POLICY "Allow users to manage own transactions"
    ON transactions FOR ALL
    USING (auth.uid()::text = user_id::text);

-- Budgets policy
CREATE POLICY "Allow users to manage own budgets"
    ON budgets FOR ALL
    USING (auth.uid()::text = user_id::text);

-- Savings goals policy
CREATE POLICY "Allow users to manage own savings goals"
    ON savings_goals FOR ALL
    USING (auth.uid()::text = user_id::text);

-- Notifications policy
CREATE POLICY "Allow users to manage own notifications"
    ON notifications FOR ALL
    USING (auth.uid()::text = user_id::text);

-- ====================================================================
-- 14. Seed Initial Default Categories
-- ====================================================================
INSERT INTO categories (name, type, icon, is_default, user_id) VALUES
-- Expense Categories
('Food', 'expense', '🍔', TRUE, NULL),
('Transport', 'expense', '🚌', TRUE, NULL),
('Education', 'expense', '📚', TRUE, NULL),
('Entertainment', 'expense', '🎬', TRUE, NULL),
('Shopping', 'expense', '🛍️', TRUE, NULL),
('Gaming', 'expense', '🎮', TRUE, NULL),
('Mobile/Internet', 'expense', '📱', TRUE, NULL),
('Sports', 'expense', '⚽', TRUE, NULL),
('Gifts', 'expense', '🎁', TRUE, NULL),
('Health', 'expense', '💊', TRUE, NULL),
('Other', 'expense', '📦', TRUE, NULL),

-- Income Categories / Sources
('Pocket Money', 'income', '💵', TRUE, NULL),
('Salary', 'income', '💼', TRUE, NULL),
('Gift', 'income', '🎉', TRUE, NULL),
('Scholarship', 'income', '🎓', TRUE, NULL),
('Freelance', 'income', '💻', TRUE, NULL),
('Other Income', 'income', '🪙', TRUE, NULL);
