WITH monthly_transactions AS (
    SELECT
        s.owner_id,
        EXTRACT(YEAR FROM s.transaction_date) AS year,
        EXTRACT(MONTH FROM s.transaction_date) AS month,
        COUNT(*) AS transactions_in_month
    FROM savings_savingsaccount s
    WHERE s.transaction_date IS NOT NULL
      AND s.confirmed_amount > 0
    GROUP BY s.owner_id, EXTRACT(YEAR FROM s.transaction_date), EXTRACT(MONTH FROM s.transaction_date)
),

average_transactions AS (
    SELECT
        mt.owner_id,
        AVG(mt.transactions_in_month) AS avg_transactions_per_month
    FROM monthly_transactions mt
    GROUP BY mt.owner_id
),

categorized_users AS (
    SELECT
        owner_id,
        ROUND(avg_transactions_per_month, 2) AS avg_transactions_per_month,
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM average_transactions
)

SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        WHEN 'Low Frequency' THEN 3
    END;
