SELECT
    work_mode,
    COUNT(*) AS salaried_postings,
    ROUND(AVG(salary_year_avg))::BIGINT AS avg_salary,
    ROUND((PERCENTILE_CONT(0.50) WITHIN GROUP (
        ORDER BY salary_year_avg
    ))::NUMERIC)::BIGINT AS median_salary
FROM analytics.data_analyst_postings
WHERE
    work_mode IN ('Remote', 'Onsite/Hybrid')
    AND salary_year_avg IS NOT NULL
GROUP BY work_mode
ORDER BY work_mode;
