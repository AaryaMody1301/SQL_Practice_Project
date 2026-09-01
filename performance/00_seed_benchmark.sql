\set ON_ERROR_STOP on

SET synchronous_commit = off;

TRUNCATE TABLE
    public.skills_job_dim,
    public.job_postings_fact,
    public.skills_dim,
    public.company_dim
RESTART IDENTITY CASCADE;

INSERT INTO public.company_dim (company_id, name)
SELECT
    company_id,
    FORMAT('Benchmark Company %s', company_id)
FROM GENERATE_SERIES(1, 500) AS company_id;

INSERT INTO public.skills_dim (skill_id, skills, type)
SELECT
    skill_id,
    FORMAT('Skill %s', LPAD(skill_id::TEXT, 2, '0')),
    CASE
        WHEN skill_id <= 10 THEN 'programming'
        ELSE 'analytics'
    END
FROM GENERATE_SERIES(1, 20) AS skill_id;

INSERT INTO public.job_postings_fact (
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_rate,
    salary_year_avg,
    salary_hour_avg
)
SELECT
    job_id,
    ((job_id - 1) % 500) + 1,
    CASE
        WHEN job_id % 5 = 0 THEN 'Data Analyst'
        WHEN job_id % 5 = 1 THEN 'Data Scientist'
        WHEN job_id % 5 = 2 THEN 'Business Analyst'
        WHEN job_id % 5 = 3 THEN 'Data Engineer'
        ELSE 'Software Engineer'
    END,
    CASE
        WHEN job_id % 5 = 0 THEN FORMAT('Data Analyst %s', job_id)
        WHEN job_id % 5 = 1 THEN FORMAT('Data Scientist %s', job_id)
        WHEN job_id % 5 = 2 THEN FORMAT('Business Analyst %s', job_id)
        WHEN job_id % 5 = 3 THEN FORMAT('Data Engineer %s', job_id)
        ELSE FORMAT('Software Engineer %s', job_id)
    END,
    CASE
        WHEN job_id % 4 = 0 THEN 'Anywhere'
        ELSE 'New York, NY'
    END,
    'Direct',
    'Full-time',
    CASE
        WHEN job_id % 4 = 0 THEN TRUE
        WHEN job_id % 13 = 0 THEN NULL
        ELSE FALSE
    END,
    'United States',
    TIMESTAMP '2023-01-01'
        + (((job_id - 1) % 365) * INTERVAL '1 day')
        + (((job_id - 1) % 1440) * INTERVAL '1 minute'),
    job_id % 3 = 0,
    job_id % 2 = 0,
    'United States',
    'year',
    CASE
        WHEN job_id % 7 = 0 THEN NULL
        ELSE 65000 + (job_id % 135001)
    END,
    NULL
FROM GENERATE_SERIES(1, 200000) AS job_id;

INSERT INTO public.skills_job_dim (job_id, skill_id)
SELECT
    job_id,
    ((job_id + skill_offset * 7) % 20) + 1
FROM GENERATE_SERIES(1, 200000) AS job_id
CROSS JOIN GENERATE_SERIES(0, 2) AS skill_offset;

ANALYZE public.company_dim;
ANALYZE public.skills_dim;
ANALYZE public.job_postings_fact;
ANALYZE public.skills_job_dim;
