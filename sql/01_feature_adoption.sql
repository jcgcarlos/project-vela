USE fintech_analytics;

-- ============================================
-- File    : 01_feature_adoption.sql
-- Track   : A
-- Goal    : Determine whether higher feature adoption correlates 
--           with greater transaction volume and value
-- --------------------------------------------------------
-- Business Problem:
--   		 Vela stakeholders wants to see if higher feature adoption drives higher
--   		 transaction value
-- ============================================

-- Step 1: EXPLORE TABLES
SELECT * FROM feature_activations;
SELECT * FROM transactions;
SELECT * FROM users;

-- Step 2: Isolate sub-calculations
-- Get the total features activated by a user
SELECT	user_id, COUNT(activation_id) AS total_features_activated
FROM 	feature_activations
GROUP BY user_id
ORDER BY total_features_activated DESC;

-- Get the total transactions and the total amount per user
SELECT	user_id, COUNT(transaction_id) AS total_transactions, SUM(amount) AS total_amount
FROM	transactions
GROUP BY user_id;

-- Get the user segment to determine if a user is a casual, regular or power user
SELECT	user_id, user_segment
FROM 	users;

-- Step 3: Combine the subqueries and write the final output
WITH feature_summary 	AS 	(SELECT	user_id, COUNT(activation_id) AS total_features_activated
							 FROM 	feature_activations
							 GROUP BY user_id
),
	transaction_summary AS  (SELECT	user_id, COUNT(transaction_id) AS total_transactions, 
							        SUM(amount) AS total_amount,
                                    ROUND(SUM(amount) / NULLIF(COUNT(transaction_id), 0), 2) AS avg_transaction_value
							 FROM	transactions
							 GROUP BY user_id
)

SELECT	f.user_id, u.user_segment, f.total_features_activated, 
		t.total_transactions, ROUND(t.total_amount, 2) AS total_amount, t.avg_transaction_value
FROM 	feature_summary f 
		LEFT JOIN transaction_summary t 
		ON f.user_id = t.user_id
        LEFT JOIN users u
        ON f.user_id = u.user_id
ORDER BY f.total_features_activated DESC,
		 total_amount DESC;