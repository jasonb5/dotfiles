# bootstrap

Provisioning steps live here.

Arch distro steps live under `bootstrap/distro/arch/`.

Current Arch steps include `yay`, `sway`, `tmux`, `rustup`, `volta`, `uv`, and YubiKey support for GPG/SSH.

The YubiKey step installs the tools and agent config, then you can import your
public key with `gpg --import pubkey.asc`.
