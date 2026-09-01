WITH top_paying_jobs AS (
    SELECT
        j.job_id,
        j.job_title,
        j.salary_year_avg,
        c.name AS company_name
    FROM job_postings_fact AS j
    LEFT JOIN company_dim AS c
        ON j.company_id = c.company_id
    WHERE j.job_title_short = 'Data Analyst'
        AND j.job_work_from_home IS TRUE
        AND j.salary_year_avg IS NOT NULL
    ORDER BY j.salary_year_avg DESC, j.job_id
    LIMIT 10
)
SELECT
    t.job_id,
    t.job_title,
    t.salary_year_avg,
    t.company_name,
    s.skills
FROM top_paying_jobs AS t
INNER JOIN skills_job_dim AS sj
    ON t.job_id = sj.job_id
INNER JOIN skills_dim AS s
    ON sj.skill_id = s.skill_id
ORDER BY t.salary_year_avg DESC, t.job_id, s.skills;
