# Entity-Relationship Diagram

This diagram documents the supported physical PostgreSQL schema used by the project. The `analytics` schema contains views derived from these four source tables and is documented separately in the data dictionary.

```mermaid
erDiagram
    COMPANY_DIM ||--o{ JOB_POSTINGS_FACT : "has postings"
    JOB_POSTINGS_FACT ||--o{ SKILLS_JOB_DIM : "maps skills"
    SKILLS_DIM ||--o{ SKILLS_JOB_DIM : "describes skill"

    COMPANY_DIM {
        integer company_id PK
        text name
        text link
        text link_google
        text thumbnail
    }

    JOB_POSTINGS_FACT {
        integer job_id PK
        integer company_id FK
        varchar job_title_short
        text job_title
        text job_location
        text job_via
        text job_schedule_type
        boolean job_work_from_home
        text search_location
        timestamp job_posted_date
        boolean job_no_degree_mention
        boolean job_health_insurance
        text job_country
        text salary_rate
        numeric salary_year_avg
        numeric salary_hour_avg
    }

    SKILLS_DIM {
        integer skill_id PK
        text skills
        text type
    }

    SKILLS_JOB_DIM {
        integer job_id PK, FK
        integer skill_id PK, FK
    }
```

## Grain and relationships

- `company_dim`: one row per company identifier.
- `job_postings_fact`: one row per job posting.
- `skills_dim`: one row per skill identifier.
- `skills_job_dim`: one row per unique `(job_id, skill_id)` relationship.
- `company_dim` to `job_postings_fact`: one company can be referenced by many postings; a posting can have a nullable company reference.
- `job_postings_fact` to `skills_job_dim`: one posting can have zero or many skill relationships.
- `skills_dim` to `skills_job_dim`: one skill can appear in zero or many postings.

## Analytical model

`analytics.data_analyst_postings` filters the fact table to Data Analyst postings and adds a normalized `work_mode` classification. `analytics.data_analyst_skills` expands that view to posting-skill grain by joining through `skills_job_dim` and `skills_dim`.

See [`DATA_DICTIONARY.md`](DATA_DICTIONARY.md) for column definitions, nullability expectations, analytical-view semantics, and indexes.
