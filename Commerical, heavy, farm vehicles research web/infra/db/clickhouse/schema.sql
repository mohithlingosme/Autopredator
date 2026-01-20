CREATE DATABASE IF NOT EXISTS autopredator;

CREATE TABLE IF NOT EXISTS autopredator.events_page_view
(
    event_id UUID DEFAULT generateUUIDv4(),
    org_id UUID,
    user_id UUID,
    session_id String,
    page String,
    referrer String,
    user_agent String,
    event_time DateTime DEFAULT now(),
    metadata Map(String, String)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)
ORDER BY (org_id, event_time, session_id);

CREATE TABLE IF NOT EXISTS autopredator.events_search
(
    event_id UUID DEFAULT generateUUIDv4(),
    org_id UUID,
    user_id UUID,
    session_id String,
    query String,
    filters Map(String, String),
    results_count UInt32,
    latency_ms UInt32,
    event_time DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)
ORDER BY (org_id, event_time, session_id);

CREATE TABLE IF NOT EXISTS autopredator.events_compare
(
    event_id UUID DEFAULT generateUUIDv4(),
    org_id UUID,
    user_id UUID,
    session_id String,
    primary_variant UUID,
    compared_variants Array(UUID),
    event_time DateTime DEFAULT now()
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)
ORDER BY (org_id, event_time, session_id);

CREATE TABLE IF NOT EXISTS autopredator.events_lead
(
    event_id UUID DEFAULT generateUUIDv4(),
    org_id UUID,
    user_id UUID,
    session_id String,
    listing_id UUID,
    lead_id UUID,
    source String,
    event_time DateTime DEFAULT now(),
    metadata Map(String, String)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)
ORDER BY (org_id, event_time, listing_id);
