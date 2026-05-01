# CarResearchWeb - Indian Car Research Platform

A full-featured PHP web application for researching Indian-market vehicles with brand/model/variant listings, search, comparison flows, and AI-assisted features.

## Quick Start

### Option 1: Using setup.bat (Windows - Recommended)
```powershell
cd autopredator\backend
setup.bat
```
Then open http://localhost:8000 in your browser.

### Option 2: PHP Built-in Server
```powershell
cd autopredator\backend
composer install
php -S localhost:8000
```
Open http://localhost:8000 in your browser.

### Option 3: Docker
```powershell
cd autopredator\backend
docker-compose up --build
```
Open http://localhost:8000 in your browser.

## Prerequisites

- **PHP 8.1+** (CLI and web SAPI) - Works with XAMPP/Apache or PHP built-in server
- **Composer** - For installing dependencies
- **MySQL 8.0+** (optional) - For database mode
- **Python 3.10+** (optional) - For legacy JSON regeneration

## Project Structure

```
CarResearchWeb/
├── autopredator/
│   ├── backend/          # PHP web app + APIs + admin
│   ├── scraper/         # Data scraping/ETL scripts
│   ├── ml/              # ML/LLM services
│   ├── data/            # Datasets and JSON files
│   ├── docs/            # Design and ops documentation
│   └── tests/           # Unit and e2e tests
├── graphify-out/        # Architecture graph (generated)
└── README.md           # This file
```

## Configuration

### Environment Variables

Create a `.env` file in `autopredator/backend/`:

```env
# Application
APP_ENV=local
USE_JSON=true

# Database (when USE_JSON=false)
DB_HOST=localhost
DB_PORT=3306
DB_NAME=autopredator_cars
DB_USER=root
DB_PASS=your_password

# AI Features (all disabled by default)
AI_ENABLED=false
AI_CONTENT_ENABLED=false
AI_SUPPORT_ENABLED=false

# Graphify (optional)
GRAPHIFY_AUTO_GENERATE=false
```

### Data Modes

The app supports two data modes:
- **JSON Mode** (default): `USE_JSON=true` - Uses `data/new_carset.json` as primary source
- **Database Mode**: `USE_JSON=false` - Uses MySQL `autopredator_cars` database

## Features

### Core Pages
- **Home** (`index.php`) - Featured brands, families, and variants
- **Brands** (`brand.php`) - All manufacturers with per-brand listings
- **Models** (`model.php`) - Model overview and variants
- **Variants** (`variant.php`) - Detailed variant specifications
- **Search** (`search.php`) - Filterable search (brand, body type, fuel, transmission, budget)
- **Compare** (`compare.php`) - Side-by-side vehicle comparison
- **My Garage** (`my_garage.php`) - Saved vehicles shortlist
- **Favourites** (`favourites.php`) - Bookmarked vehicles

### API Endpoints
- `api/autocomplete.php` - Search suggestions
- `api/details.php?slug=xuv700` - Safe detail fetch via allowlist
- `api/search.php` - Search with filters
- `api/brands.php` - Brand listings
- `api/models.php` - Model data
- `api/variants.php` - Variant details
- `api/favorites.php` - Favorites management

### Admin Features
- `admin/index.php` - Admin dashboard
- `admin/login.php` - Admin authentication
- `admin/billing.php` - Billing management

## Database Setup

### Option 1: JSON Mode (Default - Recommended for Development)

No database setup required. The app uses JSON files:
- `data/new_carset.json` - Primary dataset (make/model/segment/variants)
- `data/data.json` - Legacy dataset
- `data/details_index.json` - Detail sheet allowlist

### Option 2: MySQL Database

1. Create the database:
```sql
CREATE DATABASE autopredator_cars;
```

2. Apply schema:
```powershell
mysql -u root -p autopredator_cars < autopredator/docs/db-schema-complete.sql
```

3. Apply hardening migration:
```powershell
mysql -u root -p autopredator_cars < autopredator/docs/db-schema.sql
```

4. Seed data:
```powershell
mysql -u root -p autopredator_cars < autopredator/data/db/seeds/...
```

5. Configure environment:
```
USE_JSON=false
DB_HOST=localhost
DB_PORT=3306
DB_NAME=autopredator_cars
DB_USER=root
DB_PASS=your_password
```

### Database Schema

Key tables:
- `brands` - Vehicle manufacturers
- `models` - Model families
- `variants` - Individual variants
- `variant_price_history` - Price tracking
- `images` - Vehicle images
- `features` - Feature definitions
- `vehicle_specs` - Technical specifications

## Testing

### Run All Tests
```powershell
cd autopredator/backend
composer install
./vendor/bin/phpunit
```

### Run E2E Tests (Playwright)
```powershell
cd autopredator/backend
npx playwright test
```

### Lint and Type Check
```powershell
cd autopredator/backend
composer lint
composer typecheck
composer format
```

## AI Features

AI features are disabled by default. To enable:

```env
AI_ENABLED=true
AI_CONTENT_ENABLED=true
AI_SUPPORT_ENABLED=true
```

AI-powered features include:
- Content generation for vehicle descriptions
- Support chat assistance
- Spec extraction from unstructured data

## CI/CD

### GitHub Actions

- **CI** (`.github/workflows/ci.yml`): Runs on PRs/pushes to main
  - PHP 8.2 lint + PHPUnit
  - Node.js (if present): npm ci/lint/test/build
  - Python (if present): pytest

- **Security** (`.github/workflows/security.yml`):
  - Dependency review
  - CodeQL analysis
  - Trivy filesystem scan

- **Deploy** (`.github/workflows/deploy.yml`):
  - SSH deployment on manual dispatch or push to main

### Release

Tag `vX.Y.Z` to trigger Docker build/push to GHCR.

## Security Notes

- All output is escaped via `e()` function (UTF-8, ENT_QUOTES|ENT_SUBSTITUTE)
- Security headers: X-Content-Type-Options, X-Frame-Options, Referrer-Policy
- Detail JSON served only via slug allowlist in `data/details_index.json`
- Strict slug validation: `/^[a-z0-9]+(?:-[a-z0-9]+)*$/`

## Common Tasks

### Add a New Vehicle

1. **JSON Mode**: Add entry to `data/new_carset.json`
2. **Database Mode**: Use seed scripts with UPSERT patterns
3. Add detail sheet to `data/` if needed
4. Register in `data/details_index.json` with slug pattern `/^[a-z0-9]+(?:-[a-z0-9]+)*$/`

### Regenerate Graphify (Architecture Graph)

```powershell
cd autopredator
graphify update .
```

### Clear Cache

```powershell
# Remove Graphify outputs
Remove-Item -Recurse -Force .\autopredator\graphify-out -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .\autopredator\.graphify -ErrorAction SilentlyContinue
```

## Documentation

- [GRAPHIFY.md](autopredator/docs/GRAPHIFY.md) - Architecture graph setup
- [DATA_SCHEMA.md](autopredator/docs/DATA_SCHEMA.md) - Data schema details
- [TESTING.md](autopredator/docs/TESTING.md) - Testing guide
- [MONETIZATION.md](autopredator/docs/MONETIZATION.md) - Billing/monetization
- [INCIDENT_RESPONSE.md](autopredator/docs/INCIDENT_RESPONSE.md) - Incident handling

## License

Proprietary - All rights reserved
