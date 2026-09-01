WITH skills_demand AS (
    SELECT
        sj.skill_id,
        s.skills,
        COUNT(sj.job_id) AS demand_count
    FROM job_postings_fact AS j
    INNER JOIN skills_job_dim AS sj
        ON j.job_id = sj.job_id
    INNER JOIN skills_dim AS s
        ON sj.skill_id = s.skill_id
    WHERE j.job_title_short = 'Data Analyst'
        AND j.job_work_from_home IS TRUE
        AND j.salary_year_avg IS NOT NULL
    GROUP BY sj.skill_id, s.skills
),
avg_salary AS (
    SELECT
        sj.skill_id,
        ROUND(AVG(j.salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact AS j
    INNER JOIN skills_job_dim AS sj
        ON j.job_id = sj.job_id
    WHERE j.job_title_short = 'Data Analyst'
        AND j.job_work_from_home IS TRUE
        AND j.salary_year_avg IS NOT NULL
    GROUP BY sj.skill_id
)
SELECT
    d.skill_id,
    d.skills,
    d.demand_count,
    a.avg_salary
FROM skills_demand AS d
INNER JOIN avg_salary AS a
    ON d.skill_id = a.skill_id
WHERE d.demand_count > 10
ORDER BY d.demand_count DESC, a.avg_salary DESC, d.skills;
