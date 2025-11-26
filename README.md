# Autopredator (PHP Build)

Plain PHP, HTML, CSS, and vanilla JS implementation of the Autopredator vehicle platform. React/Next.js and Node tooling have been removed; the stack now runs entirely on PHP with MySQL/MariaDB.

## What’s inside
- `legacy/php_app/`: primary UI (dashboards, listings, calculators, auth pages).
- `legacy/static/`: shared CSS/images for the PHP UI.
- `127_0_0_1 (6).sql`: phpMyAdmin export with the `autopredator`, `autopredator_unified`, `blogs`, `cars`, and `mindflow_db` schemas.
- `docs/`, `prototype/`, `legacy/` assets for reference.

## Run locally (XAMPP/LAMP/WAMP)
1. Clone/copy this repo into your web root (e.g., `C:\xampp\htdocs\Autopredator`).
2. In phpMyAdmin, import `127_0_0_1 (6).sql` to create/populate the databases.
3. Serve the app:  
   - Either set the Apache/Nginx document root to `legacy/php_app`, **or**  
   - Open `http://localhost/Autopredator/` and follow the redirect to `legacy/php_app/`.
4. Ensure `legacy/php_app/uploads/` (and `uploads/content/` if using the upload form) is writable by the web server.
5. Update DB credentials in `legacy/php_app/config.php` (and related config files) to match your local MySQL settings.

## Stack
- PHP 8+, MySQL/MariaDB
- HTML, CSS (Tailwind CDN + `legacy/static` styles), vanilla JavaScript
- No Node/React build tools are required.

## Notes
- The root `index.php` simply redirects traffic into the PHP app.
- The gitignore is trimmed for a PHP-first workflow; uploads remain untracked.
