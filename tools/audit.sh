#!/usr/bin/env bash

set -euo pipefail

root_dir=$(cd "$(dirname "$0")" && pwd)

cd "$root_dir/python"
uv run pip-audit

cd "$root_dir/node"
npm run audit
