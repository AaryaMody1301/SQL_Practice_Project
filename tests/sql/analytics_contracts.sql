DO $$
DECLARE
    base_posting_count BIGINT;
    analytics_posting_count BIGINT;
BEGIN
    SELECT COUNT(*)
    INTO base_posting_count
    FROM public.job_postings_fact
    WHERE job_title_short = 'Data Analyst';

    SELECT COUNT(*)
    INTO analytics_posting_count
    FROM analytics.data_analyst_postings;

    IF base_posting_count <> analytics_posting_count THEN
        RAISE EXCEPTION 'analytics posting view changed Data Analyst row count';
    END IF;

    IF EXISTS (
        SELECT job_id
        FROM analytics.data_analyst_postings
        GROUP BY job_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'analytics posting view contains duplicate job_id values';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM analytics.data_analyst_postings AS analytics_posting
        INNER JOIN public.job_postings_fact AS source_posting
            ON analytics_posting.job_id = source_posting.job_id
        WHERE
            (source_posting.job_work_from_home IS TRUE
                AND analytics_posting.work_mode <> 'Remote')
            OR (source_posting.job_work_from_home IS FALSE
                AND analytics_posting.work_mode <> 'Onsite/Hybrid')
            OR (source_posting.job_work_from_home IS NULL
                AND analytics_posting.work_mode <> 'Unknown')
    ) THEN
        RAISE EXCEPTION 'analytics work-mode mapping is inconsistent with source data';
    END IF;

    IF EXISTS (
        SELECT job_id, skill_id
        FROM analytics.data_analyst_skills
        GROUP BY job_id, skill_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION 'analytics skill view changed job-skill grain';
    END IF;
END
$$;
