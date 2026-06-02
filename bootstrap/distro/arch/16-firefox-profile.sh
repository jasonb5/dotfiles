#!/usr/bin/env bash

set -euo pipefail

source "${DOTFILES_ROOT:?}/lib/common.sh"
source "${DOTFILES_ROOT:?}/lib/log.sh"

profile_name="${DOTFILES_FIREFOX_PROFILE:-dotfiles-arch}"
profile_dir="$HOME/.mozilla/firefox/$profile_name"
profiles_ini="$HOME/.mozilla/firefox/profiles.ini"
refresh_script="${DOTFILES_ROOT:?}/scripts/distro/arch/firefox-refresh-userjs"

dotfiles_log_info "refreshing arkenfox user.js for Firefox profile ${profile_name}"
"$refresh_script" "$profile_name"

if ! command -v firefox >/dev/null 2>&1; then
  dotfiles_log_info "firefox not installed yet; skipping profile registration"
  exit 0
fi

mkdir -p -- "$HOME/.mozilla/firefox"

if [[ -f "$profiles_ini" ]] && grep -Fqx "Name=$profile_name" "$profiles_ini"; then
  dotfiles_log_info "Firefox profile ${profile_name} already registered"
  exit 0
fi

dotfiles_log_info "creating Firefox profile ${profile_name}"
firefox -CreateProfile "$profile_name $profile_dir"

dotfiles_log_info "Firefox profile ${profile_name} ready"
