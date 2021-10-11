WITH 
date_range AS (
	SELECT 
		'2020-03-01'::timestamp AS start_date,
		'2020-04-01'::timestamp AS end_date,
		INTERVAL '1 months' AS inactivity_interval
),
start_accounts AS (
	SELECT DISTINCT account_id
	FROM EVENT e 
	INNER JOIN date_range d 
	ON e.event_time > start_date - inactivity_interval
	AND e.event_time <= start_date
),
start_count AS (
	SELECT count(start_accounts.*) AS n_start
	FROM start_accounts
),
end_accounts AS (
	SELECT DISTINCT account_id
	FROM EVENT e 
	INNER JOIN date_range d 
	ON e.event_time > end_date - inactivity_interval
	AND e.event_time <= end_date
),
end_count AS (
	SELECT count(end_accounts.*) AS n_end
	FROM end_accounts
),
churned_accounts AS (
	SELECT DISTINCT s.account_id
	FROM start_accounts s
	LEFT OUTER JOIN end_accounts e 
	ON s.account_id = e.account_id 
	WHERE e.account_id IS null
),
churn_count AS (
	SELECT count(churned_accounts.*) AS n_churn
	FROM churned_accounts
)
SELECT
	n_churn::float / n_start::float AS churn_rate,
	1.0 - n_churn::float / n_start::float AS retention_rate,
	n_start,
	n_churn
FROM 
	start_count, end_count, churn_count
