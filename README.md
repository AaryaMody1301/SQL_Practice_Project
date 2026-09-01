# SQL Practice Project

A PostgreSQL analytics portfolio project that began as a SQL learning project and is being rebuilt into a reproducible analytics-engineering case study.

## Project status

- **Phase 1 — Trustworthy SQL Foundation:** merged. The five foundational course analyses are corrected, cohort-consistent, linted, and regression-tested in PostgreSQL.
- **Phase 2 — Original Analytics:** implemented on `phase-2-original-analytics`. The repository now adds reusable analytical views and five repository-authored analyses beyond the course questions.

The older `sql_files/` directory remains as learning history. Supported analysis lives in `Project_sql/` and `analytics/`.

## Original Phase 2 analysis

Phase 2 asks five new questions:

1. What does the reported annual salary distribution for remote Data Analysts look like beyond the mean?
2. How do reported salaries compare between remote and onsite/hybrid Data Analyst postings?
3. How do posting volume, remote share, salary coverage, and median salary change by month?
4. How concentrated are Data Analyst postings across employers in the dataset?
5. Which skills repeatedly appear together in remote Data Analyst postings?

The analytical layer uses PostgreSQL quartiles/medians, filtered aggregates, window functions, cumulative concentration, and skill-pair self joins.

These are historical analyses of the source course dataset, not claims about current conditions.

## Repository structure

```text
Project_sql/                 verified foundational course queries
analytics/00_models.sql      reusable Data Analyst analytical views
analytics/questions/         repository-authored Phase 2 analyses
sql_files/                   historical SQL practice exercises
sql_load/                    PostgreSQL schema and portable CSV loader
docs/ANALYTICS_METHODS.md    Phase 2 methodology and interpretation limits
tests/fixtures/              deterministic CI dataset
tests/expected/              reviewed foundational outputs
tests/expected/analytics/    reviewed Phase 2 outputs
tests/sql/                   source and analytics data contracts
.github/workflows/           SQL lint and PostgreSQL integration CI
THIRD_PARTY_NOTICES.md       learning-project and dataset provenance
```

## Requirements

- PostgreSQL
- `psql`
- Python only when running SQLFluff locally

## Local setup with the course dataset

Create a database and schema:

```bash
createdb sql_course
psql -d sql_course -v ON_ERROR_STOP=1 -f sql_load/2_create_tables.sql
```

Place the four source CSV files under the ignored `csv_files/` directory:

```text
csv_files/company_dim.csv
csv_files/skills_dim.csv
csv_files/job_postings_fact.csv
csv_files/skills_job_dim.csv
```

Load the source data and build the analytical views:

```bash
psql -d sql_course -f sql_load/3_load_data.psql
psql -d sql_course -v ON_ERROR_STOP=1 -f analytics/00_models.sql
```

Run either a foundational query or an original analysis:

```bash
psql -d sql_course -f Project_sql/1_top_paying_jobs.sql
psql -d sql_course -f analytics/questions/1_salary_distribution.sql
```

The CSV loader uses psql client-side `\copy`, so paths are resolved on the client machine rather than inside the PostgreSQL server filesystem.

## Deterministic verification

The CI fixture is synthetic and belongs to this repository. It includes deliberately out-of-cohort rows, multiple months, missing salary data, and onsite postings so cohort and comparison regressions are detectable.

To reproduce the database checks locally:

```bash
createdb sql_course_test
psql -d sql_course_test -v ON_ERROR_STOP=1 -f sql_load/2_create_tables.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f tests/fixtures/seed.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f analytics/00_models.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f tests/sql/data_contracts.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f tests/sql/analytics_contracts.sql
```

CI executes every file in `Project_sql/` and `analytics/questions/` and compares pipe-delimited output with reviewed expected-result files.

## SQL quality

SQLFluff is pinned in CI and configured for PostgreSQL.

```bash
python -m pip install sqlfluff==4.3.0
sqlfluff lint Project_sql analytics sql_load/2_create_tables.sql --dialect postgres
```

## Analytical methodology

Phase 2 keeps missing salaries as missing, reports salary coverage with time trends, uses median/quartiles to complement averages, treats remote comparisons as descriptive rather than causal, and requires repeated support before returning skill pairs.

See `docs/ANALYTICS_METHODS.md` for the complete methodology and interpretation boundaries.

## Provenance

This repository began as coursework based on Luke Barousse's **SQL for Data Analytics** project and its job-postings dataset. The five foundational questions and source schema come from that learning material. Phase 1 adds independent correctness and verification work; Phase 2 adds original analytical questions and reusable models.

See `THIRD_PARTY_NOTICES.md` for source links and the provenance boundary. Raw course CSV files are not redistributed here.

## Next phase

Phase 3 will focus on performance engineering and evidence: `EXPLAIN (ANALYZE, BUFFERS)`, workload-driven index decisions, benchmark capture, and documented before/after query-plan comparisons.
