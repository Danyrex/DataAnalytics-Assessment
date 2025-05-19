WITH plan_transactions AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        CASE 
            WHEN p.is_regular_savings = TRUE THEN 'savings'
            WHEN p.is_a_fund = TRUE THEN 'investment'
            ELSE 'other'
        END AS type,
        MAX(s.transaction_date) AS last_transaction_date
    FROM plans_plan p
    LEFT JOIN savings_savingsaccount s 
        ON p.id = s.plan_id AND s.confirmed_amount > 0
    WHERE p.status_id = 1  -- active plans
    GROUP BY p.id, p.owner_id, 
        CASE 
            WHEN p.is_regular_savings = TRUE THEN 'savings'
            WHEN p.is_a_fund = TRUE THEN 'investment'
            ELSE 'other'
        END
)

SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
FROM plan_transactions
WHERE last_transaction_date IS NULL 
   OR last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 365 DAY);
