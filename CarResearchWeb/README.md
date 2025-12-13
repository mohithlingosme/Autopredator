# Autopredator Car Research Web (PHP)

Lightweight PHP build for researching new and used cars in India. The current version runs entirely from JSON data (no DB required) and ships with brand, model, variant, search, and comparison pages that mirror the Autopredator UX.

---

## What's Included

- Brand, model, and variant listings with price ranges and fuel types.
- Search with filters for brand, body type, fuel, transmission, budget, and text queries.
- Model/variant detail views wired to the JSON dataset.
- Compare flow for side-by-side variants.
- Basic auth scaffold (login/register), header nav, and shared layout/styles.
- JSON-first repository layer with schema validation and caching.

---

## Tech Overview

- PHP 8+, no framework required; works with Apache (XAMPP) or `php -S`.
- Data source: `mocks/new_carset.json` (primary) and `mocks/data.json` (legacy, converted from spreadsheet via script).
- Repository: `includes/json_car_repository.php` plus thin wrappers in `includes/repository.php` and `includes/car_repository.php` to keep existing pages working.
- Config: `includes/config.php` with `APP_ENV` and `USE_JSON` switches. Default is `USE_JSON=true` and no database connection.

---

## Quick Start (local)

1) Prerequisites: PHP 8+, Python 3.10+ (only if you need to regenerate JSON), a web server (Apache/XAMPP) or PHP built-in server.  
2) Install: Place the repo under your doc root (e.g., `C:\xampp\htdocs\Autopredator\CarResearchWeb`).  
3) Run (built-in server):  
```bash
cd C:\xampp\htdocs\Autopredator\CarResearchWeb
set APP_ENV=local
set USE_JSON=true
php -S localhost:8000
```
Visit http://localhost:8000 in your browser. For Apache/XAMPP, point a virtual host to this directory instead of using `php -S`.

---

## Configuration

- `APP_ENV` (default `local`): controls environment-specific behaviors you add later.
- `USE_JSON` (default `true`): keep this `true` for the current build. Setting `false` will require wiring a MySQL-backed repository; only JSON is implemented today.
- Database constants live in `includes/config.php`, but DB code paths are not active in this build.

---

## Data

- Primary dataset: `mocks/new_carset.json` (make, model, segment, variants with price/fuel/transmission/engine/horsepower).  
- Legacy/raw: `mocks/data.json` plus `mocks/data.original.txt`.  
- Conversion utility: `scripts/convert_data_to_json.py` converts the raw tabular file from the DriveMatrix source into clean JSON (backs up the original as `data.original.txt`).

Validation and parsing are handled in `includes/json_car_repository.php` (schema checks, price parsing, search helpers, and pagination). All pages use this repository via `includes/repository.php`.

---

## Key Pages

- `index.php`: landing with featured brands/models/variants.  
- `brand.php`: brand listing and brand-specific model grid.  
- `model.php`: model detail with variants.  
- `variant.php`: variant detail scaffold (specs/features placeholders until data is added).  
- `search.php`: filterable search results with pagination and sorting.  
- `compare.php`: simple comparison view for selected variants.  
- `login.php`, `register.php`, `my_garage.php`, `favourites.php`: auth/UI scaffolding (session-based).

---

## Structure

- `includes/`: config, auth, helpers, repositories, header/footer partials.  
- `mocks/`: JSON datasets.  
- `assets/`: CSS, images, fonts.  
- `api/` and `mocks/` (root): API stubs and sample data if you extend to AJAX.  
- `scripts/`: data conversion utilities.  
- `docs/`: product and API notes.

---

## Development Notes

- Keep `USE_JSON=true` unless you add a MySQL repository; the legacy DB tables are not currently read.  
- Price parsing currently expects Indian-style strings with "L"/"Cr" suffixes; adjust `json_parse_price` in `includes/json_car_repository.php` if your data changes.  
- If you import new data, run the Python converter or drop clean JSON into `mocks/new_carset.json` and reload.

---

## Future Work

- Swap-in MySQL repository with the same interface as `json_*` functions.  
- Enrich specs/features/pricing history and surface them on variant pages.  
- Harden auth (password hashing, validation, CSRF) and add user garage persistence.  
- Add automated tests for repository functions and search filters.
