CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE VIEW analytics.data_analyst_postings AS
SELECT
    jobs.job_id,
    jobs.company_id,
    companies.name AS company_name,
    jobs.job_title,
    jobs.job_location,
    CASE
        WHEN jobs.job_work_from_home IS TRUE THEN 'Remote'
        WHEN jobs.job_work_from_home IS FALSE THEN 'Onsite/Hybrid'
        ELSE 'Unknown'
    END AS work_mode,
    jobs.job_posted_date,
    jobs.salary_year_avg
FROM public.job_postings_fact AS jobs
LEFT JOIN public.company_dim AS companies
    ON jobs.company_id = companies.company_id
WHERE jobs.job_title_short = 'Data Analyst';

CREATE OR REPLACE VIEW analytics.data_analyst_skills AS
SELECT
    postings.job_id,
    postings.company_id,
    postings.company_name,
    postings.work_mode,
    postings.job_posted_date,
    postings.salary_year_avg,
    skills.skill_id,
    skills.skills AS skill_name
FROM analytics.data_analyst_postings AS postings
INNER JOIN public.skills_job_dim AS job_skills
    ON postings.job_id = job_skills.job_id
INNER JOIN public.skills_dim AS skills
    ON job_skills.skill_id = skills.skill_id;
