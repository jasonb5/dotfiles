# config

Managed dotfiles live here.

Scopes are layered as `common -> os -> distro -> group -> host`, and a host can load multiple groups.

Arch tmux config lives in `config/distro/arch/.tmux.conf`.

Arch sway config lives in `config/distro/arch/.config/sway/config`.

Arch Rose Pine theme config lives under `config/distro/arch/.config/` for GTK,
kitty, fuzzel, tmux, sway, swaync, ironbar, and Neovim.

Example capability groups live under `config/group/vim/`.
Group membership rules live in `lib/group-rules`.
Tool manifests live under `tools/` at the repo root.
