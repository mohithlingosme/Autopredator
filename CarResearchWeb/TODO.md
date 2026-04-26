# Cleanup & Refactor TODO

## Phase 1: Delete Redundant and Backup Files
- [x] Delete `CarResearchWeb.zip/` directory
- [x] Delete `autopredator/backend/autopredator_unified (3).sql`
- [x] Delete `data/data_legacy_raw.txt` (not found — already absent)
- [x] Delete `tests/mocks/data.original.txt`
- [x] Delete `tests/mocks/temp_snippet.txt`
- [x] Delete `tests/mocks/new_carset.json`
- [x] Delete `tests/mocks/data.json`
- [x] Delete `tests/mocks/XUV700.json`

## Phase 2: Eliminate Duplicate Architecture
- [x] Delete `src/Data/DetailRepository.php` → moved to `app/Repositories/DetailRepository.php`
- [x] Delete `src/Data/JsonLoader.php` → moved to `app/Support/JsonLoader.php`
- [x] Delete `includes/car_repository.php`
- [x] Delete `includes/json_car_repository.php`
- [x] Delete `includes/repository.php`
- [x] Update `composer.json` autoload to remove deleted files
- [x] Update all `require_once` references to point to `includes/bootstrap.php`
- [x] Update `tests/JsonRepositoryTest.php` namespaces

## Phase 3: Consolidate to `app/` Namespace & Fix Paths
- [x] Move `DetailRepository` from `App\Data` to `App\Repositories`
- [x] Move `JsonLoader` from `App\Data` to `App\Support`
- [x] Fix `DATA_DIR` in `config.php` to point to `autopredator/data/`
- [x] Add missing `AI_ENABLED`, `AI_CONTENT_ENABLED`, `AI_SUPPORT_ENABLED` constants to `config.php`
- [x] Make `bootstrap.php` gracefully fall back to JSON mode when DB is unreachable
- [x] Run PHPUnit — all 12 tests pass

## Phase 4: Architectural Advice for Remaining Flat Files
- [ ] Refactor `public/*.php` pages to route through `public/index.php` Front Controller
- [ ] Create `app/Controllers/` for each page group (PageController, AuthController, etc.)
- [ ] Move view rendering logic from flat files to `views/` templates
- [ ] Add `.htaccess` URL rewriting to route all requests to `index.php`
- [ ] Deprecate and remove legacy function wrappers in `includes/bootstrap.php`
