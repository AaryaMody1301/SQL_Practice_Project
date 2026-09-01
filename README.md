# SQL Practice Project

A PostgreSQL analytics portfolio project that began as a SQL learning project and is being rebuilt into a reproducible analytics-engineering case study.

## Project status

- **Phase 1 — Trustworthy SQL Foundation:** merged. The five foundational course analyses are corrected, cohort-consistent, linted, and regression-tested in PostgreSQL.
- **Phase 2 — Original Analytics:** merged. The repository adds reusable analytical views and five repository-authored analyses beyond the course questions.
- **Phase 3 — Performance Engineering:** implemented on `phase-3-performance-engineering`. Query plans are benchmarked with PostgreSQL before indexes are promoted into the supported schema.

The older `sql_files/` directory remains as learning history. Supported analysis lives in `Project_sql/` and `analytics/`.

## Original analytics

Phase 2 asks five repository-authored questions:

1. What does the reported annual salary distribution for remote Data Analysts look like beyond the mean?
2. How do reported salaries compare between remote and onsite/hybrid Data Analyst postings?
3. How do posting volume, remote share, salary coverage, and median salary change by month?
4. How concentrated are Data Analyst postings across employers in the dataset?
5. Which skills repeatedly appear together in remote Data Analyst postings?

The analytical layer uses PostgreSQL quartiles/medians, filtered aggregates, window functions, cumulative concentration, and skill-pair self joins.

These are historical analyses of the source course dataset, not claims about current conditions.

## Phase 3 performance evidence

Phase 3 adds a deterministic 200,000-posting / 600,000-job-skill benchmark and measures repository queries before and after candidate indexes with `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, FORMAT JSON)`.

The acceptance benchmark on PostgreSQL 18.6 produced these median execution results:

| Query | Baseline | Indexed | Improvement |
| --- | ---: | ---: | ---: |
| Top-paying remote jobs | 19.198 ms | 0.105 ms | 99.5% |
| Company concentration | 28.241 ms | 20.656 ms | 26.9% |
| Remote salary distribution | 23.816 ms | 17.726 ms | 25.6% |
| Monthly hiring trend | 44.259 ms | 34.606 ms | 21.8% |
| Top-demanded remote skills | 49.395 ms | 45.865 ms | 7.1% |
| Skill-pair co-occurrence | 92.232 ms | 91.361 ms | 0.9% |

Two partial covering indexes were accepted because PostgreSQL selected them across the measured workloads and their storage cost was modest:

- `idx_job_postings_remote_da_salary`
- `idx_job_postings_da_work_mode_job`

No additional skill-pair-specific index was added because the measured query did not use either candidate and showed no meaningful improvement.

See `performance/BENCHMARK_RESULTS.md` for the full evidence, buffer counts, index sizes, acceptance decisions, and interpretation limits.

## Repository structure

```text
Project_sql/                    verified foundational course queries
analytics/00_models.sql         reusable Data Analyst analytical views
analytics/questions/            repository-authored Phase 2 analyses
performance/                    benchmark workload, runner, plans summary, and evidence
sql_files/                      historical SQL practice exercises
sql_load/                       PostgreSQL schema and portable CSV loader
docs/ANALYTICS_METHODS.md       analytical methodology and interpretation limits
tests/fixtures/                 deterministic correctness fixture
tests/expected/                 reviewed foundational outputs
tests/expected/analytics/       reviewed original analytics outputs
tests/sql/                      source and analytics data contracts
.github/workflows/              SQL correctness and performance CI
THIRD_PARTY_NOTICES.md          learning-project and dataset provenance
```

## Requirements

- PostgreSQL
- `psql`
- Python only when running SQLFluff or the performance summary script locally

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

The correctness fixture is synthetic and belongs to this repository. It includes deliberately out-of-cohort rows, multiple months, missing salary data, and onsite postings so cohort and comparison regressions are detectable.

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

## Reproduce the performance benchmark

The performance workload is separate from the correctness fixture:

```bash
psql -d sql_course -v ON_ERROR_STOP=1 -f performance/00_seed_benchmark.sql
psql -d sql_course -v ON_ERROR_STOP=1 -f analytics/00_models.sql
bash performance/run_benchmarks.sh
```

The runner removes the Phase 3 indexes for a baseline, collects three warm-cache plans per query, creates the accepted candidate indexes, repeats the measurements, and writes `performance/results/performance-summary.md`.

## SQL quality

SQLFluff is pinned in CI and configured for PostgreSQL.

```bash
python -m pip install sqlfluff==4.3.0
sqlfluff lint Project_sql analytics performance/01_drop_candidate_indexes.sql performance/02_candidate_indexes.sql sql_load/2_create_tables.sql --dialect postgres
```

## Analytical methodology

The analytical layer keeps missing salaries as missing, reports salary coverage with time trends, uses median/quartiles to complement averages, treats remote comparisons as descriptive rather than causal, and requires repeated support before returning skill pairs.

See `docs/ANALYTICS_METHODS.md` for the complete methodology and interpretation boundaries.

## Performance methodology

Phase 3 treats execution time as supporting evidence rather than a universal latency guarantee. Index decisions also consider planner selection, buffer activity, workload coverage, and storage cost. The benchmark is run on one deterministic workload so before/after states are directly comparable in CI.

See `performance/README.md` and `performance/BENCHMARK_RESULTS.md` for details.

## Provenance

This repository began as coursework based on Luke Barousse's **SQL for Data Analytics** project and its job-postings dataset. The five foundational questions and source schema come from that learning material. Phase 1 adds independent correctness and verification work; Phase 2 adds original analytical questions and reusable models; Phase 3 adds repository-authored performance benchmarking and workload-driven schema optimization.

See `THIRD_PARTY_NOTICES.md` for source links and the provenance boundary. Raw course CSV files are not redistributed here.

## Next phase

Phase 4 will focus on the portfolio release: final documentation/ERD and data dictionary, reviewed example findings, release metadata, and a clean `v1.0.0` package.
