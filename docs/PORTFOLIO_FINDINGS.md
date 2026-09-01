# Portfolio Findings and Interpretation

This document separates three kinds of evidence so the portfolio does not blur provenance:

1. **Upstream source-dataset reference results** published with the Luke Barousse SQL course project.
2. **Repository-authored analytical questions** in `analytics/questions/`, which are reproducible against the same course dataset but are not assigned invented values here because the raw CSVs are intentionally not redistributed in this repository.
3. **Repository-owned benchmark evidence** generated from a deterministic synthetic workload in Phase 3.

## Historical source-dataset reference

The upstream course project publishes the following results for its 2023 job-postings dataset. These values are included as provenance-aware reference points for the five foundational questions, not as independent measurements produced by this repository.

### Remote Data Analyst skill demand

| Rank | Skill | Published demand count |
| ---: | --- | ---: |
| 1 | SQL | 7,291 |
| 2 | Excel | 4,611 |
| 3 | Python | 4,330 |
| 4 | Tableau | 3,745 |
| 5 | Power BI | 2,609 |

The upstream project also reports that its top ten remote Data Analyst salaries span roughly **$184,000 to $650,000**, and that among those top-paying roles **SQL appears in 8**, **Python in 7**, and **Tableau in 6** of the skill mappings.

For salary-associated skills, the upstream reference results show that niche technologies can rank highly by average salary when sample sizes are small. That is one reason this repository treats salary-by-skill outputs as descriptive evidence and uses explicit support thresholds where appropriate rather than equating a high mean with a universally valuable skill.

Source: [Luke Barousse — SQL Project Data Job Analysis](https://github.com/lukebarousse/SQL_Project_Data_Job_Analysis)

## Repository-authored analysis

The original analytical layer deliberately goes beyond those five course questions.

### 1. Salary distribution, not just averages

`analytics/questions/1_salary_distribution.sql` reports count, minimum, lower quartile, median, average, upper quartile, and maximum for salaried remote Data Analyst postings. The important portfolio point is methodological: salary distributions are summarized with robust quantiles so one extreme posting cannot define the narrative.

### 2. Remote versus onsite/hybrid compensation

`analytics/questions/2_work_mode_salary.sql` compares reported salaries by normalized work mode. This is explicitly descriptive. Work mode may correlate with geography, seniority, employer type, and other factors that are not controlled here.

### 3. Monthly hiring and salary-coverage trend

`analytics/questions/3_monthly_hiring_trend.sql` reports posting volume, remote share, salary coverage, and median salary by month. Salary coverage is included because a change in the fraction of postings that disclose salary can change the population used for salary statistics.

### 4. Employer concentration

`analytics/questions/4_company_concentration.sql` ranks employers by Data Analyst posting volume and computes cumulative share with window functions. This answers a portfolio-relevant question that the foundational course project does not: whether postings are dispersed across employers or concentrated among a smaller set.

### 5. Skill-pair co-occurrence

`analytics/questions/5_skill_pair_cooccurrence.sql` analyzes skills as combinations rather than isolated frequencies. Repeated co-occurrence can be more useful for learning-roadmap decisions because real job postings often request bundles of capabilities.

## Reproduce a real-data findings snapshot

After loading the course CSVs locally, run the supported analytical queries directly:

```bash
psql -d sql_course -v ON_ERROR_STOP=1 -f analytics/00_models.sql
psql -d sql_course -f analytics/questions/1_salary_distribution.sql
psql -d sql_course -f analytics/questions/2_work_mode_salary.sql
psql -d sql_course -f analytics/questions/3_monthly_hiring_trend.sql
psql -d sql_course -f analytics/questions/4_company_concentration.sql
psql -d sql_course -f analytics/questions/5_skill_pair_cooccurrence.sql
```

The result values should be reviewed against the actual loaded dataset before being used in a presentation or resume statement. The repository's deterministic CI fixture verifies query behavior, not empirical claims about the historical source data.

## Repository-owned performance findings

Phase 3 provides independently reproducible evidence because the benchmark workload belongs to this repository.

| Query | Baseline median | Indexed median | Change |
| --- | ---: | ---: | ---: |
| Top-paying remote jobs | 19.198 ms | 0.105 ms | 99.5% faster |
| Company concentration | 28.241 ms | 20.656 ms | 26.9% faster |
| Remote salary distribution | 23.816 ms | 17.726 ms | 25.6% faster |
| Monthly hiring trend | 44.259 ms | 34.606 ms | 21.8% faster |
| Top-demanded remote skills | 49.395 ms | 45.865 ms | 7.1% faster |
| Skill-pair co-occurrence | 92.232 ms | 91.361 ms | 0.9% faster |

The benchmark's strongest result is the partial covering index for salaried remote Data Analyst ranking: shared blocks fell from **4,203 to 38** on the acceptance run. Conversely, the skill-pair query received no extra index because the measured benefit was negligible and PostgreSQL did not select either candidate index.

See `performance/BENCHMARK_RESULTS.md` for workload counts, index sizes, planner evidence, and limitations.

## Portfolio-safe summary

A defensible summary of the project is:

> Rebuilt a SQL-course project into a tested PostgreSQL analytics-engineering case study with cohort-consistent queries, reusable analytical views, deterministic contracts, original salary/trend/concentration/skill-pair analyses, and evidence-driven indexing. A 200k-posting benchmark reduced the top-paying remote-job query from 19.198 ms to 0.105 ms while preserving all regression outputs.

The historical job-market findings should always be described as **2023 source-dataset findings**, not current-market facts.
