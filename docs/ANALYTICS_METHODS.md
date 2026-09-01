# Analytics Methods

## Scope

Phase 2 is a reproducible analysis of the historical course dataset. It does not describe current conditions.

The reusable posting view includes rows where `job_title_short = 'Data Analyst'`. Work mode is mapped from `job_work_from_home`: true is `Remote`, false is `Onsite/Hybrid`, and null is `Unknown`.

## Salary metrics

Salary calculations use `salary_year_avg` only when it is present. Missing salaries are not filled in.

The analysis reports quartiles and the median with the arithmetic mean. PostgreSQL `PERCENTILE_CONT` is used for the continuous percentile calculations.

## Work-mode comparison

The remote and onsite/hybrid salary results are descriptive comparisons. They are not causal estimates because role seniority, employers, locations, and other factors can differ between the groups.

## Monthly trend

Monthly results use the calendar month from `job_posted_date`. Each row includes posting volume, remote share, salary coverage, and median reported salary so compensation results can be interpreted together with data availability.

## Company concentration

Company concentration is the share of Data Analyst postings represented by each company in this dataset. `DENSE_RANK` and a cumulative window sum provide rank and cumulative share.

## Skill pairs

Skill pairs are built from job-skill relationships for remote Data Analyst postings. Pairs must appear in at least two postings to be returned. This transparent support rule avoids treating one-off pairs in the fixture as meaningful patterns.

## Verification boundary

GitHub Actions executes the Phase 2 SQL against the synthetic fixture and compares results with reviewed files under `tests/expected/analytics/`. These fixtures validate query behavior, not real-world findings.
