DO $$
BEGIN
    IF EXISTS (
        SELECT job_id
        FROM public.job_postings_fact
        GROUP BY job_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'duplicate job_id detected';
    END IF;

    IF EXISTS (
        SELECT skill_id
        FROM public.skills_dim
        GROUP BY skill_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'duplicate skill_id detected';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.job_postings_fact
        WHERE salary_year_avg IS NOT NULL
            AND salary_year_avg <= 0
    ) THEN
        RAISE EXCEPTION 'non-positive annual salary detected';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.skills_dim
        WHERE skills IS NULL OR BTRIM(skills) = ''
    ) THEN
        RAISE EXCEPTION 'blank skill name detected';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.skills_job_dim AS sj
        LEFT JOIN public.job_postings_fact AS j
            ON sj.job_id = j.job_id
        LEFT JOIN public.skills_dim AS s
            ON sj.skill_id = s.skill_id
        WHERE j.job_id IS NULL OR s.skill_id IS NULL
    ) THEN
        RAISE EXCEPTION 'orphaned skill-job relationship detected';
    END IF;
END
$$;
