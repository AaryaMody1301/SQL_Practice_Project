WITH
    skills_demand
    AS
    (
        SELECT
            skills_job_dim.skill_id,
            skills,
            COUNT(skills_job_dim.job_id) AS skill_count
        FROM job_postings_fact
            INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
            INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
        WHERE job_title_short = 'Data Analyst'
            AND job_work_from_home = 'True'
            AND salary_year_avg IS NOT NULL
        GROUP BY skills_job_dim.skill_id, skills
    ),
    avg_salary
    AS
    (
        SELECT
            skills_job_dim.skill_id,
            skills,
            ROUND(AVG(salary_year_avg), 0) AS avg_salary
        FROM job_postings_fact
            INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
            INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
        WHERE job_title_short = 'Data Analyst'
            AND salary_year_avg IS NOT NULL
        GROUP BY skills_job_dim.skill_id, skills
    )

SELECT
    sd.skill_id,
    sd.skills,
    sd.skill_count AS demand_count,
    a.avg_salary
FROM skills_demand sd
    INNER JOIN avg_salary a ON sd.skill_id = a.skill_id
WHERE sd.skill_count > 10
ORDER BY demand_count DESC, avg_salary DESC;