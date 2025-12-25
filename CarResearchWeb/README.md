# Autopredator Car Research Web

Lightweight PHP app for researching Indian-market cars. Ships with brand/model/variant listings, search and comparison flows, and a JSON-first data layer.

## Prerequisites
- PHP 8.1+ (CLI and web SAPI). Works with XAMPP/Apache or `php -S`.
- Composer (for installing and running the PHPUnit test suite).
- Optional: Python 3.10+ if you want to regenerate legacy JSON from tabular data.

## Run Locally
### Option 1: Using setup.bat (Recommended for Windows)
1) Clone the repository.
2) Run `setup.bat` to automatically install dependencies and start the server.
3) Open http://localhost:8000 in your browser.

### Option 2: Manual Setup
1) Place the project under your web root (e.g., `C:\xampp\htdocs\Autopredator\CarResearchWeb`) or clone anywhere and use `php -S`.
2) Configure env (optional):
   ```bash
   set APP_ENV=local
   set USE_JSON=true
   ```
3) Start the app:
   ```bash
   cd C:\xampp\htdocs\Autopredator\CarResearchWeb
   composer install
   php -S localhost:8000
   ```
   or point Apache/XAMPP to this folder as the document root.

### Option 3: Using Docker (Optional)
1) Ensure Docker and Docker Compose are installed.
2) Run `docker-compose up --build` to start the application with MySQL database.
3) Open http://localhost:8000 in your browser.

## CI/CD
- CI (`.github/workflows/ci.yml`): runs on PRs and pushes to `main`/`master`, auto-detects stacks; PHP 8.2 lint + composer install + PHPUnit; Node (if `package.json` exists) runs `npm ci`/lint/test/build and uploads `dist`; Python (if any `.py`/requirements) installs deps, runs Ruff when available, then pytest.
- Security (`.github/workflows/security.yml`): dependency review on PRs, CodeQL for detected JavaScript/Python/PHP, and Trivy filesystem scan for HIGH/CRITICAL issues on pushes/PRs/weekly.
- Release Docker (`.github/workflows/release-docker.yml`): builds with Buildx and pushes to GHCR on `v*.*.*` tags or manual dispatch, tagging both the version and `latest`; auto-detects Dockerfile location if not at repo root.
- Deploy (`.github/workflows/deploy.yml`): deploys over SSH on manual dispatch or push to `main`/`master`; writes `IMAGE` into `.env`, then `docker compose pull && docker compose up -d --remove-orphans` at `DEPLOY_PATH`.

### GitHub Actions secrets/vars
- `SSH_HOST`, `SSH_USER`, `SSH_KEY` (private key), `SSH_PORT` (optional), `DEPLOY_PATH`, `IMAGE` for deploys.
- Default GHCR auth uses `GITHUB_TOKEN` for release builds; set `IMAGE` to `ghcr.io/<owner>/carresearchweb:tag`.

## Release
- Tag `vX.Y.Z` to trigger the Docker build/push to GHCR (`ghcr.io/<owner>/carresearchweb:<tag>` and `:latest`).  
- You can also run the release workflow manually with a custom tag input if needed.

## Deploy
- Server needs Docker + Docker Compose plugin and GHCR pull access (`docker login ghcr.io -u <user> -p <PAT>` once).
- Workflow assumes `docker-compose.yml` exists at `$DEPLOY_PATH` on the server and uses the `IMAGE` env value written into `.env`.
- After a successful deploy, containers are refreshed and old images are pruned via `docker image prune -f`.

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
