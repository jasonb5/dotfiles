from __future__ import annotations

import re
from dataclasses import dataclass
from datetime import date
from typing import Any


DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
WEEK_RE = re.compile(r"^\d{4}-W\d{2}$")
STATUS_VALUES = {"open", "done", "all"}
SCOPE_VALUES = {"Work", "Personal"}


class ValidationError(ValueError):
    pass


def _require_object(payload: Any) -> dict[str, Any]:
    if payload is None:
        return {}
    if not isinstance(payload, dict):
        raise ValidationError("input must be an object")
    return payload


def parse_date(value: str, field_name: str) -> str:
    if not isinstance(value, str) or not DATE_RE.match(value):
        raise ValidationError(f"{field_name} must be YYYY-MM-DD")
    try:
        date.fromisoformat(value)
    except ValueError as exc:
        raise ValidationError(f"{field_name} must be a valid calendar date") from exc
    return value


def parse_week_key(value: str) -> str:
    if not isinstance(value, str) or not WEEK_RE.match(value):
        raise ValidationError("week_key must be YYYY-Www")
    return value


def parse_status(value: str) -> str:
    if not isinstance(value, str) or value not in STATUS_VALUES:
        raise ValidationError("status must be one of: open, done, all")
    return value


def parse_scope(value: str) -> str:
    if not isinstance(value, str) or value not in SCOPE_VALUES:
        raise ValidationError("scope must be one of: Work, Personal")
    return value


def parse_limit(value: Any, default: int = 50, max_value: int = 500) -> int:
    if value is None:
        return default
    if not isinstance(value, int):
        raise ValidationError("limit must be an integer")
    if value < 1 or value > max_value:
        raise ValidationError(f"limit must be between 1 and {max_value}")
    return value


@dataclass(frozen=True)
class SearchFilters:
    status: str = "open"
    scope: str | None = None
    project: str | None = None
    text: str | None = None
    added_from: str | None = None
    added_to: str | None = None
    completed_from: str | None = None
    completed_to: str | None = None
    limit: int = 50


def parse_search_filters(payload: Any) -> SearchFilters:
    data = _require_object(payload)
    status = parse_status(data.get("status", "open"))
    scope = data.get("scope")
    if scope is not None:
        scope = parse_scope(scope)

    project = data.get("project")
    if project is not None and not isinstance(project, str):
        raise ValidationError("project must be a string")

    text = data.get("text")
    if text is not None and not isinstance(text, str):
        raise ValidationError("text must be a string")

    added_from = data.get("added_from")
    if added_from is not None:
        added_from = parse_date(added_from, "added_from")

    added_to = data.get("added_to")
    if added_to is not None:
        added_to = parse_date(added_to, "added_to")

    completed_from = data.get("completed_from")
    if completed_from is not None:
        completed_from = parse_date(completed_from, "completed_from")

    completed_to = data.get("completed_to")
    if completed_to is not None:
        completed_to = parse_date(completed_to, "completed_to")

    return SearchFilters(
        status=status,
        scope=scope,
        project=project.strip() if isinstance(project, str) else None,
        text=text.strip() if isinstance(text, str) else None,
        added_from=added_from,
        added_to=added_to,
        completed_from=completed_from,
        completed_to=completed_to,
        limit=parse_limit(data.get("limit"), default=50, max_value=500),
    )


def parse_task_id(payload: Any) -> str:
    data = _require_object(payload)
    task_id = data.get("id")
    if not isinstance(task_id, str) or task_id.strip() == "":
        raise ValidationError("id is required and must be a non-empty string")
    return task_id.strip()


def parse_week_input(payload: Any) -> tuple[str | None, str | None]:
    data = _require_object(payload)
    week_key = data.get("week_key")
    day = data.get("date")
    if week_key is None and day is None:
        raise ValidationError("either week_key or date is required")
    if week_key is not None:
        week_key = parse_week_key(week_key)
    if day is not None:
        day = parse_date(day, "date")
    return week_key, day


def parse_stats_input(payload: Any) -> tuple[str | None, str | None]:
    data = _require_object(payload)
    start = data.get("start_date")
    end = data.get("end_date")
    if start is not None:
        start = parse_date(start, "start_date")
    if end is not None:
        end = parse_date(end, "end_date")
    return start, end
