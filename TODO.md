# PHP Build TODO (XAMPP)

## Database
- [ ] Import `127_0_0_1 (6).sql` via phpMyAdmin to create `autopredator`, `autopredator_unified`, `blogs`, `cars`, and helper schemas.
- [ ] Create a MySQL user/password (or use `root`) and note the credentials for the PHP config files.

## App bootstrap
- [ ] Point Apache DocumentRoot to `legacy/php_app` (or rely on the root redirect at `/`).
- [ ] Update DB settings in `legacy/php_app/config.php` (and related config files) to match local credentials.
- [ ] Make sure `legacy/php_app/uploads/` and `legacy/php_app/uploads/content/` exist and are writable for file uploads.

## Verification
- [ ] Load `http://localhost/Autopredator/` and confirm it redirects into the PHP dashboard.
- [ ] Open the blog and vehicle listing pages to confirm they render with imported data.
- [ ] Run through a sample file upload (if needed) to confirm the uploads directory works.
