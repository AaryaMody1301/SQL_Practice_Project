WITH skill_pairs AS (
    SELECT
        left_skill.skill_id AS skill_1_id,
        left_skill.skill_name AS skill_1,
        right_skill.skill_id AS skill_2_id,
        right_skill.skill_name AS skill_2,
        COUNT(*) AS pair_count,
        COUNT(left_skill.salary_year_avg) AS salaried_postings,
        ROUND(AVG(left_skill.salary_year_avg))::BIGINT AS avg_salary
    FROM analytics.data_analyst_skills AS left_skill
    INNER JOIN analytics.data_analyst_skills AS right_skill
        ON left_skill.job_id = right_skill.job_id
        AND left_skill.skill_id < right_skill.skill_id
    WHERE left_skill.work_mode = 'Remote'
    GROUP BY
        left_skill.skill_id,
        left_skill.skill_name,
        right_skill.skill_id,
        right_skill.skill_name
    HAVING COUNT(*) >= 2
)

SELECT
    skill_1,
    skill_2,
    pair_count,
    salaried_postings,
    avg_salary
FROM skill_pairs
ORDER BY pair_count DESC, skill_1_id, skill_2_id;
