# Autopredator (PHP Build)

Plain PHP, HTML, CSS, and vanilla JS implementation of the Autopredator vehicle platform. React/Next.js and Node tooling have been removed; the stack now runs entirely on PHP with MySQL/MariaDB.

## What's inside
- `website/` - main marketing site and portal entry (home, solutions, industries, pricing, resources, blog, contact, auth placeholder). Shared includes live in `website/includes/`, with assets under `website/assets/` and API hooks in `website/api/`.
- `legacy/` - archived experiments and the old `php_app` prototype kept for reference only.
- `database/` - local SQL dumps and scratch DB files (e.g., `autopredator_site`, `blog_posts_seed.sql`, `db.sqlite3` for local dev only).
- `docs/` - developer notes and guides.
- `frontend/`, `backend/`, `Frontend prototype/` - earlier stack ideas; not used by the current PHP site.

## Quick start (XAMPP/LAMP/WAMP)
1) Place the repo at your web root (e.g., `C:\xampp\htdocs\Autopredator`).
2) Import a schema: `database/127_0_0_1 (6).sql` (or your preferred DB dump) into MySQL/MariaDB (default DB name `autopredator_site`).
3) Configure DB creds in `website/includes/config.php` (defaults: root/no password, DB `autopredator_site`).
4) Visit `http://localhost/Autopredator/` or `http://localhost/Autopredator/website/` to view the site; the root `index.php` redirects to `website/`.
5) Auth placeholder:
   - Create a `users` row with a `password_hash` (use `password_hash('yourpass', PASSWORD_DEFAULT)`).
   - Login at `website/login.php`; redirects to `website/dashboard-placeholder.php` on success.

## Design system
- Palette: red (`#E50914`), black (`#000`/`#111`), white (`#fff`) only.
- Tokens in `website/assets/css/styles.css`; components/layout in `website/assets/css/components.css`.
- JS lives in `website/assets/js` for nav, form validation, and smooth UX.

## DB helpers
- `website/includes/helpers.php` exposes `get_db_connection()`, `escape_html()`, `create_lead()`, `create_newsletter_subscriber()`, `get_blog_post_by_slug()`.
- Blog pages expect table `blog_posts` with columns `id, title, slug, excerpt, content, featured_image, created_at`.
- Leads expect `leads` table with `name, email, phone, company, fleet_size, message, source`.

## Legacy notes
- Archived prototypes live under `legacy/` (e.g., kebab-case `.php` pages and the older `php_app`). They are not linked from the new site; keep only for reference or migration.
