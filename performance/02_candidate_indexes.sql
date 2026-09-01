CREATE INDEX idx_job_postings_remote_da_salary
ON public.job_postings_fact (salary_year_avg DESC, job_id)
INCLUDE (
    company_id,
    job_title,
    job_location,
    job_schedule_type,
    job_posted_date
)
WHERE
job_title_short = 'Data Analyst'
AND job_work_from_home IS TRUE
AND salary_year_avg IS NOT NULL;

CREATE INDEX idx_job_postings_da_work_mode_job
ON public.job_postings_fact (job_work_from_home, job_id)
INCLUDE (
    company_id,
    job_posted_date,
    salary_year_avg
)
WHERE
job_title_short = 'Data Analyst';

ANALYZE public.job_postings_fact;
