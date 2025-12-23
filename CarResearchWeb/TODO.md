# 🚗 CarResearchWeb Development Roadmap

**Goal:** Transform CarResearchWeb into a premium, research-first car platform with seamless UX for **Discover → Shortlist → Compare → Decide**.

---

## 🎯 Baseline & Foundations
### User Flows & Conventions
- [x] **Define Golden User Flows** – Ensure perfect experience for core journeys
  - [x] **Discover Flow:** Home → Brand → Model → Variant
  - [x] **Compare Flow:** Add variants anywhere, compare up to 4
  - [x] **Shortlist Flow:** Save variants → Review → Decide
- [x] **Establish UI Conventions** – Consistent design across pages
  - [x] Implement 8px spacing scale: `8/16/24/32/48px`
  - [x] Set max container width: `1200px`
  - [x] Define typography hierarchy: `h1/h2/body/muted`
- [x] **Fix Markup Issues** – Ensure clean, accessible HTML
  - [x] Remove duplicate IDs (e.g., `search-q` on index)

### Design System & Components
- [x] **Create CSS Tokens** – Foundation for consistent styling
  - [x] Add `assets/css/tokens.css` with colors, spacing, radius, shadows, typography
  - [ ] Optional: Light/dark theme support
- [x] **Build Reusable Components** – CSS classes for common UI elements
  - [x] Buttons: `btn-primary`, `btn-outline`, `btn-danger`, `btn-small`
  - [x] Badges: `badge-info`, `badge-warning`, `badge-success`, `badge-soft`
  - [x] Cards: `card-default`, `card-hover`, `card-compact`
  - [x] Tables: `table-compare`, `table-spec`
  - [x] Forms: `form-search`, `form-select`, `form-checkbox`
- [x] **Implement Page Shell** – Consistent layout structure
  - [x] Sticky header with navigation
  - [x] Main content container with proper spacing
  - [x] Aligned footer across pages

### Micro-Interactions
- [x] **Add Hover Effects** – Enhance user engagement
  - [x] Card hover: Shadow + subtle translate
  - [x] Button states: Hover/active animations
  - [x] Skeleton loaders for search/compare states

---

## 🧭 Navigation & Header
- [x] **Enhance Navbar** – Platform-like navigation experience
  - [x] Add **Compare Badge** showing count from `localStorage`
  - [x] Add **Shortlist Link** with dynamic count badge
  - [x] Hide badges when count is 0
- [x] **Mobile Navigation** – Smooth mobile experience
  - [x] Animated open/close toggle
  - [x] Prevent body scroll when menu is open

---

## ⭐ Core Features
### Shortlist Feature
- [x] **Implement Storage & UI Hooks**
  - [x] Use `localStorage` key: `shortlist_variants`
  - [x] Add/remove toggle functionality
  - [x] Update global shortlist badge count
- [x] **Add Shortlist Buttons**
  - [x] Variant cards on home/search/model pages
  - [x] Variant page header
- [x] **Create Shortlist Page** (`shortlist.php`)
  - [x] Render shortlisted variants from URL IDs or JS redirect
  - [x] Display empty state with "Browse Cars" CTA
  - [x] Enable remove from shortlist
  - [x] Add "Compare Selected" quick action

### Compare Feature
- [x] **Core Compare Logic**
  - [x] Store `variant_key` in `localStorage: compare_variants`
  - [x] URL format: `compare.php?ids=key1,key2,key3`
  - [x] Redirect to localStorage list if no `ids` provided
- [x] **Professional Compare UI**
  - [x] Sticky header with variant names
  - [x] Sticky first column for feature names
  - [x] Enforce max 4 variants
  - [x] Remove individual variants
  - [x] "Clear All" button
  - [x] "Show Differences Only" toggle
  - [ ] Inline search to add more variants
- [x] **Compare Table Builder**
  - [x] Map features: Engine, Power, Torque, Mileage/Range, Fuel Type, Transmission, Dimensions, Safety, Features
  - [x] Display "—" for missing values
  - [x] Optional: Highlight differences

### Favorites Feature
- [x] **Choose Storage Method**
  - [x] Option A: Session-based storage
  - [ ] Option B: JSON file per user
  - [ ] Option C: Database storage
- [x] **Update API & UI**
  - [x] Modify `api/favorites.php` for real responses (success + updated list)
  - [x] Implement toggle buttons for favorites state
  - [x] Create/display favorites page/list

---

## 🔍 Search & Discovery
### Search UX Upgrade
- [x] **Autocomplete Suggestions**
  - [x] Categorize dropdown: Brands, Models, Variants, Body Types/Fuel
  - [x] Keyboard navigation: ↑/↓/Enter/Esc
- [x] **Search Results Page**
  - [x] Filter-first layout: Desktop sidebar, mobile drawer/modal
  - [x] Core filters: Budget (min/max), Fuel Type, Transmission, Body Type
  - [x] Sort options: Price (low→high/high→low), Mileage/Range (high→low), Power (high→low)
  - [x] Active filter chips with remove functionality

### Page-Specific Upgrades
- [x] **Brand Page Enhancements**
  - [x] Hero section: Brand name, country tag, model count
  - [x] Tabs/sections: Models (default), Variants, About
  - [x] Apply search filters at brand level
  - [x] Model cards: Price range, fuel types, key facts (power/mileage/seats), "View Variants" CTA
- [x] **Model Page Redesign**
  - [x] Variants table/grid: Name, Price, Engine, Transmission, Mileage/Range, Actions (Compare/Shortlist/View)
  - [x] Sorting: Price, Mileage/Range, Power
  - [x] Rule-based "Best Value" label (e.g., mid-price + best mileage + common transmission)
