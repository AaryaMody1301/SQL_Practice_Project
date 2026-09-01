# Third-Party Notices and Provenance

## SQL for Data Analytics learning project

This repository began as a learning project based on Luke Barousse's public **SQL for Data Analytics** material and the companion `SQL_Project_Data_Job_Analysis` repository:

- Course page: https://www.lukebarousse.com/sql
- Companion repository: https://github.com/lukebarousse/SQL_Project_Data_Job_Analysis

The source learning project provides the job-postings schema, course dataset, and the five foundational analysis questions around top-paying Data Analyst jobs, skills for top-paying jobs, in-demand skills, salary-associated skills, and optimal skills.

## What this repository adds

The Phase 1 modernization adds repository-specific work including:

- corrected and cohort-consistent portfolio queries;
- portable PostgreSQL schema/setup behavior;
- client-side CSV loading without hard-coded server paths;
- a synthetic deterministic test fixture authored for this repository;
- reviewed expected outputs for regression testing;
- relational data-contract assertions;
- SQLFluff configuration;
- PostgreSQL-backed GitHub Actions verification;
- explicit provenance and reproducibility documentation.

Later phases are intended to add original analytical questions and models beyond the course project.

## Dataset boundary

The original job-postings CSV dataset is not committed here. Users should obtain source data through the original course materials and comply with any terms that apply to that material. The synthetic fixture under `tests/fixtures/` is solely for repository verification and must not be interpreted as real job-market evidence.

## Licensing boundary

This repository does not attempt to relicense third-party course content or source data. Any third-party material remains subject to the terms of its original source. Repository-authored additions should be considered separately from those upstream materials until an explicit repository license is added with a reviewed provenance boundary.
