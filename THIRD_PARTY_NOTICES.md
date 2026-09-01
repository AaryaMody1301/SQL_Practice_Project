# Third-Party Notices and Provenance

## SQL for Data Analytics learning project

This repository began as a learning project based on Luke Barousse's public **SQL for Data Analytics** material and the companion `SQL_Project_Data_Job_Analysis` repository:

- Course page: https://www.lukebarousse.com/sql
- Companion repository: https://github.com/lukebarousse/SQL_Project_Data_Job_Analysis

The source learning project provides the job-postings schema, course dataset, and the five foundational analysis questions around top-paying Data Analyst jobs, skills for top-paying jobs, in-demand skills, salary-associated skills, and optimal skills.

## Repository-authored additions

Phase 1 adds:

- corrected and cohort-consistent foundational queries;
- portable PostgreSQL schema/setup behavior;
- client-side CSV loading without hard-coded server paths;
- a synthetic deterministic test fixture;
- reviewed expected outputs and relational contracts;
- SQLFluff and PostgreSQL-backed GitHub Actions verification.

Phase 2 adds original work beyond the five source questions:

- reusable Data Analyst posting and skill views;
- salary quartile and median analysis;
- remote versus onsite/hybrid salary comparison;
- monthly posting, remote-share, and salary-coverage trends;
- company posting concentration with window functions;
- repeated skill-pair co-occurrence analysis;
- analytical-view contracts, deterministic result evidence, and methodology documentation.

Phase 3 adds repository-authored performance work:

- a separate deterministic benchmark workload;
- automated `EXPLAIN (ANALYZE, BUFFERS)` plan capture;
- baseline versus candidate-index comparison tooling;
- a generated performance summary for GitHub Actions;
- benchmark-backed partial covering indexes promoted into the schema;
- documented before/after evidence, storage costs, and rejected speculative optimization.

Phase 4 adds repository-authored release/documentation work:

- a Mermaid ERD of the supported physical schema;
- a table/view/index data dictionary;
- provenance-safe portfolio findings and interpretation guidance;
- release version, changelog, and curated `v1.0.0` release notes;
- GitHub generated-release-note configuration;
- release-readiness CI that checks required documentation and prevents raw course CSVs from entering the release package.

## Published upstream findings

`docs/PORTFOLIO_FINDINGS.md` includes selected numeric results already published by the upstream course project for the shared 2023 dataset. They are explicitly labeled as upstream reference results and are not presented as independently generated repository-authored findings.

## Dataset boundary

The original job-postings CSV dataset is not committed here. Users should obtain source data through the original course materials and comply with any terms that apply to that material. The synthetic fixtures and benchmark workload are solely for repository verification and performance testing and must not be interpreted as empirical evidence from the source dataset.

## Licensing boundary

This repository does not attempt to relicense third-party course content or source data. Any third-party material remains subject to the terms of its original source. Repository-authored additions should be considered separately from those upstream materials until an explicit repository license is added with a reviewed provenance boundary.
