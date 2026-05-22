from __future__ import annotations

from mcp.server.fastmcp import FastMCP

from . import query
from .types import (
    ValidationError,
    parse_search_filters,
    parse_stats_input,
    parse_task_id,
    parse_week_input,
)


mcp = FastMCP("tasks_index")


def _error_payload(message: str) -> dict[str, str]:
    return {
        "error": message,
    }


@mcp.tool(description="Search tasks in the SQLite index")
def tasks_search(input: dict | None = None) -> dict:
    try:
        filters = parse_search_filters(input)
        return query.search_tasks(filters)
    except (ValidationError, query.QueryError) as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Get one task and its occurrence history")
def tasks_get(input: dict | None = None) -> dict:
    try:
        task_id = parse_task_id(input)
        return query.get_task(task_id)
    except (ValidationError, query.QueryError) as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Summarize tasks for an ISO week")
def tasks_week(input: dict | None = None) -> dict:
    try:
        week_key, day = parse_week_input(input)
        return query.week_summary(week_key, day)
    except (ValidationError, query.QueryError, ValueError) as exc:
        return _error_payload(str(exc))


@mcp.tool(description="List projects with task counts")
def tasks_projects() -> dict:
    try:
        return query.projects_summary()
    except query.QueryError as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Return aggregate task stats")
def tasks_stats(input: dict | None = None) -> dict:
    try:
        start_date, end_date = parse_stats_input(input)
        return query.stats_summary(start_date, end_date)
    except (ValidationError, query.QueryError) as exc:
        return _error_payload(str(exc))


def main() -> None:
    mcp.run()


if __name__ == "__main__":
    main()
