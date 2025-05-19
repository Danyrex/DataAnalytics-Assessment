-- Identify customers who have both a funded savings plan and a funded investment plan
-- Sort by total confirmed deposit amount (in naira converted from kobo)

WITH deposits AS (
    SELECT
        cu.id AS owner_id,
        p.id AS plan_id,
        CONCAT(cu.first_name, ' ', cu.last_name) AS name,
        p.is_regular_savings,
        p.is_a_fund,
        ss.confirmed_amount
    FROM
        users_customuser cu
    JOIN
        plans_plan p ON cu.id = p.owner_id
    JOIN
        savings_savingsaccount ss ON p.id = ss.plan_id
    WHERE
        ss.confirmed_amount IS NOT NULL AND ss.confirmed_amount > 0
),
categorized AS (
    SELECT
        owner_id,
        name,
        SUM(confirmed_amount) / 100.0 AS total_deposits,  --  Convert from kobo to naira
        COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN plan_id END) AS savings_count,
        COUNT(DISTINCT CASE WHEN is_a_fund = 1 THEN plan_id END) AS investment_count
    FROM
        deposits
    GROUP BY
        owner_id, name
)
SELECT
    owner_id,
    name,
    savings_count,
    investment_count,
    ROUND(total_deposits, 2) AS total_deposits  -- ✅ Round to 2 decimal places for naira
FROM
    categorized
WHERE
    savings_count >= 1
    AND investment_count >= 1
ORDER BY
    total_deposits DESC;
