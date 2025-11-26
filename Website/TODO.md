````markdown
# ✅ Autopredator – Full Project TODO (PHP + HTML + CSS + JS)

> **Important UI Rule:**  
> The entire project must use **ONLY a Red, Black & White color palette** (including their shades & tints).  
> 👉 No blues, greens, gradients in other colors, etc.

Primary palette (can be refined later, but keep the idea):
- **Black / Near Black:** `#000000` / `#050505` / `#111111`
- **White / Off-White:** `#FFFFFF` / `#F7F7F7` / `#ECECEC`
- **Red / Dark Red:** `#E50914` / `#C00000` / `#8B0000`

---

## 🧱 PHASE 0 – Project Setup & Structure

- [ ] Create project root folder: `Autopredator/website/`
- [ ] Create basic folder structure:

```text
Autopredator/
└── website/
    ├── index.php
    ├── solutions.php
    ├── industries.php
    ├── how-it-works.php
    ├── pricing.php
    ├── resources.php
    ├── blog-list.php
    ├── blog-post.php
    ├── about.php
    ├── contact.php
    ├── contact-submit.php
    ├── thank-you.php
    ├── login.php
    ├── logout.php
    ├── dashboard-placeholder.php
    │
    ├── includes/
    │   ├── config.php
    │   ├── header.php
    │   ├── footer.php
    │   ├── nav.php
    │   └── helpers.php
    │
    ├── assets/
    │   ├── css/
    │   │   ├── styles.css
    │   │   └── components.css
    │   ├── js/
    │   │   ├── main.js
    │   │   └── form-validation.js
    │   └── images/
    │       ├── logo/
    │       ├── hero/
    │       └── illustrations/
    │
    ├── uploads/
    │   ├── blog-images/
    │   └── resources/
    │
    ├── api/
    │   ├── api-lead-create.php
    │   └── api-newsletter.php
    │
    ├── README.md
    └── TODO.md
````

* [ ] Configure local server path (e.g. `C:/xampp/htdocs/Autopredator/website/`)
* [ ] Test `index.php` loads correctly in browser

---

## 🎨 PHASE 1 – Design System (Red / Black / White Only)

### 1.1 Color Palette

* [ ] Define final 5–7 tokens in `styles.css`:

  ```css
  :root {
    --ap-black: #050505;
    --ap-black-soft: #111111;
    --ap-white: #ffffff;
    --ap-white-soft: #f5f5f5;
    --ap-red: #e50914;
    --ap-red-dark: #b00010;
    --ap-red-soft: #ffd6d9; /* very light tint of red */
    --ap-border: #2a2a2a;
  }
  ```

* [ ] **Rule:** No other base colors. Only use **shades/tints of red, black & white**.

* [ ] Define accessible contrast (check text vs background):

  * Black/white + Red for emphasis only
  * Avoid red text on black with low contrast

### 1.2 Typography & Spacing

* [ ] Choose a system font stack (for simplicity):

  ```css
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  ```

* [ ] Define heading, body, small text styles

* [ ] Define button styles:

  * [ ] Primary button: Red background, white text
  * [ ] Secondary button: Black background / white border
  * [ ] Ghost button: Transparent with red border

### 1.3 Components (in `components.css`)

* [ ] Navigation bar (dark background, red hover underline)
* [ ] Hero section (black background, white text, red CTA)
* [ ] Cards (white or dark background with red accent)
* [ ] Forms (white inputs, dark borders, red focus)
* [ ] Tables (if needed)
* [ ] Badges/chips (e.g. red outline / soft red fill)

---

## 🗄 PHASE 2 – Database & Backend Setup

### 2.1 Database Creation

* [ ] Create DB: `autopredator_site` (or use existing DB)

* [ ] Create tables:

  * [ ] `leads`
  * [ ] `newsletter_subscribers`
  * [ ] `blog_posts`
  * [ ] `users`

* [ ] Save SQL scripts in `/database/` folder (optional, for backup)

### 2.2 `includes/config.php`

* [ ] Add DB connection variables:

  ```php
  <?php
  $db_host = "localhost";
  $db_name = "autopredator_site";
  $db_user = "root";
  $db_pass = "";
  ?>
  ```

### 2.3 `includes/helpers.php` & DB wrapper

* [ ] Create `get_db_connection()` function using PDO
* [ ] Add helper functions:

  * [ ] `escape_html($str)` – for output escaping
  * [ ] `get_blog_post_by_slug($slug)`
  * [ ] `create_lead($data)`
  * [ ] `create_newsletter_subscriber($email)`
* [ ] Add error logging (if DB connection fails)

---

## 🧩 PHASE 3 – Layout, Header & Footer (Global Structure)

### 3.1 `includes/header.php`

* [ ] Basic HTML `<head>` section
* [ ] Link to `assets/css/styles.css` & `assets/css/components.css`
* [ ] Link to `assets/js/main.js`
* [ ] Set `<title>` and meta description (can pass via variables)
* [ ] Global `<header>` structure:

  * Logo (Black/white logo with red accent)
  * Navigation menu with links:

    * Home, Solutions, Industries, How it works, Resources, Pricing, About, Contact, Login
  * Primary CTA: “Book a demo” (red button)

> All navigation and header background should follow **black/white/red** rule.

### 3.2 `includes/footer.php`

* [ ] Footer with:

  * Quick links
  * Contact email
  * Social placeholders (icons in white/red)
  * Copyright text in muted white/grey
* [ ] Background: **black** or very dark shade

### 3.3 Basic Page Layout

* [ ] Ensure all main pages include:

  ```php
  <?php include 'includes/header.php'; ?>
  <!-- Page content -->
  <?php include 'includes/footer.php'; ?>
  ```

---

## 🏠 PHASE 4 – Public Pages Development

> Every page must respect the **Red/Black/White** palette in HTML & CSS.

### 4.1 `index.php` – Home Page

* [ ] Hero section:

  * Headline, subheadline
  * Two CTAs: **Book a demo** (red) + **Explore solutions** (outline)
* [ ] “Why vehicle management is broken” – 3–4 cards
* [ ] Solutions overview – 4 feature cards with red accents
* [ ] Industries overview – mini cards
* [ ] “How it works” – 3 steps
* [ ] Lead capture form (short) at bottom
* [ ] All backgrounds and elements styled only with red/black/white shades

### 4.2 `solutions.php`

* [ ] Intro text
* [ ] 4 solution cards:

  * Vehicle Management
  * Fleet Management
  * Cost & Analytics
  * Safety & Compliance
* [ ] Each card:

  * Red icon/accent
  * Button/link to detail pages (optional for now, can scroll or be separate)

### 4.3 `industries.php`

* [ ] Overview of industries
* [ ] 3–4 cards:

  * Logistics & Fleets
  * Construction
  * Agriculture
  * Corporate / Leasing
* [ ] Each card uses dark background with red title underline

### 4.4 `how-it-works.php`

* [ ] Step-based breakdown:

  * Step 1: Connect data
  * Step 2: Automate & monitor
  * Step 3: Optimise & report
* [ ] Info blocks with icons or numbers (white on black, red numbers)

### 4.5 `pricing.php`

* [ ] Simple tier boxes (Starter / Growth / Enterprise or “Talk to sales”)
* [ ] Red price or plan name, black cards, white text
* [ ] CTA buttons “Request quote” going to contact form

### 4.6 `resources.php`

* [ ] Links to:

  * Guides (PDF)
  * Blog posts
* [ ] Newsletter signup form (AJAX optional)

### 4.7 `blog-list.php` & `blog-post.php`

* [ ] `blog-list.php`:

  * Loop through `blog_posts` table
  * Display title, date, excerpt, red “Read more →” link
* [ ] `blog-post.php`:

  * Load post by `id` or `slug`
  * Show content in readable layout (white background, black text, red headings)

### 4.8 `about.php`

* [ ] Story of Autopredator
* [ ] Mission, vision, values
* [ ] Show timeline or bullet list (with red bullet highlights)

### 4.9 `contact.php` & `contact-submit.php`

* [ ] `contact.php`:

  * Form fields: Name, Email, Phone, Company, Fleet size, Message
  * Design: white form on dark/black background, red focus/submit button
* [ ] `contact-submit.php`:

  * Validate input
  * Save data into `leads` table
  * Redirect to `thank-you.php`

### 4.10 `thank-you.php`

* [ ] Simple thank-you message
* [ ] CTA to go back to Home or Resources
* [ ] Design consistent with palette

---

## 🔐 PHASE 5 – Auth & Dashboard Placeholder

### 5.1 `login.php`

* [ ] Login form (email + password)
* [ ] Use `users` table
* [ ] Styled with black background, white card, red submit button

### 5.2 Session Handling

* [ ] Start PHP session in header or auth-specific include
* [ ] On successful login:

  * Store `$_SESSION['user_id']`
  * Redirect to `dashboard-placeholder.php`

### 5.3 `dashboard-placeholder.php`

* [ ] Simple placeholder page:

  * “Autopredator Portal coming soon”
  * Link back to main website
* [ ] Must require login:

  * If not logged in, redirect to `login.php`

### 5.4 `logout.php`

* [ ] Destroy session
* [ ] Redirect to Home (`index.php`)

---

## 💻 PHASE 6 – JavaScript Enhancements

### 6.1 `assets/js/main.js`

* [ ] Smooth scroll for anchor links (e.g. header navigation)
* [ ] Mobile navigation toggle (if you create a burger menu)
* [ ] Add “active link” styling based on scroll position (optional)

> Ensure JS enhances UI but doesn’t break **red/black/white** visual style (no colored highlight effects beyond red/white).

### 6.2 `assets/js/form-validation.js`

* [ ] Validate required fields client-side:

  * Contact form
  * Login form
* [ ] Show error messages in white/red only (no green borders)

---

## 🧪 PHASE 7 – Testing, QA & Deployment

### 7.1 Functional Testing

* [ ] Test all navigation links
* [ ] Test contact form:

  * Valid data saved to DB
  * Redirect to thank-you page
* [ ] Test login/logout flow
* [ ] Test blog list & blog post pages
* [ ] Test newsletter signup (if implemented)

### 7.2 Design & Color QA

* [ ] Confirm **no non-red colors** anywhere in:

  * Backgrounds
  * Text
  * Buttons
  * Highlights
* [ ] Verify contrast:

  * Red on black → large enough & bold
  * White on red → readable
  * Black on white → standard

### 7.3 Responsive Check

* [ ] Test on:

  * Desktop
  * Tablet
  * Mobile
* [ ] Ensure menu works on mobile
* [ ] Ensure forms and cards scale correctly

### 7.4 Deployment

* [ ] Upload to shared hosting or production server
* [ ] Import DB schema
* [ ] Update `config.php` with production DB credentials
* [ ] Test full flow on live URL

---

## 📌 OPTIONAL PHASE – Content & SEO

* [ ] Write final copy for:

  * Home, Solutions, Industries, About, Contact, Pricing
* [ ] Add proper `<title>` and `<meta description>` per page
* [ ] Add simple blog articles to `blog_posts`
* [ ] Generate a `sitemap.xml`
* [ ] Add `robots.txt`
* [ ] Integrate Google Analytics / similar

---

> Keep this `TODO.md` updated as you work:
> Replace `[ ]` with `[x]` when tasks are completed.
> Always respect the **Red / Black / White** palette rule while designing, coding, and testing.

```
::contentReference[oaicite:0]{index=0}
```
