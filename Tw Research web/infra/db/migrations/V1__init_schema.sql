-- Flyway migration: initial schema for Autopredator data layer
-- Schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS pricing;
CREATE SCHEMA IF NOT EXISTS market;
CREATE SCHEMA IF NOT EXISTS crm;
CREATE SCHEMA IF NOT EXISTS ops;

-- AUTH SCHEMA
CREATE TABLE IF NOT EXISTS auth.users (
    id BIGSERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    password_hash TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auth.organizations (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK (type IN ('dealer', 'admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS auth.org_members (
    id BIGSERIAL PRIMARY KEY,
    org_id BIGINT NOT NULL REFERENCES auth.organizations (id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (org_id, user_id)
);

-- CATALOG SCHEMA
CREATE TABLE IF NOT EXISTS catalog.fuel_types (
    id SMALLSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS catalog.transmission_types (
    id SMALLSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS catalog.body_types (
    id SMALLSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS catalog.manufacturers (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS catalog.model_families (
    id BIGSERIAL PRIMARY KEY,
    manufacturer_id BIGINT NOT NULL REFERENCES catalog.manufacturers (id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (manufacturer_id, name)
);

CREATE TABLE IF NOT EXISTS catalog.models (
    id BIGSERIAL PRIMARY KEY,
    model_family_id BIGINT NOT NULL REFERENCES catalog.model_families (id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    year_start INTEGER NOT NULL,
    year_end INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (model_family_id, name, year_start)
);

CREATE TABLE IF NOT EXISTS catalog.variants (
    id BIGSERIAL PRIMARY KEY,
    model_id BIGINT NOT NULL REFERENCES catalog.models (id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    fuel_type_id SMALLINT NOT NULL REFERENCES catalog.fuel_types (id),
    transmission_type_id SMALLINT NOT NULL REFERENCES catalog.transmission_types (id),
    body_type_id SMALLINT NOT NULL REFERENCES catalog.body_types (id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (model_id, name)
);

CREATE TABLE IF NOT EXISTS catalog.vehicle_specs (
    variant_id BIGINT PRIMARY KEY REFERENCES catalog.variants (id) ON DELETE CASCADE,
    engine_cc INTEGER,
    power_hp INTEGER,
    torque_nm INTEGER,
    mileage_kmpl NUMERIC(6,2),
    seating SMALLINT,
    airbags SMALLINT,
    length_mm INTEGER,
    width_mm INTEGER,
    height_mm INTEGER,
    wheelbase_mm INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS catalog.features (
    id BIGSERIAL PRIMARY KEY,
    category TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (category, name)
);

CREATE TABLE IF NOT EXISTS catalog.variant_features (
    variant_id BIGINT NOT NULL REFERENCES catalog.variants (id) ON DELETE CASCADE,
    feature_id BIGINT NOT NULL REFERENCES catalog.features (id) ON DELETE CASCADE,
    is_standard BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (variant_id, feature_id)
);

-- PRICING SCHEMA
CREATE TABLE IF NOT EXISTS pricing.cities (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    state TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (name, state)
);

CREATE TABLE IF NOT EXISTS pricing.price_quotes (
    id BIGSERIAL PRIMARY KEY,
    variant_id BIGINT NOT NULL REFERENCES catalog.variants (id) ON DELETE CASCADE,
    city_id BIGINT NOT NULL REFERENCES pricing.cities (id) ON DELETE CASCADE,
    quote_date DATE NOT NULL,
    ex_showroom NUMERIC(14,2),
    on_road NUMERIC(14,2),
    source TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (variant_id, city_id, quote_date)
);

CREATE INDEX IF NOT EXISTS idx_price_quotes_variant_city_date_desc
    ON pricing.price_quotes (variant_id, city_id, quote_date DESC);

-- MARKET SCHEMA
CREATE TABLE IF NOT EXISTS market.listings (
    id BIGSERIAL PRIMARY KEY,
    org_id BIGINT NOT NULL REFERENCES auth.organizations (id) ON DELETE RESTRICT,
    user_id BIGINT REFERENCES auth.users (id) ON DELETE SET NULL,
    variant_id BIGINT NOT NULL REFERENCES catalog.variants (id) ON DELETE RESTRICT,
    city_id BIGINT NOT NULL REFERENCES pricing.cities (id) ON DELETE RESTRICT,
    fuel_type_id SMALLINT NOT NULL REFERENCES catalog.fuel_types (id),
    transmission_type_id SMALLINT NOT NULL REFERENCES catalog.transmission_types (id),
    listing_type TEXT NOT NULL CHECK (listing_type IN ('new', 'used')),
    year INTEGER,
    km INTEGER,
    price NUMERIC(14,2),
    status TEXT NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_listings_filters
    ON market.listings (city_id, listing_type, status, fuel_type_id, transmission_type_id, year, km, price);
CREATE INDEX IF NOT EXISTS idx_listings_created_at ON market.listings (created_at DESC);

CREATE TABLE IF NOT EXISTS market.listing_media (
    id BIGSERIAL PRIMARY KEY,
    listing_id BIGINT NOT NULL REFERENCES market.listings (id) ON DELETE CASCADE,
    media_type TEXT NOT NULL,
    object_key TEXT NOT NULL,
    url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS market.inspections (
    id BIGSERIAL PRIMARY KEY,
    listing_id BIGINT NOT NULL UNIQUE REFERENCES market.listings (id) ON DELETE CASCADE,
    score INTEGER,
    report_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- CRM SCHEMA
CREATE TABLE IF NOT EXISTS crm.leads (
    id BIGSERIAL PRIMARY KEY,
    listing_id BIGINT REFERENCES market.listings (id) ON DELETE SET NULL,
    org_id BIGINT NOT NULL REFERENCES auth.organizations (id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES auth.users (id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    status TEXT NOT NULL DEFAULT 'new',
    source TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_leads_org_status_created
    ON crm.leads (org_id, status, created_at DESC);

CREATE TABLE IF NOT EXISTS crm.lead_activities (
    id BIGSERIAL PRIMARY KEY,
    lead_id BIGINT NOT NULL REFERENCES crm.leads (id) ON DELETE CASCADE,
    activity_type TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- OPS SCHEMA
CREATE TABLE IF NOT EXISTS ops.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    actor_user_id BIGINT REFERENCES auth.users (id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id BIGINT NOT NULL,
    meta_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON ops.audit_logs (entity_type, entity_id, created_at DESC);

CREATE TABLE IF NOT EXISTS ops.import_jobs (
    id BIGSERIAL PRIMARY KEY,
    source TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finished_at TIMESTAMPTZ,
    stats_json JSONB
);
