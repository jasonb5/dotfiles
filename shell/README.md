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

Secrets are loaded from `~/.config/secrets/secrets.env` and merged with repo
secrets from `<repo>/.secrets/secrets.env` by `shell/distro/arch/12-secrets.sh`.
Repo values override global values.

App-specific overlays are also supported for commands run through
`with_repo_secrets`. For a program named `foo`, the loader also checks:
`~/.config/secrets/secrets.foo.env` and `<repo>/.secrets/secrets.foo.env`.
Load order is global base -> global app -> repo base -> repo app.

Secret values can reference Bitwarden with `BW:<item-name>`, for example
`HASS_MCP_URL=BW:hass.mcp.url`. The value is resolved via
`bw get password <item-name>`.

Use `with_repo_secrets <program> [args...]` to run any command after an
immediate secrets reload. When `bw` is available, it will also unlock a locked
vault before launching non-`bw` commands and lock it again when the command
exits.

Use `mkrepo-secrets` to create the repo secrets directory and a starter
`secrets.env` file in the current git repository.

Arch secrets-related aliases live in `shell/distro/arch/11-aliases.sh`.

Helper functions are available in `shell/distro/arch/13-bitwarden.sh`:
`bw_status`, `bw_sync`, `bw_login`, `bw_unlock`, `bw_lock`, and `bw_logout`.

YubiKey GPG/SSH shell setup lives in `shell/distro/arch/20-gpg.sh`.

WireGuard interactive config helper is available as `wg_setup` from
`shell/distro/arch/25-wireguard.sh`.
