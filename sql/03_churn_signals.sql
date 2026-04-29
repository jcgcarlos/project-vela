-- ============================================
-- File    : 03_churn_signals.sql
-- Track   : C
-- Goal    : Identify users showing early signs of disengagement
-- --------------------------------------------------------
-- Business Problem:
--   We want to identify users who are transacting less frequently,
--   as low transaction frequency is an early signal of disengagement.
--   This allows Vela's CRM and product teams to target at-risk users
--   with re-engagement campaigns before they fully churn.
-- ============================================

USE fintech_analytics;

-- ============================================
-- STEP 1: Explore
-- ============================================

SELECT * FROM users;
SELECT * FROM feature_activations;
SELECT * FROM transactions;

-- ============================================
-- STEP 2: Isolate sub-calculations
-- ============================================

-- 2.1 Feature count per user
SELECT
    u.user_id,
    COUNT(DISTINCT fa.feature_id) AS total_feature_activated
FROM        users u
            LEFT JOIN feature_activations fa ON u.user_id = fa.user_id
GROUP BY    u.user_id;

-- 2.2 Transaction frequency + churn flag per user
WITH dataset_end_date AS (
    SELECT  MAX(created_at) AS last_date
    FROM    transactions
)
SELECT
    u.user_id,
    COUNT(DISTINCT t.transaction_id)    AS transaction_frequency,
    MAX(t.created_at)                   AS last_transaction_date,
    de.last_date,
    CASE
        WHEN MAX(t.created_at) IS NULL                                  THEN 'never_transacted'
        WHEN MAX(t.created_at) < de.last_date - INTERVAL 3 MONTH       THEN 'churned'
        ELSE 'active'
    END AS churn_flag
FROM        users u
            LEFT JOIN transactions t ON u.user_id = t.user_id
            CROSS JOIN dataset_end_date de
GROUP BY    u.user_id, de.last_date;

-- ============================================
-- STEP 3: Final Output
-- ============================================

WITH feature_summary AS (
    SELECT
        u.user_id,
        COUNT(DISTINCT fa.feature_id)   AS total_feature_activated
    FROM        users u
                LEFT JOIN feature_activations fa ON u.user_id = fa.user_id
    GROUP BY    u.user_id
),
dataset_end_date AS (
    SELECT  MAX(created_at) AS last_date
    FROM    transactions
),
transaction_summary AS (
    SELECT
        u.user_id,
        COUNT(DISTINCT t.transaction_id)    AS transaction_frequency,
        MAX(t.created_at)                   AS last_transaction_date,
        de.last_date,
        CASE
            WHEN MAX(t.created_at) IS NULL                              THEN 'never_transacted'
            WHEN MAX(t.created_at) < de.last_date - INTERVAL 3 MONTH   THEN 'churned'
            ELSE 'active'
        END AS churn_flag
    FROM        users u
                LEFT JOIN transactions t ON u.user_id = t.user_id
                CROSS JOIN dataset_end_date de
    GROUP BY    u.user_id, de.last_date
),
churn_avg_frequency AS (
    SELECT
        churn_flag,
        AVG(transaction_frequency)  AS avg_transaction_frequency
    FROM        transaction_summary
    GROUP BY    churn_flag
)
SELECT
    u.user_segment,
    fs.total_feature_activated,
    ts.transaction_frequency,
    ROUND(caf.avg_transaction_frequency, 1)     AS avg_transaction_frequency_by_status,
    ts.last_transaction_date,
    ts.churn_flag
FROM        users u
            LEFT JOIN feature_summary fs        ON u.user_id = fs.user_id
            LEFT JOIN transaction_summary ts    ON u.user_id = ts.user_id
            LEFT JOIN churn_avg_frequency caf   ON ts.churn_flag = caf.churn_flag
ORDER BY    u.user_segment, ts.churn_flag;