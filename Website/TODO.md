## 1. Structure & Tech Setup

- [x] Decide final tech stack for the business website (pure HTML/CSS/JS, PHP templates, or React/Next.js) and stick to one approach.
- [x] Clearly separate **Business Website** vs **Car Research App**:
  - [x] Keep marketing/business site in `Website/`.
  - [x] Link out to the car research platform (DriveMatrix/product UI) via a "Launch Platform / Beta" button instead of mixing code.
- [x] Create a clean folder structure inside `Website/`:
  - [x] `Website/assets/css/` for stylesheets.
  - [x] `Website/assets/js/` for scripts.
  - [x] `Website/assets/img/` for logos, illustrations, and screenshots.
- [x] `Website/pages/` (or `src/pages/` if using React/Next) for main pages.
- [x] `Website/partials/` for shared header, footer, and layout components.
- [x] Implement a **single shared layout** (header + footer + base structure) as a partial/template and use it across all pages.

## 2. Navigation & Page Map

- [x] Finalize top navigation items:
  - [x] Home
  - [x] Solutions
  - [x] Product Suite / Apps
  - [x] For Fleets
  - [x] For Individuals
  - [x] For Partners
  - [x] Resources / Blog
  - [x] About
  - [x] Contact / Request Demo
- [x] Ensure all navbar links point to real pages (or clearly marked "Coming soon").

### 2.1 Home Page

- [x] Build a **hero section** with:
  - [x] Clear one-line pitch for Autopredator (unified vehicle intelligence & management).
  - [x] 2-3 line supporting description.
  - [x] Primary CTA button (e.g., "Request Demo" or "Join Waitlist").
- [x] Add a "Who it's for" section:
  - [x] Individuals
  - [x] Fleet owners / operators
  - [x] Dealers & brokers
  - [x] Banks & insurers
- [x] Add a "Core modules / apps" section:
  - [x] Fleet Pro
  - [x] AutoMart
  - [x] Service & Maintenance
  - [x] Finance Desk / Loan & Lease Hub
  - [x] Compliance & Safety
  - [x] EV Center
  - [x] Data & Intelligence / Analytics
- [x] Add a "Key benefits" section (3-4 bullets/cards) highlighting:
  - [x] Reduced downtime.
  - [x] Lower operating costs.
  - [x] Automatic compliance & reminders.
  - [x] Better data & insights.
- [x] Add a simple "Vision / Roadmap teaser" section.

### 2.2 Solutions Pages

- [x] Create `/solutions/individuals` page with:
  - [x] Problem statement for individual vehicle owners.
  - [x] How Autopredator solves it.
  - [x] 3-5 feature highlights.
  - [x] Use cases.
  - [x] CTA (Request demo / Join waitlist).
- [x] Create `/solutions/fleet-owners` page similarly tailored to fleets.
- [x] Create `/solutions/dealers-and-brokers` page.
- [x] Create `/solutions/banks-and-insurers` page.

### 2.3 Product Suite / Apps

- [x] Create a **Product Suite** page listing all key apps as cards:
  - [x] Fleet Pro
  - [x] AutoMart
  - [x] Service & Maintenance
  - [x] Finance Desk / Loan & Lease Hub
  - [x] Compliance & Safety
  - [x] EV Center
  - [x] Data & Intelligence / Analytics
- [x] For each app card:
  - [x] Add icon/illustration.
  - [x] Add a 1-2 line description.
  - [x] Add a "Learn more" or "Coming soon" link.

### 2.4 Detailed Product Pages (V2, plan now)

- [x] Create placeholder detailed pages (even if minimal copy for now):
  - [x] `/products/fleet-pro`
  - [x] `/products/automart`
  - [x] `/products/finance-desk`
  - [x] `/products/ev-center`
- [x] Add basic structure (problem, features, screenshots, CTA) for each.

### 2.5 About & Vision

- [x] Create an **About** page with:
  - [x] Story of Autopredator.
  - [x] Vision & mission statements.
  - [x] "Why now / market gap" explanation.
  - [x] High-level roadmap (Phase 1, 2, 3).
  - [x] Short founder section (photo optional).

### 2.6 Contact / Request Demo

- [x] Create a **Contact / Request Demo** page with form:
  - [x] Name
  - [x] Email
  - [x] Phone
  - [x] Company / Organization
  - [x] Fleet size or vehicle use-case (dropdown or input)
  - [x] Message / Requirements
- [x] Implement success state (thank-you message or redirect to "Thank you" page).
- [x] Implement basic validation for required fields.

### 2.7 Resources / Blog

- [x] Create a **Resources / Blog** page:
  - [x] Add "Coming soon" message.
  - [x] Optionally add 1-2 dummy blog cards with placeholder titles & excerpts.

## 3. Design System & Branding

- [x] Define brand identity for Autopredator:
  - [x] Choose primary color (for CTAs).
  - [x] Choose accent color.
  - [x] Choose neutral background/base color.
  - [x] Choose font pair (headings + body).
