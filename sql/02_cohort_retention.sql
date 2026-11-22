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
) 
	
SELECT *
FROM duplicates_removed;
		
	