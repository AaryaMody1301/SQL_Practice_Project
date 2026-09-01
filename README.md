# SQL Practice Project

A PostgreSQL analytics portfolio project built from a SQL learning project and hardened for reproducibility, correctness, and automated verification.

## Phase 1 status

**Trustworthy SQL Foundation is implemented on the Phase 1 branch.** The five portfolio queries now use a consistent remote Data Analyst cohort, execute against PostgreSQL in CI, and are checked against deterministic expected results.

The repository intentionally keeps the older `sql_files/` exercises as learning history. The supported portfolio analysis lives in `Project_sql/`.

## What the analysis answers

1. Which remote Data Analyst jobs have the highest reported annual salaries?
2. Which skills appear in those top-paying remote roles?
3. Which skills are most demanded across remote Data Analyst postings?
4. Which skills are associated with the highest average reported annual salaries for remote Data Analysts?
5. Which skills combine meaningful remote-job demand with higher reported annual salaries?

These are historical analyses of the source course dataset, not claims about the current job market.

## Repository structure

```text
Project_sql/                 verified portfolio queries
sql_files/                   historical SQL practice exercises
sql_load/                    PostgreSQL schema and portable CSV loader
tests/fixtures/              deterministic CI dataset
tests/expected/              reviewed query outputs for the fixture
tests/sql/                   relational data-contract assertions
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

Then load them from the repository root:

```bash
psql -d sql_course -f sql_load/3_load_data.psql
```

The loader uses psql client-side `\copy`, so CSV paths are resolved on the client machine rather than inside the PostgreSQL server filesystem.

Run an analysis:

```bash
psql -d sql_course -f Project_sql/1_top_paying_jobs.sql
```

## Deterministic verification

The CI fixture is synthetic and belongs to this repository. It includes remote Data Analyst roles plus deliberately high-paid out-of-cohort rows so accidental filter regressions are visible.

To reproduce the integration checks locally:

```bash
createdb sql_course_test
psql -d sql_course_test -v ON_ERROR_STOP=1 -f sql_load/2_create_tables.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f tests/fixtures/seed.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f tests/sql/data_contracts.sql
```

CI additionally runs every file in `Project_sql/` and compares its pipe-delimited output with the reviewed files in `tests/expected/`.

## SQL quality

SQLFluff is pinned in CI and configured for the PostgreSQL dialect.

```bash
python -m pip install sqlfluff==4.3.0
sqlfluff lint Project_sql sql_load/2_create_tables.sql --dialect postgres
```

## Data contracts

Phase 1 validates core assumptions including:

- unique primary identifiers;
- positive non-null annual salaries when salary is present;
- non-empty skill names;
- no orphaned job-skill relationships.

Foreign keys and primary keys are also enforced by the PostgreSQL schema.

## Provenance

This repository began as coursework based on Luke Barousse's **SQL for Data Analytics** project and its job-postings dataset. The five original business questions and source schema come from that learning material. Phase 1 adds independent correctness fixes, portable setup, deterministic fixtures, data-contract checks, linting, and CI.

See `THIRD_PARTY_NOTICES.md` for source links and the provenance boundary. Raw course CSV files are not redistributed in this repository.

## Next phase

Phase 2 will move beyond the course questions into original analytics-engineering work: temporal hiring trends, salary distributions, remote-work comparisons, skill co-occurrence, company concentration, and reusable analytical models/views.
