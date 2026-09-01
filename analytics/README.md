# Original Analytics Layer

Phase 2 moves beyond the five foundational course questions into repository-authored analysis.

## Model layer

Run `00_models.sql` after loading the source tables. It creates:

- `analytics.data_analyst_postings` — one row per Data Analyst posting with company context and a normalized work-mode label.
- `analytics.data_analyst_skills` — one row per Data Analyst posting/skill pair for reusable skill analysis.

The views intentionally remain ordinary PostgreSQL views. The repository does not currently need persisted query results or a refresh lifecycle.

## Questions

1. `questions/1_salary_distribution.sql` — remote salary distribution using quartiles and the median, not only the mean.
2. `questions/2_remote_salary_comparison.sql` — reported annual compensation for remote versus onsite/hybrid Data Analyst postings.
3. `questions/3_monthly_hiring_trend.sql` — monthly posting volume, remote share, salary coverage, and median reported salary.
4. `questions/4_company_concentration.sql` — employer share, rank, and cumulative concentration across Data Analyst postings.
5. `questions/5_skill_pair_cooccurrence.sql` — skill combinations that repeatedly appear together in remote Data Analyst postings.

## Run locally

```bash
psql -d sql_course -v ON_ERROR_STOP=1 -f analytics/00_models.sql
psql -d sql_course -f analytics/questions/1_salary_distribution.sql
```

Each analytical question is executed in CI against the synthetic fixture and compared with a reviewed output under `tests/expected/analytics/`.