- [x] Implement a **global stylesheet** with:
  - [x] Typography scale (H1–H6, body, caption).
  - [x] Button styles (primary, secondary, ghost).
  - [x] Card styles (padding, border-radius, shadow).
  - [x] Section spacing (consistent padding/margin).
- [x] Replace all placeholder/lorem-ipsum text with real Autopredator copy.
- [x] Ensure layout is responsive:
  - [x] Mobile-friendly navbar (hamburger if needed).
  - [x] Sections stack vertically on small screens.
  - [x] Check readability on phone/tablet/desktop.

## 4. Content & Messaging Alignment

- [x] Review the business plan and extract **core value propositions** for the website.
- [x] Ensure Home + Solutions pages clearly convey:
  - [x] Single pane of glass for vehicle operations.
  - [x] Works across personal, commercial, agricultural, and construction vehicles.
  - [x] Focus on cost savings, uptime, compliance, safety, and financing.
- [x] Add a “Who is this for?” section to Home with audience cards.
- [x] Add specific benefit sections:
  - [x] “Reduce downtime.”
  - [x] “Cut hidden vehicle costs.”
  - [x] “Never miss renewals & compliances.”
  - [x] “Get more from every vehicle asset.”
- [x] Add UI screenshots or mockups:
  - [x] Capture product/DriveMatrix UI screens.
  - [x] Place screenshots in hero/product sections as static images.

## 5. Forms, Backend Hooks & Tracking

- [x] Implement lead capture across key pages:
  - [x] CTA on Home hero leads to demo/contact form.
  - [x] Solutions pages include a mini-form or CTA linking to contact.
- [x] Decide form handling strategy:
  - [x] Simple PHP mailer script (if using PHP).
  - [x] Or third-party form service (Formspree, etc.).
- [x] Implement clear error handling for forms:
  - [x] Show messages for missing/invalid fields.
  - [x] Provide user-friendly success confirmation.
- [x] Add optional newsletter/waitlist:
  - [x] Simple email-only input for “Get early access”.
  - [x] Decide where to store or send these emails (DB or email service).
- [x] Integrate basic analytics:
  - [x] Add Google Analytics / Plausible / similar.
  - [x] Verify tracking of page views and CTA clicks.

## 8. Final QA & Deployment

- [x] Test navigation:
  - [x] All navbar links work.
  - [x] No dead links in buttons/CTAs.
- [x] Check for 404s and fix/update routes/links.
- [x] Test on multiple viewports:
  - [x] Small phone (~360–400px).
  - [x] Tablet (~768px).
  - [x] Desktop (≥1366px).
- [x] Proofread all visible text:
  - [x] Fix spelling/grammar.
  - [x] Ensure consistent naming (“Autopredator”, module names, etc.).
- [x] Deploy the website to hosting:
  - [x] Choose hosting (Netlify/Vercel/shared hosting etc.).
  - [x] Point domain (e.g., `autopredator.in`) to the deployed site.
  - [x] Verify HTTPS/SSL is working.
- [x] Do a final live-site check:
  - [x] Forms submit correctly.
  - [x] Analytics records visits.
  - [x] Site loads correctly on mobile & desktop over real internet.

## 7. Repo Cleanup & Dev Experience

- [x] Delete unused/demo/template HTML/PHP/JS files that are not part of the final sitemap.
- [x] Remove old CSS files not referenced anywhere in the site.
- [x] Standardize file naming:
  - [x] `index.*` for Home.
  - [x] `solutions-fleets.*` or `/solutions/fleets/index.*` etc.
  - [x] `contact.*` for contact page.
- [x] Add a `README.md` inside `Website/` explaining:
  - [x] Purpose of this folder (business/marketing site).
  - [x] Tech stack used.
  - [x] How to run locally.
  - [x] How to build (if applicable).
  - [x] How to deploy.
- [x] Add simple scripts or documented commands:
  - [x] For local dev (`npm run dev` / `php -S` / etc.).
  - [x] For build (`npm run build` etc.) if using a bundler/framework.

## 6. SEO, Meta & Performance

- [x] Set unique `<title>` and `<meta description>` for each page.
- [x] Use proper heading hierarchy (one H1 per page; logical H2/H3).
- [x] Add descriptive `alt` text for all key images.
- [x] Create and serve `robots.txt`.
- [x] Create and serve `sitemap.xml` with all important URLs.
- [x] Ensure URLs are clean and readable (avoid messy query strings when possible).
- [x] Add Open Graph tags to main pages:
  - [x] `og:title`
  - [x] `og:description`
  - [x] `og:image`
  - [x] `og:url`
- [x] Optimize images:
  - [x] Compress large graphics.
  - [x] Prefer `.webp` where supported.
  - [x] Lazy-load below-the-fold images.
- [x] Remove unused CSS/JS from old templates to improve load speed.
