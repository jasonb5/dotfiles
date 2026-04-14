case ":$PATH:" in
  *":$HOME/.volta/bin:"*) ;;
  *) PATH="$HOME/.volta/bin${PATH:+:$PATH}" ;;
esac

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin${PATH:+:$PATH}" ;;
esac

export PATH
