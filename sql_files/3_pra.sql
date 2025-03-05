/*SELECT 
    sd.skills AS skill_name, 
    sub.skill_count
FROM
    skills_dim sd
JOIN (
    SELECT 
         skill_id, 
         COUNT(*) AS skill_count
    FROM 
         skills_job_dim
    GROUP BY 
         skill_id
    ORDER BY 
         skill_count DESC
    LIMIT 5
) AS sub ON sd.skill_id = sub.skill_id
ORDER BY 
    sub.skill_count DESC;*/

SELECT 
    cd.name AS company_name,
    cjc.job_count,
    CASE
        WHEN cjc.job_count < 10 THEN 'Small'
        WHEN cjc.job_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS size_category
FROM company_dim cd
JOIN (
    SELECT 
         company_id, 
         COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY company_id
) AS cjc ON cd.company_id = cjc.company_id
ORDER BY cjc.job_count DESC;