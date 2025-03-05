SELECT *
FROM
    (SELECT *
     FROM job_postings_fact
     WHERE EXTRACT (MONTH FROM job_posted_date) = 1) 
    AS january_jobs;



WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1
)
SELECT *
FROM january_jobs;



SELECT 
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
    SELECT 
        company_id
    FROM
        job_postings_fact
    WHERE 
        job_no_degree_mention = TRUE
);



WITH company_job_counts AS (
    SELECT 
        company_id,
        COUNT(*) AS job_count
    FROM 
        job_postings_fact
    GROUP BY 
        company_id
)
SELECT 
    company_dim.name AS company_name,
    company_job_counts.job_count
FROM
    company_dim
LEFT JOIN
    company_job_counts ON company_dim.company_id = company_job_counts.company_id
ORDER BY
    company_job_counts.job_count DESC;