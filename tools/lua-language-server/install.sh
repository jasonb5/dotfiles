#!/usr/bin/env bash

set -euo pipefail

root_dir=$(cd "$(dirname "$0")" && pwd)
install_dir="$root_dir/install"
version="$(curl -fsSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | python -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')"
asset_url="https://github.com/LuaLS/lua-language-server/releases/download/${version}/lua-language-server-${version}-linux-x64.tar.gz"
tmp_dir=$(mktemp -d)

trap 'rm -rf "$tmp_dir"' EXIT

rm -rf "$install_dir"
mkdir -p "$install_dir"

curl -fsSL -L "$asset_url" -o "$tmp_dir/lua-language-server.tar.gz"
tar -xzf "$tmp_dir/lua-language-server.tar.gz" -C "$install_dir"
