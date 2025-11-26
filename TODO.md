# Autopredator root TODO

Primary task tracker lives in `website/TODO.md`. This root list just tracks repo-level hygiene.

## Completed
- Separated new site under `website/`
- Archived prototypes to `legacy/` with kebab-case names
- Moved SQL/DB artifacts to `database/`
- Added gitignore for `*.sqlite3` and `database/*.sql`

## Next actions
- Update legacy pages only if explicitly needed; keep them out of new nav
- Replace `GA_MEASUREMENT_ID` in `website/includes/header.php` with real analytics ID
- If using `legacy/` pages, verify their DB configs and links after the renames
