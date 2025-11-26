# Autopredator – PHP Site

Clean PHP/HTML/CSS/JS marketing site for Autopredator with a protected login placeholder. Legacy experiments are archived separately.

## Structure
- `website/` – main B2B site (red/black/white palette)
  - Pages: `index.php`, `solutions.php`, `industries.php`, `how-it-works.php`, `pricing.php`, `resources.php`, `blog-list.php`, `blog-post.php`, `about.php`, `contact.php`, `contact-submit.php`, `thank-you.php`, `login.php`, `logout.php`, `dashboard-placeholder.php`
  - `includes/` – shared header/footer/config/helpers
  - `assets/css/` – design tokens and components
  - `assets/js/` – nav/UX + form validation
  - `uploads/`, `api/`
- `legacy/` – archived prototypes renamed to kebab-case `.php` (not linked from new nav)
- `database/` – SQL dumps and local DB artifacts
- `docs/` – guides/notes
- `frontend/`, `backend/`, `Frontend prototype/` – older stacks, not used by the new PHP site

## Quick start (XAMPP/LAMP/WAMP)
1) Place repo at your web root (e.g., `C:\xampp\htdocs\Autopredator`).  
2) Import a schema (optional): see `database/127_0_0_1 (6).sql` or `database/blog_posts_seed.sql` for the blog seed.  
3) Configure DB creds in `website/includes/config.php` (defaults: root/no password, DB `autopredator_site`).  
4) Visit `http://localhost/Autopredator/website/` to view the site.  
5) Auth placeholder:
   - Create a `users` row with a `password_hash` (use `password_hash('yourpass', PASSWORD_DEFAULT)`).
   - Login at `website/login.php`; redirects to `dashboard-placeholder.php` on success.

## Design system
- Palette: red (`#E50914`), black (`#000`/`#111`), white (`#fff`) only.
- Tokens in `website/assets/css/styles.css`; components/layout in `components.css`.
- JS avoids inline colors; nav/scroll/active-link and form validation live in `assets/js`.

## DB helpers
- `website/includes/helpers.php` exposes `get_db_connection()`, `escape_html()`, `create_lead()`, `create_newsletter_subscriber()`, `get_blog_post_by_slug()`.
- Blog pages expect table `blog_posts` with columns `id, title, slug, excerpt, content, featured_image, created_at`.
- Leads expect `leads` table with `name, email, phone, company, fleet_size, message, source`.

## Legacy
- All archived prototypes live under `legacy/` (e.g., `agricultural.php`, `fleet-management.php`, `unified-dashboard.php`). They are not linked from the new site; keep for reference or migrate as needed.

## Notes
- Analytics snippet in `includes/header.php` uses `GA_MEASUREMENT_ID` placeholder—replace with your ID.
- `database/*.sql` and `*.sqlite3` are git-ignored; adjust as needed.
- Main task tracker for the site lives in `website/TODO.md`.
