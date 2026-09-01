# Changelog

All notable repository-authored changes are documented here. The project began as coursework; see `THIRD_PARTY_NOTICES.md` for the provenance boundary.

## [1.0.0]

### Added

- Reusable `analytics.data_analyst_postings` and `analytics.data_analyst_skills` views.
- Five repository-authored analyses covering salary distribution, work-mode compensation, monthly hiring trends, employer concentration, and skill-pair co-occurrence.
- Deterministic PostgreSQL correctness fixture, source/analytics contracts, reviewed expected outputs, and SQLFluff CI.
- Portable client-side CSV loading with psql `\copy`.
- Deterministic 200,000-posting / 600,000-job-skill performance benchmark using `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, FORMAT JSON)`.
- Two benchmark-accepted partial covering indexes for Data Analyst analytical workloads.
- ERD, data dictionary, portfolio findings, benchmark methodology/evidence, and explicit third-party provenance documentation.
- Release version metadata and release-readiness automation.

### Changed

- Corrected the five foundational course queries and standardized the remote Data Analyst analytical cohort.
- Removed environment-specific PostgreSQL ownership/path assumptions.
- Reframed the repository from an exercise collection into a reproducible analytics-engineering case study.
- Replaced generic optimization claims with measured planner, buffer, execution-time, and storage evidence.

### Fixed

- Invalid identifier in the top-paying-job skill query.
- Missing top-ten boundary in the top-paying-job skill analysis.
- Inconsistent remote/non-remote salary populations across foundational queries.
- Redundant `skills_job_dim(job_id)` index assumption; the composite primary key already leads with `job_id`.

### Performance evidence

Acceptance benchmark medians on the deterministic PostgreSQL 18 workload:

- top-paying remote jobs: `19.198 ms -> 0.105 ms` (99.5% faster)
- company concentration: `28.241 ms -> 20.656 ms` (26.9% faster)
- remote salary distribution: `23.816 ms -> 17.726 ms` (25.6% faster)
- monthly hiring trend: `44.259 ms -> 34.606 ms` (21.8% faster)
- top-demanded remote skills: `49.395 ms -> 45.865 ms` (7.1% faster)
- skill-pair co-occurrence: `92.232 ms -> 91.361 ms` (0.9% faster; no additional index accepted)

### Release boundary

The source course CSV files are not distributed with this release. Third-party course material/data remains subject to its original terms. This repository does not apply a blanket license to upstream material.
