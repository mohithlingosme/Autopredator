# API Implementation TODO

## 1. Create API Router
- [ ] Create /api/index.php with path-based routing to controllers

## 2. Create Controllers Directory and Controllers
- [ ] Create app/Controllers/BrandsController.php
- [ ] Create app/Controllers/ModelsController.php
- [ ] Create app/Controllers/VariantsController.php
- [ ] Create app/Controllers/SearchController.php
- [ ] Create app/Controllers/CompareController.php
- [ ] Create app/Controllers/ShortlistController.php
- [ ] Create app/Controllers/LeadsController.php
- [ ] Create app/Controllers/AdminController.php

## 3. Extend CarService
- [ ] Add compare logic to CarService.php (normalize compare payload)

## 4. Create Lead Repository
- [ ] Create app/Repositories/FileLeadRepository.php for JSON file-based lead storage

## 5. Create Support Classes
- [ ] Create app/Support/RateLimiter.php for sliding window rate limiting
- [ ] Create app/Support/CacheHelper.php for ETag/Last-Modified caching
- [ ] Create app/Support/AdminAuth.php for simple admin authentication

## 6. Update Shortlist
- [ ] Update shortlist.php to use new /api/shortlist endpoints
- [ ] Update assets/js/shortlist.js to use new API

## 7. Add Validation and Error Handling
- [ ] Add validation helpers in app/Support/Validation.php
- [ ] Ensure consistent error responses across controllers

## 8. Update README
- [ ] Add API documentation section to README.md

## 9. Testing
- [ ] Test all endpoints with curl commands
- [ ] Verify caching (304 responses)
- [ ] Verify rate limiting (429 responses)
- [ ] Manual smoke tests for all endpoints

## 10. Final Checks
- [ ] Ensure all endpoints return JSON
- [ ] Check caching headers on read endpoints
- [ ] Confirm rate limiting on abuse-prone endpoints
- [ ] Verify shortlist works end-to-end
- [ ] Confirm compare returns normalized payload
- [ ] Check admin endpoints protected
