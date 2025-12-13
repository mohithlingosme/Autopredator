# Project Roadmap & Todo

## 🚨 Phase 1: Critical Security & Stability (Immediate)
*These tasks fix vulnerabilities and prevent the app from crashing.*

- [ ] **Fix Session Fixation Vulnerability** (`login.php`)
    - [ ] Add `session_regenerate_id(true);` immediately after successful password verification.
- [ ] **Prevent XSS Attacks** (All View Files)
    - [ ] Audit `search.php`, `variant.php`, and `index.php`.
    - [ ] Ensure every `echo $variable` is wrapped in `htmlspecialchars($variable)`.
- [ ] **Hardening JSON Parsing** (`includes/json_car_repository.php`)
    - [ ] Implement Null Coalescing (`??`) for optional fields (e.g., `$car['price'] ?? 'N/A'`) to prevent "Undefined Array Key" warnings.
    - [ ] Add `try-catch` blocks around `json_decode` to handle corrupt data files gracefully.

## ⚡ Phase 2: Data Pipeline & Performance
*Optimizing the JSON logic to stop the app from slowing down as data grows.*

- [ ] **Refactor Price Data** (`scripts/convert_data_to_json.py`)
    - [ ] Update Python script to save a `price_numeric` (int) field alongside the display string.
    - [ ] Example: `{"price_display": "15.5 L", "price_numeric": 1550000}`.
- [ ] **Optimize Search Logic** (`includes/json_car_repository.php`)
    - [ ] Switch price filtering to use the new `price_numeric` field (integer comparison instead of string parsing).
    - [ ] Implement `strtolower()` on both query and data for case-insensitive search.
- [ ] **Implement Server-Side Pagination**
    - [ ] Stop sending all 500+ cars to the view. Use `array_slice()` in the repository to return only the requested page (e.g., 12 items).

## 🎨 Phase 3: UI/UX Improvements
*Fixing the interface issues to make the site feel professional.*

- [ ] **Fix "Form Amnesia"** (`search.php`)
    - [ ] Ensure filter inputs (dropdowns/checkboxes) retain their selected value after page reload.
    - [ ] Implementation: `<option value="SUV" <?php echo ($_GET['type'] == 'SUV') ? 'selected' : ''; ?>>`.
- [ ] **Unified Card Heights** (`css/style.css`)
    - [ ] Use CSS Flexbox to force car cards to equal height, ensuring "View Details" buttons align at the bottom.
- [ ] **Add "Empty State" UI**
    - [ ] Create a specific design for when `count($results) === 0` (e.g., "No cars found with these filters").
- [ ] **Formatting Helpers**
    - [ ] Create a PHP helper function to format currency (Lakhs/Crores) dynamically for the view layer.

## 🛠 Phase 4: Architecture & Refactoring (Tech Debt)
*Preparing the codebase for future growth (MySQL) and easier maintenance.*

- [ ] **Adopt Composer**
    - [ ] Initialize `composer.json`.
    - [ ] Set up PSR-4 Autoloading (replace manual `include` statements with `use App\Repository\CarRepository`).
- [ ] **Strict Typing**
    - [ ] Add `declare(strict_types=1);` to the top of all PHP files.
    - [ ] Add return types to functions (e.g., `function getById(int $id): ?array`).
- [ ] **Environment Security**
    - [ ] Ensure `mocks/` and `includes/` directories are protected from direct browser access (via `.htaccess`).

## 🔮 Phase 5: Future Features
- [ ] **User Garage Persistence:** Allow users to save favorites to a user-specific JSON file (or SQLite).
- [ ] **Comparison Matrix:** Enhance `compare.php` to highlight differences (e.g., green text for better specs).
- [ ] **Migration to SQLite:** Replace JSON repository with a SQLite implementation using the same interface.