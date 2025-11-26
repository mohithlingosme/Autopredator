# DevRun Guide (PHP-Only)

This project now runs entirely on PHP, HTML, CSS, and vanilla JS. No Node/React tooling is required.

## Prerequisites
- PHP 8+ (XAMPP/WAMP/LAMP recommended)
- MariaDB/MySQL running locally
- phpMyAdmin (optional but easiest for imports)

## Quick start
1. Place the repo in your web root (e.g., `C:\xampp\htdocs\Autopredator`).
2. Import the bundled database dump:  
   - Open phpMyAdmin → Import `127_0_0_1 (6).sql` (creates/populates `autopredator`, `autopredator_unified`, `blogs`, `cars`, `mindflow_db`, `phpmyadmin`, `test`).
3. Point Apache/Nginx to the PHP UI:  
   - Simplest: browse to `http://localhost/Autopredator/` (root `index.php` redirects to `legacy/php_app/`), **or**  
   - Set your DocumentRoot directly to `.../Autopredator/legacy/php_app`.
4. Configure DB creds in `legacy/php_app/config.php` (and related config files) to match your MySQL user/password.
5. Ensure uploads are writable: create/permission `legacy/php_app/uploads/` (and `uploads/content/` if you use the upload form).

## Directory pointers
- `legacy/php_app/` – main PHP UI (dashboards, calculators, login, blog, etc.).
- `legacy/static/` – shared CSS/images for the PHP UI.
- `legacy/uploads/` – example uploaded asset.
- `127_0_0_1 (6).sql` – phpMyAdmin export covering all schemas.

## Notes
- There are no `package.json` or Node builds anymore.
- Tailwind is loaded via CDN; other styling lives in `legacy/static`.
- If you change DB credentials, restart Apache to reload PHP configs.
