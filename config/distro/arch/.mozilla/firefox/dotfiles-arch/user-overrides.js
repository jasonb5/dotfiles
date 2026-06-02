/*
 * Dotfiles-specific overrides for the Arch Firefox profile.
 *
 * Keep this file small. arkenfox is the baseline; local changes belong here.
 * Uncomment optional hardening only after testing the breakage trade-offs.
 */

/* Enable userChrome/userContent support for future profile-local UI tweaks. */
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

/* Match HTTPS-Only behavior across all browsing modes. */
user_pref("dom.security.https_only_mode_pbm", true);

/*
 * Stronger anti-fingerprinting with higher site breakage.
 *
 * user_pref("privacy.resistFingerprinting", true);
 * user_pref("privacy.resistFingerprinting.pbmode", true);
 */