- [x] **Variant Page as Spec Hub**
  - [x] Redesign header: Variant name, sub-trim, price, badges (fuel/transmission), CTAs (Compare/Shortlist/Share)
  - [x] Highlights section: Top 6 cards (Power, Torque, Mileage/Range, Fuel, Transmission, Seats/Boot/Safety)
  - [x] Specs tabs: Overview, Engine & Transmission, Dimensions, Safety, Features
  - [x] Auto-hide empty sections; show "—" for missing values

---

## 📊 Data & Architecture
### Repository & Architecture
- [x] **Consolidate Repositories** – Use `app/Repositories/JsonCarRepository.php` as primary
- [x] **Clean Up Legacy Files** – Archive `includes/json_car_repository.php`, `test_json_repository.php` to `/scripts/` or `/tests/`
- [x] **Standardize Usage** – Ensure consistent repository entry point across services/includes

### Data Management
- [x] **Normalize Data Output**
  - [x] Standardize JSON keys: `fuel_type`, `transmission`, `engine`, `power_bhp`, `torque_nm`, `mileage_kmpl`, `range_km`
  - [x] Create normalization helper in repository
  - [x] Ensure specs return strings/null; safe number conversions
  - [x] Use normalized data in compare/spec pages only
- [x] **Data Quality Fixes**
  - [x] Parse prices: Remove artifacts, normalize "₹13.99 - 26.99 Lakh" to numeric min/max
  - [x] Normalize power: Parse "153-197 bhp" to min/max numbers
  - [x] Add JSON schema validation: Required fields for make/model/variant; log issues, prevent crashes
  - [x] Standardize fields: Map `launch_year` vs. `year`, add mapping layer

### Search & Filters Optimization
- [x] **Fix Filter Rendering** – Single `[data-filter-panel]` element, correct JS targeting
- [x] **Accessibility Improvements** – Close drawer via Esc, outside clicks, optional focus trap
- [x] **Bug Fixes** – Resolve body type string/array mismatch
- [ ] **Schema Standardization** – Define types (e.g., `make` as string, `fuel_type[]` as array); update `build_search_filters()` and `filter_panel.php`
- [ ] **Performance** – Replace `limit = PHP_INT_MAX` with `countSearchVariants($filters)`; add in-memory indices, per-request caching

---

## 🎨 UI/UX Polish
- [x] **Navigation Enhancements**
  - [x] Global header: Search, favorites link, compare badge
  - [x] Footer: Disclaimer, data sources, contact info
  - [x] Breadcrumbs: Home → Brand → Model → Variant
- [ ] **Standardize Cards & Pages**
  - [x] Listing cards: Model name, price, fuel, power, mileage; CTAs for view/compare/favorite
  - [x] Variant pages: Fix identity display; group specs (Engine/Performance, Economy, Dimensions, Safety, Features); add "Similar Cars", "Compare This" CTA
  - [ ] Compare page: Sticky header, optional best-value highlights, graceful missing value handling, shareable URLs
- [ ] **Platform Trust Features**
  - [ ] Recently viewed: `localStorage: recent_variants` (max 10), show on home/variant pages
  - [ ] Empty states: Friendly messages + CTAs for brand/search/compare/shortlist
  - [ ] Share links: Copy URLs for compare/variant pages
  - [ ] Optional analytics: Track `compare_add`, `compare_remove`, `shortlist_add`, `search_submit`

---

## 🔒 Security & Reliability
- [ ] **Fix Vulnerabilities**
  - [ ] Sanitize redirects in login/register to relative paths only (default: `index.php`)
  - [ ] Implement CSRF protection: Generate/validate tokens for login/register/favorites/compare
- [ ] **Secure Sessions**
  - [ ] Set HttpOnly, SameSite, Secure cookie flags
  - [ ] Regenerate sessions on login
- [ ] **Error Handling**
  - [ ] Create 404/error pages
  - [ ] Avoid silent redirects to home

---

## 🧪 Testing & Validation
- [ ] **Acceptance Checklist**
  - [ ] Header search functional on all pages
  - [ ] Compare add from home cards, variant page, search results
  - [ ] Compare page loads with/without `?ids=...`, enforces max 4, persists removes
  - [ ] Shortlist add/remove everywhere, page renders correctly
  - [ ] No PHP warnings/notices
  - [ ] Mobile: Usable nav, filters, scrollable compare table
- [ ] **Unit Tests**
  - [ ] Repository: JSON loading, key generation, variant lookup, price/power parsing
  - [ ] Search: Filter combinations, sort correctness
- [ ] **Integration Tests**
  - [ ] Smoke tests: Brand → Model → Variant flow
  - [ ] Compare: 2-4 variants functionality
  - [ ] Favorites persistence

---

## 📚 Documentation & Setup
- [ ] **Update README**
  - [ ] Requirements: PHP version, extensions, XAMPP setup
  - [ ] Local run instructions, data format, folder structure, features checklist
- [ ] **Developer Docs**
  - [ ] `docs/DATA_SCHEMA.md`: JSON schema + examples
  - [ ] `docs/ROUTING.md`: URLs and parameters
  - [ ] `docs/CONTRIBUTING.md`: Style, linting, PR rules

---

## 🚀 Optional Enhancements
- [ ] **All Brands Page** – Sitemap-style brand listing
- [ ] **Pagination** – Add to search results
- [ ] **Recently Viewed** – localStorage-based feature
- [ ] **Performance Logging** – Metrics tracking
- [ ] **Theme Toggle** – Light/dark mode

---

## 📈 Recommended Build Order
1. CSS tokens + layout consistency + fix duplicate IDs
2. Compare badge + stable Compare.js behavior
3. Shortlist feature + shortlist page
4. Model page variants table + sorting
5. Compare page premium table + differences toggle
6. Variant page highlights + spec sections
7. Search filters + improved autocomplete
