# Tools

Lockfile-managed Neovim tooling lives here.

Run `./install.sh` to sync both toolchains.

## Python

```sh
cd tools/python
uv lock
uv run pip-audit
```

## Node

```sh
cd tools/node
npm install
npm run audit
```

## lua-language-server

```sh
cd tools/lua-language-server
./install.sh
```

The Neovim wrapper points at `tools/lua-language-server/install/bin/lua-language-server`.

## Rust

Rust language tooling is installed with `rustup` during Arch bootstrap.
Neovim wrappers point at `~/.cargo/bin/rust-analyzer` and `~/.cargo/bin/rustfmt`.
`tools/bin/cargo-clippy` opens `cargo clippy` from the repo root.

The Node toolchain also provides `prettier` for `conform.nvim`.

## Combined audit

```sh
./tools/audit.sh
```
