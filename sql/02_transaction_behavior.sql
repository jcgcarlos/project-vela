USE fintech_analytics;

-- ============================================
-- File    : 02_transaction_behavior.sql
-- Track   : B
-- Goal    : Determine which merchant type drives transaction volume and value
--           with the highest success rate
-- --------------------------------------------------------
-- Business Problem:
--          Vela's growth team wants to determine what merchant type drives
--          transaction volume and value with the highest transaction success rate
-- ============================================

-- Step 1: Explore Tables
SELECT * FROM transactions;
SELECT * FROM merchants;
SELECT * FROM users;

-- Step 2: Isolate sub-calculations

-- 2.1 Verify join path — transactions to merchants and users
SELECT   u.user_segment, m.category, t.transaction_id, t.amount, t.status
FROM     transactions t
         LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
         LEFT JOIN users u ON t.user_id = u.user_id;

-- 2.2 Aggregate transaction metrics by segment and merchant category
SELECT   u.user_segment,
         m.category,
         COUNT(t.transaction_id)                                                   AS total_transactions,
         SUM(t.amount)                                                             AS total_amount,
         SUM(t.amount) / COUNT(t.transaction_id)                                   AS avg_transaction_value,
         SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END)                   AS completed_transactions,
         SUM(CASE WHEN t.status = 'failed'    THEN 1 ELSE 0 END)                   AS failed_transactions,
         100 * (SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END)
                / COUNT(t.transaction_id))                                         AS success_rate
FROM     transactions t
         LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
         LEFT JOIN users u ON t.user_id = u.user_id
GROUP BY u.user_segment, m.category;

-- Step 3: Final output
WITH transaction_summary AS (
    SELECT   u.user_segment,
             m.category,
             COUNT(t.transaction_id)                                               AS total_transactions,
             SUM(t.amount)                                                         AS total_amount,
             SUM(t.amount) / COUNT(t.transaction_id)                               AS avg_transaction_value,
             SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END)               AS completed_transactions,
             SUM(CASE WHEN t.status = 'failed'    THEN 1 ELSE 0 END)               AS failed_transactions,
             100 * (SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END)
                    / COUNT(t.transaction_id))                                     AS success_rate
    FROM     transactions t
             LEFT JOIN merchants m ON t.merchant_id = m.merchant_id
             LEFT JOIN users u ON t.user_id = u.user_id
    GROUP BY u.user_segment, m.category
)

SELECT   user_segment,
         category,
         total_transactions,
         ROUND(total_amount,          2) AS total_amount,
         ROUND(avg_transaction_value, 2) AS avg_transaction_value,
         completed_transactions,
         failed_transactions,
         ROUND(success_rate,          2) AS success_rate,
         DENSE_RANK() OVER (
             PARTITION BY user_segment
             ORDER BY success_rate DESC, total_transactions DESC
         )                               AS success_rate_ranking
FROM     transaction_summary
ORDER BY user_segment, success_rate_ranking;