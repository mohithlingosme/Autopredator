# Autopredator Website

This folder contains the business & marketing site for Autopredator.

## 🛠 Tech Stack
- PHP templates with shared partials (`partials/header.php`, `partials/footer.php`, `partials/layout.php`)
- HTML, CSS (`assets/css/global.css`, `assets/css/styles.css`, `assets/css/components.css`)
- Vanilla JS for UI, forms, and tracking (`assets/js/main.js`)

## 🚀 Local Development
From the repo root:
```bash
cd Website
php -S localhost:8000
```
Then open http://localhost:8000/.

## 🏗 Build
No build step required; assets are plain CSS/JS.

## 🌐 Deploy
- Sync the `Website/` directory to your PHP-capable host (or serve via Apache/Nginx pointing to this folder).
- Ensure `robots.txt` and `sitemap.xml` are served at the root.
- Set the correct `GA_MEASUREMENT_ID` in `partials/header.php` before production.
