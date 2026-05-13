dotfiles_secrets_global_file() {
  printf '%s\n' "${DOTFILES_SECRETS_GLOBAL_FILE:-$HOME/.config/secrets/secrets.env}"
}

dotfiles_secrets_repo_relpath() {
  printf '%s\n' "${DOTFILES_SECRETS_REPO_FILE:-.secrets/secrets.env}"
}

dotfiles_secrets_app_name() {
  local program="$1"
  program="${program##*/}"
  printf '%s\n' "$program"
}

dotfiles_secrets_app_file() {
  local base_file="$1"
  local app="$2"
  local dir base ext

  dir="$(dirname -- "$base_file")"
  base="$(basename -- "$base_file")"

  if [[ "$base" == *.* ]]; then
    ext=".${base##*.}"
    base="${base%.*}"
    printf '%s/%s.%s%s\n' "$dir" "$base" "$app" "$ext"
  else
    printf '%s/%s.%s\n' "$dir" "$base" "$app"
  fi
}

dotfiles_secrets_clear_loaded() {
  local name

  for name in ${DOTFILES_SECRETS_LOADED_KEYS:-}; do
    [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
    unset "$name"
  done

  DOTFILES_SECRETS_LOADED_KEYS=""
}

dotfiles_secrets_load_env_file() {
  local file="$1"
  local line key value

  [[ -r "$file" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -n "$line" ]] || continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      value="${BASH_REMATCH[2]}"
      value="${value#${value%%[![:space:]]*}}"
      value="${value%${value##*[![:space:]]}}"
      if [[ "$value" == BW:* ]]; then
        if command -v bw >/dev/null 2>&1; then
          value="$(bw get password "${value#BW:}" 2>/dev/null || true)"
        else
          value=""
        fi
      fi
      export "$key=$value"
      DOTFILES_SECRETS_LOADED_KEYS+=" $key"
    fi
  done <"$file"
}

dotfiles_secrets_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

dotfiles_secrets_reload() {
  local app="${1:-}"
  local repo_root repo_file global_file repo_app_file global_app_file

  repo_root="$(dotfiles_secrets_repo_root)"
  if [[ "${DOTFILES_SECRETS_ACTIVE_REPO:-}" == "$repo_root" && "${DOTFILES_SECRETS_ACTIVE_APP:-}" == "$app" ]]; then
    return 0
  fi

  dotfiles_secrets_clear_loaded

  global_file="$(dotfiles_secrets_global_file)"
  dotfiles_secrets_load_env_file "$global_file"
  if [[ -n "$app" ]]; then
    global_app_file="$(dotfiles_secrets_app_file "$global_file" "$app")"
    dotfiles_secrets_load_env_file "$global_app_file"
  fi

  if [[ -n "$repo_root" ]]; then
    repo_file="$repo_root/$(dotfiles_secrets_repo_relpath)"
    dotfiles_secrets_load_env_file "$repo_file"
    if [[ -n "$app" ]]; then
      repo_app_file="$(dotfiles_secrets_app_file "$repo_file" "$app")"
      dotfiles_secrets_load_env_file "$repo_app_file"
    fi
  fi

  export DOTFILES_SECRETS_ACTIVE_REPO="$repo_root"
  export DOTFILES_SECRETS_ACTIVE_APP="$app"
}

dotfiles_secrets_prompt_hook() {
  dotfiles_secrets_reload
}

dotfiles_bw_needs_unlock() {
  local status_json

  command -v bw >/dev/null 2>&1 || return 1
  status_json="$(bw status --raw 2>/dev/null || true)"
  [[ -n "$status_json" ]] || return 1
  [[ "$status_json" == *'"status":"locked"'* ]]
}

dotfiles_bw_unlock_for_command() {
  local session

  dotfiles_bw_needs_unlock || return 1
  dotfiles_secrets_reload bw
  session="$(command bw unlock --raw)" || return 1
  export BW_SESSION="$session"
  export DOTFILES_BW_LOCK_AFTER_COMMAND=1
  return 0
}

dotfiles_bw_lock_after_command() {
  [[ "${DOTFILES_BW_LOCK_AFTER_COMMAND:-0}" == "1" ]] || return 0
  dotfiles_secrets_reload bw
  command bw lock >/dev/null 2>&1 || true
  unset BW_SESSION
  unset DOTFILES_BW_LOCK_AFTER_COMMAND
}

with_repo_secrets() {
  local app command_name rc

  [[ $# -gt 0 ]] || {
    printf 'usage: with_repo_secrets <program> [args...]\n' >&2
    return 2
  }

  command_name="$1"
  app="$(dotfiles_secrets_app_name "$command_name")"

  if [[ "$app" != "bw" ]]; then
    dotfiles_bw_unlock_for_command || true
  fi

  dotfiles_secrets_reload "$app"

  command "$@"
  rc=$?

  if [[ "$app" != "bw" ]]; then
    dotfiles_bw_lock_after_command
  fi

  return "$rc"
}

repo_secrets_init() {
  local repo_root repo_dir repo_file gitignore_file ignore_entry

  repo_root="$(dotfiles_secrets_repo_root)"
  [[ -n "$repo_root" ]] || {
    printf 'repo_secrets_init: not inside a git repository\n' >&2
    return 1
  }

  repo_file="$repo_root/$(dotfiles_secrets_repo_relpath)"
  repo_dir="$(dirname -- "$repo_file")"

  mkdir -p -- "$repo_dir"
  if [[ ! -e "$repo_file" ]]; then
    cat >"$repo_file" <<'EOF'
# Example repo-local secrets
# KEY=value
# API_TOKEN=replace-me
EOF
  fi

  gitignore_file="$repo_root/.gitignore"
  ignore_entry='.secrets/'
  if [[ ! -f "$gitignore_file" ]]; then
    printf '%s\n' "$ignore_entry" >"$gitignore_file"
  elif ! grep -Fxq -- "$ignore_entry" "$gitignore_file"; then
    printf '\n%s\n' "$ignore_entry" >>"$gitignore_file"
  fi

  printf '%s\n' "$repo_file"
}

dotfiles_secrets_reload
if [[ ";${PROMPT_COMMAND:-};" != *";dotfiles_secrets_prompt_hook;"* ]]; then
  if [[ -n "${PROMPT_COMMAND:-}" ]]; then
    PROMPT_COMMAND="dotfiles_secrets_prompt_hook;${PROMPT_COMMAND}"
  else
    PROMPT_COMMAND="dotfiles_secrets_prompt_hook"
  fi
fi
