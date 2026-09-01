CREATE TABLE public.company_dim (
    company_id INTEGER PRIMARY KEY,
    name TEXT,
    link TEXT,
    link_google TEXT,
    thumbnail TEXT
);

CREATE TABLE public.skills_dim (
    skill_id INTEGER PRIMARY KEY,
    skills TEXT NOT NULL,
    type TEXT
);

CREATE TABLE public.job_postings_fact (
    job_id INTEGER PRIMARY KEY,
    company_id INTEGER REFERENCES public.company_dim (company_id),
    job_title_short VARCHAR(255),
    job_title TEXT,
    job_location TEXT,
    job_via TEXT,
    job_schedule_type TEXT,
    job_work_from_home BOOLEAN,
    search_location TEXT,
    job_posted_date TIMESTAMP,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country TEXT,
    salary_rate TEXT,
    salary_year_avg NUMERIC,
    salary_hour_avg NUMERIC
);

CREATE TABLE public.skills_job_dim (
    job_id INTEGER REFERENCES public.job_postings_fact (job_id),
    skill_id INTEGER REFERENCES public.skills_dim (skill_id),
    PRIMARY KEY (job_id, skill_id)
);

CREATE INDEX idx_job_postings_company_id ON public.job_postings_fact (company_id);
CREATE INDEX idx_skills_job_skill_id ON public.skills_job_dim (skill_id);

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
