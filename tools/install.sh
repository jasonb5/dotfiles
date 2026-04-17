#!/usr/bin/env bash

set -euo pipefail

root_dir=$(cd "$(dirname "$0")" && pwd)

cd "$root_dir/python"
uv sync

cd "$root_dir/node"
npm install

cd "$root_dir/lua-language-server"
./install.sh
