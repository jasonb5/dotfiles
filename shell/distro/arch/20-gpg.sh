if [[ -t 0 ]]; then
  export GPG_TTY="$(tty)"

  if command -v gpg-connect-agent >/dev/null 2>&1; then
    gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
  fi
fi

if command -v gpgconf >/dev/null 2>&1; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
