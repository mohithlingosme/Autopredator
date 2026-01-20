CREATE DATABASE IF NOT EXISTS autopredator_analytics;

CREATE TABLE IF NOT EXISTS autopredator_analytics.events
(
    event_date Date DEFAULT toDate(event_time),
    event_time DateTime DEFAULT now(),
    session_id String,
    user_id Nullable(String),
    org_id Nullable(Int64),
    name String,
    properties Map(String, String),
    source String DEFAULT 'web'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)
ORDER BY (event_time, name, session_id);

CREATE TABLE IF NOT EXISTS autopredator_analytics.sessions
(
    session_id String,
    user_id Nullable(String),
    org_id Nullable(Int64),
    started_at DateTime DEFAULT now(),
    ended_at Nullable(DateTime),
    device Map(String, String),
    country Nullable(String),
    city Nullable(String)
)
ENGINE = ReplacingMergeTree
ORDER BY (session_id, started_at);
