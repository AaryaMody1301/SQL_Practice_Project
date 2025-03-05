SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS avg_salary,
    AVG(salary_hour_avg) AS avg_hourly_salary
FROM
    job_postings_fact
WHERE
    job_posted_date >= '2023-07-01'
GROUP BY 
    job_schedule_type;

SELECT
    COUNT(job_id) AS job_posting_count,
    job_posted_date AT TIME ZONE 'America/New_York' AS time,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM
    job_postings_fact
WHERE
    job_posted_date >= '2023-01-01' AND job_posted_date < '2024-01-01'
GROUP BY
    time,
    month
ORDER BY
    month;

SELECT
    company_dim.name AS company_name,
    job_postings_fact.job_health_insurance AS health_insurance,
    job_postings_fact.job_posted_date AS posting_date
FROM
    job_postings_fact
    JOIN
    company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE 
    job_postings_fact.job_health_insurance = TRUE
    AND job_postings_fact.job_posted_date > '2023-04-01'
    AND job_postings_fact.job_posted_date < '2023-07-01'
ORDER BY
    posting_date DESC;



