# Data Dictionary

This dictionary describes the supported PostgreSQL schema and the repository-authored analytical views. Raw course CSVs are not redistributed in this repository; see `THIRD_PARTY_NOTICES.md` for provenance.

## `public.company_dim`

Grain: one row per company identifier.

| Column | Type | Nullable | Key | Meaning |
| --- | --- | --- | --- | --- |
| `company_id` | `INTEGER` | No | PK | Stable company identifier used by job postings. |
| `name` | `TEXT` | Yes |  | Company name from the source dataset. |
| `link` | `TEXT` | Yes |  | Source company/profile link when available. |
| `link_google` | `TEXT` | Yes |  | Google-related company link from the source extract when available. |
| `thumbnail` | `TEXT` | Yes |  | Company thumbnail/image reference when available. |

## `public.skills_dim`

Grain: one row per skill identifier.

| Column | Type | Nullable | Key | Meaning |
| --- | --- | --- | --- | --- |
| `skill_id` | `INTEGER` | No | PK | Stable skill identifier. |
| `skills` | `TEXT` | No |  | Human-readable skill name such as SQL, Python, or Tableau. |
| `type` | `TEXT` | Yes |  | Source skill category/type when available. |

## `public.job_postings_fact`

Grain: one row per job posting.

| Column | Type | Nullable | Key | Meaning |
| --- | --- | --- | --- | --- |
| `job_id` | `INTEGER` | No | PK | Stable job-posting identifier. |
| `company_id` | `INTEGER` | Yes | FK | References `company_dim.company_id`. |
| `job_title_short` | `VARCHAR(255)` | Yes |  | Normalized role family used for cohort filters, e.g. `Data Analyst`. |
| `job_title` | `TEXT` | Yes |  | Original posting title. |
| `job_location` | `TEXT` | Yes |  | Posting location text. |
| `job_via` | `TEXT` | Yes |  | Posting/source platform description. |
| `job_schedule_type` | `TEXT` | Yes |  | Schedule/employment-type description. |
| `job_work_from_home` | `BOOLEAN` | Yes |  | Source remote-work flag. `TRUE` is classified as Remote; `FALSE` as Onsite/Hybrid; `NULL` as Unknown in the analytical view. |
| `search_location` | `TEXT` | Yes |  | Search geography associated with the source record. |
| `job_posted_date` | `TIMESTAMP` | Yes |  | Posting timestamp used for time-trend analysis. |
| `job_no_degree_mention` | `BOOLEAN` | Yes |  | Source flag indicating no degree requirement was mentioned. |
| `job_health_insurance` | `BOOLEAN` | Yes |  | Source flag indicating health-insurance information. |
| `job_country` | `TEXT` | Yes |  | Country associated with the posting. |
| `salary_rate` | `TEXT` | Yes |  | Source salary-rate descriptor. |
| `salary_year_avg` | `NUMERIC` | Yes |  | Reported/normalized annual average salary when available. Missing salary remains `NULL`. |
| `salary_hour_avg` | `NUMERIC` | Yes |  | Reported/normalized hourly average salary when available. |

### Supported indexes

| Index | Definition/purpose |
| --- | --- |
| `idx_job_postings_company_id` | B-tree on `company_id` for company joins. |
| `idx_job_postings_remote_da_salary` | Partial covering index on `(salary_year_avg DESC, job_id)` for salaried remote Data Analyst ranking workloads; includes company/title/location/schedule/date columns. |
| `idx_job_postings_da_work_mode_job` | Partial covering index on `(job_work_from_home, job_id)` for Data Analyst analytical workloads; includes company/date/annual salary columns. |

The two Data Analyst partial indexes were promoted only after the Phase 3 benchmark showed planner use and measurable workload benefit. See `performance/BENCHMARK_RESULTS.md`.

## `public.skills_job_dim`

Grain: one row per unique job-skill relationship.

| Column | Type | Nullable | Key | Meaning |
| --- | --- | --- | --- | --- |
| `job_id` | `INTEGER` | No | PK, FK | References `job_postings_fact.job_id`. |
| `skill_id` | `INTEGER` | No | PK, FK | References `skills_dim.skill_id`. |

The composite primary key prevents duplicate job-skill relationships.

### Supported index

| Index | Definition/purpose |
| --- | --- |
| `idx_skills_job_skill_id` | B-tree on `skill_id` for skill-centric joins/grouping. The composite PK already begins with `job_id`, so a separate single-column `job_id` index is not maintained. |

## `analytics.data_analyst_postings`

Type: ordinary PostgreSQL view.

Grain: one row per source posting where `job_title_short = 'Data Analyst'`.

| Column | Source/derivation | Meaning |
| --- | --- | --- |
| `job_id` | `job_postings_fact.job_id` | Posting identifier. |
| `company_id` | `job_postings_fact.company_id` | Company identifier. |
| `company_name` | left join to `company_dim.name` | Company name where available. |
| `job_title` | source | Original job title. |
| `job_location` | source | Posting location. |
| `work_mode` | derived from `job_work_from_home` | `Remote`, `Onsite/Hybrid`, or `Unknown`. |
| `job_posted_date` | source | Posting timestamp. |
| `salary_year_avg` | source | Annual average salary; remains nullable. |

## `analytics.data_analyst_skills`

Type: ordinary PostgreSQL view.

Grain: one row per Data Analyst posting-skill relationship.

| Column | Source/derivation | Meaning |
| --- | --- | --- |
| `job_id` | analytical posting view | Posting identifier. |
| `company_id` | analytical posting view | Company identifier. |
| `company_name` | analytical posting view | Company name where available. |
| `work_mode` | analytical posting view | Normalized work mode. |
| `job_posted_date` | analytical posting view | Posting timestamp. |
| `salary_year_avg` | analytical posting view | Annual average salary; nullable. |
| `skill_id` | `skills_dim.skill_id` | Skill identifier. |
| `skill_name` | `skills_dim.skills` | Human-readable skill name. |

## Null and interpretation rules

- Missing salaries are not imputed as zero and are excluded only when a salary statistic requires a reported salary.
- Remote comparisons use `job_work_from_home IS TRUE`; they do not infer remote status from free-text location.
- Remote-vs-onsite salary comparisons are descriptive and should not be interpreted as causal effects.
- Counts in `data_analyst_skills` are relationship counts; a posting with multiple skills contributes multiple rows.
- The source dataset represents historical 2023 postings and is not evidence of the current job market.

## Machine-readable validation

PostgreSQL exposes schema metadata through `information_schema`, which can be used to inspect column names and types without relying on client-specific catalog queries. Release CI validates the schema by creating it in PostgreSQL and running the existing relational and analytical contracts.
