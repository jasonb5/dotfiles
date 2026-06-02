# Firefox Arch Profile

This profile is managed from the Arch distro scope.

- `user-overrides.js` is the hand-maintained overlay.
- `user.js` is generated from upstream `arkenfox/user.js` plus that overlay.
- `./scripts/distro/arch/firefox-refresh-userjs` refreshes the generated file.

Bootstrap also registers the `dotfiles-arch` Firefox profile locally if it does not
already exist.
