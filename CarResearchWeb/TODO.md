# TODO: Complete UI Layer Implementation for Car Research Platform

## P0 — Design System Foundation
- [x] Extend assets/css/tokens.css with additional colors, spacing, typography, radius, shadows
- [x] Create assets/css/components.css with reusable UI components: buttons, cards, badges, tables, tabs, accordions, modals, toasts
- [x] Extend layout shells in app.css: sticky header, main containers, footer

## P1 — Core Research Journey
- [x] Update index.php (Home): hero, featured sections, recently viewed
- [x] Update search.php (Search Results): filters (desktop left panel, mobile bottom-sheet), sorting, pagination, empty state, add-to-compare/shortlist
- [x] Update brand.php (Brand Page): brand header, model grid, empty state
- [x] Update model.php (Model Page): hero, variants table (filterable), specs, pros/cons, FAQs (accordion), competitors, CTA modal
- [x] Update variant.php (Variant Page): price block, full specs, features, gallery (lazy + swipe), actions, recently viewed
- [x] Update compare.php (Compare Page): sticky header with chips/actions, shareable URL, only differences toggle, best-value highlights, missing values handling, mobile horizontal scroll
- [x] Update shortlist.php (Shortlist/Garage): saved cars list, remove/notes, quick compare, empty state

## P2 — Trust + UX Polish
- [ ] Extend trust.js for recently viewed (localStorage, max 10, add on variant view, render on home/variant)
- [ ] Add share buttons (copy to clipboard, toast)
- [ ] Enhance empty states everywhere
- [ ] Add loading skeletons for heavy pages
- [ ] Add micro-interactions: toast on add/remove

## P3 — Mobile-First Responsiveness
- [ ] Header compact mode on scroll
- [ ] Filters as bottom-sheet on mobile
- [ ] Compare tables scroll + sticky column
- [ ] Gallery swipe; images optimized
- [ ] Touch targets >= 44px

## P4 — SEO UI Requirements
- [ ] Semantic headings and content blocks
- [ ] Breadcrumb UI matching schema
- [ ] Internal linking modules: Popular models, Alternatives, Related comparisons
- [ ] FAQ markup for schema

## P5 — Conversion UI
- [ ] Lead form modal: name/phone/city/intent, success state
- [ ] Sticky CTA bar on mobile
- [ ] Add privacy/trust note near CTA

## Additional Tasks
- [ ] Create assets/js/search.js for autosuggest (debounced, keyboard nav)
- [ ] Extend compare.js for URL updates, toggles, highlights
- [ ] Update layout.php for scripts and meta
- [ ] Create empty_state.php component if needed
