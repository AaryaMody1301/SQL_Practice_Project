SELECT
    s.skills,
    COUNT(sj.job_id) AS skill_count
FROM job_postings_fact AS j
INNER JOIN skills_job_dim AS sj
    ON j.job_id = sj.job_id
INNER JOIN skills_dim AS s
    ON sj.skill_id = s.skill_id
WHERE
    j.job_title_short = 'Data Analyst'
    AND j.job_work_from_home IS TRUE
GROUP BY s.skills
ORDER BY skill_count DESC, s.skills
LIMIT 5;
