-- ============================================================
-- AUTOPREDATOR MONETIZATION SCHEMA
-- Tables for pricing, billing, subscriptions, and entitlements
-- ============================================================

USE `autopredator_unified`;

-- ============================================================
-- 1. ORGANIZATIONS TABLE (for multi-tenant)
-- ============================================================
CREATE TABLE IF NOT EXISTS `organizations` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(120) NOT NULL,
    `slug` VARCHAR(120) UNIQUE,
    `email` VARCHAR(160),
    `phone` VARCHAR(20),
    `address` TEXT,
    `gst_number` VARCHAR(20),
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_slug` (`slug`),
    INDEX `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. USERS TABLE EXTENSION (add org_id)
-- ============================================================
ALTER TABLE `users` ADD COLUMN `org_id` INT UNSIGNED NULL AFTER `role`;
ALTER TABLE `users` ADD FOREIGN KEY (`org_id`) REFERENCES `organizations` (`id`) ON DELETE SET NULL;
ALTER TABLE `users` ADD INDEX `idx_org_id` (`org_id`);

-- ============================================================
-- 3. PLANS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `plans` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(100) UNIQUE,
    `description` TEXT,
    `price_monthly` DECIMAL(10, 2) NOT NULL, -- INR
    `price_yearly` DECIMAL(10, 2) NULL,
    `billing_unit` ENUM('user', 'org', 'vehicle', 'usage') NOT NULL DEFAULT 'user',
    `max_users` INT NULL,
    `max_vehicles` INT NULL,
    `max_exports` INT NULL,
    `features` JSON, -- Array of feature slugs
    `trial_days` INT NOT NULL DEFAULT 0,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `sort_order` INT NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_slug` (`slug`),
    INDEX `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. SUBSCRIPTIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `subscriptions` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `org_id` INT UNSIGNED NOT NULL,
    `plan_id` INT UNSIGNED NOT NULL,
    `status` ENUM('trial', 'active', 'past_due', 'canceled', 'read_only') NOT NULL DEFAULT 'trial',
    `current_period_start` DATETIME NOT NULL,
    `current_period_end` DATETIME NOT NULL,
    `trial_end` DATETIME NULL,
    `cancel_at_period_end` TINYINT(1) NOT NULL DEFAULT 0,
    `canceled_at` DATETIME NULL,
    `quantity` INT NOT NULL DEFAULT 1, -- Number of units (users, etc.)
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`org_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`) ON DELETE RESTRICT,
    INDEX `idx_org_id` (`org_id`),
    INDEX `idx_plan_id` (`plan_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_current_period_end` (`current_period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. PAYMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `payments` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `subscription_id` INT UNSIGNED NOT NULL,
    `amount` DECIMAL(10, 2) NOT NULL,
    `currency` VARCHAR(3) NOT NULL DEFAULT 'INR',
    `status` ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    `payment_method` VARCHAR(50), -- razorpay, stripe, etc.
    `external_id` VARCHAR(100), -- Razorpay/Stripe payment ID
    `invoice_url` VARCHAR(255),
    `failure_reason` TEXT,
    `paid_at` DATETIME NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`) ON DELETE CASCADE,
    INDEX `idx_subscription_id` (`subscription_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_external_id` (`external_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. INVOICES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `invoices` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `subscription_id` INT UNSIGNED NOT NULL,
    `payment_id` INT UNSIGNED NULL,
    `invoice_number` VARCHAR(50) UNIQUE,
    `amount` DECIMAL(10, 2) NOT NULL,
    `currency` VARCHAR(3) NOT NULL DEFAULT 'INR',
    `status` ENUM('draft', 'sent', 'paid', 'void') NOT NULL DEFAULT 'draft',
    `billing_period_start` DATETIME NOT NULL,
    `billing_period_end` DATETIME NOT NULL,
    `due_date` DATETIME NOT NULL,
    `paid_at` DATETIME NULL,
    `pdf_url` VARCHAR(255),
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL,
    INDEX `idx_subscription_id` (`subscription_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_due_date` (`due_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. USAGE COUNTERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `usage_counters` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `org_id` INT UNSIGNED NOT NULL,
    `metric` VARCHAR(50) NOT NULL, -- searches, comparisons, exports, etc.
    `count` INT NOT NULL DEFAULT 0,
    `period_start` DATETIME NOT NULL,
    `period_end` DATETIME NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`org_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_org_metric_period` (`org_id`, `metric`, `period_start`),
    INDEX `idx_org_id` (`org_id`),
    INDEX `idx_metric` (`metric`),
    INDEX `idx_period` (`period_start`, `period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. COUPONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `coupons` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(50) UNIQUE NOT NULL,
    `description` TEXT,
    `discount_type` ENUM('percentage', 'fixed') NOT NULL,
    `discount_value` DECIMAL(10, 2) NOT NULL,
    `max_uses` INT NULL,
    `used_count` INT NOT NULL DEFAULT 0,
    `valid_from` DATETIME NOT NULL,
    `valid_until` DATETIME NOT NULL,
    `applicable_plans` JSON, -- Array of plan IDs or null for all
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_code` (`code`),
    INDEX `idx_active` (`is_active`),
    INDEX `idx_valid_until` (`valid_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. AUDIT EVENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `audit_events` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `org_id` INT UNSIGNED NULL,
    `user_id` INT UNSIGNED NULL,
    `event_type` VARCHAR(50) NOT NULL, -- subscription_created, payment_failed, etc.
    `event_data` JSON,
    `ip_address` VARCHAR(45),
    `user_agent` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`org_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    INDEX `idx_org_id` (`org_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_event_type` (`event_type`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. SUPPORT TICKETS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `support_tickets` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `org_id` INT UNSIGNED NULL,
    `user_id` INT UNSIGNED NULL,
    `subject` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `status` ENUM('open', 'in_progress', 'waiting_for_user', 'resolved', 'closed') NOT NULL DEFAULT 'open',
    `priority` ENUM('low', 'medium', 'high', 'urgent') NOT NULL DEFAULT 'medium',
    `category` VARCHAR(50), -- billing, technical, feature_request, etc.
    `assigned_to` INT UNSIGNED NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
    `resolved_at` DATETIME NULL,
    FOREIGN KEY (`org_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
    INDEX `idx_org_id` (`org_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_priority` (`priority`),
    INDEX `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. SUPPORT MESSAGES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS `support_messages` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `ticket_id` INT UNSIGNED NOT NULL,
    `user_id` INT UNSIGNED NULL,
    `message` TEXT NOT NULL,
    `is_internal` TINYINT(1) NOT NULL DEFAULT 0, -- Internal notes
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX `idx_ticket_id` (`ticket_id`),
    INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. USER CONSENTS TABLE (for GDPR compliance)
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_consents` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `consent_type` VARCHAR(50) NOT NULL, -- marketing, analytics, data_processing, etc.
    `consented` TINYINT(1) NOT NULL,
    `ip_address` VARCHAR(45),
    `user_agent` TEXT,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_consent_type` (`consent_type`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. DUNNING EMAILS TABLE (for failed payment notifications)
-- ============================================================
CREATE TABLE IF NOT EXISTS `dunning_emails` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `payment_id` INT UNSIGNED NOT NULL,
    `dunning_level` INT NOT NULL DEFAULT 1,
    `subject` VARCHAR(255) NOT NULL,
    `body` TEXT NOT NULL,
    `sent_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE CASCADE,
    INDEX `idx_payment_id` (`payment_id`),
    INDEX `idx_dunning_level` (`dunning_level`),
    INDEX `idx_sent_at` (`sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add dunning-related columns to payments table
ALTER TABLE `payments` ADD COLUMN `dunning_level` INT DEFAULT 0 AFTER `failure_reason`;
ALTER TABLE `payments` ADD COLUMN `last_dunning_attempt` DATETIME NULL AFTER `dunning_level`;

-- Add suspension tracking to subscriptions table
ALTER TABLE `subscriptions` ADD COLUMN `suspension_date` DATETIME NULL AFTER `canceled_at`;
ALTER TABLE `subscriptions` ADD COLUMN `suspended_at` DATETIME NULL AFTER `suspension_date`;

-- ============================================================
-- 14. SAMPLE DATA
-- ============================================================

-- Insert sample organizations
INSERT INTO `organizations` (`name`, `slug`, `email`) VALUES
('Demo Org', 'demo-org', 'billing@demo.com');

-- Insert sample plans
INSERT INTO `plans` (`name`, `slug`, `description`, `price_monthly`, `billing_unit`, `max_users`, `max_vehicles`, `max_exports`, `features`, `trial_days`, `sort_order`) VALUES
('Free', 'free', 'Basic features for individual users', 0.00, 'user', 1, 5, 1, '["search", "compare"]', 0, 1),
('Starter', 'starter', 'For small teams', 499.00, 'user', 5, 50, 10, '["search", "compare", "favorites", "export"]', 14, 2),
('Pro', 'pro', 'For growing businesses', 1499.00, 'user', 25, 200, 50, '["search", "compare", "favorites", "export", "ai_content", "analytics"]', 14, 3),
('Enterprise', 'enterprise', 'Unlimited everything', 4999.00, 'org', NULL, NULL, NULL, '["all"]', 30, 4);
