# TODO: SEO Foundation Implementation for Autopredator CarResearchWeb

## P0 — URL & Indexing Rules
- [x] Create .htaccess for URL normalization (lowercase slugs, trailing slash enforcement, 301 redirects from non-canonical to canonical)
- [x] Add noindex,follow meta robots to faceted/search pages: search.php, compare.php, shortlist.php
- [x] Document canonical URL structure in comments or README

## P1 — Technical SEO Essentials
- [x] Create robots.txt at root with allow crawling of main pages, disallow junk paths
- [x] Create dynamic sitemap.xml generator at /seo/sitemap.php including brands, models, variants, blog posts with lastmod
- [x] Add canonical URL tags to all indexable pages (index.php, brand.php, model.php, variant.php)
- [ ] Implement proper 404 page and prevent soft-404 indexing

## P2 — Metadata Templates
- [x] Create includes/seo_helpers.php with functions for generating titles, descriptions, OG/Twitter cards
- [x] Update includes/header.php to include OG and Twitter meta tags on all pages

## P3 — Structured Data (JSON-LD)
- [x] Create includes/structured_data.php with JSON-LD generators
- [ ] Add BreadcrumbList structured data to brand.php, model.php, variant.php
- [ ] Add Product/Vehicle structured data to model.php and variant.php
- [ ] Add Article structured data to blog posts (if blog is implemented)

## P4 — Internal Linking
- [ ] Ensure breadcrumbs are rendered on all pages (brand.php, model.php, variant.php)
- [ ] Add internal link modules: "Competitors/Alternatives" on model.php, "Similar Cars" on variant.php

## P5 — Core Web Vitals Basics
- [ ] Add lazy loading to images below the fold (update views/layout.php or specific pages)
- [ ] Add aggressive caching headers for static assets (.htaccess or PHP headers)
- [ ] Add ETag/Last-Modified headers to HTML pages for caching

## Followup Steps
- [ ] Test URL redirects and normalization
- [ ] Validate structured data with Google's Rich Results Test
- [ ] Submit sitemap.xml to Google Search Console
- [ ] Monitor Core Web Vitals in Lighthouse and PageSpeed Insights
