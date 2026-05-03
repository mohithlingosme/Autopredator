-- SIAM Sales & VAHAN Registration Tables

CREATE TABLE IF NOT EXISTS siam_sales (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  month VARCHAR(7) NOT NULL, -- YYYY-MM
  oem VARCHAR(100) NOT NULL,
  passenger_cars INT DEFAULT 0,
  utility_vehicles INT DEFAULT 0,
  vans_pcv INT DEFAULT 0,
  domestic INT DEFAULT 0,
  exports INT DEFAULT 0,
  total INT DEFAULT 0,
  pdf_source VARCHAR(500),
  imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_siam (month, oem),
  KEY idx_oem (oem),
  KEY idx_month (month)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vahan_registrations (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  state_code VARCHAR(10),
  state_name VARCHAR(100),
  vehicle_class VARCHAR(100),
  category_2wic INT DEFAULT 0,
  category_lmv INT DEFAULT 0,
  category_mmv INT DEFAULT 0,
  category_hmv INT DEFAULT 0,
  total INT DEFAULT 0,
  year_month VARCHAR(7),
  imported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_vahan (state_code, vehicle_class, year_month),
  KEY idx_state (state_code),
  KEY idx_class (vehicle_class)
) ENGINE=InnoDB;

-- Indexes for KG queries
CREATE INDEX idx_vehicle_reg_trends ON vahan_registrations (state_code, year_month);

