# tasks-index MCP

Read-only MCP server for querying your Neovim task SQLite index.

## Data flow

- Canonical data: `~/Documents/tasks` markdown files
- Index source: Neovim task plugin command `:TaskIndex`
- MCP query target: `~/.local/state/tasks/tasks.db`

If the DB is missing or stale, run `:TaskIndex` in Neovim.

## OpenCode integration

Arch OpenCode config is managed at:

- `config/distro/arch/.config/opencode/opencode.json`

The local MCP server is launched via:

```sh
uv run --directory /home/titters/devel/personal/dotfiles/tools/mcp/tasks-index python -m tasks_index_mcp.server
```

## Tools

- `tasks_search`: search by status/scope/project/text/date filters
- `tasks_get`: fetch one task and full occurrence history by task ID
- `tasks_week`: week summary via `week_key` (`YYYY-Www`) or `date` (`YYYY-MM-DD`)
- `tasks_projects`: list projects and open/done totals
- `tasks_stats`: aggregate totals and completion rate (optional date range)

All tools are read-only and never mutate markdown or SQLite.

## Local development

From repo root:

```sh
uv run --directory tools/mcp/tasks-index python -m tasks_index_mcp.server
```

## Troubleshooting

- List configured MCP servers: `opencode mcp list`
- Verify DB exists: `ls ~/.local/state/tasks/tasks.db`
- Rebuild DB index: `:TaskIndex` in Neovim
- If schema errors persist, run `:TaskIndex` again and retry
