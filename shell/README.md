# shell

Bash aliases and functions live here.

Common shell setup runs first from `shell/common/`, including clearing any
pre-existing aliases before distro-specific shell snippets are sourced.

Arch PATH setup for `~/.volta/bin`, `~/.cargo/bin`, and `~/.local/bin` lives in
`shell/distro/arch/10-path.sh`.

YubiKey GPG/SSH shell setup lives in `shell/distro/arch/20-gpg.sh`.
