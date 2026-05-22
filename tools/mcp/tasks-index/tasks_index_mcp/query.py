from __future__ import annotations

import os
import sqlite3
from contextlib import closing
from datetime import date, timedelta
from typing import Any

from .types import SearchFilters


DEFAULT_DB_PATH = "~/.local/state/tasks/tasks.db"


class QueryError(RuntimeError):
    pass


def resolve_db_path() -> str:
    return os.path.expanduser(os.environ.get("TASKS_DB_PATH", DEFAULT_DB_PATH))


def _dict_rows(cursor: sqlite3.Cursor) -> list[dict[str, Any]]:
    columns = [column[0] for column in cursor.description or ()]
    out: list[dict[str, Any]] = []
    for row in cursor.fetchall():
        out.append(dict(zip(columns, row, strict=False)))
    return out


def _connect() -> sqlite3.Connection:
    db_path = resolve_db_path()
    if not os.path.exists(db_path):
        raise QueryError(f"Task index not found at {db_path}. Run :TaskIndex in Neovim.")
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn


def _check_schema(conn: sqlite3.Connection) -> None:
    required = {"tasks", "task_occurrences", "weekly_summaries"}
    query = "SELECT name FROM sqlite_master WHERE type='table'"
    with closing(conn.cursor()) as cursor:
        cursor.execute(query)
        names = {row[0] for row in cursor.fetchall()}
    missing = sorted(required - names)
    if missing:
        raise QueryError(
            "Task index schema is incomplete (missing: "
            + ", ".join(missing)
            + "). Run :TaskIndex in Neovim."
        )


def search_tasks(filters: SearchFilters) -> dict[str, Any]:
    clauses = []
    params: list[Any] = []

    if filters.status in {"open", "done"}:
        clauses.append("l.status = ?")
        params.append(filters.status)
    if filters.scope:
        clauses.append("t.scope = ?")
        params.append(filters.scope)
    if filters.project:
        clauses.append("t.project = ?")
        params.append(filters.project)
    if filters.text:
        clauses.append("(t.description LIKE ? OR t.id LIKE ?)")
        text_like = f"%{filters.text}%"
        params.extend([text_like, text_like])
    if filters.added_from:
        clauses.append("t.added_date >= ?")
        params.append(filters.added_from)
    if filters.added_to:
        clauses.append("t.added_date <= ?")
        params.append(filters.added_to)
    if filters.completed_from:
        clauses.append("l.completed_date >= ?")
        params.append(filters.completed_from)
    if filters.completed_to:
        clauses.append("l.completed_date <= ?")
        params.append(filters.completed_to)

    where_clause = f"WHERE {' AND '.join(clauses)}" if clauses else ""

    sql = f"""
        WITH latest AS (
          SELECT
            o.task_id,
            o.file_date,
            o.status,
            o.completed_date,
            o.source_file,
            ROW_NUMBER() OVER (PARTITION BY o.task_id ORDER BY o.file_date DESC) AS rn
          FROM task_occurrences o
        )
        SELECT
          t.id,
          t.description,
          t.scope,
          t.project,
          t.added_date,
          l.file_date AS latest_file_date,
          l.status AS latest_status,
          l.completed_date AS latest_completed_date,
          l.source_file AS latest_source_file
        FROM tasks t
        JOIN latest l ON l.task_id = t.id AND l.rn = 1
        {where_clause}
        ORDER BY
          CASE l.status WHEN 'open' THEN 0 ELSE 1 END,
          t.project ASC,
          t.added_date DESC,
          t.id ASC
        LIMIT ?
    """
    params.append(filters.limit)

    with closing(_connect()) as conn:
        _check_schema(conn)
        with closing(conn.cursor()) as cursor:
            cursor.execute(sql, params)
            rows = _dict_rows(cursor)

    return {
        "db_path": resolve_db_path(),
        "filters": {
            "status": filters.status,
            "scope": filters.scope,
            "project": filters.project,
            "text": filters.text,
            "added_from": filters.added_from,
            "added_to": filters.added_to,
            "completed_from": filters.completed_from,
            "completed_to": filters.completed_to,
            "limit": filters.limit,
        },
        "count": len(rows),
        "tasks": rows,
    }


def get_task(task_id: str) -> dict[str, Any]:
    task_sql = """
        SELECT id, description, scope, project, added_date
        FROM tasks
        WHERE id = ?
    """
    occ_sql = """
        SELECT task_id, file_date, status, completed_date, source_file
        FROM task_occurrences
        WHERE task_id = ?
        ORDER BY file_date ASC
    """

    with closing(_connect()) as conn:
        _check_schema(conn)
        with closing(conn.cursor()) as cursor:
            cursor.execute(task_sql, [task_id])
            task_rows = _dict_rows(cursor)
            if not task_rows:
                return {
                    "db_path": resolve_db_path(),
                    "found": False,
                    "id": task_id,
                }

            cursor.execute(occ_sql, [task_id])
            occurrences = _dict_rows(cursor)

    return {
        "db_path": resolve_db_path(),
        "found": True,
        "task": task_rows[0],
        "occurrences": occurrences,
    }


