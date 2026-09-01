SELECT
    j.job_id,
    j.job_title,
    j.job_location,
    j.job_schedule_type,
    j.salary_year_avg,
    j.job_posted_date,
    c.name AS company_name
FROM job_postings_fact AS j
LEFT JOIN company_dim AS c
    ON j.company_id = c.company_id
WHERE j.job_title_short = 'Data Analyst'
    AND j.job_work_from_home IS TRUE
    AND j.salary_year_avg IS NOT NULL
ORDER BY j.salary_year_avg DESC, j.job_id
LIMIT 10;
