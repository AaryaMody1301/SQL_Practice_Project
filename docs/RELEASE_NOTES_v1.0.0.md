# v1.0.0 — Analytics Engineering Portfolio Release

`v1.0.0` is the first portfolio-grade release of the modernized SQL Practice Project.

## What this release demonstrates

- PostgreSQL analytical SQL with explicit cohort definitions.
- Reusable view-based modeling at posting and posting-skill grain.
- Salary distribution, work-mode, time-trend, concentration, and co-occurrence analysis.
- Deterministic correctness verification with PostgreSQL-backed CI.
- SQL linting with a pinned SQLFluff version.
- Portable client-side data loading without server-specific file paths.
- Evidence-driven index design using real PostgreSQL execution plans and buffer metrics.
- Clear source-data provenance and separation of inherited coursework from repository-authored work.

## Performance highlight

On the repository-owned benchmark workload of 200,000 job postings and 600,000 job-skill relationships, the accepted partial covering salary index reduced the top-paying remote Data Analyst query from a median **19.198 ms to 0.105 ms** and reduced shared-block activity from **4,203 to 38**.

A second partial covering index improved several Data Analyst analytical workloads. No extra index was added for the skill-pair co-occurrence query because the measured improvement was negligible.

## Documentation included

- `README.md` — portfolio overview and reproduction guide.
- `docs/ERD.md` — physical schema ERD.
- `docs/DATA_DICTIONARY.md` — table/view/index definitions and null semantics.
- `docs/ANALYTICS_METHODS.md` — analytical methodology and interpretation limits.
- `docs/PORTFOLIO_FINDINGS.md` — provenance-safe historical findings and repository-owned evidence.
- `performance/README.md` — benchmark methodology.
- `performance/BENCHMARK_RESULTS.md` — accepted before/after evidence.
- `THIRD_PARTY_NOTICES.md` — course/data provenance boundary.

## Data and provenance

This repository does not redistribute the original course CSV files. The five foundational questions and source schema originate from Luke Barousse's SQL learning project. Repository-authored work includes correctness fixes, portable setup, deterministic testing, analytical views/questions, performance benchmarking, accepted indexes, and release documentation.

Historical job-market statements refer to the source **2023** dataset and should not be presented as current-market facts.

## Release procedure

After the Phase 4 PR is merged and all `main` checks are green, create the Git tag `v1.0.0` from the merged `main` commit and publish a GitHub release using these notes (or GitHub-generated notes supplemented with this summary).
