# Performance Engineering

The supported schema uses measured PostgreSQL query plans before accepting new indexes. Phase 3 established the benchmark and promoted only the indexes supported by that evidence; `v1.0.0` preserves the benchmark as part of the release verification story.

## Benchmark workload

`00_seed_benchmark.sql` generates a deterministic synthetic workload with:

- 200,000 job postings;
- 40,000 Data Analyst postings;
- 10,000 remote Data Analyst postings;
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

- **baseline**: the two measured Data Analyst indexes are removed;
- **indexed**: those indexes are recreated and table statistics are refreshed with `ANALYZE`.

`TIMING OFF` avoids per-plan-node clock calls while preserving total execution time and actual row counts. This keeps the comparison focused on planner behavior, total runtime, and buffer work.

## Accepted indexes

The benchmark promoted two partial covering indexes into `sql_load/2_create_tables.sql`:

- `idx_job_postings_remote_da_salary` for selective salaried remote Data Analyst ranking workloads;
- `idx_job_postings_da_work_mode_job` for broader Data Analyst analytical scans and joins.

The acceptance run showed the first index reducing the top-paying remote-job query from **19.198 ms to 0.105 ms** and shared blocks from **4,203 to 38**. The second index was selected across several analytical workloads and produced smaller but repeatable improvements.

No additional skill-pair-specific index was accepted because the co-occurrence query showed negligible benefit and did not select either candidate.

See [`BENCHMARK_RESULTS.md`](BENCHMARK_RESULTS.md) for the complete before/after evidence and storage cost.

## Reproduce locally

With PostgreSQL running and the repository schema loaded:

```bash
psql -d sql_course -v ON_ERROR_STOP=1 -f performance/00_seed_benchmark.sql
psql -d sql_course -v ON_ERROR_STOP=1 -f analytics/00_models.sql
bash performance/run_benchmarks.sh
```

The generated summary is written to `performance/results/performance-summary.md`.

## Release verification

The `Performance evidence` GitHub Actions workflow reruns the deterministic benchmark whenever analytical, schema, or performance files change in a pull request. Version `1.0.0` therefore carries committed acceptance evidence while CI remains capable of detecting material planner or benchmark regressions when those surfaces change.

## Interpretation limits

Microbenchmarks are environment-dependent. Execution time varies with CPU, storage, cache state, PostgreSQL configuration, statistics, and data distribution. Timing is therefore supporting evidence alongside plan shape, buffer activity, index usage, and index storage cost. The benchmark does not claim universal production latency.
