# shell

Bash aliases, shell startup banner, and functions live here.

Common shell setup runs first from `shell/common/`, including clearing any
pre-existing aliases before distro-specific shell snippets are sourced.

`shell/common/01-banner.sh` prints the interactive startup banner and package
update count.

Group shell setup can live under `shell/group/` and is sourced for every matched group.

Arch Rose Pine shell/theme setup lives in `bootstrap/distro/arch/` and
`config/distro/arch/`.

Arch PATH setup for `~/.volta/bin`, `~/.cargo/bin`, and `~/.local/bin` lives in
`shell/distro/arch/10-path.sh`.

Arch editor defaults (`EDITOR`/`VISUAL`) are set to `nvim` in
`shell/distro/arch/15-editor.sh`.

YubiKey GPG/SSH shell setup lives in `shell/distro/arch/20-gpg.sh`.

WireGuard interactive config helper is available as `wg_setup` from
`shell/distro/arch/25-wireguard.sh`.
