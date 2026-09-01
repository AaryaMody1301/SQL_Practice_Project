SELECT
    TO_CHAR(DATE_TRUNC('month', job_posted_date), 'YYYY-MM') AS month,
    COUNT(*) AS posting_count,
    COUNT(*) FILTER (WHERE work_mode = 'Remote') AS remote_count,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE work_mode = 'Remote') / COUNT(*),
        2
    ) AS remote_share_pct,
    COUNT(salary_year_avg) AS salaried_count,
    ROUND(
        100.0 * COUNT(salary_year_avg) / COUNT(*),
        2
    ) AS salary_coverage_pct,
    ROUND((PERCENTILE_CONT(0.50) WITHIN GROUP (
        ORDER BY salary_year_avg
    ))::NUMERIC)::BIGINT AS median_salary
FROM analytics.data_analyst_postings
WHERE job_posted_date IS NOT NULL
GROUP BY DATE_TRUNC('month', job_posted_date)
ORDER BY DATE_TRUNC('month', job_posted_date);
