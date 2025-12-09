# TODO – Autopredator Business Website (`/Website`)

Status (Dec 2025):  
- ✅ Tech stack decided: PHP with shared partials (`partials/header.php`, `partials/footer.php`, `partials/layout.php`).  
- ✅ Structure in place: `assets/`, `pages/`, `products/`, `solutions/`, `api/`, `includes/`.  
- ✅ Core pages implemented: Home, Solutions + subpages, Product Suite, Resources, About, Contact, Login, Dashboard placeholder.  
- ✅ Lead + newsletter APIs wired (`api/api-lead-create.php`, `api/api-newsletter.php`).  

This TODO focuses on **remaining work, polish, and production-readiness**.

---

## 1. Navigation, Footer & Page Inventory

- [x] **Decide what to do with footer-only pages that don't exist yet:**
  - [x] `industries.php` - either:
    - [x] Create a dedicated Industries page **or**
    - [x] Remove the footer link or point it to an existing section (e.g., `solutions.php#who-for`).
  - [x] `how-it-works.php` - either:
    - [x] Create a "How it works" page describing data sources, workflow, and value **or**
    - [x] Point this link to a section on the home page (e.g., "vision" / "how it works" block) and use an anchor.
  - [x] `pricing.php` - either:
    - [x] Create a simple pricing / "Talk to sales for pricing" page **or**
    - [x] Hide/remove this link until you're ready to publish pricing.
- [x] Verify every link in:
  - [x] Header nav (from `$navItems` in `partials/header.php`).
  - [x] Footer "Quick links", "Company", and "Contact" sections.
  - [x] Buttons and CTAs in `pages/home.php`, `pages/solutions/*.php`, `pages/product-suite.php`, `pages/resources.php`, etc.
  - [x] Ensure no link points to a non-existent `.php` or wrong anchor.
- [x] Confirm the **sitemap (`sitemap.xml`) matches final navigation:**
  - [x] Add/remove URLs to match whatever you decide about `industries.php`, `how-it-works.php`, `pricing.php`.
  - [x] Verify every `<loc>` URL has a corresponding `.php` file / route.
---

## 2. Content & Copy Polish

