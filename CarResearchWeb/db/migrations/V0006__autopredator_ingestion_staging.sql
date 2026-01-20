USE autopredator_ingestion_staging;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ingest_runs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  source VARCHAR(150) NOT NULL,
  status ENUM('running','failed','completed') NOT NULL DEFAULT 'running',
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME NULL,
  total_rows INT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_ingest_runs_status (status, started_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ingest_errors (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ingest_run_id BIGINT UNSIGNED NOT NULL,
  staging_table VARCHAR(120) NOT NULL,
  staging_row_id BIGINT UNSIGNED NULL,
  error_code VARCHAR(80) NULL,
  error_message VARCHAR(500) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_ingest_errors_run (ingest_run_id),
  CONSTRAINT fk_ingest_errors_run FOREIGN KEY (ingest_run_id) REFERENCES ingest_runs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ingest_row_status (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ingest_run_id BIGINT UNSIGNED NOT NULL,
  staging_table VARCHAR(120) NOT NULL,
  staging_row_id BIGINT UNSIGNED NOT NULL,
  status ENUM('pending','validated','error','loaded','skipped') NOT NULL DEFAULT 'pending',
  message VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_ingest_row_status (ingest_run_id, staging_table, staging_row_id),
  KEY idx_ingest_row_status_status (status),
  CONSTRAINT fk_ingest_row_status_run FOREIGN KEY (ingest_run_id) REFERENCES ingest_runs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS staging_variants (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ingest_run_id BIGINT UNSIGNED NOT NULL,
  manufacturer_name VARCHAR(150) NOT NULL,
  model_family_name VARCHAR(150) NULL,
  model_name VARCHAR(150) NOT NULL,
  variant_name VARCHAR(150) NOT NULL,
  variant_code VARCHAR(100) NULL,
  fuel_type VARCHAR(80) NULL,
  transmission VARCHAR(80) NULL,
  body_type VARCHAR(80) NULL,
  year_start SMALLINT NULL,
  year_end SMALLINT NULL,
  raw_payload JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_staging_variants_run (ingest_run_id),
  CONSTRAINT fk_staging_variants_run FOREIGN KEY (ingest_run_id) REFERENCES ingest_runs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS staging_specs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ingest_run_id BIGINT UNSIGNED NOT NULL,
  variant_ref VARCHAR(150) NOT NULL,
  spec_key VARCHAR(150) NOT NULL,
  spec_value VARCHAR(255) NULL,
  unit VARCHAR(50) NULL,
  raw_payload JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_staging_specs_run (ingest_run_id),
  KEY idx_staging_specs_variant (variant_ref),
  CONSTRAINT fk_staging_specs_run FOREIGN KEY (ingest_run_id) REFERENCES ingest_runs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS staging_prices (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ingest_run_id BIGINT UNSIGNED NOT NULL,
  variant_ref VARCHAR(150) NOT NULL,
  city_name VARCHAR(150) NOT NULL,
  state_name VARCHAR(120) NOT NULL,
  price_type ENUM('ex_showroom','on_road') NOT NULL DEFAULT 'ex_showroom',
  price_amount DECIMAL(15,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  captured_on DATE NULL,
  source VARCHAR(150) NULL,
  raw_payload JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_staging_prices_run (ingest_run_id),
  KEY idx_staging_prices_variant_city (variant_ref, city_name),
  CONSTRAINT fk_staging_prices_run FOREIGN KEY (ingest_run_id) REFERENCES ingest_runs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS staging_media (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ingest_run_id BIGINT UNSIGNED NOT NULL,
  entity_type ENUM('model','variant') NOT NULL,
  entity_ref VARCHAR(150) NOT NULL,
  media_type ENUM('image','video','brochure') NOT NULL DEFAULT 'image',
  url TEXT NOT NULL,
  title VARCHAR(200) NULL,
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  raw_payload JSON NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_staging_media_run (ingest_run_id),
  KEY idx_staging_media_entity (entity_type, entity_ref),
  CONSTRAINT fk_staging_media_run FOREIGN KEY (ingest_run_id) REFERENCES ingest_runs(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
