TRUNCATE TABLE
    public.skills_job_dim,
    public.job_postings_fact,
    public.skills_dim,
    public.company_dim
RESTART IDENTITY CASCADE;

INSERT INTO public.company_dim (company_id, name)
VALUES
    (1, 'Alpha Analytics'),
    (2, 'Beta Data'),
    (3, 'Gamma Insights');

INSERT INTO public.skills_dim (skill_id, skills, type)
VALUES
    (1, 'SQL', 'programming'),
    (2, 'Python', 'programming'),
    (3, 'Tableau', 'analytics'),
    (4, 'Excel', 'analytics');

INSERT INTO public.job_postings_fact (
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_work_from_home,
    job_posted_date,
    salary_year_avg
)
VALUES
    (101, 1, 'Data Analyst', 'Data Analyst I', 'Anywhere', TRUE, '2023-01-01', 130000),
    (102, 2, 'Data Analyst', 'Data Analyst II', 'Anywhere', TRUE, '2023-01-02', 129000),
    (103, 3, 'Data Analyst', 'Data Analyst III', 'Anywhere', TRUE, '2023-01-03', 128000),
    (104, 1, 'Data Analyst', 'Senior Data Analyst', 'Anywhere', TRUE, '2023-01-04', 127000),
    (105, 2, 'Data Analyst', 'Product Data Analyst', 'Anywhere', TRUE, '2023-01-05', 126000),
    (106, 3, 'Data Analyst', 'Marketing Data Analyst', 'Anywhere', TRUE, '2023-01-06', 125000),
    (107, 1, 'Data Analyst', 'Operations Data Analyst', 'Anywhere', TRUE, '2023-01-07', 124000),
    (108, 2, 'Data Analyst', 'BI Data Analyst', 'Anywhere', TRUE, '2023-01-08', 123000),
    (109, 3, 'Data Analyst', 'Risk Data Analyst', 'Anywhere', TRUE, '2023-01-09', 122000),
    (110, 1, 'Data Analyst', 'Finance Data Analyst', 'Anywhere', TRUE, '2023-01-10', 121000),
    (111, 2, 'Data Analyst', 'People Data Analyst', 'Anywhere', TRUE, '2023-01-11', 120000),
    (112, 3, 'Data Analyst', 'Growth Data Analyst', 'Anywhere', TRUE, '2023-01-12', 119000),
    (113, 1, 'Data Analyst', 'Customer Data Analyst', 'Anywhere', TRUE, '2023-01-13', 118000),
    (114, 2, 'Data Analyst', 'Onsite Principal Analyst', 'New York, NY', FALSE, '2023-01-14', 250000),
    (115, 3, 'Data Scientist', 'Remote Data Scientist', 'Anywhere', TRUE, '2023-01-15', 200000);

INSERT INTO public.skills_job_dim (job_id, skill_id)
SELECT job_id, 1
FROM public.job_postings_fact
WHERE job_id BETWEEN 101 AND 113;

INSERT INTO public.skills_job_dim (job_id, skill_id)
SELECT job_id, 2
FROM public.job_postings_fact
WHERE job_id BETWEEN 101 AND 106;

INSERT INTO public.skills_job_dim (job_id, skill_id)
SELECT job_id, 3
FROM public.job_postings_fact
WHERE job_id BETWEEN 101 AND 104;

INSERT INTO public.skills_job_dim (job_id, skill_id)
SELECT job_id, 4
FROM public.job_postings_fact
WHERE job_id BETWEEN 101 AND 102;

INSERT INTO public.skills_job_dim (job_id, skill_id)
VALUES
    (114, 2),
    (115, 2);
