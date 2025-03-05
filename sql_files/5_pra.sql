/*SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    sd.skills AS skill_name,
    sd.type AS skill_type
FROM 
    job_postings_fact jpf
LEFT JOIN 
    skills_job_dim sjd ON jpf.job_id = sjd.job_id
LEFT JOIN 
    skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE 
    EXTRACT(MONTH FROM jpf.job_posted_date) BETWEEN 1 AND 3
    AND jpf.salary_year_avg > 70000
ORDER BY 
    jpf.job_id, sd.skills;*/

SELECT 
    quater1_job_postings.job_title_short,
    quater1_job_postings.job_location,
    quater1_job_postings.job_via,
    quater1_job_postings.job_posted_date::DATE,
    quater1_job_postings.salary_year_avg
FROM (
    SELECT * 
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS quater1_job_postings
WHERE 
    quater1_job_postings.salary_year_avg > 70000 AND quater1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
    quater1_job_postings.salary_year_avg DESC;