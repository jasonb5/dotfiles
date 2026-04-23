# bootstrap

Provisioning steps live here.

Scopes are layered as `common -> os -> distro -> group -> host`, and hosts can match multiple groups.

Arch distro steps live under `bootstrap/distro/arch/`.

Host-specific bootstrap steps live under `bootstrap/host/<hostname>/`.

Current Arch steps include `common packages`, `security/runtime baseline`, `yay`, `rose-pine`, `sway`, `swaync`, `containers`, `screen`, `tmux`, `rustup`, `volta`, `npm packages`, `uv`, and YubiKey support for GPG/SSH.

The `lo` host now keeps only laptop-specific hardening: it disables SSH, disables unused network services, and installs firejail for per-app sandboxing.

Docker, sysctl hardening, and auditd live in the general Arch bootstrap. Docker is kept rootful and does not use user namespace remapping.

UFW stays in the `lo` host bootstrap so firewall policy remains host-specific and does not affect every Arch machine.

The `lo` host also disables `avahi`, `cups`, and `bluetooth` by default.

The `ganymede` host gets libvirt, a minimal x86 QEMU stack, virt-manager, and firmware support for managing a dedicated VM.

`./dotfiles bootstrap` ends by running `./dotfiles install`.

The YubiKey step installs the tools and agent config, then you can import your
public key with `gpg --import pubkey.asc`.
