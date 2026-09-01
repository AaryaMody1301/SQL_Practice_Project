# Phase 3 Benchmark Evidence

This document records the controlled benchmark used to decide which Phase 3 indexes belong in the supported schema.

## Acceptance run

- GitHub Actions workflow: `Performance evidence`
- Workflow run: `33506301980`
- Benchmark commit: `fa5429222d31736689ce1ffdcd963d050061e589`
- PostgreSQL: 18.6
- Runner: Ubuntu 24.04
- Measurement: three warm-cache `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, FORMAT JSON)` runs per query and state; medians reported

The benchmark commit predates promotion of the candidate indexes into `sql_load/2_create_tables.sql`, so the baseline state did not contain the Phase 3 indexes.

## Workload

| Metric | Rows |
| --- | ---: |
| Job postings | 200,000 |
| Data Analyst postings | 40,000 |
| Remote Data Analyst postings | 10,000 |
| Job-skill relationships | 600,000 |

The workload is synthetic and deterministic. It is designed to exercise planner selectivity and join behavior, not to reproduce the real course dataset distribution.

## Results

| Query | Baseline ms | Indexed ms | Improvement | Baseline shared blocks | Indexed shared blocks | Candidate index used |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Company concentration | 28.241 | 20.656 | 26.9% | 4,173 | 4,415 | `idx_job_postings_da_work_mode_job` |
| Monthly hiring trend | 44.259 | 34.606 | 21.8% | 4,174 | 4,416 | `idx_job_postings_da_work_mode_job` |
| Remote salary distribution | 23.816 | 17.726 | 25.6% | 4,171 | 4,413 | `idx_job_postings_da_work_mode_job` |
| Skill-pair co-occurrence | 92.232 | 91.361 | 0.9% | 244,182 | 244,182 | none |
| Top-demanded remote skills | 49.395 | 45.865 | 7.1% | 6,831 | 6,894 | `idx_job_postings_da_work_mode_job` |
| Top-paying remote jobs | 19.198 | 0.105 | 99.5% | 4,203 | 38 | `idx_job_postings_remote_da_salary` |

Positive improvement means the median indexed execution time was lower than the median baseline execution time.

## Storage cost

| Index | Benchmark size |
| --- | ---: |
| `idx_job_postings_da_work_mode_job` | 1,944 kB |
| `idx_job_postings_remote_da_salary` | 736 kB |

## Decisions

### Accept `idx_job_postings_remote_da_salary`

This partial covering index produced the clearest result in the benchmark. The top-paying remote-job query dropped from 19.198 ms to 0.105 ms and shared-buffer activity fell from 4,203 blocks to 38 blocks. The index is restricted to salaried remote Data Analyst rows, so its benchmark footprint remained under 1 MB.

### Accept `idx_job_postings_da_work_mode_job`

This partial covering index was selected by four measured workloads and improved their median execution time by roughly 7% to 27%. Its shared-block counts were slightly higher in those plans because index pages are part of the measured buffer work, so the decision is not based on buffer reduction. It is accepted because PostgreSQL consistently chose the index, multiple independent analytical workloads improved, and its benchmark storage cost was modest.

### Do not add a skill-pair-specific index

The skill-pair co-occurrence query did not use either candidate and changed by only 0.9%, well within the range where runner noise can matter. Phase 3 therefore adds no speculative index for that query. The existing `(job_id, skill_id)` primary key already aligns with the job-based relationship joins.

## Interpretation

These figures are benchmark evidence, not production latency guarantees. PostgreSQL plan choices and timings depend on data distribution, table size, cache state, statistics, hardware, and server configuration. The committed indexes are justified by this repository's measured workload, but a different production workload should be benchmarked independently.
