if [[ -t 0 ]]; then
  export GPG_TTY="$(tty)"

  if command -v gpg-connect-agent >/dev/null 2>&1; then
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
  fi
fi
