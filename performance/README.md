# Performance Engineering

Phase 3 measures query plans before accepting new indexes into the supported PostgreSQL schema.

## Benchmark workload

`00_seed_benchmark.sql` generates a deterministic synthetic workload with:

- 200,000 job postings;
- 40,000 Data Analyst postings;
- a selective remote Data Analyst cohort;
- 500 companies;
- 20 skills;
- 600,000 job-skill relationships;
- annual salary values with deliberate missingness;
- one year of posting timestamps.

The workload is not intended to imitate the real distribution of the course dataset. Its purpose is to be large enough and selective enough for PostgreSQL planner choices to be observable and repeatable in CI.

## Queries measured

The benchmark executes repository queries rather than separate toy SQL:

- top-paying remote Data Analyst jobs;
- top-demanded remote Data Analyst skills;
- remote salary distribution;
- monthly hiring trend;
- company concentration;
- remote skill-pair co-occurrence.

## Measurement method

For every query and state:

1. execute one warm-up plan;
2. collect three `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, SUMMARY ON, FORMAT JSON)` plans;
3. report median total execution time and shared-buffer activity;
4. record which candidate indexes PostgreSQL actually chose.

The two states are measured in the same GitHub Actions job:

- **baseline**: candidate Phase 3 indexes are absent;
- **indexed**: candidate indexes are created and table statistics are refreshed with `ANALYZE`.

`TIMING OFF` avoids per-plan-node clock calls while preserving total execution time and actual row counts. This makes the benchmark more focused on planner behavior and buffer work.

## Candidate indexes

Phase 3 initially tests two partial covering indexes:

- a remote Data Analyst salary index for selective salary ranking/distribution work;
- a Data Analyst work-mode/job index for analytical scans and job-skill joins.

These are candidates, not automatically accepted schema changes. The final Phase 3 schema should retain only indexes supported by the measured evidence.

## Reproduce locally

With PostgreSQL running and the repository schema loaded:

```bash
psql -d sql_course -v ON_ERROR_STOP=1 -f performance/00_seed_benchmark.sql
psql -d sql_course -v ON_ERROR_STOP=1 -f analytics/00_models.sql
bash performance/run_benchmarks.sh
```

The generated summary is written to `performance/results/performance-summary.md`.

## Interpretation limits

Microbenchmarks are environment-dependent. Execution time varies with CPU, storage, cache state, PostgreSQL configuration, statistics, and data distribution. Phase 3 therefore uses timing as supporting evidence alongside plan shape, buffer activity, index usage, and index storage cost. The benchmark does not claim universal production latency.
