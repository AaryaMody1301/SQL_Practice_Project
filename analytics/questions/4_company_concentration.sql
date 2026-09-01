WITH company_counts AS (
    SELECT
        company_id,
        company_name,
        COUNT(*) AS posting_count
    FROM analytics.data_analyst_postings
    GROUP BY company_id, company_name
),
ranked AS (
    SELECT
        company_id,
        company_name,
        posting_count,
        SUM(posting_count) OVER () AS total_postings,
        DENSE_RANK() OVER (
            ORDER BY posting_count DESC
        ) AS concentration_rank,
        SUM(posting_count) OVER (
            ORDER BY posting_count DESC, company_name
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_postings
    FROM company_counts
)

SELECT
    company_name,
    posting_count,
    ROUND(100.0 * posting_count / total_postings, 2) AS posting_share_pct,
    concentration_rank,
    ROUND(100.0 * cumulative_postings / total_postings, 2) AS cumulative_share_pct
FROM ranked
ORDER BY posting_count DESC, company_name;
