-- ============================================================
-- AUTOPREDATOR CAR RESEARCH PLATFORM DATABASE SCHEMA
-- Complete database structure for vehicle research, comparison
-- and user management
-- ============================================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS `autopredator_unified` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `autopredator_unified`;

-- ============================================================
-- 1. MANUFACTURERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `manufacturers` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(120) NOT NULL UNIQUE,
    `slug` VARCHAR(120) UNIQUE,
    `country` VARCHAR(100),
    `description` TEXT,
    `logo_url` VARCHAR(255),
    `website_url` VARCHAR(255),
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_name` (`name`),
    INDEX `idx_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. MODEL FAMILIES TABLE
-- Represents vehicle families (e.g., Swift, Creta, Fortuner)
-- ============================================================
CREATE TABLE IF NOT EXISTS `model_families` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `manufacturer_id` INT UNSIGNED NOT NULL,
    `nameplate` VARCHAR(120) NOT NULL,
    `slug` VARCHAR(120),
    `body_type` VARCHAR(50),  -- Hatchback, Sedan, SUV, MUV, etc.
    `description` TEXT,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_nameplate` (`manufacturer_id`, `nameplate`),
    INDEX `idx_nameplate` (`nameplate`),
    INDEX `idx_body_type` (`body_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. MODEL LIFECYCLE TABLE
-- Tracks generations and facelifts (e.g., 1st Gen, 2nd Gen)
-- ============================================================
CREATE TABLE IF NOT EXISTS `model_lifecycle` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `generation_name` VARCHAR(100),  -- e.g., '3rd Generation', 'Facelift 2023'
    `start_year` INT,
    `end_year` INT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. MODELS TABLE
