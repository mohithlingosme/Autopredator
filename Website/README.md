# Autopredator B2B Website (PHP + HTML + CSS + JS)

This repository contains the **marketing / B2B website** for **Autopredator**.

- Tech stack: **PHP 8**, **MySQL**, **HTML5**, **CSS3**, **Vanilla JavaScript**
- Goal: A clean, fast, B2B-style website that explains Autopredator, collects leads, and connects to the core platform later.

---

## 1. Tech Stack & Requirements

### 1.1 Technologies

- **Frontend**: HTML5 + CSS3 + JavaScript
- **Backend**: PHP (procedural or simple MVC-style)
- **Database**: MySQL / MariaDB (via XAMPP or similar)
- **Server**: Apache (XAMPP / shared hosting)
- **Tools** (optional):
  - VS Code
  - Git + GitHub
  - phpMyAdmin for DB management

### 1.2 Minimum Server Requirements

- PHP 7.4+ (recommended PHP 8+)
- MySQL / MariaDB
- Apache with `mod_rewrite` (optional but useful)

---

## 2. Folder & File Structure

> This is the **proposed** structure for the website part of Autopredator.  
> You can put this inside your existing `Autopredator/legacy/php_app/` folder or as a standalone `website/` folder.

```text
project-root/
└── website/
    ├── index.php                  # Home (landing) page
    ├── solutions.php              # Solutions overview page
    ├── solution-vehicle.php       # Detailed: Vehicle Management
    ├── solution-fleet.php         # Detailed: Fleet Management
    ├── solution-costs.php         # Detailed: Cost & Analytics
    ├── solution-compliance.php    # Detailed: Safety & Compliance

    ├── industries.php             # Industries overview
    ├── industry-logistics.php     # Logistics & fleets
    ├── industry-construction.php  # Construction & heavy equipment
    ├── industry-agriculture.php   # Agriculture & farm vehicles
    ├── industry-corporate.php     # Corporate / leasing

    ├── how-it-works.php           # Platform workflow
    ├── pricing.php                # Pricing / plans (even “Talk to sales” only)
    ├── resources.php              # Resources landing page
    ├── blog-list.php              # Blog listing
    ├── blog-post.php              # Single blog post (dynamic by ID/slug)

    ├── about.php                  # About the company
    ├── contact.php                # Contact / Book a demo page
    ├── contact-submit.php         # Handles contact form POST
    ├── thank-you.php              # Simple thank-you page after form submit

    ├── login.php                  # Login page (for future customer portal)
    ├── logout.php                 # Logout logic
    ├── dashboard-placeholder.php  # Placeholder page after login

    ├── includes/
    │   ├── config.php             # DB connection & global config
    │   ├── header.php             # Common <head> + navigation
    │   ├── footer.php             # Common footer
    │   ├── helpers.php            # Helper functions
    │   └── db.php                 # Optional: DB wrapper (PDO)

    ├── assets/
    │   ├── css/
    │   │   ├── styles.css         # Global styles
    │   │   └── components.css     # Extra component styles (cards, buttons)
    │   ├── js/
    │   │   ├── main.js            # Global scripts (menu, animations, etc.)
    │   │   └── form-validation.js # Contact / demo form validation
    │   └── images/
    │       ├── logo/
    │       ├── hero/
    │       └── illustrations/

    ├── uploads/
    │   ├── blog-images/           # Uploaded blog feature images
    │   └── resources/             # PDF downloads (product overview, guides)

    ├── api/
    │   ├── api-lead-create.php    # AJAX endpoint to save a lead
    │   └── api-newsletter.php     # AJAX endpoint for newsletter signup

    └── README.md                  # (this file)
You can simplify this structure if you want fewer pages or features.

3. Database Requirements
This website is mainly marketing + lead generation, so the DB can be simple.

3.1 Database Name
Use an existing DB (e.g. autopredator) or create a new one (e.g. autopredator_site).

3.2 Suggested Tables
3.2.1 leads – B2B demo / contact requests
Stores all “Book a demo” / “Talk to sales” submissions.

sql
Copy code
CREATE TABLE leads (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  phone VARCHAR(30) NULL,
  company VARCHAR(160) NULL,
  role VARCHAR(120) NULL,
  fleet_size VARCHAR(50) NULL,      -- e.g. "1-10", "11-50", "50+"
  message TEXT NULL,
  source_page VARCHAR(120) NULL,    -- e.g. 'hero', 'contact', 'pricing'
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
3.2.2 newsletter_subscribers – email capture
sql
Copy code
CREATE TABLE newsletter_subscribers (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(160) NOT NULL UNIQUE,
  name VARCHAR(120) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
3.2.3 blog_posts – simple CMS for blog
sql
Copy code
CREATE TABLE blog_posts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  slug VARCHAR(220) NOT NULL UNIQUE,
  excerpt TEXT NULL,
  content LONGTEXT NOT NULL,
  featured_image VARCHAR(255) NULL,   -- path to /uploads/blog-images/...
  author VARCHAR(120) NULL,
  published_at DATETIME NULL,
  is_published TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL
);
3.2.4 users – for basic login to a dashboard (future)
sql
Copy code
CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','editor','viewer') NOT NULL DEFAULT 'viewer',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
If you already have a users table in your main Autopredator schema, you can reuse that instead of creating a new one.

4. Pages Overview
Below is a list of the main pages and what they do.

4.1 Public Pages
index.php – Home

Hero section (headline, subtext, CTAs)

“Why vehicle management is broken” (pain points)

“What Autopredator does” (key features)

Industries overview

Simple lead capture CTA (“Book a demo”)

solutions.php – Solutions overview

Short cards for each solution:

Vehicle Management

Fleet Management

Cost & Analytics

Safety & Compliance

Links to detailed solution pages.

solution-vehicle.php

Deep dive into “Unified Vehicle Management”:

Vehicle data

Ownership docs

Insurance, finance, etc.

solution-fleet.php

Fleet tracking, uptime, driver performance, etc.

solution-costs.php

Cost tracking, TCO, fuel analysis, maintenance cost.

solution-compliance.php

Compliance, documentation, renewals, alerts.

industries.php – Industries overview

Cards for:

Logistics & Fleets

Construction

Agriculture

Corporate / Leasing

Industry detail pages (industry-*.php)

Explain specific pain & outcomes for each sector.

how-it-works.php

Step 1: Connect vehicles & data

Step 2: Automate tracking & alerts

Step 3: Optimise with insights & reports

pricing.php

Basic pricing structure (even if only:

“Contact sales for a quote”

Or “Starter / Growth / Enterprise” blocks)

CTA to contact/demo form.

resources.php

List of:

Blog articles

Guides / PDFs (links to /uploads/resources/...)

FAQ (optional)

blog-list.php

List of blog_posts (title, date, excerpt, “Read more”).

blog-post.php

Full content of a single blog. Loaded via id or slug.

about.php

Story of why Autopredator exists.

Mission, vision, values.

contact.php

Contact form:

Name, Email, Phone, Company, Fleet size, Message.

Submits to contact-submit.php.

thank-you.php

Simple “Thanks, we’ll get back to you” after form submit.

login.php

Login form for admin / future customer portal.

dashboard-placeholder.php

Placeholder page after login for now (“Portal coming soon”).

5. Wiremap / Information Architecture
You can think of the site structure like this:

text
Copy code
Home (index.php)
│
├── Solutions (solutions.php)
│   ├── Vehicle Management (solution-vehicle.php)
│   ├── Fleet Management (solution-fleet.php)
│   ├── Cost & Analytics (solution-costs.php)
│   └── Safety & Compliance (solution-compliance.php)
│
├── Industries (industries.php)
│   ├── Logistics & Fleets (industry-logistics.php)
│   ├── Construction (industry-construction.php)
│   ├── Agriculture (industry-agriculture.php)
│   └── Corporate / Leasing (industry-corporate.php)
│
├── How It Works (how-it-works.php)
├── Pricing (pricing.php)
│
├── Resources (resources.php)
│   ├── Blog listing (blog-list.php)
│   └── Blog post (blog-post.php)
│
├── About (about.php)
├── Contact / Book a Demo (contact.php)
│   └── Thank You (thank-you.php)
│
└── Login (login.php)
    └── Dashboard (dashboard-placeholder.php)
5.1 Simple Wireframe (Home Page)
Home (index.php) – Section-level wireframe:

Header

Logo (Autopredator)

Navigation: Solutions | Industries | How it works | Resources | About | Contact | Login

“Book a demo” button

Hero

Headline: “All-in-one vehicle management for fleets, farms & construction”

Subheadline: 1–2 lines

Primary CTA: “Book a 30-minute strategy call”

Secondary CTA: “Explore the platform”

Visual: simple stat card / mini dashboard mock (static for now)

Pain Points

“Why vehicle management is broken”

3–4 short bullet cards (data scattered, no real-time view, manual compliance, etc.)

Solutions Overview

4 cards:

Vehicle Management

Fleet Management

Cost & Analytics

Safety & Compliance

Each with link “Learn more →”

Industries

3–4 small cards:

Logistics, Construction, Agriculture, Corporate

Each link to industry detail pages.

How it Works

3-step strip:

Connect → Automate → Optimise

Proof / Trust

Placeholder for:

Testimonials / case studies (future)

Partner logos (future)

Lead Capture

Short form:

Name, Email, Company, Fleet Size, Message

“Get a custom demo”

Footer

Quick links

Email / contact

Terms & Privacy placeholders

6. Setup Instructions (Local)
Clone or copy the project into your server root
e.g. C:/xampp/htdocs/Autopredator/website/

Create database in phpMyAdmin

e.g. autopredator_site

Run the SQL to create tables (leads, newsletter_subscribers, blog_posts, users).

Update DB config

Open includes/config.php and set:

php
Copy code
<?php
$db_host = "localhost";
$db_name = "autopredator_site";
$db_user = "root";
$db_pass = ""; // or your password
?>
Start XAMPP

Start Apache + MySQL.

Open in browser

Visit: http://localhost/Autopredator/website/

Test contact form

Fill in the form on contact.php.

Check leads table to confirm data is saved.

7. Next Steps
Fill each page (.php) with real copy and design.

Hook up forms to database using PHP.

Gradually connect this marketing site to your core Autopredator platform (login, dashboards, etc.).

Add analytics (e.g. Google Analytics) for tracking.

