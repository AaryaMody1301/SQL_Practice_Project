# SQL Practice Project

[![SQL quality](https://github.com/AaryaMody1301/SQL_Practice_Project/actions/workflows/sql-quality.yml/badge.svg)](https://github.com/AaryaMody1301/SQL_Practice_Project/actions/workflows/sql-quality.yml)
[![Performance evidence](https://github.com/AaryaMody1301/SQL_Practice_Project/actions/workflows/performance.yml/badge.svg)](https://github.com/AaryaMody1301/SQL_Practice_Project/actions/workflows/performance.yml)

A PostgreSQL analytics-engineering portfolio case study rebuilt from a SQL learning project. The repository keeps the original course questions as attributed foundations, then adds reproducible setup, correctness contracts, original analytical models/questions, measured performance engineering, and release-grade documentation.

**Release target:** `v1.0.0`

**Data period:** historical 2023 job postings

**Database:** PostgreSQL 18 in CI

> Historical job-market results in this repository describe the source 2023 dataset. They are not claims about the current job market.

## Portfolio highlights

- Corrected and cohort-standardized five foundational Data Analyst queries.
- Portable PostgreSQL setup using client-side psql `\copy` instead of machine-specific server paths.
- Deterministic synthetic fixture, relational/analytical contracts, frozen expected outputs, SQLFluff, and PostgreSQL-backed GitHub Actions.
- Two reusable analytical views at posting and posting-skill grain.
- Five repository-authored analyses: salary distribution, remote-vs-onsite compensation, monthly hiring/salary coverage, employer concentration, and skill-pair co-occurrence.
- Evidence-driven indexing based on `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, FORMAT JSON)` rather than generic optimization claims.
- ERD, data dictionary, methodology, provenance-safe findings, benchmark evidence, changelog, and release notes.

## Analytical model

The supported analytical layer lives in `analytics/`:

1. `analytics.data_analyst_postings` — one row per Data Analyst posting, with normalized work mode.
2. `analytics.data_analyst_skills` — one row per Data Analyst posting-skill relationship.

The five original analyses answer:

1. What does the remote Data Analyst salary distribution look like beyond the mean?
2. How do reported salaries compare between remote and onsite/hybrid postings?
3. How do posting volume, remote share, salary coverage, and median salary vary by month?
4. How concentrated are Data Analyst postings across employers?
5. Which skills repeatedly appear together in remote Data Analyst postings?

See [`docs/ANALYTICS_METHODS.md`](docs/ANALYTICS_METHODS.md) for methodology and interpretation boundaries.

## Performance evidence

Phase 3 uses a deterministic workload with **200,000 job postings**, **40,000 Data Analyst postings**, **10,000 remote Data Analyst postings**, and **600,000 job-skill relationships**.

Median PostgreSQL 18 acceptance results:

| Query | Baseline | Indexed | Improvement |
| --- | ---: | ---: | ---: |
| Top-paying remote jobs | 19.198 ms | 0.105 ms | 99.5% |
| Company concentration | 28.241 ms | 20.656 ms | 26.9% |
| Remote salary distribution | 23.816 ms | 17.726 ms | 25.6% |
| Monthly hiring trend | 44.259 ms | 34.606 ms | 21.8% |
| Top-demanded remote skills | 49.395 ms | 45.865 ms | 7.1% |
| Skill-pair co-occurrence | 92.232 ms | 91.361 ms | 0.9% |

The strongest accepted optimization reduced the top-paying remote-job query from **19.198 ms to 0.105 ms** and shared-block activity from **4,203 to 38**. No extra skill-pair-specific index was added because the measured benefit was negligible.

Full methodology and evidence:

- [`performance/README.md`](performance/README.md)
- [`performance/BENCHMARK_RESULTS.md`](performance/BENCHMARK_RESULTS.md)

## Schema documentation

- [`docs/ERD.md`](docs/ERD.md) — Mermaid entity-relationship diagram.
- [`docs/DATA_DICTIONARY.md`](docs/DATA_DICTIONARY.md) — tables, views, keys, null semantics, and supported indexes.
- [`docs/PORTFOLIO_FINDINGS.md`](docs/PORTFOLIO_FINDINGS.md) — upstream reference findings, repository-authored analytical scope, reproducibility guidance, and repository-owned benchmark findings.

## Repository structure

```text
Project_sql/                     corrected foundational course analyses
analytics/00_models.sql          reusable analytical views
analytics/questions/             repository-authored analyses
performance/                     deterministic benchmark and evidence
sql_files/                       historical SQL practice exercises
sql_load/                        PostgreSQL schema and portable CSV loader
docs/                            ERD, dictionary, methods, findings, release notes
tests/fixtures/                  deterministic correctness fixture
tests/expected/                  reviewed foundational outputs
tests/expected/analytics/        reviewed original analytics outputs
tests/sql/                       relational and analytical contracts
.github/workflows/               correctness, performance, release-readiness CI
CHANGELOG.md                     v1.0.0 change history
VERSION                          release version
THIRD_PARTY_NOTICES.md           source/course provenance boundary
```

## Local setup

Requirements:

- PostgreSQL
- `psql`
- Python only for SQLFluff or the performance summary script

Create the database and schema:

```bash
createdb sql_course
psql -d sql_course -v ON_ERROR_STOP=1 -f sql_load/2_create_tables.sql
```

Place the four source course CSVs under the ignored `csv_files/` directory:

```text
csv_files/company_dim.csv
csv_files/skills_dim.csv
csv_files/job_postings_fact.csv
csv_files/skills_job_dim.csv
```

Load data and create analytical views:

```bash
psql -d sql_course -f sql_load/3_load_data.psql
psql -d sql_course -v ON_ERROR_STOP=1 -f analytics/00_models.sql
```

Run analyses:

```bash
psql -d sql_course -f Project_sql/1_top_paying_jobs.sql
psql -d sql_course -f analytics/questions/1_salary_distribution.sql
```

## Deterministic verification

The correctness fixture belongs to this repository and deliberately contains out-of-cohort rows, onsite/remote roles, multiple months, and missing salaries so analytical regressions are detectable.

```bash
createdb sql_course_test
psql -d sql_course_test -v ON_ERROR_STOP=1 -f sql_load/2_create_tables.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f tests/fixtures/seed.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f analytics/00_models.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f tests/sql/data_contracts.sql
psql -d sql_course_test -v ON_ERROR_STOP=1 -f tests/sql/analytics_contracts.sql
```

CI also executes every supported foundational/original analysis and diffs its result against reviewed expected output.

## SQL quality

SQLFluff is pinned for reproducibility:

```bash
python -m pip install sqlfluff==4.3.0
sqlfluff lint Project_sql analytics performance/01_drop_candidate_indexes.sql performance/02_candidate_indexes.sql sql_load/2_create_tables.sql --dialect postgres
```

## Reproduce the performance benchmark

```bash
psql -d sql_course -v ON_ERROR_STOP=1 -f performance/00_seed_benchmark.sql
psql -d sql_course -v ON_ERROR_STOP=1 -f analytics/00_models.sql
bash performance/run_benchmarks.sh
```

The runner measures baseline and candidate-index states on the same generated workload and writes `performance/results/performance-summary.md`.

## Provenance and licensing boundary

This repository began as coursework based on Luke Barousse's **SQL for Data Analytics** project and its job-postings dataset. The source schema and five foundational questions are attributed upstream. Repository-authored work includes correctness fixes, portable setup, tests/contracts, analytical views and questions, performance benchmarking/index decisions, and release documentation.

Raw course CSV files are not redistributed. A blanket repository license is intentionally not asserted over upstream material; see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## v1.0.0 release

The repository prepares release version `1.0.0` in [`VERSION`](VERSION), [`CHANGELOG.md`](CHANGELOG.md), and [`docs/RELEASE_NOTES_v1.0.0.md`](docs/RELEASE_NOTES_v1.0.0.md). The `v1.0.0` Git tag should be created only from the merged `main` commit after all release checks are green.
