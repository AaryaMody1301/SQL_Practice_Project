#!/usr/bin/env bash
set -euo pipefail

RESULTS_DIR="${1:-performance/results}"
RUNS=3

rm -rf "${RESULTS_DIR}"
mkdir -p "${RESULTS_DIR}/baseline" "${RESULTS_DIR}/indexed"

queries=(
  "project_top_paying|Project_sql/1_top_paying_jobs.sql"
  "project_top_demanded_skills|Project_sql/3_top_demanded_skills.sql"
  "analytics_salary_distribution|analytics/questions/1_salary_distribution.sql"
  "analytics_monthly_hiring_trend|analytics/questions/3_monthly_hiring_trend.sql"
  "analytics_company_concentration|analytics/questions/4_company_concentration.sql"
  "analytics_skill_pair_cooccurrence|analytics/questions/5_skill_pair_cooccurrence.sql"
)

explain_query() {
  local query_file="$1"
  {
    printf '%s\n' 'EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, SUMMARY ON, FORMAT JSON)'
    cat "${query_file}"
  } | psql -X -v ON_ERROR_STOP=1 -A -t
}

run_stage() {
  local stage="$1"
  local spec name query_file run

  for spec in "${queries[@]}"; do
    IFS='|' read -r name query_file <<< "${spec}"

    # Warm the relevant table/index pages before recording comparable runs.
    explain_query "${query_file}" > /dev/null

    for run in $(seq 1 "${RUNS}"); do
      explain_query "${query_file}" > "${RESULTS_DIR}/${stage}/${name}_run${run}.json"
    done
  done
}

psql -X -v ON_ERROR_STOP=1 -f performance/01_drop_candidate_indexes.sql
run_stage baseline

psql -X -v ON_ERROR_STOP=1 -f performance/02_candidate_indexes.sql
run_stage indexed

psql -X -v ON_ERROR_STOP=1 -A -t -F '|' -c "
SELECT
    relname,
    pg_size_pretty(pg_relation_size(oid))
FROM pg_class
WHERE relname IN (
    'idx_job_postings_remote_da_salary',
    'idx_job_postings_da_work_mode_job'
)
ORDER BY relname;
" > "${RESULTS_DIR}/index_sizes.txt"

psql -X -v ON_ERROR_STOP=1 -A -t -F '|' -c "
SELECT 'job_postings', COUNT(*) FROM public.job_postings_fact
UNION ALL
SELECT 'data_analyst_postings', COUNT(*) FROM public.job_postings_fact WHERE job_title_short = 'Data Analyst'
UNION ALL
SELECT 'remote_data_analyst_postings', COUNT(*) FROM public.job_postings_fact WHERE job_title_short = 'Data Analyst' AND job_work_from_home IS TRUE
UNION ALL
SELECT 'skill_relationships', COUNT(*) FROM public.skills_job_dim;
" > "${RESULTS_DIR}/workload_counts.txt"

python3 performance/summarize_plans.py "${RESULTS_DIR}"
