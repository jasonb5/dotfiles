# Dotfiles

## Layout

- `config/` for managed dotfiles that may be linked into `$HOME`
- `scripts/` for helper executables
- `shell/` for bash aliases and functions
- `bootstrap/` for provisioning steps
- `lib/` for shared implementation helpers

`config/` paths mirror the target path under `$HOME`. For example,
`config/common/.bashrc` maps to `~/.bashrc`.

Git config lives in `config/common/.gitconfig` and delegates identity to
top-level `~/.gitconfig.work` and `~/.gitconfig.personal` via `includeIf` rules.

Backups use the postfix `.dotfiles.backup`, so `~/.config/nvim/init.lua`
backs up to `~/.config/nvim/init.lua.dotfiles.backup`.

Logs are written to `~/.local/state/dotfiles/dotfiles.log`.

## Rules

- `./dotfiles install` links scoped config files into `$HOME`
- Symlinks must be relative
- Scoped overlays are resolved in this order: `host`, `distro`, `os`, `common`
- Detect `os`, `distro`, and `host` at bootstrap time
- Bootstrap runs as the user and uses `sudo` only for privileged steps
- Bash rc injection is explicit and reversible
- Uninstall only removes manifest-tracked items and injected rc lines
- Never touch unmanaged top-level dotfiles in `$HOME`

Arch bootstrap steps live under `bootstrap/distro/arch/`.
Current Arch steps include `yay`, `volta`, and `uv`.
Arch shell PATH setup lives under `shell/distro/arch/` and is sourced both by
interactive shells and bootstrap.

## Commands

- `./dotfiles detect`
- `./dotfiles bootstrap`
- `./dotfiles install`
- `./dotfiles inject-shell [rcfile]`
- `./dotfiles uninstall`
