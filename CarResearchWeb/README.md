# Autopredator Car Research Web

Lightweight PHP app for researching Indian-market cars. Ships with brand/model/variant listings, search and comparison flows, and a JSON-first data layer.

## Prerequisites
- PHP 8.1+ (CLI and web SAPI). Works with XAMPP/Apache or `php -S`.
- Composer (for installing and running the PHPUnit test suite).
- Optional: Python 3.10+ if you want to regenerate legacy JSON from tabular data.

## Run Locally
1) Place the project under your web root (e.g., `C:\xampp\htdocs\Autopredator\CarResearchWeb`) or clone anywhere and use `php -S`.  
2) Configure env (optional):
   ```bash
   set APP_ENV=local
   set USE_JSON=true
   ```  
3) Start the app:
   ```bash
   cd C:\xampp\htdocs\Autopredator\CarResearchWeb
   php -S localhost:8000
   ```  
   or point Apache/XAMPP to this folder as the document root.

## Configuration
- `config.php` defines `BASE_PATH`, `DATA_DIR`, `APP_ENV`, and `USE_JSON` (JSON is the primary source). Production mode disables display_errors.  
- `includes/config.php` simply loads the shared config for legacy includes.
- Logs: `storage/logs/app.log` (auto-created).  
- Database constants live in `config.php`, but JSON is the active datastore.

## Data Layout
- `data/new_carset.json` — primary dataset (make/model/segment/variants with pricing and fuel).  
- `data/data.json` — legacy dataset merged in for backward compatibility.  
- `data/details_index.json` — allowlist mapping `slug -> detail file` (e.g., `xuv700` -> `XUV700.json`).  
- `data/XUV700.json` — example detail sheet referenced via the allowlist.  
- `scripts/convert_data_to_json.py` — regenerates `mocks/data.json` from the original spreadsheet; now uses project-relative paths for portability.

### Adding Data
1) Drop new model entries into `data/new_carset.json` (or legacy `data/data.json`).  
2) If you add a per-model detail sheet, place it under `data/` and register it in `data/details_index.json` with a slug matching `/^[a-z0-9]+(?:-[a-z0-9]+)*$/`.  
3) Clear PHP opcache if enabled, then reload the page.

## Routes & Pages
- `index.php` — landing with featured brands/families/variants.  
- `brand.php` — all manufacturers and per-brand model listings.  
- `model.php` — model overview and variants.  
- `variant.php` — variant details.  
- `search.php` — filterable search (brand, body type, fuel, transmission, budget, text).  
- `compare.php` — side-by-side comparison.  
- API: `api/autocomplete.php` (search suggestions), `api/details.php?slug=xuv700` (safe detail fetch via allowlist).

## Testing
1) Install dev tools: `composer install`  
2) Run the suite: `./vendor/bin/phpunit`  

Tests cover JSON loading, regression for BMW model counts, JSON error handling, and traversal protection on detail slugs.

## Security & Reliability Notes
- All template output flows through `e()` (UTF-8, `ENT_QUOTES|ENT_SUBSTITUTE`); defaults handle `null`/ints cleanly.  
- Security headers added globally: `X-Content-Type-Options`, `X-Frame-Options`, and `Referrer-Policy`.  
- JSON loading is centralized in `src/Data/JsonLoader` with readability checks, JSON exceptions trapped, and logging.  
- Detail JSON is served only via the slug allowlist in `data/details_index.json` with strict slug validation and path whitelisting.
