from __future__ import annotations

import json
import statistics
import sys
from pathlib import Path

CANDIDATE_INDEXES = {
    "idx_job_postings_remote_da_salary",
    "idx_job_postings_da_work_mode_job",
}


def load_plan(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        payload = json.load(handle)
    return payload[0]


def collect_indexes(node: dict) -> set[str]:
    names: set[str] = set()
    index_name = node.get("Index Name")
    if index_name:
        names.add(index_name)
    for child in node.get("Plans", []):
        names.update(collect_indexes(child))
    return names


def median_metric(plans: list[dict], key: str) -> float:
    return statistics.median(float(plan.get(key, 0.0)) for plan in plans)


def median_plan_metric(plans: list[dict], key: str) -> float:
    return statistics.median(float(plan["Plan"].get(key, 0.0)) for plan in plans)


def load_stage(stage_dir: Path, name: str) -> list[dict]:
    files = sorted(stage_dir.glob(f"{name}_run*.json"))
    if not files:
        raise RuntimeError(f"no plans found for {name} in {stage_dir}")
    return [load_plan(path) for path in files]


def format_pct(value: float) -> str:
    return f"{value:+.1f}%"


def append_pipe_table(lines: list[str], path: Path, heading: str) -> None:
    if not path.exists():
        return
    rows = [row for row in path.read_text(encoding="utf-8").splitlines() if row.strip()]
    if not rows:
        return
    lines.extend(["", heading, "", "| Metric | Value |", "| --- | ---: |"])
    for row in rows:
        name, value = row.split("|", 1)
        lines.append(f"| {name} | {value} |")


def main() -> None:
    results_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "performance/results")
    baseline_dir = results_dir / "baseline"
    indexed_dir = results_dir / "indexed"

    query_names = sorted(
        {
            path.stem.rsplit("_run", 1)[0]
            for path in baseline_dir.glob("*_run*.json")
        }
    )

    lines = [
        "# PostgreSQL performance benchmark",
        "",
        "Three warm-cache `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, FORMAT JSON)` runs are collected per query for both the baseline and candidate-index states. The table reports medians.",
        "",
        "| Query | Baseline ms | Indexed ms | Execution change | Baseline shared blocks | Indexed shared blocks | Candidate indexes used |",
        "| --- | ---: | ---: | ---: | ---: | ---: | --- |",
    ]

    for name in query_names:
        baseline = load_stage(baseline_dir, name)
        indexed = load_stage(indexed_dir, name)

        baseline_ms = median_metric(baseline, "Execution Time")
        indexed_ms = median_metric(indexed, "Execution Time")
        execution_change = (
            ((baseline_ms - indexed_ms) / baseline_ms) * 100.0
            if baseline_ms > 0
            else 0.0
        )

        baseline_blocks = median_plan_metric(baseline, "Shared Hit Blocks") + median_plan_metric(
            baseline, "Shared Read Blocks"
        )
        indexed_blocks = median_plan_metric(indexed, "Shared Hit Blocks") + median_plan_metric(
            indexed, "Shared Read Blocks"
        )

        index_names: set[str] = set()
        for plan in indexed:
            index_names.update(collect_indexes(plan["Plan"]))
        candidate_names = sorted(index_names & CANDIDATE_INDEXES)

        lines.append(
            "| {name} | {baseline:.3f} | {indexed:.3f} | {change} | {base_blocks:.0f} | {idx_blocks:.0f} | {indexes} |".format(
                name=name,
                baseline=baseline_ms,
                indexed=indexed_ms,
                change=format_pct(execution_change),
                base_blocks=baseline_blocks,
                idx_blocks=indexed_blocks,
                indexes=", ".join(candidate_names) if candidate_names else "none",
            )
        )

    workload_counts = results_dir / "workload_counts.txt"
    append_pipe_table(lines, workload_counts, "## Benchmark workload")

    index_sizes = results_dir / "index_sizes.txt"
    if index_sizes.exists():
        lines.extend(["", "## Candidate index sizes", "", "| Index | Size |", "| --- | ---: |"])
        for row in index_sizes.read_text(encoding="utf-8").splitlines():
            if not row.strip():
                continue
            name, size = row.split("|", 1)
            lines.append(f"| {name} | {size} |")

    lines.extend(
        [
            "",
            "Execution time is supporting evidence, not a universal latency guarantee. Planner choices and timings depend on data distribution, cache state, hardware, PostgreSQL settings, and statistics.",
        ]
    )

    summary = "\n".join(lines) + "\n"
    output = results_dir / "performance-summary.md"
    output.write_text(summary, encoding="utf-8")
    print(summary, end="")


if __name__ == "__main__":
    main()
