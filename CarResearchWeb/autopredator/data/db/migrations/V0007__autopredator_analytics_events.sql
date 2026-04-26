USE autopredator_analytics_events;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  occurred_at DATETIME NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  session_id CHAR(64) NOT NULL,
  event_type VARCHAR(120) NOT NULL,
  page_id BIGINT UNSIGNED NULL,
  entity_type ENUM('manufacturer','model','variant','listing','page') NULL,
  entity_id BIGINT UNSIGNED NULL,
  props_json JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_events_event_type (event_type, occurred_at),
  KEY idx_events_page (page_id, occurred_at),
  KEY idx_events_occurred_at (occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS daily_rollups (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  rollup_date DATE NOT NULL,
  metric_key VARCHAR(150) NOT NULL,
  metric_value DECIMAL(20,4) NOT NULL,
  dims_json JSON NULL,
  dims_key VARCHAR(255) NOT NULL DEFAULT '',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_daily_rollups_key (rollup_date, metric_key, dims_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
