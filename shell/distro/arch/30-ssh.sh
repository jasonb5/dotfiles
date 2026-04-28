# Reuse a single ssh-agent socket across terminals.
export SSH_AUTH_SOCK="$HOME/.ssh/agent/ssh-agent.sock"
if ! SSH_AUTH_SOCK="$SSH_AUTH_SOCK" ssh-add -l >/dev/null 2>&1; then
  mkdir -p "$HOME/.ssh/agent"
  [ -S "$SSH_AUTH_SOCK" ] && rm -f "$SSH_AUTH_SOCK"
  eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)" >/dev/null
fi


