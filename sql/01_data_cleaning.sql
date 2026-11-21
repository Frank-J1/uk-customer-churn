CREATE TABLE cleaned_retail_transactions AS 
WITH parsed AS (
	SELECT
		rowid,
		InvoiceDate,
		INSTR(InvoiceDate, '/') AS slash1, --First slash instance
		SUBSTR(InvoiceDate, INSTR(InvoiceDate, '/') + 1) AS slash2, --String containing second slash instance
		INSTR(InvoiceDate, ' ') AS space --Time probably won't be important, but we will parse it aswell
	FROM raw_retail_transactions
), 
parts AS (
	SELECT
		rowid,
		SUBSTR('0' || SUBSTR(InvoiceDate, 1, slash1 - 1), -2, 2) AS month, --Adds a 0 to the month 
		SUBSTR('0' || SUBSTR(slash2, 1, INSTR(slash2, '/') - 1), -2, 2) AS day, 
		SUBSTR(slash2, INSTR(slash2, '/') + 1, 4) AS year, --Gets the year value
		SUBSTR('0' || SUBSTR(InvoiceDate, space + 1), -5, 5) AS time_part
	FROM parsed
),
cleaned AS(
	--These fields do not contain NULL values, checked in a seperate SQL script
	SELECT
		r.Invoice AS invoice,
		TRIM(r.StockCode) AS stock_code,
		TRIM(r.Description) AS description,
		r.Quantity AS quantity,
		DATE(p.year || '-' || p.month || '-' || p.day) AS invoice_date, -- Convert to DATE, this does not include the time
		r.Price AS price,
		TRIM(r."Customer ID") AS customer_id,
		TRIM(r.country) AS country
	FROM raw_retail_transactions AS r
	JOIN parts AS p ON r.rowid = p.rowid -- Join the tables on the same row ID's
)
SELECT *
FROM cleaned;


SELECT * 
FROM cleaned_retail_transactions
LIMIT 10;

DROP TABLE IF EXISTS cleaned_retail_transactions;