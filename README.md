# DataAnalytics-Assessment

**Question 1: High-Value Customers with Multiple Products**
 
 Approach
This query aims to identify high-value customers who have both:
•	At least one funded savings plan, and

•	At least one funded investment plan.

To solve this:
1.	I created a Common Table Expression (CTE) called deposits that joins the users_customuser, plans_plan, and savings_savingsaccount tables.
2.	Within the CTE, I filtered for only funded plans by checking that confirmed_amount > 0.
3.	I used the is_regular_savings = 1 flag to identify savings plans and is_a_fund = 1 to identify investment plans.
4.	In a second CTE (categorized), I aggregated data per user to count the number of funded savings and investment plans using conditional COUNT(DISTINCT CASE WHEN ...) clauses.
5.	I also summed the confirmed deposit amount per user to get their total_deposits.
6.	Finally, I filtered the result to return only users with at least one of each product type and sorted them in descending order of total deposits.
NB: The confirmed amount was converted from kobo to naira
________________________________________
 Challenges Encountered & Resolutions:
 
•	Large Schema Size: The plans_plan table contains over 50 columns, making initial exploration complex. I focused only on relevant columns such as is_regular_savings, is_a_fund, owner_id, and id.

•	Understanding Plan Type Flags: It wasn’t immediately obvious that is_regular_savings and is_a_fund define savings vs investment plans. I relied on the provided hints to use these flags correctly.

•	Duplicate Data from Joins: The join between plans and savings records could return multiple rows per plan. To prevent inflated counts, I used COUNT(DISTINCT plan_id) during aggregation.

•	Name Concatenation Issues: SQL concatenation syntax varies by DBMS. I used CONCAT(first_name, ' ', last_name) to ensure compatibility across platforms like PostgreSQL or MySQL.


**Question 2: Transaction Frequency Analysis**
 
 Approach:
The goal of this analysis was to classify customers based on how frequently they transact using their savings accounts. To solve this, I followed a multi-step SQL approach:

1.	Monthly Aggregation:
I started by counting how many transactions each customer made per month. This involved grouping transactions by customer and month using the EXTRACT(YEAR FROM ...) and EXTRACT(MONTH FROM ...) functions. Only confirmed transactions with a non-null date were considered to ensure meaningful activity.
2.	Customer Average Calculation:
I computed the average number of transactions per month for each customer using the AVG() function across the monthly groups.
3.	Categorization:
Each customer was then categorized based on their average monthly transaction count:
o	High Frequency: ≥10 transactions/month
o	Medium Frequency: 3–9 transactions/month
o	Low Frequency: ≤2 transactions/month
4.	Final Summary:
The final output grouped all users by their frequency category, showing:
o	The total number of customers (customer_count)
o	The average transaction count in each category (avg_transactions_per_month)
________________________________________

Challenges Encountered & Resolutions:

•	Challenge 1: Data Granularity
Initially, the data did not directly provide monthly aggregates. I had to extract both year and month from the transaction date to generate accurate monthly transaction groupings.
Resolution:
I used EXTRACT(YEAR FROM ...) and EXTRACT(MONTH FROM ...) to construct logical time buckets for monthly counting.

•	Challenge 2: Filtering Invalid Transactions

Some transactions lacked valid dates or had confirmed_amount values of zero, which could skew the frequency analysis.
Resolution:
I added a filter to include only records with a valid transaction_date and confirmed_amount > 0.

•	Challenge 3: Custom Ordering of Frequency Buckets
SQL’s default ordering would sort the categories alphabetically, not logically.
Resolution:
I implemented a CASE statement in the ORDER BY clause to manually order the frequency categories as High → Medium → Low.


**Question 3 – Account Inactivity Alert**

Approach
1.	Identify active savings and investment plans using is_regular_savings = 1 for savings and is_a_fund = 1 for investments from the plans_plan table.

2.	Join the plans_plan table with the savings_savingsaccount table on plan_id to access transaction details.

3.	Use MAX(transaction_date) to find the most recent transaction per plan.

4.	Compute the number of days since the last transaction using a date difference function (e.g., DATEDIFF).

5.	Filter out accounts with last_transaction_date older than 365 days or with no transactions at all (i.e., NULL values).

6.	Return columns: plan_id, owner_id, type (Savings or Investment), last_transaction_date, and inactivity_days.
________________________________________
Challenges & Resolutions :

•	One of the main challenges was handling plans with no transaction records. These resulted in NULL values for last_transaction_date, which initially appeared to be an error. However, it was later understood that such cases represent truly inactive plans and should be included in the results. This was addressed by using a LEFT JOIN to retain all plans and adding a condition to include plans with either a NULL transaction date or one older than 365 days.

•	Another issue involved the date arithmetic syntax (CURRENT_DATE – INTERVAL ‘365 days’), which caused compatibility errors in some environments. This was resolved by using DATEDIFF(CURRENT_DATE, last_transaction_date).


•	Additionally, combining aggregate functions and filtering introduced complexity, especially when applying HAVING clauses with conditions on MAX(transaction_date). To resolve this, I used a subquery to calculate the latest transaction date and then applied filtering logic on the result.


**Question 4: Customer Lifetime Value (CLV) Estimation**

Approach
1.	Join the users_customuser and savings_savingsaccount tables using owner_id to associate users with their transactions.
2.	Calculate tenure using TIMESTAMPDIFF(MONTH, date_joined, CURDATE()).
3.	Count total transactions per user from the savings table.
4.	Sum confirmed_amount to get total transaction value and apply 0.001 (i.e., 0.1%) to estimate profit.
5.	Compute CLV using the given formula.
6.	Round the result to two decimal places for readability.
7.	Group by user ID to get per-customer metrics.
8.	Order the result by estimated_clv in descending order.
________________________________________
   Challenges Encountered & Resolutions:
   
•	Division by zero: Users with zero tenure_months or zero total_transactions could cause division errors.
 Resolved by using NULLIF(value, 0) to safely avoid division by zero without affecting the logic.
 
•	Profit estimation clarity: Interpreting the correct way to apply the 0.1% profit rate required clarification.

I used (SUM(confirmed_amount) * 0.001) to model the average profit per transaction and multiplied it appropriately in the CLV formula.
 
•	Ensuring accurate filtering: Only inflow transactions were considered by excluding rows with null transaction_type_id or confirmed_amount.
 Ensured the query filtered only meaningful transactions for the analysis.
 
NB: Estimated_clv column was converted to naira 




