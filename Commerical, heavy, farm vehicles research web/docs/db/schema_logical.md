# Logical Schema Overview

## IAM
- `users` (extended with `phone`, `full_name`), `organizations`, `org_members`
- `roles`, `permissions`, `role_permissions`, `user_roles`

## Lookups
- `states`, `cities`, `fuel_types`, `transmissions`, `body_types`

## Vehicle Catalog
- `manufacturers`, `model_families`, `models`, `model_lifecycle`
- `variants`, `variant_specs`, `features`, `variant_features`
- `media_assets`, `price_history` (partitioned by month)

## Marketplace
- `listings`, `listing_media`
- `leads`, `lead_status_history`, `offers`

## FleetCommand
- `fleet_vehicles`, `drivers`, `driver_assignments`
- `trips`, `fuel_logs`, `maintenance_jobs`, `compliance_docs`

## FinanceDesk
- `finance_applications`, `kyc_documents`, `bank_offers`, `finance_status_history`

## Content Hub
- `categories`, `tags`, `articles`, `article_tags`, `seo_meta`

## Analytics (ClickHouse)
- `events_page_view`, `events_search`, `events_compare`, `events_lead`

## Search (OpenSearch)
- Index templates: `listing_search`, `catalog_search`

## Cache (Redis)
- See `docs/db/redis_keys.md` for cache/queue patterns.