-- Specific model generations and facelifts
-- ============================================================
CREATE TABLE IF NOT EXISTS `models` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `family_id` INT UNSIGNED NOT NULL,
    `manufacturer_id` INT UNSIGNED NOT NULL,
    `name` VARCHAR(120) NOT NULL,
    `slug` VARCHAR(120),
    `lifecycle_id` INT UNSIGNED,
    `launch_year` INT,
    `end_year` INT,
    `description` TEXT,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`family_id`) REFERENCES `model_families` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`lifecycle_id`) REFERENCES `model_lifecycle` (`id`) ON DELETE SET NULL,
    INDEX `idx_family_id` (`family_id`),
    INDEX `idx_manufacturer_id` (`manufacturer_id`),
    INDEX `idx_launch_year` (`launch_year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. VARIANTS TABLE
-- Specific variants (trim levels) of a model
-- ============================================================
CREATE TABLE IF NOT EXISTS `variants` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `model_id` INT UNSIGNED NOT NULL,
    `variant_name` VARCHAR(150) NOT NULL,
    `slug` VARCHAR(150),
    `fuel_type` VARCHAR(50),  -- Petrol, Diesel, CNG, Hybrid, Electric
    `transmission` VARCHAR(50),  -- Manual, Automatic, CVT, AMT, etc.
    `body_color_options` VARCHAR(255),  -- Comma-separated list
    `ex_showroom_price` DECIMAL(15, 2),  -- Price in INR
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`model_id`) REFERENCES `models` (`id`) ON DELETE CASCADE,
    INDEX `idx_model_id` (`model_id`),
    INDEX `idx_fuel_type` (`fuel_type`),
    INDEX `idx_transmission` (`transmission`),
    INDEX `idx_price` (`ex_showroom_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. VEHICLE SPECS TABLE
-- Detailed engine and performance specifications
-- ============================================================
CREATE TABLE IF NOT EXISTS `vehicle_specs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `variant_id` INT UNSIGNED NOT NULL UNIQUE,
    `engine_type` VARCHAR(100),  -- e.g., '1.2L K-Series Petrol'
    `displacement` INT,  -- in cc
    `max_power` DECIMAL(6, 2),  -- in bhp
    `max_torque` DECIMAL(6, 2),  -- in Nm
    `transmission` VARCHAR(100),
    `fuel_tank_capacity` DECIMAL(6, 2),  -- in liters
    `seating_capacity` INT,
    `ground_clearance` DECIMAL(5, 1),  -- in mm
    `boot_space` INT,  -- in liters
    `fuel_efficiency` DECIMAL(6, 2),  -- ARAI rating in kmpl
    `doors` INT,
    `wheelbase` DECIMAL(7, 2),  -- in mm
    `length` DECIMAL(7, 2),  -- in mm
    `width` DECIMAL(7, 2),  -- in mm
    `height` DECIMAL(7, 2),  -- in mm
    `curb_weight` DECIMAL(6, 2),  -- in kg
    `acceleration_0_100` DECIMAL(5, 2),  -- seconds (0-100 kmph)
    `top_speed` INT,  -- km/h
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. FEATURES TABLE
-- Catalog of all available car features
-- ============================================================
CREATE TABLE IF NOT EXISTS `features` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(120) NOT NULL,
    `category` VARCHAR(50),  -- Safety, Comfort, Tech, Convenience, etc.
    `description` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_category` (`category`),
    UNIQUE KEY `unique_feature` (`name`, `category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. VARIANT FEATURES MAPPING TABLE
-- Links variants to features (many-to-many)
-- ============================================================
CREATE TABLE IF NOT EXISTS `variant_features` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `variant_id` INT UNSIGNED NOT NULL,
    `feature_id` INT UNSIGNED NOT NULL,
    `is_standard` TINYINT(1) NOT NULL DEFAULT 1,  -- Standard vs optional
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`feature_id`) REFERENCES `features` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_variant_feature` (`variant_id`, `feature_id`),
    INDEX `idx_feature_id` (`feature_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. CITIES TABLE
-- Cities where pricing varies
-- ============================================================
CREATE TABLE IF NOT EXISTS `cities` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `state` VARCHAR(100),
    `region` VARCHAR(100),
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_name` (`name`),
    INDEX `idx_state` (`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. PRICE HISTORY TABLE
-- Tracks price changes over time
-- ============================================================
CREATE TABLE IF NOT EXISTS `price_history` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `variant_id` INT UNSIGNED NOT NULL,
    `city_id` INT UNSIGNED,
    `ex_showroom_price` DECIMAL(15, 2),
    `on_road_price` DECIMAL(15, 2),
    `effective_from` DATE NOT NULL,
    `effective_to` DATE,
    `notes` VARCHAR(255),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL,
    INDEX `idx_variant_city` (`variant_id`, `city_id`),
    INDEX `idx_effective_date` (`effective_from`, `effective_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. USERS TABLE
-- User accounts for saved favorites and comparisons
-- ============================================================
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(120) NOT NULL,
    `email` VARCHAR(160) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255),
    `phone` VARCHAR(20),
    `city` VARCHAR(100),
    `role` ENUM('user', 'admin', 'editor') NOT NULL DEFAULT 'user',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `last_login` DATETIME,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_email` (`email`),
    INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. USER FAVORITES TABLE
-- Variants saved by users
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_favorites` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `variant_id` INT UNSIGNED NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_user_favorite` (`user_id`, `variant_id`),
    INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. USER COMPARISONS TABLE
-- Track variant comparisons made by users
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_comparisons` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED,
    `variant_ids` JSON,  -- Array of variant IDs
    `comparison_name` VARCHAR(200),
    `notes` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 14. SAMPLE DATA
-- ============================================================

-- Insert sample manufacturers
INSERT INTO `manufacturers` (`name`, `country`, `is_active`) VALUES
('Maruti Suzuki', 'India', 1),
('Hyundai', 'South Korea', 1),
('Tata Motors', 'India', 1),
('Mahindra', 'India', 1),
('Toyota', 'Japan', 1),
('Honda', 'Japan', 1),
('Kia', 'South Korea', 1),
('Skoda', 'Czech Republic', 1);

-- Insert sample cities
INSERT INTO `cities` (`name`, `state`) VALUES
('Delhi', 'Delhi'),
('Mumbai', 'Maharashtra'),
('Bangalore', 'Karnataka'),
('Hyderabad', 'Telangana'),
('Pune', 'Maharashtra'),
('Kolkata', 'West Bengal'),
('Chennai', 'Tamil Nadu'),
('Ahmedabad', 'Gujarat');

-- Insert sample features
INSERT INTO `features` (`name`, `category`) VALUES
('Dual Airbags', 'Safety'),
('ABS with EBD', 'Safety'),
('Rear Parking Sensors', 'Safety'),
('ISOFIX', 'Safety'),
('Auto AC', 'Comfort'),
('Power Steering', 'Comfort'),
('Cruise Control', 'Comfort'),
('Touchscreen Infotainment', 'Technology'),
('Android Auto', 'Technology'),
('Apple CarPlay', 'Technology'),
('Steering Mounted Controls', 'Technology');

-- Create indices for better performance
CREATE INDEX idx_manufacturers_active ON `manufacturers` (`is_active`);
CREATE INDEX idx_variants_active ON `variants` (`is_active`);
CREATE INDEX idx_models_active ON `models` (`is_active`);
