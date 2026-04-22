# bootstrap

Provisioning steps live here.

Scopes are layered as `common -> os -> distro -> group -> host`, and hosts can match multiple groups.

Arch distro steps live under `bootstrap/distro/arch/`.

Host-specific bootstrap steps live under `bootstrap/host/<hostname>/`.

Current Arch steps include `common packages`, `yay`, `rose-pine`, `sway`, `swaync`, `containers`, `tmux`, `rustup`, `volta`, `npm packages`, `uv`, and YubiKey support for GPG/SSH.

The `lo` host includes a security baseline that enables a firewall, disables SSH, applies conservative sysctl hardening, and enables audit logging.

The `lo` host also disables `avahi`, `cups`, and `bluetooth` by default, and installs `firejail` for per-app sandboxing.

`./dotfiles bootstrap` ends by running `./dotfiles install`.

The YubiKey step installs the tools and agent config, then you can import your
public key with `gpg --import pubkey.asc`.
