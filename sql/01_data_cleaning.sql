--Formatting InvoiceDate to be in YYYY-MM-DD
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
		SUBSTR('0' || SUBSTR(InvoiceDate, 1, slash1 - 1), -2, 2) AS day, --Adds a 0 to the month 
		SUBSTR('0' || SUBSTR(slash2, 1, INSTR(slash2, '/') - 1), -2, 2) AS month, 
		SUBSTR(slash2, INSTR(slash2, '/') + 1, 4) AS year, --Gets the year value
		SUBSTR('0' || SUBSTR(InvoiceDate, space + 1), -5, 5) AS time_part
	FROM parsed
),
cleaned AS(
	SELECT
		r.Invoice AS invoice,
		TRIM(r.StockCode) AS stock_code,
		TRIM(r.Description) AS description,
		

	
	
		
		
		