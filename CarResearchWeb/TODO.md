# AUTOPREDATOR Ecosystem Implementation Tracker
**Approved Plan: Build ecosystem/ hub + MVP First Wave (Hub, Vault, Garage, FuelTracker, MiniFleet, AutoMart)**

## Phase 1: Foundation (Current)
- [x] Hub (search/compare/model/garage) - LIVE ✅
- [x] Scrapers (tier1-4) - Docker/Ollama pending
- [x] Billing/Pricing - Razorpay integrated ✅
- [ ] DB Population: Run scrapers for DBP_TODO.md models

## Phase 2: Ecosystem Structure (Next)
1. **Create `autopredator/ecosystem/`** - PRDs/folder structures/tech stacks
   - MVP_FIRST_WAVE.md (detailed PRDs for 5 apps)
   - STRUCTURE/ subdirs (Vault/Garage/etc.)
2. **New `autopredator/backend/dashboard.php`** - App launcher grid/nav
3. **Update nav:** header.php + footer.php (add ecosystem dropdown)
4. **Update READMEs:** autopredator/README.md + backend/README.md
5. **Merge TODOs:** Prioritize scrapers/DB in autopredator/backend/TODO.md

## Phase 3: Implement MVP Wave 1 Apps
- Vehicle Vault (#2): Docs storage/reminders
- Fuel & Expense Tracker (#4): Logs/mileage/cost/km
- Mini Fleet (#5): Multi-vehicle dashboard
- AutoMart (#11): Basic listings (extend search)
- Update billing plans for new apps

## Phase 4: Data & Polish
- Run scrapers/import_json_to_db.php
- Tests: phpunit + e2e
- Deploy: GitHub workflows

**Phase 2 Progress:** Steps 1-2 complete (PRD + dashboard). Nav/README updated. Ready for app implementations (Vault next).