- [ ] Do a pass on **all marketing copy** for clarity and consistency:
  - [ ] Home (pages/home.php).
  - [ ] Solutions overview (pages/solutions.php).
  - [ ] Individual solutions (pages/solutions/*.php).
  - [ ] Product suite + each product page (pages/product-suite.php, pages/products/*.php).
  - [ ] For Fleets / Individuals / Partners (pages/for-*.php).
  - [ ] About (pages/about.php).
  - [ ] Resources (pages/resources.php).
- [ ] Standardise language & tone:
  - [ ] Use one consistent way to describe Autopredator (e.g., unified vehicle intelligence & management platform).
  - [ ] Ensure DriveMatrix vs Autopredator usage is clear (product vs company vs platform).
- [x] Replace any placeholder / coming soon text where you now have more concrete messaging:
  - [x] pages/product-suite.php (Coming soon titles/descriptions for modules).
  - [x] pages/for-individuals.php, pages/for-partners.php, pages/dashboard-placeholder.php.
  - [x] pages/resources.php cards (blog/resource teasers).
- [ ] Run a final **spelling/grammar** check across all pages.

---

## 3. Lead Capture, Contact Form & Newsletter

### 3.1 Database & Helpers

- [ ] Ensure the database `autopredator_site` exists with tables that match the PHP helpers:
  - [ ] `leads` table (for `create_lead(...)`):
    - [ ] Columns to support: `name`, `email`, `phone`, `company`, `fleet_size`, `notes`, `source_page`, plus standard meta (`created_at` etc.).
  - [ ] `newsletter_subscribers` table (for `create_newsletter_subscriber(...)`):
    - [ ] At minimum: `id`, `email`, `created_at`, optional `is_confirmed`.
- [ ] Optionally add a **simple admin view** (even unlinked URL) to confirm leads/newsletter entries are being stored.

### 3.2 Contact Form (`pages/contact.php` / `contact-submit.php`)

- [ ] Confirm `contact-submit.php` correctly:
  - [ ] Validates required fields.
  - [ ] Creates lead via `create_lead(...)` **or** falls back to email + `error_log`.
  - [ ] Redirects or renders a clear success/failure message.
- [ ] Ensure **frontend UX** is smooth:
  - [ ] `#contact-form` is correctly handled in `assets/js/main.js` (AJAX vs normal POST).
  - [ ] Status messages (e.g., `.form-status`) update on success/failure.
  - [ ] Required fields are marked and show errors on invalid input.

### 3.3 Inline / Mini Lead Forms

- [ ] In `main.js`, either **use or remove** the mini lead form logic:
  - [ ] If you want mini lead forms (“Get early access” sections on pages):
    - [ ] Add markup with `data-lead-form`, input fields, and `.form-status` where needed.
    - [ ] Confirm the JS selector and action URL (`api/api-lead-create.php`) are correct.
  - [ ] If not needed, simplify/remove `initMiniLeadForms()` to reduce dead code.

### 3.4 Newsletter Form (Footer)

- [ ] Confirm `<form data-newsletter-form>` in `partials/footer.php`:
  - [ ] Posts to `api/api-newsletter.php`.
  - [ ] Shows loading / success / error states via `.form-status` in the footer.
  - [ ] Validates email on the client before firing the request.

---

## 4. Blog & Resources

- [ ] Finalise **blog data model** (used in `blog-list.php` and `blog-post.php`):
  - [ ] `blog_posts` table with at least: `id`, `title`, `slug`, `excerpt`, `content`, `featured_image`, `published_at`, `is_published`.
- [ ] Confirm `blog-list.php`:
  - [ ] Queries published posts from `blog_posts`.
  - [ ] Passes `$posts` into `pages/blog-list.php`.
  - [ ] Displays a “No posts yet” state if DB is empty (already present – just test).
- [ ] Confirm `blog-post.php`:
  - [ ] Supports loading by `slug` or ID from query string.
  - [ ] Handles “not found / unpublished” posts with a friendly message instead of a fatal error.
- [ ] When you’re ready:
  - [ ] Seed DB with 2–3 real posts about predictive maintenance, data, etc.
  - [ ] Link relevant cards in `pages/resources.php` to actual `blog-post.php?slug=...` URLs.

---

## 5. Auth, Portal & Session Handling

- [ ] Ensure `users` table exists for login (`auth-process.php`):
  - [ ] Columns: `id`, `name`, `email`, `password_hash`, `role`, `created_at`, `updated_at`.
- [ ] Confirm **login flow**:
  - [ ] Validates email/password on `auth-process.php`.
  - [ ] On success, sets `$_SESSION['user_id']`, `$_SESSION['user_name']`, `$_SESSION['user_role']`.
  - [ ] Redirects to `dashboard-placeholder.php`.
  - [ ] On failure, redirects back to `login.php?error=1` and shows the error banner in `pages/login.php`.
- [ ] Confirm **logout**:
  - [ ] `logout.php` properly clears session and redirects to `index.php` or `login.php`.
- [ ] Harden sessions for production:
  - [ ] Use secure session cookies (`session.cookie_secure`, `session.cookie_httponly`, `session.use_strict_mode`).
  - [ ] Consider CSRF tokens for login and lead forms if you expose them publicly.
- [ ] Plan next steps for replacing `dashboard-placeholder.php`:
  - [ ] Decide whether to keep it as a “coming soon” page or connect it later to a real portal app.

---

## 6. Design, Layout & Responsiveness

- [ ] Run through all pages on:
  - [ ] Mobile (~360–400px width).
  - [ ] Tablet (~768px).
  - [ ] Desktop (≥1366px).
- [ ] Fix any layout issues:
  - [ ] Overflow or horizontal scrolling on small screens.
  - [ ] Cards or grids breaking at awkward breakpoints.
  - [ ] Hero image (`mock-dashboard.svg`) scaling on mobile.
- [ ] Check buttons & CTAs:
  - [ ] All buttons have clear hover/focus states.
  - [ ] Tap targets are large enough on touch devices.
- [ ] Ensure typography is consistent:
  - [ ] Same font sizes / line heights for section headings, body text, captions.
  - [ ] Consistent usage of `.muted`, `.text-small`, `.tagline`, `.pill` etc.

---

## 7. Analytics, Tracking & Config

- [ ] Replace **Google Analytics placeholder** in `partials/header.php`:
  - [ ] Set the real `GA_MEASUREMENT_ID`.
  - [ ] Or remove GA entirely if you’re not using it.
- [ ] Verify `initCTATracking()` in `assets/js/main.js`:
  - [ ] All key CTAs (`data-cta="..."`) are tagged:
    - [ ] Hero buttons.
    - [ ] Nav actions (Launch Beta, Book a demo).
    - [ ] Footer newsletter button.
    - [ ] Any “Learn more” / “Talk to us” buttons you care about.
  - [ ] Confirm events appear in GA (if configured).
- [ ] Consider basic **privacy / cookie** note if required for your region.

---

## 8. Configuration, Security & Cleanup

- [ ] Review **DB config** in `includes/config.php`:
  - [ ] Move credentials (`$db_host`, `$db_name`, `$db_user`, `$db_pass`) to environment variables or a config not committed to Git.
  - [ ] Document required DB setup in `README.md` (database name, tables).
- [ ] Clean up unused files:
  - [ ] `includes/nav.php` is currently empty – either wire it up or remove it.
  - [ ] Remove any old / unused prototypes if they creep back in future.
- [ ] Error handling:
  - [ ] Make sure DB errors are `error_log`’d but not exposed to the user.
  - [ ] Add simple user-friendly messages where appropriate (“Something went wrong, please try again”).
- [ ] Make sure `robots.txt` and `sitemap.xml` are updated and deployed from the correct document root.

---

## 9. Final QA & Launch Checklist

- [ ] Click-through test:
  - [ ] Manually click every header and footer link.
  - [ ] Check all in-page anchor links (`#demo`, etc.).
- [ ] Forms:
  - [ ] Submit contact form with valid/invalid data and verify:
    - [ ] DB/lead entry or email log.
    - [ ] User feedback on success/failure.
  - [ ] Submit newsletter form and verify subscription is stored.
- [ ] SEO basics:
  - [ ] Unique `<title>` and `<meta name="description">` for each page.
  - [ ] Proper `<h1>` usage per page.
- [ ] Deployment:
  - [ ] Sync `/Website` to your hosting.
  - [ ] Configure domain (e.g., `autopredator.in`) to point to this folder.
  - [ ] Verify HTTPS/SSL.
- [ ] Live-site smoke test:
  - [ ] Test from mobile and desktop over real mobile data / Wi-Fi.
  - [ ] Check load time and basic Lighthouse scores (performance, accessibility, SEO).

---

## 10. Future Enhancements (Nice-to-have)

- [ ] Add a simple **admin dashboard** to view leads and newsletter subscribers.
- [ ] Add a small CMS or markdown-based system for blog posts.
- [ ] Add testimonials / case studies once you have early users.
- [ ] Multi-language support if needed in future.






