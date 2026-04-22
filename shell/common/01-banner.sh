[[ $- == *i* ]] || return 0
[[ -t 1 ]] || return 0

dotfiles_banner_update_count() {
  local count=0

  if command -v checkupdates >/dev/null 2>&1; then
    count="$(checkupdates 2>/dev/null | wc -l | tr -d '[:space:]')"
  elif command -v pacman >/dev/null 2>&1; then
    count="$(pacman -Qu 2>/dev/null | wc -l | tr -d '[:space:]')"
  elif command -v apt >/dev/null 2>&1; then
    count="$(apt list --upgradable 2>/dev/null | awk 'NR > 1 { c++ } END { print c + 0 }')"
  fi

  [[ -n "$count" ]] || count=0

  printf '%s\n' "$count"
}

dotfiles_banner_update_count_label() {
  local count

  count="$(dotfiles_banner_update_count)"
  if [[ "$count" == "0" ]]; then
    printf 'no upgradable packages\n'
  else
    printf '%s upgradable packages\n' "$count"
  fi
}

printf '%s\n' '  ____        _   _  __ _ _'
printf '%s\n' ' |  _ \  ___ | |_| |/ _(_) | ___'
printf '%s\n' ' | | | |/ _ \| __| | |_| | |/ _ \'
printf '%s\n' ' | |_| | (_) | |_| |  _| | |  __/'
printf '%s\n' ' |____/ \___/ \__|_|_| |_|_|\___|'
printf '\n'
printf '  %s@%s\n' "${USER:-unknown}" "${DOTFILES_HOST:-${HOSTNAME:-$(uname -n)}}"
printf '  os: %s\n' "${DOTFILES_DISTRO:-$(uname -s)}"
printf '  kernel: %s\n' "$(uname -r)"
printf '  shell: %s\n' "${SHELL##*/}"
uptime_text="$(uptime -p 2>/dev/null)"
uptime_text="${uptime_text#up }"
printf '  uptime: %s\n' "$uptime_text"
printf '  updates: %s\n' "$(dotfiles_banner_update_count_label)"
printf '%s\n' '----------------------------------------'
