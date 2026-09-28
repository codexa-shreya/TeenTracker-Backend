-- ====================================================================
-- TeenTrack — Optional Demo Seed Data
-- ====================================================================
-- NOTE: This file is for DEMO / TESTING purposes only.
-- It creates a simulated teenager account ("Alex River") with sample
-- income, expenses, category budgets, and savings goals.
-- ====================================================================

DO $$
DECLARE
    demo_user_id UUID := 'a0000000-0000-0000-0000-000000000001'::UUID;
    food_cat_id UUID;
    transport_cat_id UUID;
    gaming_cat_id UUID;
    shopping_cat_id UUID;
    pocket_money_cat_id UUID;
    gift_cat_id UUID;
    demo_budget_id UUID;
BEGIN
    -- 1. Create or replace Demo User (Password: "DemoTeen123!" hashed with bcrypt salt 10)
    -- Hash corresponds to: DemoTeen123!
    DELETE FROM users WHERE email = 'demo@teentrack.app';

    INSERT INTO users (id, email, password_hash, username, full_name)
    VALUES (
        demo_user_id,
        'demo@teentrack.app',
        '$2b$10$7vM/E84V0c84yW1H20hG6.u2i5q7C1m3g3oU5e7o9d1a3b5c7e9g.',
        'alex_teen',
        'Alex River'
    );

    -- 2. Create Demo Profile
    INSERT INTO profiles (user_id, full_name, username, email, monthly_income_target, currency)
    VALUES (
        demo_user_id,
        'Alex River',
        'alex_teen',
        'demo@teentrack.app',
        5000.00,
        'INR'
    );

    -- 3. Retrieve Category IDs
    SELECT id INTO food_cat_id FROM categories WHERE name = 'Food' LIMIT 1;
    SELECT id INTO transport_cat_id FROM categories WHERE name = 'Transport' LIMIT 1;
    SELECT id INTO gaming_cat_id FROM categories WHERE name = 'Gaming' LIMIT 1;
    SELECT id INTO shopping_cat_id FROM categories WHERE name = 'Shopping' LIMIT 1;
    SELECT id INTO pocket_money_cat_id FROM categories WHERE name = 'Pocket Money' LIMIT 1;
    SELECT id INTO gift_cat_id FROM categories WHERE name = 'Gift' LIMIT 1;

    -- 4. Insert Demo Income Transactions
    INSERT INTO transactions (user_id, type, amount, category_id, source, description, payment_method, transaction_date)
    VALUES
    (demo_user_id, 'income', 5000.00, pocket_money_cat_id, 'Pocket Money', 'Monthly pocket money from parents', 'UPI', CURRENT_DATE - INTERVAL '15 days'),
    (demo_user_id, 'income', 1000.00, gift_cat_id, 'Gift', 'Grandma birthday cash gift', 'Cash', CURRENT_DATE - INTERVAL '5 days');

    -- 5. Insert Demo Expense Transactions
    INSERT INTO transactions (user_id, type, amount, category_id, description, payment_method, transaction_date)
    VALUES
    (demo_user_id, 'expense', 450.00, food_cat_id, 'Weekend pizza with school friends', 'UPI', CURRENT_DATE - INTERVAL '12 days'),
    (demo_user_id, 'expense', 320.00, food_cat_id, 'School canteen burgers and juice', 'Cash', CURRENT_DATE - INTERVAL '8 days'),
    (demo_user_id, 'expense', 280.00, transport_cat_id, 'Metro smart card monthly recharge', 'Card', CURRENT_DATE - INTERVAL '14 days'),
    (demo_user_id, 'expense', 899.00, gaming_cat_id, 'Steam seasonal battle pass', 'Card', CURRENT_DATE - INTERVAL '6 days'),
    (demo_user_id, 'expense', 1150.00, shopping_cat_id, 'New graphic hoodie from sale', 'UPI', CURRENT_DATE - INTERVAL '3 days'),
    (demo_user_id, 'expense', 120.00, food_cat_id, 'Ice cream treat after exam', 'UPI', CURRENT_DATE - INTERVAL '1 day');

    -- 6. Insert Demo Monthly Budget
    INSERT INTO budgets (user_id, name, amount, period, start_date, end_date)
    VALUES (
        demo_user_id,
        'September Student Budget',
        4000.00,
        'monthly',
        DATE_TRUNC('month', CURRENT_DATE)::DATE,
        (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::DATE
    ) RETURNING id INTO demo_budget_id;

    -- 7. Insert Category Budget Limits
    IF food_cat_id IS NOT NULL THEN
        INSERT INTO budget_categories (budget_id, category_id, limit_amount)
        VALUES (demo_budget_id, food_cat_id, 1500.00);
    END IF;

    IF gaming_cat_id IS NOT NULL THEN
        INSERT INTO budget_categories (budget_id, category_id, limit_amount)
        VALUES (demo_budget_id, gaming_cat_id, 1000.00);
    END IF;

    IF shopping_cat_id IS NOT NULL THEN
        INSERT INTO budget_categories (budget_id, category_id, limit_amount)
        VALUES (demo_budget_id, shopping_cat_id, 1000.00);
    END IF;

    IF transport_cat_id IS NOT NULL THEN
        INSERT INTO budget_categories (budget_id, category_id, limit_amount)
        VALUES (demo_budget_id, transport_cat_id, 500.00);
    END IF;

    -- 8. Insert Demo Savings Goals
    INSERT INTO savings_goals (user_id, name, target_amount, current_amount, target_date, description)
    VALUES
    (demo_user_id, 'Noise Cancelling Headphones', 5000.00, 2750.00, CURRENT_DATE + INTERVAL '60 days', 'Saving for study & music wireless headphones'),
    (demo_user_id, 'Science Fair Project Kit', 1800.00, 1200.00, CURRENT_DATE + INTERVAL '30 days', 'Robotics sensor kit for school competition');

    -- 9. Insert Demo In-App Notifications
    INSERT INTO notifications (user_id, title, message, type, is_read)
    VALUES
    (demo_user_id, 'Food Budget at 60%', 'You have spent ₹890 of your ₹1,500 Food budget for this month.', 'budget_warning', FALSE),
    (demo_user_id, 'Halfway There!', 'Awesome job! You reached 55% of your "Noise Cancelling Headphones" goal.', 'goal_progress', FALSE),
    (demo_user_id, 'Welcome to TeenTrack 👋', 'Start tracking every pocket money receipt and expense to take control of your financial freedom!', 'info', TRUE);

    RAISE NOTICE 'Demo TeenTrack seed data successfully installed!';
END $$;
