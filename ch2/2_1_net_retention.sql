WITH
date_range AS (
	SELECT '2020-03-01'::date AS start_date, 
	'2020-04-01'::date AS end_date
),
start_accounts AS (
	SELECT account_id, SUM(mrr) AS total_mrr
	FROM SUBSCRIPTION s 
	INNER JOIN date_range d 
	ON s.start_date <= d.start_date
	AND (s.end_date > d.start_date OR s.end_date IS null)
	GROUP BY account_id
), 
end_accounts AS (
	SELECT account_id, SUM(mrr) AS total_mrr
	FROM SUBSCRIPTION s 
	INNER JOIN date_range d 
	ON s.start_date <= d.end_date
	AND (s.end_date > d.end_date OR s.end_date IS null)
	GROUP BY account_id
), 
retained_accounts AS (
	SELECT s.account_id, SUM(e.total_mrr) AS total_mrr
	FROM start_accounts s 
	INNER JOIN end_accounts e 
	ON s.account_id = e.account_id
	GROUP BY s.account_id 
),
start_mrr AS (
	SELECT SUM(start_accounts.total_mrr) AS start_mrr
	FROM start_accounts
),
retain_mrr AS (
	SELECT SUM(retained_accounts.total_mrr) AS retain_mrr
	FROM retained_accounts
)
SELECT
	retain_mrr / start_mrr AS net_mrr_retention_rate,
	1.0 - retain_mrr / start_mrr AS net_mrr_churn_rate,
	start_mrr,
	retain_mrr
FROM start_mrr, retain_mrr