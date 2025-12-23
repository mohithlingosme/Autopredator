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

-- ============================================================
-- CONTENT SYSTEM TABLES
-- Blog posts, categories, authors, media management
-- ============================================================

-- ============================================================
-- 15. CONTENT AUTHORS TABLE
-- Authors/editors for content management
-- ============================================================
CREATE TABLE IF NOT EXISTS `content_authors` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED,
    `name` VARCHAR(120) NOT NULL,
    `email` VARCHAR(160) NOT NULL UNIQUE,
    `bio` TEXT,
    `avatar_url` VARCHAR(255),
    `social_links` JSON,  -- Twitter, LinkedIn, etc.
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    INDEX `idx_email` (`email`),
    INDEX `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 16. CONTENT CATEGORIES TABLE
-- Categories for organizing blog posts
-- ============================================================
CREATE TABLE IF NOT EXISTS `content_categories` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `slug` VARCHAR(100) NOT NULL UNIQUE,
    `description` TEXT,
    `parent_id` INT UNSIGNED,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`parent_id`) REFERENCES `content_categories` (`id`) ON DELETE SET NULL,
    INDEX `idx_slug` (`slug`),
    INDEX `idx_parent` (`parent_id`),
    INDEX `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 17. BLOG POSTS TABLE
-- Main content posts with editorial workflow
-- ============================================================
CREATE TABLE IF NOT EXISTS `blog_posts` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `slug` VARCHAR(255) NOT NULL UNIQUE,
    `excerpt` TEXT,
    `content` LONGTEXT NOT NULL,
    `featured_image` VARCHAR(255),
    `author_id` INT UNSIGNED NOT NULL,
    `category_id` INT UNSIGNED,
    `status` ENUM('draft', 'review', 'published', 'archived') NOT NULL DEFAULT 'draft',
    `published_at` DATETIME,
    `seo_title` VARCHAR(255),
    `seo_description` TEXT,
    `seo_keywords` VARCHAR(255),
    `reading_time` INT,  -- in minutes
    `word_count` INT,
    `is_featured` TINYINT(1) NOT NULL DEFAULT 0,
    `is_ai_generated` TINYINT(1) NOT NULL DEFAULT 0,
    `ai_prompt` TEXT,  -- Store the AI prompt used for generation
    `review_notes` TEXT,  -- Editor notes during review
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`author_id`) REFERENCES `content_authors` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`category_id`) REFERENCES `content_categories` (`id`) ON DELETE SET NULL,
    INDEX `idx_slug` (`slug`),
    INDEX `idx_author` (`author_id`),
    INDEX `idx_category` (`category_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_published` (`published_at`),
    INDEX `idx_featured` (`is_featured`),
    INDEX `idx_ai_generated` (`is_ai_generated`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 18. MEDIA LIBRARY TABLE
-- File uploads for images, documents, etc.
-- ============================================================
CREATE TABLE IF NOT EXISTS `media_library` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `filename` VARCHAR(255) NOT NULL,
    `original_name` VARCHAR(255) NOT NULL,
    `mime_type` VARCHAR(100) NOT NULL,
    `file_path` VARCHAR(500) NOT NULL,
    `file_size` INT UNSIGNED NOT NULL,  -- in bytes
    `dimensions` VARCHAR(50),  -- width x height for images
    `alt_text` VARCHAR(255),
    `caption` TEXT,
    `uploaded_by` INT UNSIGNED,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    INDEX `idx_filename` (`filename`),
    INDEX `idx_mime_type` (`mime_type`),
    INDEX `idx_uploaded_by` (`uploaded_by`),
    INDEX `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 19. BLOG POST MEDIA TABLE
-- Links posts to media files (featured images, galleries)
-- ============================================================
CREATE TABLE IF NOT EXISTS `blog_post_media` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `post_id` INT UNSIGNED NOT NULL,
    `media_id` INT UNSIGNED NOT NULL,
    `media_type` ENUM('featured', 'gallery', 'inline') NOT NULL DEFAULT 'gallery',
    `sort_order` INT NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`media_id`) REFERENCES `media_library` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_post_media` (`post_id`, `media_id`, `media_type`),
    INDEX `idx_post` (`post_id`),
    INDEX `idx_media` (`media_id`),
    INDEX `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 20. BLOG POST TAGS TABLE
-- Tags for better content organization
-- ============================================================
CREATE TABLE IF NOT EXISTS `blog_tags` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `slug` VARCHAR(50) NOT NULL UNIQUE,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 21. BLOG POST TAGS MAPPING TABLE
-- Many-to-many relationship between posts and tags
-- ============================================================
CREATE TABLE IF NOT EXISTS `blog_post_tags` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `post_id` INT UNSIGNED NOT NULL,
    `tag_id` INT UNSIGNED NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`tag_id`) REFERENCES `blog_tags` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_post_tag` (`post_id`, `tag_id`),
    INDEX `idx_post` (`post_id`),
    INDEX `idx_tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 22. AI DRAFT QUEUE TABLE
-- Queue for AI-generated content drafts
-- ============================================================
CREATE TABLE IF NOT EXISTS `ai_draft_queue` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `prompt` TEXT NOT NULL,
    `topic` VARCHAR(255),
    `category_id` INT UNSIGNED,
    `target_word_count` INT,
    `priority` ENUM('low', 'medium', 'high') NOT NULL DEFAULT 'medium',
    `status` ENUM('pending', 'processing', 'completed', 'failed', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    `generated_content` LONGTEXT,
    `review_notes` TEXT,
    `reviewed_by` INT UNSIGNED,
    `reviewed_at` DATETIME,
    `created_by` INT UNSIGNED,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`category_id`) REFERENCES `content_categories` (`id`) ON DELETE SET NULL,
    FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    INDEX `idx_status` (`status`),
    INDEX `idx_priority` (`priority`),
    INDEX `idx_category` (`category_id`),
    INDEX `idx_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SAMPLE CONTENT DATA
-- ============================================================

-- Insert sample content author
INSERT INTO `content_authors` (`name`, `email`, `bio`) VALUES
('CarResearch Team', 'editor@carresearch.com', 'Expert automotive journalists and reviewers providing in-depth analysis of cars in India.');

-- Insert sample categories
INSERT INTO `content_categories` (`name`, `slug`, `description`) VALUES
('Car Reviews', 'car-reviews', 'Detailed reviews of new car launches and models'),
('Buying Guide', 'buying-guide', 'Comprehensive guides to help you choose the right car'),
('News', 'news', 'Latest automotive news and industry updates'),
('Tips & Advice', 'tips-advice', 'Practical tips for car maintenance and ownership');

-- Insert sample tags
INSERT INTO `blog_tags` (`name`, `slug`) VALUES
('SUV', 'suv'),
('Sedan', 'sedan'),
('Electric', 'electric'),
('Hybrid', 'hybrid'),
('Petrol', 'petrol'),
('Diesel', 'diesel'),
('Automatic', 'automatic'),
('Manual', 'manual');

-- Create indices for better performance
CREATE INDEX idx_manufacturers_active ON `manufacturers` (`is_active`);
CREATE INDEX idx_variants_active ON `variants` (`is_active`);
CREATE INDEX idx_models_active ON `models` (`is_active`);
CREATE INDEX idx_content_authors_active ON `content_authors` (`is_active`);
CREATE INDEX idx_content_categories_active ON `content_categories` (`is_active`);
CREATE INDEX idx_blog_posts_status ON `blog_posts` (`status`);
CREATE INDEX idx_blog_posts_published ON `blog_posts` (`published_at`);
CREATE INDEX idx_media_library_active ON `media_library` (`is_active`);
