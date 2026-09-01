SELECT
    COUNT(*) AS salaried_postings,
    ROUND(MIN(salary_year_avg))::BIGINT AS min_salary,
    ROUND((PERCENTILE_CONT(0.25) WITHIN GROUP (
        ORDER BY salary_year_avg
    ))::NUMERIC)::BIGINT AS p25_salary,
    ROUND((PERCENTILE_CONT(0.50) WITHIN GROUP (
        ORDER BY salary_year_avg
    ))::NUMERIC)::BIGINT AS median_salary,
    ROUND(AVG(salary_year_avg))::BIGINT AS avg_salary,
    ROUND((PERCENTILE_CONT(0.75) WITHIN GROUP (
        ORDER BY salary_year_avg
    ))::NUMERIC)::BIGINT AS p75_salary,
    ROUND(MAX(salary_year_avg))::BIGINT AS max_salary
FROM analytics.data_analyst_postings
WHERE
    work_mode = 'Remote'
    AND salary_year_avg IS NOT NULL;
