USE autopredator_marketplace;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS states (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  code VARCHAR(20) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_marketplace_states_code (code),
  UNIQUE KEY uq_marketplace_states_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cities (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  state_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(150) NOT NULL,
  code VARCHAR(40) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_marketplace_cities_name (state_id, name),
  UNIQUE KEY uq_marketplace_cities_code (state_id, code),
  KEY idx_marketplace_cities_state (state_id),
  CONSTRAINT fk_marketplace_cities_state FOREIGN KEY (state_id) REFERENCES states(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS listings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  org_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NULL,
  model_id BIGINT UNSIGNED NULL,
  variant_id BIGINT UNSIGNED NULL,
  city_id BIGINT UNSIGNED NOT NULL,
  year SMALLINT NULL,
  kms_driven INT UNSIGNED NULL,
  price DECIMAL(15,2) NULL,
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  listing_type ENUM('sell','buy') NOT NULL DEFAULT 'sell',
  condition_state ENUM('new','used','certified') NOT NULL DEFAULT 'used',
  status ENUM('draft','published','sold','expired','archived') NOT NULL DEFAULT 'draft',
  description TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_listings_status (status, city_id),
  KEY idx_listings_variant (variant_id),
  KEY idx_listings_model (model_id),
  CONSTRAINT fk_listings_city FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS leads (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  listing_id BIGINT UNSIGNED NULL,
  model_id BIGINT UNSIGNED NULL,
  variant_id BIGINT UNSIGNED NULL,
  buyer_name VARCHAR(150) NOT NULL,
  buyer_email VARCHAR(150) NULL,
  buyer_phone VARCHAR(40) NULL,
  source VARCHAR(120) NULL,
  status ENUM('new','contacted','qualified','lost','converted') NOT NULL DEFAULT 'new',
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_leads_listing (listing_id),
  KEY idx_leads_status (status),
  CONSTRAINT fk_leads_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS lead_status_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  lead_id BIGINT UNSIGNED NOT NULL,
  status ENUM('new','contacted','qualified','lost','converted') NOT NULL,
  changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  changed_by_user_id BIGINT UNSIGNED NULL,
  note VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_lead_status_history_lead (lead_id),
  CONSTRAINT fk_lead_status_history_lead FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
