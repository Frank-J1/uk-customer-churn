/*
================================================================================
Script:        02_cohort_retention.sql
Project:       Customer Retention Engine (UK Online Retail Dataset)
Database:      SQLite (retail_churn.db)
Input Table:   cleaned_retail_transactions
Output Grain:  1 row per (cohort_month, cohort_index)

Purpose:
  Calculates monthly customer cohort retention rates by deduplicating monthly
  customer activity, assigning each customer to an acquisition cohort based on
  their first purchase month, and measuring active retention across subsequent
  months.

Business Questions Addressed:
  1. Which acquisition cohorts demonstrate the strongest and weakest retention?
  2. How does retention decay from Month 0 through subsequent months?
  3. Do holiday-acquired cohorts retain differently than off-peak cohorts?
================================================================================
*/

-- Step 1: Rank each customer's transactions within a calendar month to prep for deduplication
WITH ranked_transactions AS( 
	SELECT
		rowid,
		customer_id,
		STRFTIME('%Y-%m', invoice_date) as year_month,
		ROW_NUMBER() OVER(PARTITION BY STRFTIME('%Y-%m', invoice_date), customer_id  --We dont want to count multiple same day transactions for our retention
		ORDER BY rowid ASC
		) AS rn
	FROM cleaned_retail_transactions
),
duplicates_removed AS ( 
	SELECT 
		customer_id,
		year_month
	FROM ranked_transactions
	WHERE rn = 1 -- Selects the first row from our ranked transactions. rn is the partitions
),

-- Assigns a index to the first items purchased by a customer
customer_cohorts AS(
	SELECT 
		customer_id,
		year_month,
		MIN(year_month) OVER (PARTITION BY customer_id
		) AS cohort_month
	FROM duplicates_removed
),
--Assigns an value to how many months has passed since the FIRST customer purchase (0 indexed)
cohort_periods AS(
	SELECT 
		customer_id,
		cohort_month,
		(CAST(STRFTIME('%Y', year_month || '-01') AS INTEGER) - (CAST(STRFTIME('%Y', cohort_month || '-01') AS INTEGER))) 
		* 12 + (CAST(STRFTIME('%m', year_month || '-01') AS INTEGER) - (CAST(STRFTIME('%m', cohort_month || '-01') AS INTEGER))) AS cohort_index
		FROM customer_cohorts
),

-- Assigns each of the month value from the previous CTE to a specific bucket
cohort_counts AS(
	SELECT
		COUNT(customer_id) AS active_customer,
		cohort_month,
		cohort_index
	FROM cohort_periods
	GROUP BY cohort_month , cohort_index
	)

SELECT *
FROM cohort_counts;
		 

	