def _parse_week_key(week_key: str) -> tuple[int, int]:
    year = int(week_key[0:4])
    week = int(week_key[6:8])
    return year, week


def _week_bounds_from_key(week_key: str) -> tuple[str, str]:
    year, week = _parse_week_key(week_key)
    start = date.fromisocalendar(year, week, 1)
    end = start + timedelta(days=6)
    return start.isoformat(), end.isoformat()


def week_summary(week_key: str | None, day: str | None) -> dict[str, Any]:
    if week_key is None:
        ref = date.fromisoformat(day)
        iso = ref.isocalendar()
        week_key = f"{iso.year:04d}-W{iso.week:02d}"

    range_start, range_end = _week_bounds_from_key(week_key)

    sql = """
        WITH latest AS (
          SELECT
            o.task_id,
            o.file_date,
            o.status,
            o.completed_date,
            ROW_NUMBER() OVER (PARTITION BY o.task_id ORDER BY o.file_date DESC) AS rn
          FROM task_occurrences o
          WHERE o.file_date >= ? AND o.file_date <= ?
        )
        SELECT
          t.id,
          t.description,
          t.scope,
          t.project,
          t.added_date,
          l.file_date,
          l.status,
          l.completed_date
        FROM latest l
        JOIN tasks t ON t.id = l.task_id
        WHERE l.rn = 1
        ORDER BY t.scope ASC, t.project ASC, t.description ASC
    """

    with closing(_connect()) as conn:
        _check_schema(conn)
        with closing(conn.cursor()) as cursor:
            cursor.execute(sql, [range_start, range_end])
            rows = _dict_rows(cursor)

    completed: list[dict[str, Any]] = []
    open_tasks: list[dict[str, Any]] = []
    for row in rows:
        if row["status"] == "done":
            completed.append(row)
        else:
            open_tasks.append(row)

    return {
        "db_path": resolve_db_path(),
        "week_key": week_key,
        "range_start": range_start,
        "range_end": range_end,
        "completed_count": len(completed),
        "open_count": len(open_tasks),
        "completed": completed,
        "open": open_tasks,
    }


def projects_summary() -> dict[str, Any]:
    sql = """
        WITH latest AS (
          SELECT
            o.task_id,
            o.status,
            ROW_NUMBER() OVER (PARTITION BY o.task_id ORDER BY o.file_date DESC) AS rn
          FROM task_occurrences o
        )
        SELECT
          t.scope,
          t.project,
          COUNT(*) AS total,
          SUM(CASE WHEN l.status = 'open' THEN 1 ELSE 0 END) AS open_count,
          SUM(CASE WHEN l.status = 'done' THEN 1 ELSE 0 END) AS done_count
        FROM tasks t
        JOIN latest l ON l.task_id = t.id AND l.rn = 1
        GROUP BY t.scope, t.project
        ORDER BY t.scope ASC, t.project ASC
    """

    with closing(_connect()) as conn:
        _check_schema(conn)
        with closing(conn.cursor()) as cursor:
            cursor.execute(sql)
            rows = _dict_rows(cursor)

    return {
        "db_path": resolve_db_path(),
        "count": len(rows),
        "projects": rows,
    }


def stats_summary(start_date: str | None, end_date: str | None) -> dict[str, Any]:
    date_clause = ""
    params: list[Any] = []
    if start_date is not None:
        date_clause += " AND t.added_date >= ?"
        params.append(start_date)
    if end_date is not None:
        date_clause += " AND t.added_date <= ?"
        params.append(end_date)

    sql = f"""
        WITH latest AS (
          SELECT
            o.task_id,
            o.status,
            ROW_NUMBER() OVER (PARTITION BY o.task_id ORDER BY o.file_date DESC) AS rn
          FROM task_occurrences o
        )
        SELECT
          COUNT(*) AS total,
          SUM(CASE WHEN l.status = 'open' THEN 1 ELSE 0 END) AS open_count,
          SUM(CASE WHEN l.status = 'done' THEN 1 ELSE 0 END) AS done_count
        FROM tasks t
        JOIN latest l ON l.task_id = t.id AND l.rn = 1
        WHERE 1 = 1 {date_clause}
    """

    with closing(_connect()) as conn:
        _check_schema(conn)
        with closing(conn.cursor()) as cursor:
            cursor.execute(sql, params)
            rows = _dict_rows(cursor)

    stats = rows[0] if rows else {"total": 0, "open_count": 0, "done_count": 0}
    total = int(stats.get("total") or 0)
    done_count = int(stats.get("done_count") or 0)
    completion_rate = (done_count / total) if total > 0 else 0.0

    return {
        "db_path": resolve_db_path(),
        "start_date": start_date,
        "end_date": end_date,
        "total": total,
        "open_count": int(stats.get("open_count") or 0),
        "done_count": done_count,
        "completion_rate": round(completion_rate, 4),
    }
