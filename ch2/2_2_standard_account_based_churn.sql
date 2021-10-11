WITH 
date_range AS (
	SELECT 
	'2020-03-01'::date AS start_date,
	'2020-04-01'::date AS end_date
),
start_accounts AS (
	SELECT DISTINCT account_id
	FROM SUBSCRIPTION s 
	INNER JOIN date_range d 
	ON s.start_date <= d.start_date
	AND (s.end_date > d.start_date OR s.end_date IS null)
),
end_accounts AS (
	SELECT DISTINCT account_id
	FROM SUBSCRIPTION s
	INNER JOIN date_range d 
	ON s.start_date <= d.end_date
	AND (s.end_date > d.end_date OR s.end_date IS null) 
), 
churned_accounts AS (
	SELECT s.account_id 
	FROM start_accounts s
	LEFT OUTER JOIN end_accounts e 
	ON s.account_id = e.account_id
	WHERE e.account_id IS null
),
start_count AS (
	SELECT count(*) AS n_start
	FROM start_accounts
),
churn_count AS (
	SELECT count(*) AS n_churn
	FROM churned_accounts
)
SELECT
	n_churn::float/n_start::float AS churn_rate,
	1.0 - n_churn::float/n_start::float AS retention_rate,
	n_start,
	n_churn
FROM 
	start_count, churn_count