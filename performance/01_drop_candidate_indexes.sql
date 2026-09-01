DROP INDEX IF EXISTS public.idx_job_postings_remote_da_salary;
DROP INDEX IF EXISTS public.idx_job_postings_da_work_mode_job;

ANALYZE public.job_postings_fact;
