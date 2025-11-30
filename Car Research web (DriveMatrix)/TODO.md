# TODO: Switch to JSON Database

## Tasks
- [x] Load JSON data in repository.php
- [x] Modify get_all_manufacturers to use JSON
- [x] Modify get_manufacturer_by_id to use JSON
- [x] Modify get_model_families_by_manufacturer to use JSON (use segments as families)
- [x] Modify get_featured_families to use JSON
- [x] Modify get_models_by_family to use JSON
- [x] Modify get_model_by_id to use JSON
- [x] Modify get_variants_by_model to use JSON
- [x] Modify get_variant_by_id to use JSON
- [x] Modify get_featured_variants to use JSON
- [x] Modify search functions to use JSON
- [x] Remove database dependency from repository.php
- [x] Update API endpoints to use repository.php instead of db.php
- [x] Disable favorites API for JSON mode

---

# Car Research Platform (DriveMatrix) – UI & Navigation Fixes

## 1. Top-level Navigation
- [x] Rename navbar to: Autopredator | Car Research | Compare | Sell | Finance | Login
- [x] Add active state logic: Highlight "Car Research" on index.php, "Compare" on compare.php, etc.
- [x] Ensure only one nav item is active per page (remove any conflicting highlights).

## 2. Active State & Highlight Issues
- [x] Add CSS for `.nav-links a.active { color: var(--primary); text-decoration: underline; }`
- [x] In header.php, add PHP logic: if current page is index.php, add class="active" to Home link.
- [ ] Test on multiple pages to ensure no double highlights.

## 3. Homepage for Car Research
- [x] Change hero title to: "Research New & Used Cars – Compare Prices & Specs"
- [x] Add primary CTA button: "Find a Car" linking to search.php
- [x] Secondary CTA: "Compare Cars" linking to compare.php
- [x] Rename sections: "Popular Brands" instead of "Manufacturers", "Trending Models" instead of "Model Families"

## 4. Search & Filters
- [ ] Expand quick filters to include fuel, transmission, year.
- [ ] Add "Clear Filters" and "No results found" message on search.php (if not already).
- [ ] Make pill links more clickable (larger, better contrast).

## 5. Listing & Detail Pages
- [ ] On variant cards, prioritize: Price → Key specs (mileage, engine) → Fuel/Transmission
- [ ] Add "Add to Compare" button on each card.
- [ ] Ensure links are user-friendly: "View [Brand] Cars" instead of "View Models"

## 6. Compare Feature
- [ ] Implement compare bar: Show when ≥2 items selected, with "Compare Now" button.
- [ ] Add toggle buttons on cards: "Add to Compare" / "Remove"
- [ ] Limit compare to 3-4 cars max.

## 7. Forms & CTAs
- [ ] Add client-side validation to search forms (e.g., require at least 3 chars).
- [ ] Change generic CTAs to specific: "Explore [Brand]" or "Get Price for [Model]"

## 8. Mobile Responsiveness
- [ ] Test on 360px width: Ensure hero doesn't overflow.
- [ ] Add sticky bottom bar on mobile: Search | Filters | Compare | Contact
- [ ] Fix nav toggle: Ensure it opens/closes properly.
