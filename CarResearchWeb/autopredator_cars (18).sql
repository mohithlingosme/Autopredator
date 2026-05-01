-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 01, 2026 at 06:58 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `autopredator_cars`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_audit_logs`
--

CREATE TABLE `admin_audit_logs` (
  `log_id` bigint(20) NOT NULL,
  `admin_user` varchar(255) DEFAULT NULL,
  `action_type` varchar(100) DEFAULT NULL,
  `table_name` varchar(100) DEFAULT NULL,
  `affected_record_id` bigint(20) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_attribute_extraction`
--

CREATE TABLE `ai_attribute_extraction` (
  `extraction_id` bigint(20) NOT NULL,
  `raw_id` bigint(20) DEFAULT NULL,
  `attribute_name` varchar(150) DEFAULT NULL,
  `extracted_value` text DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `approved` tinyint(1) DEFAULT 0,
  `ai_model_version` varchar(100) DEFAULT NULL,
  `extraction_source` varchar(255) DEFAULT NULL,
  `review_status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `human_override` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_metadata`
--

CREATE TABLE `ai_metadata` (
  `ai_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `recommendation_tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recommendation_tags`)),
  `buyer_persona_tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`buyer_persona_tags`)),
  `commercial_use_tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`commercial_use_tags`)),
  `predicted_market_demand` decimal(5,2) DEFAULT NULL,
  `scraper_confidence` decimal(5,2) DEFAULT NULL,
  `last_ai_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `ai_model_version` varchar(100) DEFAULT NULL,
  `human_verified` tinyint(1) DEFAULT 0,
  `feedback_score` decimal(5,2) DEFAULT NULL,
  `anomaly_detected` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_population_pipeline`
--

CREATE TABLE `ai_population_pipeline` (
  `pipeline_id` bigint(20) NOT NULL,
  `source_id` bigint(20) DEFAULT NULL,
  `pipeline_stage` varchar(100) DEFAULT NULL,
  `processed_records` bigint(20) DEFAULT NULL,
  `failed_records` bigint(20) DEFAULT NULL,
  `success_rate` decimal(5,2) DEFAULT NULL,
  `avg_processing_time_ms` decimal(15,2) DEFAULT NULL,
  `model_version` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_training_feedback`
--

CREATE TABLE `ai_training_feedback` (
  `feedback_id` bigint(20) NOT NULL,
  `extraction_id` bigint(20) DEFAULT NULL,
  `correction_notes` text DEFAULT NULL,
  `corrected_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `api_performance_logs`
--

CREATE TABLE `api_performance_logs` (
  `log_id` bigint(20) NOT NULL,
  `endpoint_name` varchar(255) DEFAULT NULL,
  `avg_response_time_ms` decimal(10,2) DEFAULT NULL,
  `request_volume` bigint(20) DEFAULT NULL,
  `error_rate` decimal(5,2) DEFAULT NULL,
  `logged_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `autonomous_system_specs`
--

CREATE TABLE `autonomous_system_specs` (
  `autonomous_id` bigint(20) NOT NULL,
  `config_id` bigint(20) DEFAULT NULL,
  `autonomy_level` varchar(50) DEFAULT NULL,
  `lidar_count` int(11) DEFAULT NULL,
  `radar_count` int(11) DEFAULT NULL,
  `ultrasonic_sensor_count` int(11) DEFAULT NULL,
  `self_parking` tinyint(1) DEFAULT NULL,
  `summon_mode` tinyint(1) DEFAULT NULL,
  `geo_fenced_autonomy` tinyint(1) DEFAULT NULL,
  `highway_assist` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `body_builder_compatibility`
--

CREATE TABLE `body_builder_compatibility` (
  `compatibility_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `body_type` varchar(150) DEFAULT NULL,
  `cargo_class` varchar(100) DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `id` int(11) NOT NULL,
  `brand_name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `parent_company` varchar(150) DEFAULT NULL,
  `country_of_origin` varchar(100) DEFAULT NULL,
  `original_country` varchar(100) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `official_website` varchar(255) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `brand_category` enum('Mass Market','Premium','Luxury','Performance','Commercial','Defunct') DEFAULT 'Mass Market',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `founded_year` year(4) DEFAULT NULL,
  `support_email` varchar(255) DEFAULT NULL,
  `support_phone` varchar(50) DEFAULT NULL,
  `global_presence` longtext DEFAULT NULL,
  `stock_symbol` varchar(20) DEFAULT NULL,
  `market_cap` decimal(20,2) DEFAULT NULL,
  `sustainability_score` decimal(5,2) DEFAULT NULL,
  `autonomous_investment_score` decimal(5,2) DEFAULT NULL,
  `luxury_score` decimal(5,2) DEFAULT NULL,
  `reliability_score` decimal(5,2) DEFAULT NULL,
  `ev_focus_score` decimal(5,2) DEFAULT NULL,
  `commercial_vehicle_focus_score` decimal(5,2) DEFAULT NULL,
  `seo_slug` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_by` varchar(150) DEFAULT NULL,
  `updated_by` varchar(150) DEFAULT NULL,
  `active_status` tinyint(1) DEFAULT 1,
  `uuid` char(36) DEFAULT NULL,
  `external_api_id` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `brand_pages`
--

CREATE TABLE `brand_pages` (
  `page_id` bigint(20) NOT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `slug` varchar(220) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` longtext DEFAULT NULL,
  `target_segment` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `budget_pages`
--

CREATE TABLE `budget_pages` (
  `page_id` bigint(20) NOT NULL,
  `slug` varchar(220) NOT NULL,
  `title` varchar(255) NOT NULL,
  `budget_min` decimal(15,2) DEFAULT NULL,
  `budget_max` decimal(15,2) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `buyer_behavior_analytics`
--

CREATE TABLE `buyer_behavior_analytics` (
  `behavior_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `search_frequency` bigint(20) DEFAULT NULL,
  `comparison_frequency` bigint(20) DEFAULT NULL,
  `lead_conversion_rate` decimal(5,2) DEFAULT NULL,
  `average_purchase_intent_score` decimal(5,2) DEFAULT NULL,
  `tracked_month` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `buyer_budget_profiles`
--

CREATE TABLE `buyer_budget_profiles` (
  `budget_profile_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `budget_min` decimal(15,2) DEFAULT NULL,
  `budget_max` decimal(15,2) DEFAULT NULL,
  `down_payment_budget` decimal(15,2) DEFAULT NULL,
  `monthly_emi_budget` decimal(15,2) DEFAULT NULL,
  `vehicle_type_preference` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `buyer_personas`
--

CREATE TABLE `buyer_personas` (
  `persona_id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `priority_features_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`priority_features_json`)),
  `budget_weight` decimal(3,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `buyer_persona_matches`
--

CREATE TABLE `buyer_persona_matches` (
  `match_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `persona_id` bigint(20) DEFAULT NULL,
  `fit_score` decimal(5,2) DEFAULT NULL,
  `budget_fit_score` decimal(5,2) DEFAULT NULL,
  `family_fit_score` decimal(5,2) DEFAULT NULL,
  `enthusiast_fit_score` decimal(5,2) DEFAULT NULL,
  `rural_fit_score` decimal(5,2) DEFAULT NULL,
  `urban_fit_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `buyer_persona_profiles`
--

CREATE TABLE `buyer_persona_profiles` (
  `persona_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `budget_range` varchar(100) DEFAULT NULL,
  `use_case` varchar(150) DEFAULT NULL,
  `family_size` int(11) DEFAULT NULL,
  `fuel_preference` varchar(50) DEFAULT NULL,
  `city_type` varchar(50) DEFAULT NULL,
  `rural_score` decimal(5,2) DEFAULT NULL,
  `enthusiast_score` decimal(5,2) DEFAULT NULL,
  `first_time_buyer_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `fitment_score` decimal(5,2) DEFAULT NULL,
  `budget_fit_score` decimal(5,2) DEFAULT NULL,
  `family_fit_score` decimal(5,2) DEFAULT NULL,
  `rural_fit_score` decimal(5,2) DEFAULT NULL,
  `urban_fit_score` decimal(5,2) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `buyer_recommendation_logs`
--

CREATE TABLE `buyer_recommendation_logs` (
  `recommendation_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `recommended_variant_id` bigint(20) DEFAULT NULL,
  `recommendation_score` decimal(5,2) DEFAULT NULL,
  `conversion_probability` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `buyer_vehicle_research_view`
-- (See below for the actual view)
--
CREATE TABLE `buyer_vehicle_research_view` (
`brand_id` int(11)
,`brand_name` varchar(150)
,`brand_uuid` char(36)
,`model_id` bigint(20)
,`model_name` varchar(150)
,`model_uuid` char(36)
,`segment` varchar(50)
,`body_type` varchar(100)
,`variant_id` bigint(20)
,`variant_name` varchar(200)
,`variant_uuid` char(36)
,`slug` varchar(200)
,`ex_showroom_price` decimal(15,2)
,`on_road_price` decimal(15,2)
,`country_id` int(11)
,`currency_code` varchar(10)
,`predicted_market_demand` decimal(5,2)
,`scraper_confidence` decimal(5,2)
,`human_verified` tinyint(1)
,`feedback_score` decimal(5,2)
,`anomaly_detected` tinyint(1)
,`reliability_score` decimal(5,2)
,`predicted_resale_value` decimal(5,2)
,`fuel_type` varchar(50)
,`displacement_cc` int(11)
,`max_power_hp` decimal(8,2)
,`max_torque_nm` decimal(8,2)
,`fuel_efficiency_kmpl` decimal(8,2)
,`battery_usable_kwh` decimal(8,2)
,`range_real_world_km` decimal(8,2)
,`airbag_count` int(11)
,`adas_level` varchar(50)
,`ncap_rating` varchar(50)
,`estimated_annual_maintenance_cost` decimal(12,2)
,`insurance_estimate_new` decimal(12,2)
,`payload_capacity_kg` int(11)
,`gross_vehicle_weight_kg` int(11)
,`commercial_use_case` varchar(255)
);

-- --------------------------------------------------------

--
-- Table structure for table `buying_guides`
--

CREATE TABLE `buying_guides` (
  `guide_id` bigint(20) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `segment` varchar(100) DEFAULT NULL,
  `seo_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cargo_body_compatibility`
--

CREATE TABLE `cargo_body_compatibility` (
  `compatibility_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `body_type` varchar(150) DEFAULT NULL,
  `compatibility_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chassis_specs`
--

CREATE TABLE `chassis_specs` (
  `chassis_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `frame_type` varchar(100) DEFAULT NULL,
  `front_suspension` varchar(150) DEFAULT NULL,
  `rear_suspension` varchar(150) DEFAULT NULL,
  `steering_type` varchar(100) DEFAULT NULL,
  `wheelbase_mm` int(11) DEFAULT NULL,
  `ground_clearance_mm` int(11) DEFAULT NULL,
  `length_mm` int(11) DEFAULT NULL,
  `width_mm` int(11) DEFAULT NULL,
  `height_mm` int(11) DEFAULT NULL,
  `kerb_weight_kg` int(11) DEFAULT NULL,
  `gross_vehicle_weight_kg` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `city_price_pages`
--

CREATE TABLE `city_price_pages` (
  `page_id` bigint(20) NOT NULL,
  `city_name` varchar(100) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `seo_content` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `color_options`
--

CREATE TABLE `color_options` (
  `color_id` bigint(20) NOT NULL,
  `color_name` varchar(100) NOT NULL,
  `color_code` varchar(50) DEFAULT NULL,
  `finish_type` varchar(50) DEFAULT NULL,
  `extra_cost` decimal(12,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `commercial_buyer_guides`
--

CREATE TABLE `commercial_buyer_guides` (
  `guide_id` bigint(20) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `route_type` varchar(100) DEFAULT NULL,
  `fleet_use_case` varchar(150) DEFAULT NULL,
  `seo_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `commercial_permit_data`
--

CREATE TABLE `commercial_permit_data` (
  `permit_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `country_id` int(11) DEFAULT NULL,
  `permit_type` varchar(150) DEFAULT NULL,
  `compliance_status` varchar(100) DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `permit_cost` decimal(15,2) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `comparison_history`
--

CREATE TABLE `comparison_history` (
  `comparison_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_ids_json` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `comparison_slug` varchar(220) DEFAULT NULL,
  `comparison_name` varchar(180) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `comparison_pages`
--

CREATE TABLE `comparison_pages` (
  `page_id` bigint(20) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `compared_variants_json` longtext DEFAULT NULL,
  `seo_score` decimal(5,2) DEFAULT NULL,
  `canonical_region` varchar(100) DEFAULT NULL,
  `language_code` varchar(10) DEFAULT 'en'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `competitor_mapping`
--

CREATE TABLE `competitor_mapping` (
  `mapping_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `competitor_variant_id` bigint(20) NOT NULL,
  `segment_rank` int(11) DEFAULT NULL,
  `price_rank` int(11) DEFAULT NULL,
  `performance_rank` int(11) DEFAULT NULL,
  `efficiency_rank` int(11) DEFAULT NULL,
  `overall_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `competitor_market_tracking`
--

CREATE TABLE `competitor_market_tracking` (
  `competitor_id` bigint(20) NOT NULL,
  `competitor_brand` varchar(255) DEFAULT NULL,
  `competitor_model` varchar(255) DEFAULT NULL,
  `segment` varchar(100) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `avg_price` decimal(15,2) DEFAULT NULL,
  `market_share_score` decimal(5,2) DEFAULT NULL,
  `threat_level` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `compliance_certifications`
--

CREATE TABLE `compliance_certifications` (
  `certification_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `certification_type` varchar(150) DEFAULT NULL,
  `certification_region` varchar(100) DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `authority_name` varchar(150) DEFAULT NULL,
  `status` enum('Active','Expired','Pending','Revoked') DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `compliance_framework`
--

CREATE TABLE `compliance_framework` (
  `compliance_id` bigint(20) NOT NULL,
  `country_id` int(11) DEFAULT NULL,
  `regulation_type` varchar(255) DEFAULT NULL,
  `compliance_requirement` text DEFAULT NULL,
  `affected_vehicle_category` varchar(100) DEFAULT NULL,
  `mandatory_status` tinyint(1) DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `content_localization`
--

CREATE TABLE `content_localization` (
  `localization_id` bigint(20) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `language_code` varchar(10) DEFAULT NULL,
  `localized_title` varchar(255) DEFAULT NULL,
  `localized_description` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `countries`
--

CREATE TABLE `countries` (
  `country_id` int(11) NOT NULL,
  `country_name` varchar(100) NOT NULL,
  `iso_code` varchar(10) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `tax_structure` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tax_structure`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `country_pricing`
--

CREATE TABLE `country_pricing` (
  `pricing_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `country_code` varchar(10) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `ex_showroom_price` decimal(15,2) DEFAULT NULL,
  `on_road_price` decimal(15,2) DEFAULT NULL,
  `tax_rate` decimal(6,2) DEFAULT NULL,
  `subsidy_amount` decimal(15,2) DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `data_freshness_scores`
--

CREATE TABLE `data_freshness_scores` (
  `freshness_id` bigint(20) NOT NULL,
  `source_id` bigint(20) DEFAULT NULL,
  `freshness_score` decimal(5,2) DEFAULT NULL,
  `last_verified` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `data_quality_control`
--

CREATE TABLE `data_quality_control` (
  `quality_id` bigint(20) NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `quality_score` decimal(5,2) DEFAULT NULL,
  `completeness_score` decimal(5,2) DEFAULT NULL,
  `consistency_score` decimal(5,2) DEFAULT NULL,
  `anomaly_flags` text DEFAULT NULL,
  `review_required` tinyint(1) DEFAULT 0,
  `last_checked` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `data_source_governance`
--

CREATE TABLE `data_source_governance` (
  `source_id` int(11) NOT NULL,
  `source_name` varchar(150) DEFAULT NULL,
  `trust_score` decimal(3,2) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `last_crawl` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealers`
--

CREATE TABLE `dealers` (
  `dealer_id` bigint(20) NOT NULL,
  `dealer_name` varchar(150) NOT NULL,
  `dealer_slug` varchar(150) DEFAULT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `contact_number` varchar(50) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `dealer_status` enum('Active','Pending','Suspended','Blocked') DEFAULT 'Pending',
  `sponsored_rank_score` decimal(5,2) DEFAULT NULL,
  `sla_score` decimal(5,2) DEFAULT NULL,
  `lead_conversion_score` decimal(5,2) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `uuid` char(36) DEFAULT NULL,
  `external_api_id` varchar(255) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `commercial_specialist` tinyint(1) DEFAULT 0,
  `performance_score` decimal(5,2) DEFAULT NULL,
  `response_sla_hours` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_city_pages`
--

CREATE TABLE `dealer_city_pages` (
  `page_id` bigint(20) NOT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `city_name` varchar(100) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_inquiries`
--

CREATE TABLE `dealer_inquiries` (
  `inquiry_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `inquiry_type` varchar(100) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `lead_score` decimal(5,2) DEFAULT NULL,
  `assigned_to` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_inventory`
--

CREATE TABLE `dealer_inventory` (
  `inventory_id` bigint(20) NOT NULL,
  `dealer_name` varchar(150) DEFAULT NULL,
  `dealer_location` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) NOT NULL,
  `stock_count` int(11) DEFAULT NULL,
  `price_override` decimal(15,2) DEFAULT NULL,
  `delivery_eta_days` int(11) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `dealer_id` bigint(20) DEFAULT NULL,
  `city_id` int(11) DEFAULT NULL,
  `availability_status` enum('In Stock','Out of Stock','Coming Soon') DEFAULT 'In Stock'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_leads`
--

CREATE TABLE `dealer_leads` (
  `lead_id` bigint(20) NOT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `lead_source` varchar(100) DEFAULT NULL,
  `lead_stage` enum('New','Contacted','Qualified','Converted','Dropped') DEFAULT 'New',
  `lead_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_promotions`
--

CREATE TABLE `dealer_promotions` (
  `promotion_id` bigint(20) NOT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `promotion_type` varchar(100) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `budget` decimal(15,2) DEFAULT NULL,
  `active_status` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_ratings`
--

CREATE TABLE `dealer_ratings` (
  `rating_id` bigint(20) NOT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT NULL,
  `review` text DEFAULT NULL,
  `response_time_score` decimal(5,2) DEFAULT NULL,
  `fulfillment_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_sla_scores`
--

CREATE TABLE `dealer_sla_scores` (
  `sla_score_id` bigint(20) NOT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `response_time_score` decimal(5,2) DEFAULT NULL,
  `fulfillment_score` decimal(5,2) DEFAULT NULL,
  `cancellation_rate` decimal(5,2) DEFAULT NULL,
  `complaint_rate` decimal(5,2) DEFAULT NULL,
  `overall_sla_score` decimal(5,2) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_subscription_plans`
--

CREATE TABLE `dealer_subscription_plans` (
  `subscription_id` bigint(20) NOT NULL,
  `dealer_id` bigint(20) NOT NULL,
  `plan_name` varchar(150) DEFAULT NULL,
  `monthly_fee` decimal(15,2) DEFAULT NULL,
  `lead_limit` int(11) DEFAULT NULL,
  `premium_listing_enabled` tinyint(1) DEFAULT 0,
  `analytics_access` tinyint(1) DEFAULT 0,
  `valid_from` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_subscription_tiers`
--

CREATE TABLE `dealer_subscription_tiers` (
  `tier_id` bigint(20) NOT NULL,
  `tier_name` varchar(100) DEFAULT NULL,
  `monthly_fee` decimal(12,2) DEFAULT NULL,
  `lead_limit` int(11) DEFAULT NULL,
  `featured_listing` tinyint(1) DEFAULT NULL,
  `analytics_access` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealer_tenants`
--

CREATE TABLE `dealer_tenants` (
  `dealer_id` bigint(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `sla_score` decimal(5,2) DEFAULT NULL,
  `subscription_tier` enum('Basic','Pro','Enterprise') DEFAULT 'Basic',
  `is_verified` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `drivetrain_options`
--

CREATE TABLE `drivetrain_options` (
  `drivetrain_id` int(11) NOT NULL,
  `drivetrain_name` varchar(100) NOT NULL,
  `axle_configuration` varchar(50) DEFAULT NULL,
  `front_drive` tinyint(1) DEFAULT 0,
  `rear_drive` tinyint(1) DEFAULT 0,
  `all_wheel_drive` tinyint(1) DEFAULT 0,
  `four_wheel_drive` tinyint(1) DEFAULT 0,
  `torque_vectoring` tinyint(1) DEFAULT 0,
  `differential_lock` tinyint(1) DEFAULT 0,
  `transfer_case_type` varchar(100) DEFAULT NULL,
  `low_range_ratio` decimal(5,2) DEFAULT NULL,
  `gcw_rating_kg` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `duplicate_detection_registry`
--

CREATE TABLE `duplicate_detection_registry` (
  `duplicate_id` bigint(20) NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `primary_entity_id` bigint(20) DEFAULT NULL,
  `duplicate_entity_id` bigint(20) DEFAULT NULL,
  `similarity_score` decimal(5,2) DEFAULT NULL,
  `merge_status` enum('Pending','Merged','Ignored') DEFAULT 'Pending',
  `detected_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `emi_calculator_runs`
--

CREATE TABLE `emi_calculator_runs` (
  `emi_run_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `principal_amount` decimal(15,2) DEFAULT NULL,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `tenure_months` int(11) DEFAULT NULL,
  `monthly_emi` decimal(15,2) DEFAULT NULL,
  `total_interest` decimal(15,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `enterprise_scorecard`
--

CREATE TABLE `enterprise_scorecard` (
  `scorecard_id` bigint(20) NOT NULL,
  `module_name` varchar(255) DEFAULT NULL,
  `architecture_score` decimal(5,2) DEFAULT NULL,
  `scalability_score` decimal(5,2) DEFAULT NULL,
  `monetization_score` decimal(5,2) DEFAULT NULL,
  `ai_readiness_score` decimal(5,2) DEFAULT NULL,
  `global_expansion_score` decimal(5,2) DEFAULT NULL,
  `evaluated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `enterprise_scorecard`
--

INSERT INTO `enterprise_scorecard` (`scorecard_id`, `module_name`, `architecture_score`, `scalability_score`, `monetization_score`, `ai_readiness_score`, `global_expansion_score`, `evaluated_at`) VALUES
(1, 'Autopredator Master Platform', 10.00, 10.00, 10.00, 10.00, 10.00, '2026-04-30 20:32:13');

-- --------------------------------------------------------

--
-- Table structure for table `ev_infrastructure_support`
--

CREATE TABLE `ev_infrastructure_support` (
  `infra_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `charger_type_supported` varchar(255) DEFAULT NULL,
  `charging_network_compatibility_score` decimal(5,2) DEFAULT NULL,
  `avg_fast_charge_time_minutes` int(11) DEFAULT NULL,
  `battery_degradation_risk_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ev_specs`
--

CREATE TABLE `ev_specs` (
  `ev_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `motor_type` varchar(100) DEFAULT NULL,
  `motor_count` int(11) DEFAULT NULL,
  `motor_position` varchar(100) DEFAULT NULL,
  `peak_power_kw` decimal(8,2) DEFAULT NULL,
  `peak_torque_nm` decimal(8,2) DEFAULT NULL,
  `battery_gross_kwh` decimal(8,2) DEFAULT NULL,
  `battery_usable_kwh` decimal(8,2) DEFAULT NULL,
  `battery_chemistry` varchar(100) DEFAULT NULL,
  `architecture_voltage` int(11) DEFAULT NULL,
  `ac_charge_kw` decimal(8,2) DEFAULT NULL,
  `dc_fast_charge_kw` decimal(8,2) DEFAULT NULL,
  `range_wltp_km` decimal(8,2) DEFAULT NULL,
  `range_real_world_km` decimal(8,2) DEFAULT NULL,
  `v2l_supported` tinyint(1) DEFAULT 0,
  `v2g_supported` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `executive_dashboard_cache`
--

CREATE TABLE `executive_dashboard_cache` (
  `dashboard_id` bigint(20) NOT NULL,
  `module_name` varchar(255) DEFAULT NULL,
  `metric_name` varchar(255) DEFAULT NULL,
  `metric_value` decimal(20,4) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `reporting_period` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `expert_reviews`
--

CREATE TABLE `expert_reviews` (
  `review_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `source_name` varchar(150) DEFAULT NULL,
  `review_score` decimal(4,2) DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `pros` text DEFAULT NULL,
  `cons` text DEFAULT NULL,
  `review_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `external_api_registry`
--

CREATE TABLE `external_api_registry` (
  `api_id` bigint(20) NOT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `api_type` varchar(100) DEFAULT NULL,
  `endpoint_reference` text DEFAULT NULL,
  `authentication_method` varchar(100) DEFAULT NULL,
  `sync_frequency_hours` int(11) DEFAULT NULL,
  `active_status` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fake_review_detection`
--

CREATE TABLE `fake_review_detection` (
  `detection_id` bigint(20) NOT NULL,
  `review_id` bigint(20) DEFAULT NULL,
  `fraud_score` decimal(5,2) DEFAULT NULL,
  `flagged` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fcev_specs`
--

CREATE TABLE `fcev_specs` (
  `fcev_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `fuel_cell_stack_type` varchar(100) DEFAULT NULL,
  `stack_power_kw` decimal(8,2) DEFAULT NULL,
  `stack_efficiency_percent` decimal(5,2) DEFAULT NULL,
  `hydrogen_tank_capacity_kg` decimal(8,2) DEFAULT NULL,
  `storage_pressure_bar` int(11) DEFAULT NULL,
  `refuel_time_minutes` decimal(5,2) DEFAULT NULL,
  `motor_power_kw` decimal(8,2) DEFAULT NULL,
  `battery_buffer_kwh` decimal(8,2) DEFAULT NULL,
  `range_km` decimal(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `features`
--

CREATE TABLE `features` (
  `feature_id` bigint(20) NOT NULL,
  `feature_name` varchar(150) NOT NULL,
  `feature_category` enum('Safety','Comfort','Technology','Interior','Exterior','Performance','Convenience') DEFAULT 'Technology',
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `group_id` int(11) DEFAULT NULL,
  `parent_feature_id` bigint(20) DEFAULT NULL,
  `oem_type` enum('OEM','Aftermarket','Dealer Installed') DEFAULT 'OEM',
  `package_level` enum('Base','Mid','Top','Optional','Addon') DEFAULT 'Base',
  `feature_importance_score` decimal(5,2) DEFAULT 0.00,
  `buyer_relevance_score` decimal(5,2) DEFAULT 0.00,
  `compare_priority` int(11) DEFAULT 0,
  `seo_priority` int(11) DEFAULT 0,
  `commercial_relevance_score` decimal(5,2) DEFAULT 0.00,
  `ownership_relevance_score` decimal(5,2) DEFAULT 0.00,
  `future_ready` tinyint(1) DEFAULT 0,
  `feature_code` varchar(150) DEFAULT NULL,
  `feature_slug` varchar(180) DEFAULT NULL,
  `feature_type` enum('Hardware','Software','Service','Package','Safety','Comfort','Convenience','Performance','Commercial') DEFAULT 'Hardware',
  `availability_scope` enum('Standard','Optional','Package','Dealer Installed','Aftermarket') DEFAULT 'Standard',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `voice_assistant_support` tinyint(1) DEFAULT NULL,
  `subscription_locked` tinyint(1) DEFAULT NULL,
  `software_upgradeable` tinyint(1) DEFAULT NULL,
  `cybersecurity_level` varchar(50) DEFAULT NULL,
  `future_proof_score` decimal(5,2) DEFAULT NULL,
  `premium_score` decimal(5,2) DEFAULT NULL,
  `commercial_utility_score` decimal(5,2) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feature_aliases`
--

CREATE TABLE `feature_aliases` (
  `alias_id` bigint(20) NOT NULL,
  `feature_id` bigint(20) NOT NULL,
  `alias_name` varchar(200) NOT NULL,
  `alias_slug` varchar(220) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feature_groups`
--

CREATE TABLE `feature_groups` (
  `group_id` int(11) NOT NULL,
  `group_name` varchar(100) NOT NULL,
  `display_name` varchar(150) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `group_slug` varchar(150) DEFAULT NULL,
  `group_description` text DEFAULT NULL,
  `icon_name` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `feature_groups`
--

INSERT INTO `feature_groups` (`group_id`, `group_name`, `display_name`, `sort_order`, `is_active`, `created_at`, `group_slug`, `group_description`, `icon_name`, `updated_at`) VALUES
(1, 'safety', 'Safety', 1, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(2, 'comfort', 'Comfort', 2, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(3, 'technology', 'Technology', 3, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(4, 'interior', 'Interior', 4, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(5, 'exterior', 'Exterior', 5, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(6, 'convenience', 'Convenience', 6, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(7, 'security', 'Security', 25, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(8, 'utility', 'Utility', 8, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(9, 'performance', 'Performance', 9, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(10, 'ev_specific', 'EV Specific', 10, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(11, 'commercial', 'Commercial', 11, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(12, 'ownership', 'Ownership Support', 12, 1, '2026-04-30 17:53:00', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(20, 'adas', 'ADAS', 13, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(21, 'connectivity', 'Connectivity', 14, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(22, 'lighting', 'Lighting', 15, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(23, 'climate_control', 'Climate Control', 16, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(24, 'wheels_tyres', 'Wheels & Tyres', 17, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(25, 'software', 'Software Features', 18, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(26, 'ota', 'OTA Support', 19, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(27, 'maintenance', 'Maintenance', 20, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(28, 'fleet', 'Fleet Suitability', 21, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(29, 'compliance', 'Compliance', 22, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(30, 'finance', 'Finance', 23, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(31, 'insurance', 'Insurance', 24, 1, '2026-04-30 19:01:07', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(33, 'user_experience', 'User Experience', 26, 1, '2026-04-30 19:06:45', NULL, NULL, NULL, '2026-04-30 19:06:45'),
(34, 'sustainability', 'Sustainability', 27, 1, '2026-04-30 19:06:45', NULL, NULL, NULL, '2026-04-30 19:06:45');

-- --------------------------------------------------------

--
-- Table structure for table `feature_packages`
--

CREATE TABLE `feature_packages` (
  `package_id` bigint(20) NOT NULL,
  `package_name` varchar(150) NOT NULL,
  `package_category` enum('Luxury','Performance','Safety','Off-Road','Commercial','Technology','Fleet') NOT NULL,
  `description` text DEFAULT NULL,
  `package_price` decimal(15,2) DEFAULT NULL,
  `package_slug` varchar(180) DEFAULT NULL,
  `package_level` enum('Base','Mid','Top','Optional','Addon','Fleet','Commercial') DEFAULT 'Optional',
  `group_id` int(11) DEFAULT NULL,
  `oem_type` enum('OEM','Aftermarket','Dealer Installed') DEFAULT 'OEM',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `feature_package_features`
--

CREATE TABLE `feature_package_features` (
  `id` bigint(20) NOT NULL,
  `package_id` bigint(20) NOT NULL,
  `feature_id` bigint(20) NOT NULL,
  `is_standard` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `finance_lender_products`
--

CREATE TABLE `finance_lender_products` (
  `lender_product_id` bigint(20) NOT NULL,
  `lender_name` varchar(150) DEFAULT NULL,
  `bank_name` varchar(150) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `interest_rate_min` decimal(5,2) DEFAULT NULL,
  `interest_rate_max` decimal(5,2) DEFAULT NULL,
  `tenure_min_months` int(11) DEFAULT NULL,
  `tenure_max_months` int(11) DEFAULT NULL,
  `down_payment_min_pct` decimal(5,2) DEFAULT NULL,
  `down_payment_max_pct` decimal(5,2) DEFAULT NULL,
  `commercial_financing` tinyint(1) DEFAULT 0,
  `lease_option` tinyint(1) DEFAULT 0,
  `subscription_model` tinyint(1) DEFAULT 0,
  `preapproved` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `finance_quote_requests`
--

CREATE TABLE `finance_quote_requests` (
  `quote_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `down_payment` decimal(15,2) DEFAULT NULL,
  `tenure_months` int(11) DEFAULT NULL,
  `credit_score_band` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `bank_preference` varchar(150) DEFAULT NULL,
  `request_status` enum('Open','Quoted','Approved','Rejected','Expired') DEFAULT 'Open'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `financing_products`
--

CREATE TABLE `financing_products` (
  `finance_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `lender_name` varchar(150) DEFAULT NULL,
  `interest_rate` decimal(5,2) DEFAULT NULL,
  `tenure_months` int(11) DEFAULT NULL,
  `down_payment_percentage` decimal(5,2) DEFAULT NULL,
  `emi_estimate` decimal(15,2) DEFAULT NULL,
  `processing_fee` decimal(12,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `bank_name` varchar(150) DEFAULT NULL,
  `eligibility_score` decimal(5,2) DEFAULT NULL,
  `preapproved` tinyint(1) DEFAULT 0,
  `lease_option` tinyint(1) DEFAULT 0,
  `subscription_model` tinyint(1) DEFAULT 0,
  `commercial_financing` tinyint(1) DEFAULT 0,
  `min_credit_score` int(11) DEFAULT NULL,
  `max_credit_score` int(11) DEFAULT NULL,
  `approval_probability` decimal(5,2) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fintech_lenders`
--

CREATE TABLE `fintech_lenders` (
  `lender_id` int(11) NOT NULL,
  `bank_name` varchar(150) DEFAULT NULL,
  `interest_rate_base` decimal(5,2) DEFAULT NULL,
  `processing_fee_pct` decimal(5,2) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fleet_guides`
--

CREATE TABLE `fleet_guides` (
  `guide_id` bigint(20) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `tco_focus` varchar(100) DEFAULT NULL,
  `seo_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fleet_management_data`
--

CREATE TABLE `fleet_management_data` (
  `fleet_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `average_operating_cost` decimal(15,2) DEFAULT NULL,
  `maintenance_interval_km` int(11) DEFAULT NULL,
  `payload_efficiency_score` decimal(5,2) DEFAULT NULL,
  `permit_category` varchar(100) DEFAULT NULL,
  `route_type` varchar(100) DEFAULT NULL,
  `annual_profitability_score` decimal(5,2) DEFAULT NULL,
  `fleet_recommendation_grade` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fleet_operations`
--

CREATE TABLE `fleet_operations` (
  `fleet_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `route_type` varchar(100) DEFAULT NULL,
  `daily_profitability` decimal(15,2) DEFAULT NULL,
  `payload_efficiency` decimal(5,2) DEFAULT NULL,
  `downtime_risk` decimal(5,2) DEFAULT NULL,
  `annual_roi` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fleet_profitability_scores`
--

CREATE TABLE `fleet_profitability_scores` (
  `score_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `payload_score` decimal(5,2) DEFAULT NULL,
  `route_profitability_score` decimal(5,2) DEFAULT NULL,
  `uptime_score` decimal(5,2) DEFAULT NULL,
  `downtime_score` decimal(5,2) DEFAULT NULL,
  `maintenance_score` decimal(5,2) DEFAULT NULL,
  `resale_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fleet_tco_scores`
--

CREATE TABLE `fleet_tco_scores` (
  `score_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `payload_score` decimal(5,2) DEFAULT NULL,
  `uptime_score` decimal(5,2) DEFAULT NULL,
  `downtime_score` decimal(5,2) DEFAULT NULL,
  `maintenance_score` decimal(5,2) DEFAULT NULL,
  `route_profitability_score` decimal(5,2) DEFAULT NULL,
  `commercial_resale_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fuel_type_pages`
--

CREATE TABLE `fuel_type_pages` (
  `page_id` bigint(20) NOT NULL,
  `slug` varchar(220) NOT NULL,
  `title` varchar(255) NOT NULL,
  `fuel_type` varchar(50) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_attribute_taxonomy`
--

CREATE TABLE `global_attribute_taxonomy` (
  `taxonomy_id` bigint(20) NOT NULL,
  `attribute_name` varchar(255) DEFAULT NULL,
  `normalized_attribute_key` varchar(255) DEFAULT NULL,
  `attribute_group` varchar(100) DEFAULT NULL,
  `global_standard_unit` varchar(50) DEFAULT NULL,
  `regulatory_classification` varchar(100) DEFAULT NULL,
  `commercial_priority_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hybrid_specs`
--

CREATE TABLE `hybrid_specs` (
  `hybrid_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `hybrid_type` varchar(50) DEFAULT NULL,
  `hybrid_architecture` varchar(50) DEFAULT NULL,
  `combined_power_hp` decimal(8,2) DEFAULT NULL,
  `combined_torque_nm` decimal(8,2) DEFAULT NULL,
  `motor_count` int(11) DEFAULT NULL,
  `battery_gross_kwh` decimal(8,2) DEFAULT NULL,
  `battery_usable_kwh` decimal(8,2) DEFAULT NULL,
  `battery_chemistry` varchar(100) DEFAULT NULL,
  `nominal_voltage` int(11) DEFAULT NULL,
  `regenerative_braking_type` varchar(100) DEFAULT NULL,
  `ev_only_range_km` decimal(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ice_engine_specs`
--

CREATE TABLE `ice_engine_specs` (
  `engine_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `engine_code` varchar(100) DEFAULT NULL,
  `fuel_type` varchar(50) DEFAULT NULL,
  `engine_layout` varchar(50) DEFAULT NULL,
  `displacement_cc` int(11) DEFAULT NULL,
  `cylinder_count` int(11) DEFAULT NULL,
  `valves_per_cylinder` int(11) DEFAULT NULL,
  `compression_ratio` decimal(5,2) DEFAULT NULL,
  `bore_mm` decimal(6,2) DEFAULT NULL,
  `stroke_mm` decimal(6,2) DEFAULT NULL,
  `induction_type` varchar(50) DEFAULT NULL,
  `turbo_type` varchar(100) DEFAULT NULL,
  `max_boost_bar` decimal(5,2) DEFAULT NULL,
  `fuel_injection_type` varchar(100) DEFAULT NULL,
  `max_power_hp` decimal(8,2) DEFAULT NULL,
  `max_torque_nm` decimal(8,2) DEFAULT NULL,
  `redline_rpm` int(11) DEFAULT NULL,
  `fuel_tank_capacity_l` decimal(8,2) DEFAULT NULL,
  `fuel_efficiency_kmpl` decimal(8,2) DEFAULT NULL,
  `emission_standard` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `insurance_addon_products`
--

CREATE TABLE `insurance_addon_products` (
  `addon_id` bigint(20) NOT NULL,
  `provider_name` varchar(150) DEFAULT NULL,
  `addon_name` varchar(150) DEFAULT NULL,
  `addon_category` varchar(100) DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `commercial_available` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `insurance_comparison_results`
--

CREATE TABLE `insurance_comparison_results` (
  `comparison_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `provider_name` varchar(150) DEFAULT NULL,
  `policy_type` varchar(100) DEFAULT NULL,
  `annual_premium` decimal(15,2) DEFAULT NULL,
  `zero_dep` tinyint(1) DEFAULT 0,
  `roadside_assistance` tinyint(1) DEFAULT 0,
  `claims_score` decimal(5,2) DEFAULT NULL,
  `commercial_coverage` tinyint(1) DEFAULT 0,
  `renewal_support` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `insurance_finance_marketplace`
--

CREATE TABLE `insurance_finance_marketplace` (
  `offer_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `provider_name` varchar(255) DEFAULT NULL,
  `offer_type` enum('Insurance','Loan','Lease','Warranty') DEFAULT NULL,
  `interest_rate` decimal(6,2) DEFAULT NULL,
  `emi_estimate` decimal(15,2) DEFAULT NULL,
  `coverage_score` decimal(5,2) DEFAULT NULL,
  `active_status` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `insurance_products`
--

CREATE TABLE `insurance_products` (
  `insurance_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `provider_name` varchar(150) DEFAULT NULL,
  `policy_type` varchar(100) DEFAULT NULL,
  `annual_premium` decimal(15,2) DEFAULT NULL,
  `zero_dep` tinyint(1) DEFAULT 0,
  `roadside_assistance` tinyint(1) DEFAULT 0,
  `claim_settlement_ratio` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `add_on_packages` text DEFAULT NULL,
  `claims_score` decimal(5,2) DEFAULT NULL,
  `commercial_coverage` tinyint(1) DEFAULT 0,
  `renewal_support` tinyint(1) DEFAULT 0,
  `addon_bundles` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `insurance_quote_requests`
--

CREATE TABLE `insurance_quote_requests` (
  `quote_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `coverage_type` varchar(100) DEFAULT NULL,
  `zero_dep_required` tinyint(1) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `provider_preference` varchar(150) DEFAULT NULL,
  `request_status` enum('Open','Quoted','Purchased','Rejected','Expired') DEFAULT 'Open'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `insurance_renewal_tasks`
--

CREATE TABLE `insurance_renewal_tasks` (
  `renewal_task_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `provider_name` varchar(150) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `reminder_date` date DEFAULT NULL,
  `status` enum('Pending','Reminded','Renewed','Expired') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `interior_specs`
--

CREATE TABLE `interior_specs` (
  `interior_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `upholstery_type` varchar(100) DEFAULT NULL,
  `seat_material` varchar(100) DEFAULT NULL,
  `climate_zones` int(11) DEFAULT NULL,
  `infotainment_screen_inches` decimal(5,2) DEFAULT NULL,
  `digital_cluster_inches` decimal(5,2) DEFAULT NULL,
  `speaker_count` int(11) DEFAULT NULL,
  `android_auto` tinyint(1) DEFAULT 0,
  `apple_carplay` tinyint(1) DEFAULT 0,
  `wireless_charging` tinyint(1) DEFAULT 0,
  `sunroof_type` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_live`
--

CREATE TABLE `inventory_live` (
  `stock_id` bigint(20) NOT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `price_override` decimal(15,2) DEFAULT NULL,
  `stock_count` int(11) DEFAULT 0,
  `is_promoted` tinyint(1) DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lead_funnel`
--

CREATE TABLE `lead_funnel` (
  `lead_id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `intent_type` enum('Test Drive','Finance Quote','Booking') DEFAULT NULL,
  `ai_conversion_score` decimal(5,2) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `attribution_source` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lead_management`
--

CREATE TABLE `lead_management` (
  `lead_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `lead_source` varchar(150) DEFAULT NULL,
  `customer_name` varchar(255) DEFAULT NULL,
  `customer_phone` varchar(50) DEFAULT NULL,
  `customer_email` varchar(255) DEFAULT NULL,
  `lead_status` enum('New','Contacted','Qualified','Converted','Closed') DEFAULT 'New',
  `lead_score` decimal(5,2) DEFAULT NULL,
  `estimated_value` decimal(15,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `legacy_car_models_backup`
--

CREATE TABLE `legacy_car_models_backup` (
  `make_id` int(11) NOT NULL,
  `make` varchar(150) NOT NULL,
  `model_id` bigint(20) NOT NULL,
  `model` varchar(150) NOT NULL,
  `fuel_option` varchar(100) DEFAULT NULL,
  `power_hp` decimal(8,2) DEFAULT NULL,
  `fuel_efficiency_kmpl` decimal(8,2) DEFAULT NULL,
  `base_price` decimal(15,2) DEFAULT NULL,
  `top_price` decimal(15,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `legacy_car_variants_backup`
--

CREATE TABLE `legacy_car_variants_backup` (
  `variant_id` bigint(20) NOT NULL,
  `variant_specs_id` bigint(20) NOT NULL,
  `make_id` int(11) NOT NULL,
  `model_id` bigint(20) NOT NULL,
  `variant_name` varchar(200) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lender_products`
--

CREATE TABLE `lender_products` (
  `lender_id` int(11) NOT NULL,
  `bank_name` varchar(150) DEFAULT NULL,
  `base_interest_rate` decimal(5,2) DEFAULT NULL,
  `max_tenure_months` int(11) DEFAULT 84,
  `eligibility_criteria_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`eligibility_criteria_json`)),
  `is_integrated_api` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `maintenance_guides`
--

CREATE TABLE `maintenance_guides` (
  `guide_id` bigint(20) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manual_audit_queue`
--

CREATE TABLE `manual_audit_queue` (
  `audit_id` bigint(20) NOT NULL,
  `source_id` bigint(20) DEFAULT NULL,
  `issue_type` varchar(100) DEFAULT NULL,
  `issue_details` text DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `market_demand_forecasts`
--

CREATE TABLE `market_demand_forecasts` (
  `forecast_id` bigint(20) NOT NULL,
  `model_id` bigint(20) DEFAULT NULL,
  `demand_score` decimal(5,2) DEFAULT NULL,
  `resale_projection` decimal(15,2) DEFAULT NULL,
  `price_forecast` decimal(15,2) DEFAULT NULL,
  `inventory_pressure_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `market_regions`
--

CREATE TABLE `market_regions` (
  `region_id` int(11) NOT NULL,
  `region_name` varchar(100) NOT NULL,
  `country` varchar(100) DEFAULT NULL,
  `taxation_rules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`taxation_rules`)),
  `subsidy_rules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`subsidy_rules`)),
  `emissions_regulations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`emissions_regulations`)),
  `safety_regulations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`safety_regulations`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `market_trend_forecasting`
--

CREATE TABLE `market_trend_forecasting` (
  `trend_id` bigint(20) NOT NULL,
  `vehicle_segment` varchar(100) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `forecast_period_months` int(11) DEFAULT NULL,
  `predicted_demand_growth` decimal(8,2) DEFAULT NULL,
  `pricing_shift_percent` decimal(8,2) DEFAULT NULL,
  `competitor_pressure_score` decimal(5,2) DEFAULT NULL,
  `generated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migration_audit_log`
--

CREATE TABLE `migration_audit_log` (
  `audit_id` bigint(20) NOT NULL,
  `migration_phase` varchar(255) DEFAULT NULL,
  `migration_status` varchar(100) DEFAULT NULL,
  `executed_by` varchar(255) DEFAULT NULL,
  `execution_notes` text DEFAULT NULL,
  `executed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `migration_audit_log`
--

INSERT INTO `migration_audit_log` (`audit_id`, `migration_phase`, `migration_status`, `executed_by`, `execution_notes`, `executed_at`) VALUES
(1, 'Phase 1-10 Master Upgrade', 'Completed', 'OpenAI GPT', 'Autopredator upgraded to enterprise-grade 10/10 schema', '2026-04-30 20:31:12'),
(2, 'Phase 11 Enterprise Enhancement', 'Completed', 'OpenAI GPT', 'Autopredator upgraded to full investor-grade automotive intelligence ecosystem', '2026-04-30 20:32:13'),
(3, 'Phase 12 Global Optimization', 'Completed', 'OpenAI GPT', 'Autopredator fully transformed into global automotive intelligence + SaaS + fleet + marketplace ecosystem', '2026-04-30 20:33:17');

-- --------------------------------------------------------

--
-- Table structure for table `models`
--

CREATE TABLE `models` (
  `model_id` bigint(20) NOT NULL,
  `brand_id` int(11) NOT NULL,
  `model_name` varchar(150) NOT NULL,
  `slug` varchar(150) DEFAULT NULL,
  `generation` varchar(100) DEFAULT NULL,
  `facelift_code` varchar(100) DEFAULT NULL,
  `chassis_code` varchar(100) DEFAULT NULL,
  `body_type` varchar(100) DEFAULT NULL,
  `segment` varchar(50) DEFAULT NULL,
  `seating_layout` varchar(50) DEFAULT NULL,
  `door_count` int(11) DEFAULT NULL,
  `launch_year` year(4) DEFAULT NULL,
  `discontinuation_year` year(4) DEFAULT NULL,
  `platform_name` varchar(150) DEFAULT NULL,
  `manufacturing_plant` varchar(150) DEFAULT NULL,
  `vehicle_category` enum('Passenger Vehicle','SUV','Pickup','LCV','MCV','HCV','Bus','Coach','Agricultural','Construction','Defense') NOT NULL DEFAULT 'Passenger Vehicle',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `architecture_type` enum('Monocoque','Body-on-Frame','Skateboard','Spaceframe') DEFAULT NULL,
  `platform_generation` varchar(100) DEFAULT NULL,
  `facelift_cycle_years` int(11) DEFAULT NULL,
  `global_ncap_rating` varchar(50) DEFAULT NULL,
  `india_ncap_rating` varchar(50) DEFAULT NULL,
  `euro_ncap_rating` varchar(50) DEFAULT NULL,
  `iiHS_rating` varchar(50) DEFAULT NULL,
  `target_demographic` varchar(150) DEFAULT NULL,
  `lifecycle_status` enum('Concept','Upcoming','Active','Facelift','Discontinued') DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `segment_id` int(11) DEFAULT NULL,
  `seo_slug` varchar(255) DEFAULT NULL,
  `uuid` char(36) DEFAULT NULL,
  `external_api_id` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `model_pages`
--

CREATE TABLE `model_pages` (
  `page_id` bigint(20) NOT NULL,
  `model_id` bigint(20) DEFAULT NULL,
  `slug` varchar(220) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` longtext DEFAULT NULL,
  `target_segment` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oem_partnership_registry`
--

CREATE TABLE `oem_partnership_registry` (
  `partnership_id` bigint(20) NOT NULL,
  `brand_id` bigint(20) DEFAULT NULL,
  `partnership_level` varchar(100) DEFAULT NULL,
  `api_data_access` tinyint(1) DEFAULT 0,
  `direct_feed_enabled` tinyint(1) DEFAULT 0,
  `revenue_share_percent` decimal(6,2) DEFAULT NULL,
  `active_status` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `optional_accessories`
--

CREATE TABLE `optional_accessories` (
  `accessory_id` bigint(20) NOT NULL,
  `accessory_name` varchar(150) NOT NULL,
  `accessory_category` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `accessory_price` decimal(12,2) DEFAULT NULL,
  `slug` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ownership_calculators`
--

CREATE TABLE `ownership_calculators` (
  `calculator_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `annual_running_km` int(11) DEFAULT NULL,
  `fuel_price` decimal(15,2) DEFAULT NULL,
  `estimated_monthly_emi` decimal(15,2) DEFAULT NULL,
  `estimated_monthly_fuel_cost` decimal(15,2) DEFAULT NULL,
  `estimated_monthly_maintenance` decimal(15,2) DEFAULT NULL,
  `estimated_monthly_insurance` decimal(15,2) DEFAULT NULL,
  `total_monthly_cost` decimal(15,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ownership_cost_history`
--

CREATE TABLE `ownership_cost_history` (
  `cost_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `region_id` int(11) DEFAULT NULL,
  `annual_fuel_cost` decimal(15,2) DEFAULT NULL,
  `annual_service_cost` decimal(15,2) DEFAULT NULL,
  `annual_insurance_cost` decimal(15,2) DEFAULT NULL,
  `depreciation_rate` decimal(5,2) DEFAULT NULL,
  `resale_value_estimate` decimal(15,2) DEFAULT NULL,
  `effective_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ownership_financial_forecasting`
--

CREATE TABLE `ownership_financial_forecasting` (
  `forecast_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `ownership_period_years` int(11) DEFAULT NULL,
  `projected_total_cost` decimal(15,2) DEFAULT NULL,
  `projected_resale_value` decimal(15,2) DEFAULT NULL,
  `projected_roi_score` decimal(5,2) DEFAULT NULL,
  `insurance_projection` decimal(15,2) DEFAULT NULL,
  `maintenance_projection` decimal(15,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ownership_specs`
--

CREATE TABLE `ownership_specs` (
  `ownership_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `standard_warranty_years` int(11) DEFAULT NULL,
  `standard_warranty_km` int(11) DEFAULT NULL,
  `battery_warranty_years` int(11) DEFAULT NULL,
  `service_interval_months` int(11) DEFAULT NULL,
  `service_interval_km` int(11) DEFAULT NULL,
  `free_service_count` int(11) DEFAULT 0,
  `roadside_assistance_years` int(11) DEFAULT NULL,
  `estimated_annual_maintenance_cost` decimal(12,2) DEFAULT NULL,
  `insurance_estimate_new` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `performance_specs`
--

CREATE TABLE `performance_specs` (
  `performance_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `zero_to_60_kmph` decimal(6,2) DEFAULT NULL,
  `zero_to_100_kmph` decimal(6,2) DEFAULT NULL,
  `zero_to_200_kmph` decimal(6,2) DEFAULT NULL,
  `quarter_mile_time` decimal(6,2) DEFAULT NULL,
  `top_speed_kmph` decimal(6,2) DEFAULT NULL,
  `braking_100_0_m` decimal(6,2) DEFAULT NULL,
  `drag_coefficient` decimal(5,3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permit_compliance_rules`
--

CREATE TABLE `permit_compliance_rules` (
  `rule_id` bigint(20) NOT NULL,
  `region_id` int(11) DEFAULT NULL,
  `vehicle_category` varchar(100) DEFAULT NULL,
  `permit_type` varchar(150) DEFAULT NULL,
  `compliance_notes` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `platform_global_score`
--

CREATE TABLE `platform_global_score` (
  `score_id` bigint(20) NOT NULL,
  `total_variants` bigint(20) DEFAULT NULL,
  `total_brands` bigint(20) DEFAULT NULL,
  `total_markets` bigint(20) DEFAULT NULL,
  `ai_automation_score` decimal(5,2) DEFAULT NULL,
  `monetization_score` decimal(5,2) DEFAULT NULL,
  `seo_authority_score` decimal(5,2) DEFAULT NULL,
  `fleet_market_score` decimal(5,2) DEFAULT NULL,
  `enterprise_readiness_score` decimal(5,2) DEFAULT NULL,
  `calculated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `platform_global_score`
--

INSERT INTO `platform_global_score` (`score_id`, `total_variants`, `total_brands`, `total_markets`, `ai_automation_score`, `monetization_score`, `seo_authority_score`, `fleet_market_score`, `enterprise_readiness_score`, `calculated_at`) VALUES
(1, 0, 0, 0, 10.00, 10.00, 10.00, 10.00, 10.00, '2026-04-30 20:33:17');

-- --------------------------------------------------------

--
-- Table structure for table `popular_comparison_cache`
--

CREATE TABLE `popular_comparison_cache` (
  `comparison_id` bigint(20) NOT NULL,
  `variant_a` bigint(20) DEFAULT NULL,
  `variant_b` bigint(20) DEFAULT NULL,
  `comparison_count` bigint(20) DEFAULT NULL,
  `conversion_rate` decimal(5,2) DEFAULT NULL,
  `seo_priority_score` decimal(5,2) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `powertrain_configs`
--

CREATE TABLE `powertrain_configs` (
  `config_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `type` enum('ICE','EV','HEV','PHEV','FCEV','CNG','LPG') NOT NULL,
  `is_primary` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `powertrain_ev_details`
--

CREATE TABLE `powertrain_ev_details` (
  `config_id` bigint(20) NOT NULL,
  `battery_usable_kwh` decimal(10,2) DEFAULT NULL,
  `battery_chemistry` varchar(50) DEFAULT NULL,
  `voltage_architecture` int(11) DEFAULT NULL,
  `max_dc_charge_rate_kw` int(11) DEFAULT NULL,
  `v2l_support` tinyint(1) DEFAULT 0,
  `regen_levels` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `powertrain_fcev_details`
--

CREATE TABLE `powertrain_fcev_details` (
  `config_id` bigint(20) NOT NULL,
  `h2_tank_capacity_kg` decimal(10,2) DEFAULT NULL,
  `stack_power_kw` int(11) DEFAULT NULL,
  `refuel_time_mins` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `powertrain_types`
--

CREATE TABLE `powertrain_types` (
  `powertrain_type_id` int(11) NOT NULL,
  `powertrain_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `powertrain_types`
--

INSERT INTO `powertrain_types` (`powertrain_type_id`, `powertrain_name`, `description`) VALUES
(1, 'ICE', 'Internal Combustion Engine'),
(2, 'MHEV', 'Mild Hybrid'),
(3, 'HEV', 'Hybrid Electric Vehicle'),
(4, 'PHEV', 'Plug-in Hybrid Electric Vehicle'),
(5, 'EREV', 'Extended Range Electric Vehicle'),
(6, 'EV', 'Battery Electric Vehicle'),
(7, 'FCEV', 'Fuel Cell Electric Vehicle'),
(8, 'CNG', 'Compressed Natural Gas'),
(9, 'LNG', 'Liquified Natural Gas');

-- --------------------------------------------------------

--
-- Table structure for table `predictive_maintenance_data`
--

CREATE TABLE `predictive_maintenance_data` (
  `maintenance_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `avg_service_interval_km` int(11) DEFAULT NULL,
  `avg_annual_service_cost` decimal(15,2) DEFAULT NULL,
  `high_risk_components` text DEFAULT NULL,
  `predicted_failure_probability` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `raw_vehicle_data`
--

CREATE TABLE `raw_vehicle_data` (
  `raw_id` bigint(20) NOT NULL,
  `source_id` bigint(20) DEFAULT NULL,
  `raw_json` longtext DEFAULT NULL,
  `scrape_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `processing_status` enum('Pending','Processed','Failed','Manual Review') DEFAULT 'Pending',
  `processing_version` varchar(50) DEFAULT NULL,
  `ai_processed` tinyint(1) DEFAULT 0,
  `validation_status` enum('Pending','Validated','Rejected') DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recall_history`
--

CREATE TABLE `recall_history` (
  `recall_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `recall_title` varchar(255) DEFAULT NULL,
  `recall_description` text DEFAULT NULL,
  `severity_level` varchar(50) DEFAULT NULL,
  `recall_date` date DEFAULT NULL,
  `regulatory_body` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recommendation_personalization`
--

CREATE TABLE `recommendation_personalization` (
  `recommendation_id` bigint(20) NOT NULL,
  `user_profile_type` varchar(100) DEFAULT NULL,
  `budget_range_min` decimal(15,2) DEFAULT NULL,
  `budget_range_max` decimal(15,2) DEFAULT NULL,
  `vehicle_preference_type` varchar(100) DEFAULT NULL,
  `commercial_use_case` varchar(255) DEFAULT NULL,
  `ai_match_confidence` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `regional_market_data`
--

CREATE TABLE `regional_market_data` (
  `market_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `country_id` int(11) DEFAULT NULL,
  `city_name` varchar(100) DEFAULT NULL,
  `demand_score` decimal(5,2) DEFAULT NULL,
  `avg_wait_time_days` int(11) DEFAULT NULL,
  `dealership_density_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reliability_scores`
--

CREATE TABLE `reliability_scores` (
  `reliability_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `reliability_score` decimal(5,2) DEFAULT NULL,
  `maintenance_cost_index` decimal(5,2) DEFAULT NULL,
  `known_issue_count` int(11) DEFAULT NULL,
  `predicted_resale_value` decimal(5,2) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `route_profiles`
--

CREATE TABLE `route_profiles` (
  `route_profile_id` bigint(20) NOT NULL,
  `route_name` varchar(150) DEFAULT NULL,
  `terrain_type` varchar(100) DEFAULT NULL,
  `avg_daily_distance_km` int(11) DEFAULT NULL,
  `payload_class` varchar(100) DEFAULT NULL,
  `profitability_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `distance_band` varchar(100) DEFAULT NULL,
  `fuel_efficiency_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `route_profitability_data`
--

CREATE TABLE `route_profitability_data` (
  `route_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `route_category` varchar(100) DEFAULT NULL,
  `avg_fuel_cost` decimal(15,2) DEFAULT NULL,
  `avg_maintenance_cost` decimal(15,2) DEFAULT NULL,
  `estimated_monthly_revenue` decimal(15,2) DEFAULT NULL,
  `profitability_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `safety_specs`
--

CREATE TABLE `safety_specs` (
  `safety_id` bigint(20) NOT NULL,
  `config_id` bigint(20) NOT NULL,
  `airbag_count` int(11) DEFAULT NULL,
  `abs` tinyint(1) DEFAULT 0,
  `esc` tinyint(1) DEFAULT 0,
  `traction_control` tinyint(1) DEFAULT 0,
  `hill_hold` tinyint(1) DEFAULT 0,
  `adas_level` varchar(50) DEFAULT NULL,
  `radar_count` int(11) DEFAULT NULL,
  `camera_count` int(11) DEFAULT NULL,
  `lidar_count` int(11) DEFAULT NULL,
  `ncap_rating` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `saved_searches`
--

CREATE TABLE `saved_searches` (
  `search_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) NOT NULL,
  `search_query` text DEFAULT NULL,
  `filters_json` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `search_slug` varchar(220) DEFAULT NULL,
  `search_name` varchar(180) DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schema_change_log`
--

CREATE TABLE `schema_change_log` (
  `change_id` bigint(20) NOT NULL,
  `table_name` varchar(150) DEFAULT NULL,
  `change_type` varchar(100) DEFAULT NULL,
  `sql_applied` longtext DEFAULT NULL,
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `applied_by` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schema_versions`
--

CREATE TABLE `schema_versions` (
  `version_id` bigint(20) NOT NULL,
  `version_name` varchar(150) NOT NULL,
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `applied_by` varchar(150) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `schema_versions`
--

INSERT INTO `schema_versions` (`version_id`, `version_name`, `applied_at`, `applied_by`, `notes`) VALUES
(1, 'Autopredator Enterprise 10.0', '2026-04-30 20:31:12', 'OpenAI GPT', 'Full enterprise normalization including AI governance, SEO expansion, fleet dominance, marketplace monetization, global pricing, and advanced analytics');

-- --------------------------------------------------------

--
-- Table structure for table `schema_version_control`
--

CREATE TABLE `schema_version_control` (
  `version_id` bigint(20) NOT NULL,
  `version_name` varchar(100) DEFAULT NULL,
  `migration_notes` longtext DEFAULT NULL,
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `applied_by` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `schema_version_control`
--

INSERT INTO `schema_version_control` (`version_id`, `version_name`, `migration_notes`, `applied_at`, `applied_by`) VALUES
(1, 'Autopredator Enterprise 10.0', 'Full normalization, AI governance, SEO scaling, monetization, global readiness', '2026-04-30 20:21:47', 'OpenAI GPT');

-- --------------------------------------------------------

--
-- Table structure for table `scraper_orchestration_registry`
--

CREATE TABLE `scraper_orchestration_registry` (
  `scraper_id` bigint(20) NOT NULL,
  `source_name` varchar(255) DEFAULT NULL,
  `source_type` varchar(100) DEFAULT NULL,
  `extraction_priority` int(11) DEFAULT NULL,
  `success_rate` decimal(5,2) DEFAULT NULL,
  `avg_latency_ms` decimal(15,2) DEFAULT NULL,
  `anti_bot_risk_score` decimal(5,2) DEFAULT NULL,
  `automation_level` varchar(50) DEFAULT NULL,
  `active_status` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `scrape_logs`
--

CREATE TABLE `scrape_logs` (
  `log_id` bigint(20) NOT NULL,
  `source_id` bigint(20) DEFAULT NULL,
  `target_table` varchar(150) DEFAULT NULL,
  `scrape_status` enum('Success','Failed','Partial','Validation Error') DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `records_processed` int(11) DEFAULT NULL,
  `last_scraped_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL,
  `processing_stage` varchar(100) DEFAULT NULL,
  `error_code` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `scrape_sources`
--

CREATE TABLE `scrape_sources` (
  `source_id` bigint(20) NOT NULL,
  `source_name` varchar(150) NOT NULL,
  `source_url` varchar(500) DEFAULT NULL,
  `source_type` enum('OEM','Dealer','Government','Review','Marketplace','Manual') DEFAULT NULL,
  `trust_score` decimal(5,2) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `source_region` varchar(100) DEFAULT NULL,
  `source_language` varchar(50) DEFAULT NULL,
  `api_available` tinyint(1) DEFAULT 0,
  `crawl_frequency_hours` int(11) DEFAULT 24
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `search_analytics_cache`
--

CREATE TABLE `search_analytics_cache` (
  `cache_id` bigint(20) NOT NULL,
  `search_query` varchar(500) DEFAULT NULL,
  `search_type` varchar(100) DEFAULT NULL,
  `result_count` int(11) DEFAULT NULL,
  `avg_click_rate` decimal(5,2) DEFAULT NULL,
  `monetization_value` decimal(15,2) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `search_optimized_variants`
--

CREATE TABLE `search_optimized_variants` (
  `variant_id` bigint(20) NOT NULL,
  `full_display_name` varchar(255) DEFAULT NULL,
  `brand_name` varchar(100) DEFAULT NULL,
  `model_name` varchar(150) DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `fuel_type` varchar(50) DEFAULT NULL,
  `powertrain_type` varchar(50) DEFAULT NULL,
  `is_ev` tinyint(1) DEFAULT NULL,
  `is_upcoming` tinyint(1) DEFAULT NULL,
  `search_vector` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `segment_pages`
--

CREATE TABLE `segment_pages` (
  `page_id` bigint(20) NOT NULL,
  `slug` varchar(220) NOT NULL,
  `title` varchar(255) NOT NULL,
  `segment_name` varchar(100) DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seo_content_pages`
--

CREATE TABLE `seo_content_pages` (
  `page_id` bigint(20) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `title` varchar(255) NOT NULL,
  `meta_description` text DEFAULT NULL,
  `content` longtext DEFAULT NULL,
  `target_segment` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seo_content_registry`
--

CREATE TABLE `seo_content_registry` (
  `page_id` bigint(20) NOT NULL,
  `entity_type` enum('Brand','Model','Variant','Comparison','Guide') DEFAULT NULL,
  `entity_id` bigint(20) DEFAULT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `canonical_url` varchar(255) DEFAULT NULL,
  `ai_generated_summary` text DEFAULT NULL,
  `last_crawl_status` varchar(50) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `language_code` varchar(10) DEFAULT 'en',
  `page_type` varchar(100) DEFAULT NULL,
  `freshness_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seo_keyword_clusters`
--

CREATE TABLE `seo_keyword_clusters` (
  `cluster_id` bigint(20) NOT NULL,
  `target_page_slug` varchar(220) DEFAULT NULL,
  `keyword` varchar(255) DEFAULT NULL,
  `search_volume` int(11) DEFAULT NULL,
  `ranking_position` int(11) DEFAULT NULL,
  `intent_type` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `seo_page_performance`
--

CREATE TABLE `seo_page_performance` (
  `performance_id` bigint(20) NOT NULL,
  `page_id` bigint(20) DEFAULT NULL,
  `page_type` varchar(100) DEFAULT NULL,
  `impressions` bigint(20) DEFAULT NULL,
  `clicks` bigint(20) DEFAULT NULL,
  `ctr` decimal(8,4) DEFAULT NULL,
  `avg_position` decimal(8,2) DEFAULT NULL,
  `region_id` int(11) DEFAULT NULL,
  `tracked_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `software_capabilities`
--

CREATE TABLE `software_capabilities` (
  `software_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `os_platform` varchar(100) DEFAULT NULL,
  `ota_updates` tinyint(1) DEFAULT NULL,
  `app_store_support` tinyint(1) DEFAULT NULL,
  `subscription_features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`subscription_features`)),
  `cybersecurity_rating` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `source_conflict_resolution`
--

CREATE TABLE `source_conflict_resolution` (
  `conflict_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `attribute_id` bigint(20) DEFAULT NULL,
  `conflicting_sources_json` longtext DEFAULT NULL,
  `resolved_value` text DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_attributes`
--

CREATE TABLE `spec_attributes` (
  `attribute_id` bigint(20) NOT NULL,
  `category_id` int(11) NOT NULL,
  `attribute_name` varchar(150) NOT NULL,
  `display_label` varchar(200) NOT NULL,
  `data_type` enum('text','number','boolean','enum','date','json') NOT NULL DEFAULT 'text',
  `unit` varchar(50) DEFAULT NULL,
  `filterable` tinyint(1) NOT NULL DEFAULT 1,
  `comparable` tinyint(1) NOT NULL DEFAULT 1,
  `show_on_card` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `attribute_slug` varchar(180) DEFAULT NULL,
  `category_group` varchar(150) DEFAULT NULL,
  `source_priority` int(11) NOT NULL DEFAULT 0,
  `data_precision` int(11) DEFAULT NULL,
  `display_order_override` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `international_name` varchar(200) DEFAULT NULL,
  `regulatory_required` tinyint(1) DEFAULT 0,
  `commercial_relevance_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_categories`
--

CREATE TABLE `spec_categories` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `display_name` varchar(150) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `category_slug` varchar(150) DEFAULT NULL,
  `category_description` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `seo_priority` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `spec_categories`
--

INSERT INTO `spec_categories` (`category_id`, `category_name`, `display_name`, `sort_order`, `is_active`, `created_at`, `category_slug`, `category_description`, `updated_at`, `seo_priority`) VALUES
(1, 'dimensions', 'Dimensions', 1, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(2, 'exterior', 'Exterior', 2, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(3, 'engine', 'Engine', 3, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(4, 'powertrain', 'Powertrain', 4, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(5, 'transmission', 'Transmission', 5, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(6, 'drivetrain', 'Drivetrain', 6, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(7, 'performance', 'Performance', 7, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(8, 'fuel_efficiency', 'Fuel & Efficiency', 8, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(9, 'suspension', 'Suspension', 9, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(10, 'brakes', 'Brakes', 10, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(11, 'steering', 'Steering', 11, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(12, 'wheels_tyres', 'Wheels & Tyres', 12, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(13, 'safety', 'Safety', 13, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(14, 'adas', 'ADAS', 14, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(15, 'interior', 'Interior', 15, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(16, 'comfort', 'Comfort', 16, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(17, 'infotainment', 'Infotainment', 17, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(18, 'connectivity', 'Connectivity', 18, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(19, 'seating', 'Seating', 19, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(20, 'climate', 'Climate Control', 20, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(21, 'lighting', 'Lighting', 21, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(22, 'ev', 'EV Specific', 22, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(23, 'hybrid', 'Hybrid Specific', 23, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(24, 'ownership', 'Ownership & Warranty', 24, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(25, 'compliance', 'Compliance', 25, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(26, 'pricing', 'Pricing', 26, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(27, 'availability', 'Availability', 27, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(28, 'dealer', 'Dealer Info', 28, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(29, 'reviews', 'Reviews & Ratings', 29, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(30, 'accessories', 'Accessories', 30, 1, '2026-04-30 17:53:00', NULL, NULL, '2026-04-30 19:06:45', 0),
(49, 'software', 'Software Features', 36, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(50, 'ota', 'OTA Support', 37, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(51, 'warranty', 'Warranty Details', 32, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(52, 'maintenance', 'Maintenance Schedule', 34, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(53, 'commercial_utility', 'Commercial Utility', 34, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(54, 'fleet_suitability', 'Fleet Suitability', 35, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(55, 'cargo', 'Cargo Utility', 37, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(56, 'route_profitability', 'Route Profitability', 38, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(57, 'buyer_persona', 'Buyer Persona', 39, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(58, 'resale', 'Resale Value', 40, 1, '2026-04-30 19:01:07', NULL, NULL, '2026-04-30 19:06:45', 0),
(59, 'security', 'Security Systems', 31, 1, '2026-04-30 19:06:45', NULL, NULL, '2026-04-30 19:06:45', 0),
(61, 'maintenance_schedule', 'Maintenance Schedule', 33, 1, '2026-04-30 19:06:45', NULL, NULL, '2026-04-30 19:06:45', 0);

-- --------------------------------------------------------

--
-- Table structure for table `spec_chassis_dimensions`
--

CREATE TABLE `spec_chassis_dimensions` (
  `variant_id` bigint(20) NOT NULL,
  `length_mm` int(11) DEFAULT NULL,
  `width_mm` int(11) DEFAULT NULL,
  `height_mm` int(11) DEFAULT NULL,
  `wheelbase_mm` int(11) DEFAULT NULL,
  `ground_clearance_mm` int(11) DEFAULT NULL,
  `kerb_weight_kg` int(11) DEFAULT NULL,
  `gross_weight_kg` int(11) DEFAULT NULL,
  `boot_space_l` int(11) DEFAULT NULL,
  `turning_radius_m` decimal(4,2) DEFAULT NULL,
  `approach_angle` decimal(4,1) DEFAULT NULL,
  `departure_angle` decimal(4,1) DEFAULT NULL,
  `breakover_angle` decimal(4,1) DEFAULT NULL,
  `front_suspension` varchar(150) DEFAULT NULL,
  `rear_suspension` varchar(150) DEFAULT NULL,
  `steering_type` enum('Electric','Hydraulic','Manual') DEFAULT NULL,
  `steering_adjustment` enum('None','Tilt','Telescopic','Tilt & Telescopic') DEFAULT NULL,
  `front_brake_type` varchar(50) DEFAULT NULL,
  `rear_brake_type` varchar(50) DEFAULT NULL,
  `parking_brake_type` enum('Manual','Electronic') DEFAULT NULL,
  `wheel_type` enum('Steel','Alloy') DEFAULT NULL,
  `wheel_size_inch` int(11) DEFAULT NULL,
  `tyre_size_front` varchar(100) DEFAULT NULL,
  `tyre_size_rear` varchar(100) DEFAULT NULL,
  `spare_wheel_type` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_definition`
--

CREATE TABLE `spec_definition` (
  `spec_id` int(11) NOT NULL,
  `display_name` varchar(100) DEFAULT NULL,
  `unit_type` varchar(20) DEFAULT NULL,
  `is_filterable` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_ev_details`
--

CREATE TABLE `spec_ev_details` (
  `config_id` bigint(20) NOT NULL,
  `motor_type` varchar(100) DEFAULT NULL,
  `battery_usable_kwh` decimal(10,2) DEFAULT NULL,
  `battery_chemistry` enum('LFP','NMC','Solid-State') DEFAULT NULL,
  `range_real_world_km` decimal(8,2) DEFAULT NULL,
  `range_certified_km` decimal(8,2) DEFAULT NULL,
  `ac_charge_time_hours` decimal(5,2) DEFAULT NULL,
  `dc_fast_charge_mins` int(11) DEFAULT NULL,
  `v2l_supported` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_fcev_details`
--

CREATE TABLE `spec_fcev_details` (
  `config_id` bigint(20) NOT NULL,
  `stack_power_kw` int(11) DEFAULT NULL,
  `h2_tank_kg` decimal(6,2) DEFAULT NULL,
  `refuel_time_mins` int(11) DEFAULT NULL,
  `buffer_battery_kwh` decimal(6,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_gas_details`
--

CREATE TABLE `spec_gas_details` (
  `config_id` bigint(20) NOT NULL,
  `fuel_mode` enum('Bi-fuel','Dedicated') DEFAULT NULL,
  `gas_type` enum('CNG','LPG') DEFAULT NULL,
  `gas_injection_system` varchar(100) DEFAULT NULL,
  `gas_ecu` varchar(100) DEFAULT NULL,
  `gas_regulator` varchar(100) DEFAULT NULL,
  `gas_cylinder_count` int(11) DEFAULT NULL,
  `cylinder_capacity_l` int(11) DEFAULT NULL,
  `cylinder_pressure_bar` int(11) DEFAULT NULL,
  `cylinder_material` varchar(100) DEFAULT NULL,
  `cylinder_certification` varchar(100) DEFAULT NULL,
  `cylinder_location` varchar(100) DEFAULT NULL,
  `leak_detection_system` tinyint(1) DEFAULT 1,
  `automatic_shut_off` tinyint(1) DEFAULT 1,
  `gas_mileage_km_kg` decimal(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_hybrid_details`
--

CREATE TABLE `spec_hybrid_details` (
  `config_id` bigint(20) NOT NULL,
  `hybrid_type` enum('Mild Hybrid','Full Hybrid','Plug-in Hybrid') DEFAULT NULL,
  `architecture` enum('Series','Parallel','Series-Parallel') DEFAULT NULL,
  `motor_type` varchar(100) DEFAULT NULL,
  `motor_power_kw` decimal(8,2) DEFAULT NULL,
  `motor_torque_nm` decimal(8,2) DEFAULT NULL,
  `motor_location` varchar(100) DEFAULT NULL,
  `battery_capacity_kwh` decimal(10,2) DEFAULT NULL,
  `battery_chemistry` varchar(50) DEFAULT NULL,
  `electric_range_km` int(11) DEFAULT NULL,
  `regenerative_braking` tinyint(1) DEFAULT 1,
  `energy_flow_display` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_ice_details`
--

CREATE TABLE `spec_ice_details` (
  `config_id` bigint(20) NOT NULL,
  `engine_code` varchar(50) DEFAULT NULL,
  `displacement_cc` int(11) DEFAULT NULL,
  `fuel_type` enum('Petrol','Diesel','CNG','LPG') DEFAULT NULL,
  `cylinder_count` int(11) DEFAULT NULL,
  `max_power_hp` decimal(8,2) DEFAULT NULL,
  `max_torque_nm` decimal(8,2) DEFAULT NULL,
  `fuel_efficiency_kmpl` decimal(8,2) DEFAULT NULL,
  `emission_standard` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_performance_efficiency`
--

CREATE TABLE `spec_performance_efficiency` (
  `config_id` bigint(20) NOT NULL,
  `accel_0_60` decimal(5,2) DEFAULT NULL,
  `accel_0_100` decimal(5,2) DEFAULT NULL,
  `top_speed_kmph` int(11) DEFAULT NULL,
  `power_to_weight_ratio` decimal(8,2) DEFAULT NULL,
  `fuel_tank_capacity_l` decimal(8,2) DEFAULT NULL,
  `mileage_city` decimal(8,2) DEFAULT NULL,
  `mileage_highway` decimal(8,2) DEFAULT NULL,
  `mileage_arai` decimal(8,2) DEFAULT NULL,
  `mileage_real_world` decimal(8,2) DEFAULT NULL,
  `emission_standard` varchar(50) DEFAULT NULL,
  `co2_emissions_gkm` decimal(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spec_validation_queue`
--

CREATE TABLE `spec_validation_queue` (
  `audit_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `attribute_name` varchar(100) DEFAULT NULL,
  `conflicting_values_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`conflicting_values_json`)),
  `status` enum('Pending','Resolved','Flagged') DEFAULT 'Pending',
  `resolved_by` varchar(100) DEFAULT NULL,
  `priority_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sponsored_dealer_listings`
--

CREATE TABLE `sponsored_dealer_listings` (
  `sponsored_listing_id` bigint(20) NOT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `placement_type` enum('Search','Category','Comparison','City','Homepage') DEFAULT 'Search',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `budget` decimal(15,2) DEFAULT NULL,
  `cpc_rate` decimal(12,2) DEFAULT NULL,
  `cpl_rate` decimal(12,2) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sponsored_listings`
--

CREATE TABLE `sponsored_listings` (
  `sponsor_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `campaign_name` varchar(255) DEFAULT NULL,
  `placement_type` varchar(100) DEFAULT NULL,
  `bid_amount` decimal(15,2) DEFAULT NULL,
  `impressions` bigint(20) DEFAULT 0,
  `clicks` bigint(20) DEFAULT 0,
  `conversions` bigint(20) DEFAULT 0,
  `active_status` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `suitability_scores`
--

CREATE TABLE `suitability_scores` (
  `variant_id` bigint(20) NOT NULL,
  `persona_id` int(11) NOT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_health_monitor`
--

CREATE TABLE `system_health_monitor` (
  `health_id` bigint(20) NOT NULL,
  `module_name` varchar(255) DEFAULT NULL,
  `health_score` decimal(5,2) DEFAULT NULL,
  `anomaly_count` int(11) DEFAULT NULL,
  `last_reviewed` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('Healthy','Warning','Critical') DEFAULT 'Healthy'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `taxation_rules`
--

CREATE TABLE `taxation_rules` (
  `tax_id` bigint(20) NOT NULL,
  `region_id` bigint(20) DEFAULT NULL,
  `gst_rate` decimal(5,2) DEFAULT NULL,
  `registration_cost` decimal(15,2) DEFAULT NULL,
  `insurance_multiplier` decimal(5,2) DEFAULT NULL,
  `subsidy_available` tinyint(1) DEFAULT NULL,
  `subsidy_amount` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `test_drive_requests`
--

CREATE TABLE `test_drive_requests` (
  `request_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `dealer_id` bigint(20) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `preferred_date` datetime DEFAULT NULL,
  `status` enum('Pending','Confirmed','Completed','Cancelled') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `fulfillment_status` enum('Pending','Scheduled','Completed','No Show','Cancelled') DEFAULT 'Pending',
  `assigned_dealer_employee` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transmission_options`
--

CREATE TABLE `transmission_options` (
  `transmission_id` int(11) NOT NULL,
  `transmission_type` varchar(100) NOT NULL,
  `gearbox_manufacturer` varchar(150) DEFAULT NULL,
  `gearbox_model` varchar(150) DEFAULT NULL,
  `gear_count` int(11) DEFAULT NULL,
  `gear_ratios` text DEFAULT NULL,
  `clutch_type` varchar(100) DEFAULT NULL,
  `torque_capacity_nm` int(11) DEFAULT NULL,
  `pto_support` tinyint(1) DEFAULT 0,
  `retarder_type` varchar(100) DEFAULT NULL,
  `shift_logic` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_behavior_tracking`
--

CREATE TABLE `user_behavior_tracking` (
  `event_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) DEFAULT NULL,
  `event_type` varchar(100) DEFAULT NULL,
  `page_type` varchar(100) DEFAULT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `metadata_json` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `session_id` varchar(100) DEFAULT NULL,
  `page_slug` varchar(220) DEFAULT NULL,
  `referrer_url` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_reviews`
--

CREATE TABLE `user_reviews` (
  `user_review_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `user_rating` decimal(4,2) DEFAULT NULL,
  `ownership_duration_months` int(11) DEFAULT NULL,
  `review_text` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_saved_comparisons`
--

CREATE TABLE `user_saved_comparisons` (
  `comparison_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `saved_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_wishlist`
--

CREATE TABLE `user_wishlist` (
  `wishlist_id` bigint(20) NOT NULL,
  `user_identifier` varchar(255) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `priority_score` decimal(5,2) DEFAULT NULL,
  `added_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variants`
--

CREATE TABLE `variants` (
  `variant_id` bigint(20) NOT NULL,
  `model_id` bigint(20) NOT NULL,
  `variant_name` varchar(200) NOT NULL,
  `trim_level` varchar(100) DEFAULT NULL,
  `model_year` year(4) DEFAULT NULL,
  `market_region` varchar(100) DEFAULT NULL,
  `seating_capacity` int(11) DEFAULT NULL,
  `ex_showroom_price` decimal(15,2) DEFAULT NULL,
  `on_road_price` decimal(15,2) DEFAULT NULL,
  `booking_amount` decimal(15,2) DEFAULT NULL,
  `waiting_period_days` int(11) DEFAULT NULL,
  `launch_status` enum('Upcoming','Launched','Facelift','Discontinued Soon') DEFAULT 'Launched',
  `homologation_status` varchar(150) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `slug` varchar(200) DEFAULT NULL,
  `subscription_available` tinyint(1) DEFAULT NULL,
  `battery_subscription` tinyint(1) DEFAULT NULL,
  `software_defined_vehicle` tinyint(1) DEFAULT NULL,
  `autonomous_level` varchar(50) DEFAULT NULL,
  `connected_services_years` int(11) DEFAULT NULL,
  `resale_prediction_score` decimal(5,2) DEFAULT NULL,
  `fleet_suitability_score` decimal(5,2) DEFAULT NULL,
  `first_owner_cost_index` decimal(10,2) DEFAULT NULL,
  `long_term_cost_index` decimal(10,2) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `fuel_type_id` int(11) DEFAULT NULL,
  `powertrain_type_id` int(11) DEFAULT NULL,
  `safety_rating` decimal(3,2) DEFAULT NULL,
  `seo_slug` varchar(255) DEFAULT NULL,
  `uuid` char(36) DEFAULT NULL,
  `external_api_id` varchar(255) DEFAULT NULL,
  `payload_capacity_kg` int(11) DEFAULT NULL,
  `gross_vehicle_weight_kg` int(11) DEFAULT NULL,
  `commercial_use_case` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_accessory_map`
--

CREATE TABLE `variant_accessory_map` (
  `id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `accessory_id` bigint(20) NOT NULL,
  `is_oem` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_color_map`
--

CREATE TABLE `variant_color_map` (
  `id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `color_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_configurations`
--

CREATE TABLE `variant_configurations` (
  `config_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `powertrain_type_id` int(11) NOT NULL,
  `drivetrain_id` int(11) NOT NULL,
  `transmission_id` int(11) NOT NULL,
  `payload_capacity_kg` int(11) DEFAULT NULL,
  `towing_capacity_kg` int(11) DEFAULT NULL,
  `roof_load_capacity_kg` int(11) DEFAULT NULL,
  `commercial_package` varchar(150) DEFAULT NULL,
  `passenger_package` varchar(150) DEFAULT NULL,
  `final_price` decimal(15,2) DEFAULT NULL,
  `is_special_edition` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_feature_map`
--

CREATE TABLE `variant_feature_map` (
  `id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `feature_id` bigint(20) NOT NULL,
  `availability` enum('Standard','Optional','Package') DEFAULT 'Standard',
  `notes` varchar(255) DEFAULT NULL,
  `source_id` bigint(20) DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `version_number` int(11) DEFAULT 1,
  `verification_status` enum('Pending','Verified','Conflict','Rejected') DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_feature_matrix`
--

CREATE TABLE `variant_feature_matrix` (
  `variant_id` bigint(20) NOT NULL,
  `feature_id` bigint(20) NOT NULL,
  `availability` enum('Standard','Optional','Package-Only','Not Available') DEFAULT 'Standard',
  `is_oem` tinyint(1) DEFAULT 1,
  `regional_availability` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`regional_availability`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_feature_package_map`
--

CREATE TABLE `variant_feature_package_map` (
  `id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `package_id` bigint(20) NOT NULL,
  `is_standard` tinyint(1) DEFAULT 0,
  `source_id` bigint(20) DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_pages`
--

CREATE TABLE `variant_pages` (
  `page_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `slug` varchar(220) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` longtext DEFAULT NULL,
  `budget_band` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_price_history`
--

CREATE TABLE `variant_price_history` (
  `price_history_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `region_id` int(11) DEFAULT NULL,
  `ex_showroom_price` decimal(15,2) DEFAULT NULL,
  `on_road_price` decimal(15,2) DEFAULT NULL,
  `insurance_estimate` decimal(15,2) DEFAULT NULL,
  `subsidy_amount` decimal(15,2) DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `currency_code` varchar(10) DEFAULT NULL,
  `tax_rate` decimal(6,2) DEFAULT NULL,
  `price_validity_region` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_spec_ledger`
--

CREATE TABLE `variant_spec_ledger` (
  `value_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `spec_id` int(11) DEFAULT NULL,
  `raw_value` text DEFAULT NULL,
  `normalized_value` decimal(18,4) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `last_verified_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `validation_status` enum('Pending','Validated','Conflict','Rejected') DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_spec_values`
--

CREATE TABLE `variant_spec_values` (
  `value_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `attribute_id` bigint(20) NOT NULL,
  `value_text` longtext DEFAULT NULL,
  `value_number` decimal(18,4) DEFAULT NULL,
  `value_bool` tinyint(1) DEFAULT NULL,
  `value_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (`value_json` is null or json_valid(`value_json`)),
  `source_id` bigint(20) DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `version_number` int(11) DEFAULT 1,
  `last_verified_source` bigint(20) DEFAULT NULL,
  `verification_status` enum('Pending','Verified','Conflict','Rejected') DEFAULT 'Pending',
  `source_priority` int(11) DEFAULT 0,
  `manual_override` tinyint(1) DEFAULT 0,
  `override_reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variant_suitability_scores`
--

CREATE TABLE `variant_suitability_scores` (
  `variant_id` bigint(20) NOT NULL,
  `persona_id` int(11) NOT NULL,
  `score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_media`
--

CREATE TABLE `vehicle_media` (
  `media_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `media_type` enum('Image','Video','Brochure','Document','360 View') DEFAULT NULL,
  `media_url` varchar(500) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `source_id` bigint(20) DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `verified_user_reviews`
--

CREATE TABLE `verified_user_reviews` (
  `review_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) NOT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `ownership_duration_months` int(11) DEFAULT NULL,
  `mileage_km` int(11) DEFAULT NULL,
  `rating_overall` decimal(3,2) DEFAULT NULL,
  `rating_reliability` decimal(3,2) DEFAULT NULL,
  `rating_comfort` decimal(3,2) DEFAULT NULL,
  `rating_value` decimal(3,2) DEFAULT NULL,
  `pros` text DEFAULT NULL,
  `cons` text DEFAULT NULL,
  `verified_purchase` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `buyer_vehicle_research_view`
--
DROP TABLE IF EXISTS `buyer_vehicle_research_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `buyer_vehicle_research_view`  AS SELECT `b`.`id` AS `brand_id`, `b`.`brand_name` AS `brand_name`, `b`.`uuid` AS `brand_uuid`, `m`.`model_id` AS `model_id`, `m`.`model_name` AS `model_name`, `m`.`uuid` AS `model_uuid`, `m`.`segment` AS `segment`, `m`.`body_type` AS `body_type`, `v`.`variant_id` AS `variant_id`, `v`.`variant_name` AS `variant_name`, `v`.`uuid` AS `variant_uuid`, `v`.`slug` AS `slug`, `vp`.`ex_showroom_price` AS `ex_showroom_price`, `vp`.`on_road_price` AS `on_road_price`, `vp`.`country_id` AS `country_id`, `vp`.`currency_code` AS `currency_code`, `ai`.`predicted_market_demand` AS `predicted_market_demand`, `ai`.`scraper_confidence` AS `scraper_confidence`, `ai`.`human_verified` AS `human_verified`, `ai`.`feedback_score` AS `feedback_score`, `ai`.`anomaly_detected` AS `anomaly_detected`, `rs`.`reliability_score` AS `reliability_score`, `rs`.`predicted_resale_value` AS `predicted_resale_value`, `ie`.`fuel_type` AS `fuel_type`, `ie`.`displacement_cc` AS `displacement_cc`, `ie`.`max_power_hp` AS `max_power_hp`, `ie`.`max_torque_nm` AS `max_torque_nm`, `ie`.`fuel_efficiency_kmpl` AS `fuel_efficiency_kmpl`, `ev`.`battery_usable_kwh` AS `battery_usable_kwh`, `ev`.`range_real_world_km` AS `range_real_world_km`, `ss`.`airbag_count` AS `airbag_count`, `ss`.`adas_level` AS `adas_level`, `ss`.`ncap_rating` AS `ncap_rating`, `os`.`estimated_annual_maintenance_cost` AS `estimated_annual_maintenance_cost`, `os`.`insurance_estimate_new` AS `insurance_estimate_new`, `v`.`payload_capacity_kg` AS `payload_capacity_kg`, `v`.`gross_vehicle_weight_kg` AS `gross_vehicle_weight_kg`, `v`.`commercial_use_case` AS `commercial_use_case` FROM ((((((((((`variants` `v` join `models` `m` on(`v`.`model_id` = `m`.`model_id`)) join `brands` `b` on(`m`.`brand_id` = `b`.`id`)) left join `variant_price_history` `vp` on(`v`.`variant_id` = `vp`.`variant_id`)) left join `ai_metadata` `ai` on(`v`.`variant_id` = `ai`.`variant_id`)) left join `reliability_scores` `rs` on(`v`.`variant_id` = `rs`.`variant_id`)) left join `variant_configurations` `vc` on(`v`.`variant_id` = `vc`.`variant_id`)) left join `ice_engine_specs` `ie` on(`vc`.`config_id` = `ie`.`config_id`)) left join `ev_specs` `ev` on(`vc`.`config_id` = `ev`.`config_id`)) left join `safety_specs` `ss` on(`vc`.`config_id` = `ss`.`config_id`)) left join `ownership_specs` `os` on(`vc`.`config_id` = `os`.`config_id`)) WHERE `v`.`deleted_at` is null ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_audit_logs`
--
ALTER TABLE `admin_audit_logs`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `ai_attribute_extraction`
--
ALTER TABLE `ai_attribute_extraction`
  ADD PRIMARY KEY (`extraction_id`);

--
-- Indexes for table `ai_metadata`
--
ALTER TABLE `ai_metadata`
  ADD PRIMARY KEY (`ai_id`),
  ADD KEY `idx_ai_conf` (`variant_id`,`scraper_confidence`),
  ADD KEY `idx_ai_metadata_demand` (`predicted_market_demand`),
  ADD KEY `idx_ai_variant` (`variant_id`),
  ADD KEY `idx_ai_demand` (`predicted_market_demand`);

--
-- Indexes for table `ai_population_pipeline`
--
ALTER TABLE `ai_population_pipeline`
  ADD PRIMARY KEY (`pipeline_id`);

--
-- Indexes for table `ai_training_feedback`
--
ALTER TABLE `ai_training_feedback`
  ADD PRIMARY KEY (`feedback_id`),
  ADD KEY `extraction_id` (`extraction_id`);

--
-- Indexes for table `api_performance_logs`
--
ALTER TABLE `api_performance_logs`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `autonomous_system_specs`
--
ALTER TABLE `autonomous_system_specs`
  ADD PRIMARY KEY (`autonomous_id`);

--
-- Indexes for table `body_builder_compatibility`
--
ALTER TABLE `body_builder_compatibility`
  ADD PRIMARY KEY (`compatibility_id`),
  ADD KEY `idx_body_builder_variant` (`variant_id`);

--
-- Indexes for table `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `brand_name` (`brand_name`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD UNIQUE KEY `idx_b_slug` (`seo_slug`),
  ADD UNIQUE KEY `idx_brand_uuid` (`uuid`),
  ADD UNIQUE KEY `uk_brands_uuid` (`uuid`),
  ADD KEY `idx_brand_name` (`brand_name`);

--
-- Indexes for table `brand_pages`
--
ALTER TABLE `brand_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `uq_brand_pages_slug` (`slug`),
  ADD KEY `idx_brand_pages_brand` (`brand_id`);

--
-- Indexes for table `budget_pages`
--
ALTER TABLE `budget_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `uq_budget_pages_slug` (`slug`);

--
-- Indexes for table `buyer_behavior_analytics`
--
ALTER TABLE `buyer_behavior_analytics`
  ADD PRIMARY KEY (`behavior_id`);

--
-- Indexes for table `buyer_budget_profiles`
--
ALTER TABLE `buyer_budget_profiles`
  ADD PRIMARY KEY (`budget_profile_id`),
  ADD KEY `idx_budget_user` (`user_identifier`);

--
-- Indexes for table `buyer_personas`
--
ALTER TABLE `buyer_personas`
  ADD PRIMARY KEY (`persona_id`);

--
-- Indexes for table `buyer_persona_matches`
--
ALTER TABLE `buyer_persona_matches`
  ADD PRIMARY KEY (`match_id`),
  ADD KEY `idx_bpm_user` (`user_identifier`),
  ADD KEY `idx_bpm_variant` (`variant_id`),
  ADD KEY `idx_bpm_persona` (`persona_id`),
  ADD KEY `idx_persona_variant` (`persona_id`,`variant_id`,`fit_score`);

--
-- Indexes for table `buyer_persona_profiles`
--
ALTER TABLE `buyer_persona_profiles`
  ADD PRIMARY KEY (`persona_id`);

--
-- Indexes for table `buyer_recommendation_logs`
--
ALTER TABLE `buyer_recommendation_logs`
  ADD PRIMARY KEY (`recommendation_id`);

--
-- Indexes for table `buying_guides`
--
ALTER TABLE `buying_guides`
  ADD PRIMARY KEY (`guide_id`);

--
-- Indexes for table `cargo_body_compatibility`
--
ALTER TABLE `cargo_body_compatibility`
  ADD PRIMARY KEY (`compatibility_id`);

--
-- Indexes for table `chassis_specs`
--
ALTER TABLE `chassis_specs`
  ADD PRIMARY KEY (`chassis_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `city_price_pages`
--
ALTER TABLE `city_price_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `color_options`
--
ALTER TABLE `color_options`
  ADD PRIMARY KEY (`color_id`);

--
-- Indexes for table `commercial_buyer_guides`
--
ALTER TABLE `commercial_buyer_guides`
  ADD PRIMARY KEY (`guide_id`),
  ADD UNIQUE KEY `uq_commercial_guide_slug` (`slug`);

--
-- Indexes for table `commercial_permit_data`
--
ALTER TABLE `commercial_permit_data`
  ADD PRIMARY KEY (`permit_id`),
  ADD KEY `idx_permit_variant` (`variant_id`);

--
-- Indexes for table `comparison_history`
--
ALTER TABLE `comparison_history`
  ADD PRIMARY KEY (`comparison_id`);

--
-- Indexes for table `comparison_pages`
--
ALTER TABLE `comparison_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `competitor_mapping`
--
ALTER TABLE `competitor_mapping`
  ADD PRIMARY KEY (`mapping_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `competitor_variant_id` (`competitor_variant_id`);

--
-- Indexes for table `competitor_market_tracking`
--
ALTER TABLE `competitor_market_tracking`
  ADD PRIMARY KEY (`competitor_id`);

--
-- Indexes for table `compliance_certifications`
--
ALTER TABLE `compliance_certifications`
  ADD PRIMARY KEY (`certification_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `compliance_framework`
--
ALTER TABLE `compliance_framework`
  ADD PRIMARY KEY (`compliance_id`);

--
-- Indexes for table `content_localization`
--
ALTER TABLE `content_localization`
  ADD PRIMARY KEY (`localization_id`);

--
-- Indexes for table `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`country_id`);

--
-- Indexes for table `country_pricing`
--
ALTER TABLE `country_pricing`
  ADD PRIMARY KEY (`pricing_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `data_freshness_scores`
--
ALTER TABLE `data_freshness_scores`
  ADD PRIMARY KEY (`freshness_id`);

--
-- Indexes for table `data_quality_control`
--
ALTER TABLE `data_quality_control`
  ADD PRIMARY KEY (`quality_id`);

--
-- Indexes for table `data_source_governance`
--
ALTER TABLE `data_source_governance`
  ADD PRIMARY KEY (`source_id`),
  ADD KEY `idx_source_trust` (`trust_score`);

--
-- Indexes for table `dealers`
--
ALTER TABLE `dealers`
  ADD PRIMARY KEY (`dealer_id`),
  ADD UNIQUE KEY `dealer_slug` (`dealer_slug`),
  ADD UNIQUE KEY `idx_dealer_uuid` (`uuid`),
  ADD KEY `brand_id` (`brand_id`),
  ADD KEY `idx_dealer_city_brand` (`city`,`brand_id`);

--
-- Indexes for table `dealer_city_pages`
--
ALTER TABLE `dealer_city_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `dealer_inquiries`
--
ALTER TABLE `dealer_inquiries`
  ADD PRIMARY KEY (`inquiry_id`);

--
-- Indexes for table `dealer_inventory`
--
ALTER TABLE `dealer_inventory`
  ADD PRIMARY KEY (`inventory_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `idx_inventory_stock` (`stock_count`),
  ADD KEY `fk_dealer_inventory_dealer` (`dealer_id`);

--
-- Indexes for table `dealer_leads`
--
ALTER TABLE `dealer_leads`
  ADD PRIMARY KEY (`lead_id`),
  ADD KEY `idx_dealer_leads_dealer` (`dealer_id`),
  ADD KEY `idx_dealer_leads_variant` (`variant_id`),
  ADD KEY `idx_dealer_leads_stage` (`lead_stage`);

--
-- Indexes for table `dealer_promotions`
--
ALTER TABLE `dealer_promotions`
  ADD PRIMARY KEY (`promotion_id`);

--
-- Indexes for table `dealer_ratings`
--
ALTER TABLE `dealer_ratings`
  ADD PRIMARY KEY (`rating_id`);

--
-- Indexes for table `dealer_sla_scores`
--
ALTER TABLE `dealer_sla_scores`
  ADD PRIMARY KEY (`sla_score_id`),
  ADD KEY `idx_sla_dealer` (`dealer_id`);

--
-- Indexes for table `dealer_subscription_plans`
--
ALTER TABLE `dealer_subscription_plans`
  ADD PRIMARY KEY (`subscription_id`);

--
-- Indexes for table `dealer_subscription_tiers`
--
ALTER TABLE `dealer_subscription_tiers`
  ADD PRIMARY KEY (`tier_id`);

--
-- Indexes for table `dealer_tenants`
--
ALTER TABLE `dealer_tenants`
  ADD PRIMARY KEY (`dealer_id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `fk_dealer_tenants_brand` (`brand_id`);

--
-- Indexes for table `drivetrain_options`
--
ALTER TABLE `drivetrain_options`
  ADD PRIMARY KEY (`drivetrain_id`),
  ADD UNIQUE KEY `drivetrain_name` (`drivetrain_name`);

--
-- Indexes for table `duplicate_detection_registry`
--
ALTER TABLE `duplicate_detection_registry`
  ADD PRIMARY KEY (`duplicate_id`);

--
-- Indexes for table `emi_calculator_runs`
--
ALTER TABLE `emi_calculator_runs`
  ADD PRIMARY KEY (`emi_run_id`),
  ADD KEY `idx_emi_variant` (`variant_id`),
  ADD KEY `idx_emi_user` (`user_identifier`);

--
-- Indexes for table `enterprise_scorecard`
--
ALTER TABLE `enterprise_scorecard`
  ADD PRIMARY KEY (`scorecard_id`);

--
-- Indexes for table `ev_infrastructure_support`
--
ALTER TABLE `ev_infrastructure_support`
  ADD PRIMARY KEY (`infra_id`);

--
-- Indexes for table `ev_specs`
--
ALTER TABLE `ev_specs`
  ADD PRIMARY KEY (`ev_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `executive_dashboard_cache`
--
ALTER TABLE `executive_dashboard_cache`
  ADD PRIMARY KEY (`dashboard_id`);

--
-- Indexes for table `expert_reviews`
--
ALTER TABLE `expert_reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `idx_review_score` (`review_score`);

--
-- Indexes for table `external_api_registry`
--
ALTER TABLE `external_api_registry`
  ADD PRIMARY KEY (`api_id`);

--
-- Indexes for table `fake_review_detection`
--
ALTER TABLE `fake_review_detection`
  ADD PRIMARY KEY (`detection_id`);

--
-- Indexes for table `fcev_specs`
--
ALTER TABLE `fcev_specs`
  ADD PRIMARY KEY (`fcev_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `features`
--
ALTER TABLE `features`
  ADD PRIMARY KEY (`feature_id`),
  ADD UNIQUE KEY `unique_feature_name` (`feature_name`),
  ADD KEY `idx_features_group_id` (`group_id`),
  ADD KEY `idx_parent_feature_id` (`parent_feature_id`);

--
-- Indexes for table `feature_aliases`
--
ALTER TABLE `feature_aliases`
  ADD PRIMARY KEY (`alias_id`),
  ADD UNIQUE KEY `uq_feature_alias` (`feature_id`,`alias_name`),
  ADD KEY `idx_alias_slug` (`alias_slug`);

--
-- Indexes for table `feature_groups`
--
ALTER TABLE `feature_groups`
  ADD PRIMARY KEY (`group_id`),
  ADD UNIQUE KEY `uq_feature_group_name` (`group_name`);

--
-- Indexes for table `feature_packages`
--
ALTER TABLE `feature_packages`
  ADD PRIMARY KEY (`package_id`);

--
-- Indexes for table `feature_package_features`
--
ALTER TABLE `feature_package_features`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fpf_package` (`package_id`),
  ADD KEY `idx_fpf_feature` (`feature_id`);

--
-- Indexes for table `finance_lender_products`
--
ALTER TABLE `finance_lender_products`
  ADD PRIMARY KEY (`lender_product_id`),
  ADD KEY `idx_flp_variant` (`variant_id`),
  ADD KEY `idx_flp_lender` (`lender_name`);

--
-- Indexes for table `finance_quote_requests`
--
ALTER TABLE `finance_quote_requests`
  ADD PRIMARY KEY (`quote_id`);

--
-- Indexes for table `financing_products`
--
ALTER TABLE `financing_products`
  ADD PRIMARY KEY (`finance_id`),
  ADD KEY `idx_financing_variant` (`variant_id`);

--
-- Indexes for table `fintech_lenders`
--
ALTER TABLE `fintech_lenders`
  ADD PRIMARY KEY (`lender_id`);

--
-- Indexes for table `fleet_guides`
--
ALTER TABLE `fleet_guides`
  ADD PRIMARY KEY (`guide_id`),
  ADD UNIQUE KEY `uq_fleet_guide_slug` (`slug`);

--
-- Indexes for table `fleet_management_data`
--
ALTER TABLE `fleet_management_data`
  ADD PRIMARY KEY (`fleet_id`),
  ADD KEY `idx_fleet_variant` (`variant_id`);

--
-- Indexes for table `fleet_operations`
--
ALTER TABLE `fleet_operations`
  ADD PRIMARY KEY (`fleet_id`);

--
-- Indexes for table `fleet_profitability_scores`
--
ALTER TABLE `fleet_profitability_scores`
  ADD PRIMARY KEY (`score_id`);

--
-- Indexes for table `fleet_tco_scores`
--
ALTER TABLE `fleet_tco_scores`
  ADD PRIMARY KEY (`score_id`),
  ADD KEY `idx_fleet_tco_variant` (`variant_id`);

--
-- Indexes for table `fuel_type_pages`
--
ALTER TABLE `fuel_type_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `uq_fuel_pages_slug` (`slug`);

--
-- Indexes for table `global_attribute_taxonomy`
--
ALTER TABLE `global_attribute_taxonomy`
  ADD PRIMARY KEY (`taxonomy_id`);

--
-- Indexes for table `hybrid_specs`
--
ALTER TABLE `hybrid_specs`
  ADD PRIMARY KEY (`hybrid_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `ice_engine_specs`
--
ALTER TABLE `ice_engine_specs`
  ADD PRIMARY KEY (`engine_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `insurance_addon_products`
--
ALTER TABLE `insurance_addon_products`
  ADD PRIMARY KEY (`addon_id`),
  ADD KEY `idx_ins_addon_provider` (`provider_name`);

--
-- Indexes for table `insurance_comparison_results`
--
ALTER TABLE `insurance_comparison_results`
  ADD PRIMARY KEY (`comparison_id`),
  ADD KEY `idx_ins_cmp_variant` (`variant_id`),
  ADD KEY `idx_ins_cmp_user` (`user_identifier`);

--
-- Indexes for table `insurance_finance_marketplace`
--
ALTER TABLE `insurance_finance_marketplace`
  ADD PRIMARY KEY (`offer_id`),
  ADD KEY `idx_finance_variant` (`variant_id`);

--
-- Indexes for table `insurance_products`
--
ALTER TABLE `insurance_products`
  ADD PRIMARY KEY (`insurance_id`),
  ADD KEY `idx_insurance_variant` (`variant_id`);

--
-- Indexes for table `insurance_quote_requests`
--
ALTER TABLE `insurance_quote_requests`
  ADD PRIMARY KEY (`quote_id`);

--
-- Indexes for table `insurance_renewal_tasks`
--
ALTER TABLE `insurance_renewal_tasks`
  ADD PRIMARY KEY (`renewal_task_id`),
  ADD KEY `idx_ins_renew_variant` (`variant_id`),
  ADD KEY `idx_ins_renew_user` (`user_identifier`);

--
-- Indexes for table `interior_specs`
--
ALTER TABLE `interior_specs`
  ADD PRIMARY KEY (`interior_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `inventory_live`
--
ALTER TABLE `inventory_live`
  ADD PRIMARY KEY (`stock_id`),
  ADD KEY `dealer_id` (`dealer_id`),
  ADD KEY `fk_inventory_live_variant` (`variant_id`);

--
-- Indexes for table `lead_funnel`
--
ALTER TABLE `lead_funnel`
  ADD PRIMARY KEY (`lead_id`);

--
-- Indexes for table `lead_management`
--
ALTER TABLE `lead_management`
  ADD PRIMARY KEY (`lead_id`),
  ADD KEY `idx_lead_variant` (`variant_id`);

--
-- Indexes for table `legacy_car_models_backup`
--
ALTER TABLE `legacy_car_models_backup`
  ADD PRIMARY KEY (`model_id`),
  ADD KEY `idx_make_id` (`make_id`),
  ADD KEY `idx_make_model` (`make`,`model`),
  ADD KEY `idx_price_range` (`base_price`,`top_price`);

--
-- Indexes for table `legacy_car_variants_backup`
--
ALTER TABLE `legacy_car_variants_backup`
  ADD PRIMARY KEY (`variant_id`),
  ADD KEY `idx_make_id` (`make_id`),
  ADD KEY `idx_model_id` (`model_id`),
  ADD KEY `idx_variant_specs_id` (`variant_specs_id`),
  ADD KEY `idx_make_model_variant` (`make_id`,`model_id`,`variant_name`);

--
-- Indexes for table `lender_products`
--
ALTER TABLE `lender_products`
  ADD PRIMARY KEY (`lender_id`);

--
-- Indexes for table `maintenance_guides`
--
ALTER TABLE `maintenance_guides`
  ADD PRIMARY KEY (`guide_id`);

--
-- Indexes for table `manual_audit_queue`
--
ALTER TABLE `manual_audit_queue`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `market_demand_forecasts`
--
ALTER TABLE `market_demand_forecasts`
  ADD PRIMARY KEY (`forecast_id`);

--
-- Indexes for table `market_regions`
--
ALTER TABLE `market_regions`
  ADD PRIMARY KEY (`region_id`),
  ADD UNIQUE KEY `region_name` (`region_name`);

--
-- Indexes for table `market_trend_forecasting`
--
ALTER TABLE `market_trend_forecasting`
  ADD PRIMARY KEY (`trend_id`);

--
-- Indexes for table `migration_audit_log`
--
ALTER TABLE `migration_audit_log`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `models`
--
ALTER TABLE `models`
  ADD PRIMARY KEY (`model_id`),
  ADD UNIQUE KEY `idx_m_slug` (`seo_slug`),
  ADD UNIQUE KEY `idx_model_uuid` (`uuid`),
  ADD UNIQUE KEY `uk_models_uuid` (`uuid`),
  ADD KEY `idx_model_name` (`model_name`),
  ADD KEY `idx_model_body_type` (`body_type`),
  ADD KEY `idx_model_segment` (`segment`),
  ADD KEY `idx_models_brand_segment` (`brand_id`,`segment`),
  ADD KEY `idx_models_soft_delete` (`is_deleted`,`deleted_at`),
  ADD KEY `idx_m_brand_seg` (`brand_id`,`segment_id`),
  ADD KEY `idx_m_delete` (`is_deleted`),
  ADD KEY `idx_models_brand_category` (`brand_id`,`vehicle_category`),
  ADD KEY `idx_model_brand_segment` (`brand_id`,`segment`);
ALTER TABLE `models` ADD FULLTEXT KEY `ft_models_search` (`model_name`,`segment`,`body_type`);

--
-- Indexes for table `model_pages`
--
ALTER TABLE `model_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `uq_model_pages_slug` (`slug`),
  ADD KEY `idx_model_pages_model` (`model_id`);

--
-- Indexes for table `oem_partnership_registry`
--
ALTER TABLE `oem_partnership_registry`
  ADD PRIMARY KEY (`partnership_id`);

--
-- Indexes for table `optional_accessories`
--
ALTER TABLE `optional_accessories`
  ADD PRIMARY KEY (`accessory_id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `ownership_calculators`
--
ALTER TABLE `ownership_calculators`
  ADD PRIMARY KEY (`calculator_id`),
  ADD KEY `idx_ownership_variant` (`variant_id`),
  ADD KEY `idx_ownership_user` (`user_identifier`);

--
-- Indexes for table `ownership_cost_history`
--
ALTER TABLE `ownership_cost_history`
  ADD PRIMARY KEY (`cost_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `region_id` (`region_id`);

--
-- Indexes for table `ownership_financial_forecasting`
--
ALTER TABLE `ownership_financial_forecasting`
  ADD PRIMARY KEY (`forecast_id`);

--
-- Indexes for table `ownership_specs`
--
ALTER TABLE `ownership_specs`
  ADD PRIMARY KEY (`ownership_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `performance_specs`
--
ALTER TABLE `performance_specs`
  ADD PRIMARY KEY (`performance_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `permit_compliance_rules`
--
ALTER TABLE `permit_compliance_rules`
  ADD PRIMARY KEY (`rule_id`),
  ADD KEY `idx_permit_region` (`region_id`);

--
-- Indexes for table `platform_global_score`
--
ALTER TABLE `platform_global_score`
  ADD PRIMARY KEY (`score_id`);

--
-- Indexes for table `popular_comparison_cache`
--
ALTER TABLE `popular_comparison_cache`
  ADD PRIMARY KEY (`comparison_id`);

--
-- Indexes for table `powertrain_configs`
--
ALTER TABLE `powertrain_configs`
  ADD PRIMARY KEY (`config_id`),
  ADD KEY `fk_powertrain_variant` (`variant_id`);

--
-- Indexes for table `powertrain_ev_details`
--
ALTER TABLE `powertrain_ev_details`
  ADD PRIMARY KEY (`config_id`);

--
-- Indexes for table `powertrain_fcev_details`
--
ALTER TABLE `powertrain_fcev_details`
  ADD PRIMARY KEY (`config_id`);

--
-- Indexes for table `powertrain_types`
--
ALTER TABLE `powertrain_types`
  ADD PRIMARY KEY (`powertrain_type_id`),
  ADD UNIQUE KEY `powertrain_name` (`powertrain_name`);

--
-- Indexes for table `predictive_maintenance_data`
--
ALTER TABLE `predictive_maintenance_data`
  ADD PRIMARY KEY (`maintenance_id`);

--
-- Indexes for table `raw_vehicle_data`
--
ALTER TABLE `raw_vehicle_data`
  ADD PRIMARY KEY (`raw_id`);

--
-- Indexes for table `recall_history`
--
ALTER TABLE `recall_history`
  ADD PRIMARY KEY (`recall_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `recommendation_personalization`
--
ALTER TABLE `recommendation_personalization`
  ADD PRIMARY KEY (`recommendation_id`);

--
-- Indexes for table `regional_market_data`
--
ALTER TABLE `regional_market_data`
  ADD PRIMARY KEY (`market_id`);

--
-- Indexes for table `reliability_scores`
--
ALTER TABLE `reliability_scores`
  ADD PRIMARY KEY (`reliability_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `idx_reliability_score` (`reliability_score`);

--
-- Indexes for table `route_profiles`
--
ALTER TABLE `route_profiles`
  ADD PRIMARY KEY (`route_profile_id`),
  ADD KEY `idx_route_name` (`route_name`);

--
-- Indexes for table `route_profitability_data`
--
ALTER TABLE `route_profitability_data`
  ADD PRIMARY KEY (`route_id`);

--
-- Indexes for table `safety_specs`
--
ALTER TABLE `safety_specs`
  ADD PRIMARY KEY (`safety_id`),
  ADD KEY `config_id` (`config_id`);

--
-- Indexes for table `saved_searches`
--
ALTER TABLE `saved_searches`
  ADD PRIMARY KEY (`search_id`);

--
-- Indexes for table `schema_change_log`
--
ALTER TABLE `schema_change_log`
  ADD PRIMARY KEY (`change_id`);

--
-- Indexes for table `schema_versions`
--
ALTER TABLE `schema_versions`
  ADD PRIMARY KEY (`version_id`);

--
-- Indexes for table `schema_version_control`
--
ALTER TABLE `schema_version_control`
  ADD PRIMARY KEY (`version_id`);

--
-- Indexes for table `scraper_orchestration_registry`
--
ALTER TABLE `scraper_orchestration_registry`
  ADD PRIMARY KEY (`scraper_id`);

--
-- Indexes for table `scrape_logs`
--
ALTER TABLE `scrape_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `source_id` (`source_id`);

--
-- Indexes for table `scrape_sources`
--
ALTER TABLE `scrape_sources`
  ADD PRIMARY KEY (`source_id`);

--
-- Indexes for table `search_analytics_cache`
--
ALTER TABLE `search_analytics_cache`
  ADD PRIMARY KEY (`cache_id`);

--
-- Indexes for table `search_optimized_variants`
--
ALTER TABLE `search_optimized_variants`
  ADD PRIMARY KEY (`variant_id`),
  ADD KEY `idx_price` (`price`),
  ADD KEY `idx_fuel` (`fuel_type`);
ALTER TABLE `search_optimized_variants` ADD FULLTEXT KEY `idx_variant_search` (`full_display_name`,`brand_name`,`model_name`,`search_vector`);

--
-- Indexes for table `segment_pages`
--
ALTER TABLE `segment_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `uq_segment_pages_slug` (`slug`);

--
-- Indexes for table `seo_content_pages`
--
ALTER TABLE `seo_content_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `seo_content_registry`
--
ALTER TABLE `seo_content_registry`
  ADD PRIMARY KEY (`page_id`);

--
-- Indexes for table `seo_keyword_clusters`
--
ALTER TABLE `seo_keyword_clusters`
  ADD PRIMARY KEY (`cluster_id`),
  ADD KEY `idx_keyword_cluster_page` (`target_page_slug`),
  ADD KEY `idx_keyword_cluster_keyword` (`keyword`);

--
-- Indexes for table `seo_page_performance`
--
ALTER TABLE `seo_page_performance`
  ADD PRIMARY KEY (`performance_id`);

--
-- Indexes for table `software_capabilities`
--
ALTER TABLE `software_capabilities`
  ADD PRIMARY KEY (`software_id`);

--
-- Indexes for table `source_conflict_resolution`
--
ALTER TABLE `source_conflict_resolution`
  ADD PRIMARY KEY (`conflict_id`);

--
-- Indexes for table `spec_attributes`
--
ALTER TABLE `spec_attributes`
  ADD PRIMARY KEY (`attribute_id`),
  ADD UNIQUE KEY `uq_category_attribute` (`category_id`,`attribute_name`),
  ADD KEY `idx_spec_attr_category` (`category_id`);

--
-- Indexes for table `spec_categories`
--
ALTER TABLE `spec_categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `uq_spec_category_name` (`category_name`);

--
-- Indexes for table `spec_chassis_dimensions`
--
ALTER TABLE `spec_chassis_dimensions`
  ADD PRIMARY KEY (`variant_id`);

--
-- Indexes for table `spec_definition`
--
ALTER TABLE `spec_definition`
  ADD PRIMARY KEY (`spec_id`);

--
-- Indexes for table `spec_ev_details`
--
ALTER TABLE `spec_ev_details`
  ADD PRIMARY KEY (`config_id`);

--
-- Indexes for table `spec_fcev_details`
--
ALTER TABLE `spec_fcev_details`
  ADD PRIMARY KEY (`config_id`);

--
-- Indexes for table `spec_gas_details`
--
ALTER TABLE `spec_gas_details`
  ADD PRIMARY KEY (`config_id`);

--
-- Indexes for table `spec_hybrid_details`
--
ALTER TABLE `spec_hybrid_details`
  ADD PRIMARY KEY (`config_id`);

--
-- Indexes for table `spec_ice_details`
--
ALTER TABLE `spec_ice_details`
  ADD PRIMARY KEY (`config_id`);

--
-- Indexes for table `spec_performance_efficiency`
--
ALTER TABLE `spec_performance_efficiency`
  ADD PRIMARY KEY (`config_id`);

--
-- Indexes for table `spec_validation_queue`
--
ALTER TABLE `spec_validation_queue`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `sponsored_dealer_listings`
--
ALTER TABLE `sponsored_dealer_listings`
  ADD PRIMARY KEY (`sponsored_listing_id`),
  ADD KEY `idx_sdl_dealer` (`dealer_id`),
  ADD KEY `idx_sdl_variant` (`variant_id`);

--
-- Indexes for table `sponsored_listings`
--
ALTER TABLE `sponsored_listings`
  ADD PRIMARY KEY (`sponsor_id`),
  ADD KEY `idx_sponsor_variant` (`variant_id`);

--
-- Indexes for table `suitability_scores`
--
ALTER TABLE `suitability_scores`
  ADD PRIMARY KEY (`variant_id`,`persona_id`),
  ADD KEY `persona_id` (`persona_id`);

--
-- Indexes for table `system_health_monitor`
--
ALTER TABLE `system_health_monitor`
  ADD PRIMARY KEY (`health_id`);

--
-- Indexes for table `taxation_rules`
--
ALTER TABLE `taxation_rules`
  ADD PRIMARY KEY (`tax_id`);

--
-- Indexes for table `test_drive_requests`
--
ALTER TABLE `test_drive_requests`
  ADD PRIMARY KEY (`request_id`);

--
-- Indexes for table `transmission_options`
--
ALTER TABLE `transmission_options`
  ADD PRIMARY KEY (`transmission_id`);

--
-- Indexes for table `user_behavior_tracking`
--
ALTER TABLE `user_behavior_tracking`
  ADD PRIMARY KEY (`event_id`);

--
-- Indexes for table `user_reviews`
--
ALTER TABLE `user_reviews`
  ADD PRIMARY KEY (`user_review_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `user_saved_comparisons`
--
ALTER TABLE `user_saved_comparisons`
  ADD PRIMARY KEY (`comparison_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `user_wishlist`
--
ALTER TABLE `user_wishlist`
  ADD PRIMARY KEY (`wishlist_id`);

--
-- Indexes for table `variants`
--
ALTER TABLE `variants`
  ADD PRIMARY KEY (`variant_id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD UNIQUE KEY `idx_v_slug` (`seo_slug`),
  ADD UNIQUE KEY `idx_variant_uuid` (`uuid`),
  ADD UNIQUE KEY `uk_variants_uuid` (`uuid`),
  ADD KEY `idx_variant_name` (`variant_name`),
  ADD KEY `idx_market_region` (`market_region`),
  ADD KEY `idx_variant_launch_status` (`launch_status`),
  ADD KEY `idx_variant_market_region` (`market_region`),
  ADD KEY `idx_variants_price` (`model_id`,`ex_showroom_price`),
  ADD KEY `idx_variants_slug` (`slug`),
  ADD KEY `idx_variants_launch_status` (`launch_status`),
  ADD KEY `idx_variants_soft_delete` (`is_deleted`,`deleted_at`),
  ADD KEY `idx_v_price` (`ex_showroom_price`,`on_road_price`),
  ADD KEY `idx_v_fuel_power` (`fuel_type_id`,`powertrain_type_id`),
  ADD KEY `idx_v_logic` (`is_deleted`,`launch_status`),
  ADD KEY `idx_variants_region_price` (`market_region`,`ex_showroom_price`),
  ADD KEY `idx_variant_model` (`model_id`),
  ADD KEY `idx_variant_slug` (`slug`);
ALTER TABLE `variants` ADD FULLTEXT KEY `ft_variants_search` (`variant_name`);

--
-- Indexes for table `variant_accessory_map`
--
ALTER TABLE `variant_accessory_map`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `accessory_id` (`accessory_id`);

--
-- Indexes for table `variant_color_map`
--
ALTER TABLE `variant_color_map`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `color_id` (`color_id`);

--
-- Indexes for table `variant_configurations`
--
ALTER TABLE `variant_configurations`
  ADD PRIMARY KEY (`config_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `transmission_id` (`transmission_id`),
  ADD KEY `idx_powertrain_type` (`powertrain_type_id`),
  ADD KEY `idx_drivetrain_type` (`drivetrain_id`);

--
-- Indexes for table `variant_feature_map`
--
ALTER TABLE `variant_feature_map`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_variant_feature` (`variant_id`,`feature_id`),
  ADD KEY `feature_id` (`feature_id`),
  ADD KEY `idx_vf_map` (`variant_id`,`feature_id`);

--
-- Indexes for table `variant_feature_matrix`
--
ALTER TABLE `variant_feature_matrix`
  ADD PRIMARY KEY (`variant_id`,`feature_id`),
  ADD KEY `feature_id` (`feature_id`);

--
-- Indexes for table `variant_feature_package_map`
--
ALTER TABLE `variant_feature_package_map`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `package_id` (`package_id`);

--
-- Indexes for table `variant_pages`
--
ALTER TABLE `variant_pages`
  ADD PRIMARY KEY (`page_id`),
  ADD UNIQUE KEY `uq_variant_pages_slug` (`slug`),
  ADD KEY `idx_variant_pages_variant` (`variant_id`);

--
-- Indexes for table `variant_price_history`
--
ALTER TABLE `variant_price_history`
  ADD PRIMARY KEY (`price_history_id`),
  ADD KEY `region_id` (`region_id`),
  ADD KEY `idx_variant_price_history_variant` (`variant_id`),
  ADD KEY `fk_variant_price_country` (`country_id`),
  ADD KEY `idx_price_variant_country` (`variant_id`,`country_id`);

--
-- Indexes for table `variant_spec_ledger`
--
ALTER TABLE `variant_spec_ledger`
  ADD PRIMARY KEY (`value_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `spec_id` (`spec_id`);

--
-- Indexes for table `variant_spec_values`
--
ALTER TABLE `variant_spec_values`
  ADD PRIMARY KEY (`value_id`),
  ADD UNIQUE KEY `uq_variant_attribute` (`variant_id`,`attribute_id`),
  ADD KEY `idx_vsv_variant` (`variant_id`),
  ADD KEY `idx_vsv_attribute` (`attribute_id`),
  ADD KEY `idx_vsv_source` (`source_id`),
  ADD KEY `idx_v_specs` (`variant_id`,`attribute_id`),
  ADD KEY `idx_specs_confidence` (`confidence_score`),
  ADD KEY `idx_spec_variant_attribute` (`variant_id`,`attribute_id`);

--
-- Indexes for table `variant_suitability_scores`
--
ALTER TABLE `variant_suitability_scores`
  ADD PRIMARY KEY (`variant_id`,`persona_id`),
  ADD KEY `persona_id` (`persona_id`);

--
-- Indexes for table `vehicle_media`
--
ALTER TABLE `vehicle_media`
  ADD PRIMARY KEY (`media_id`),
  ADD KEY `variant_id` (`variant_id`),
  ADD KEY `source_id` (`source_id`);

--
-- Indexes for table `verified_user_reviews`
--
ALTER TABLE `verified_user_reviews`
  ADD PRIMARY KEY (`review_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_audit_logs`
--
ALTER TABLE `admin_audit_logs`
  MODIFY `log_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_attribute_extraction`
--
ALTER TABLE `ai_attribute_extraction`
  MODIFY `extraction_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_metadata`
--
ALTER TABLE `ai_metadata`
  MODIFY `ai_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_population_pipeline`
--
ALTER TABLE `ai_population_pipeline`
  MODIFY `pipeline_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_training_feedback`
--
ALTER TABLE `ai_training_feedback`
  MODIFY `feedback_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `api_performance_logs`
--
ALTER TABLE `api_performance_logs`
  MODIFY `log_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `autonomous_system_specs`
--
ALTER TABLE `autonomous_system_specs`
  MODIFY `autonomous_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `buyer_behavior_analytics`
--
ALTER TABLE `buyer_behavior_analytics`
  MODIFY `behavior_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `buyer_personas`
--
ALTER TABLE `buyer_personas`
  MODIFY `persona_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `buyer_persona_profiles`
--
ALTER TABLE `buyer_persona_profiles`
  MODIFY `persona_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `buyer_recommendation_logs`
--
ALTER TABLE `buyer_recommendation_logs`
  MODIFY `recommendation_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `buying_guides`
--
ALTER TABLE `buying_guides`
  MODIFY `guide_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cargo_body_compatibility`
--
ALTER TABLE `cargo_body_compatibility`
  MODIFY `compatibility_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chassis_specs`
--
ALTER TABLE `chassis_specs`
  MODIFY `chassis_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `city_price_pages`
--
ALTER TABLE `city_price_pages`
  MODIFY `page_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `color_options`
--
ALTER TABLE `color_options`
  MODIFY `color_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `commercial_permit_data`
--
ALTER TABLE `commercial_permit_data`
  MODIFY `permit_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `comparison_history`
--
ALTER TABLE `comparison_history`
  MODIFY `comparison_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `comparison_pages`
--
ALTER TABLE `comparison_pages`
  MODIFY `page_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `competitor_mapping`
--
ALTER TABLE `competitor_mapping`
  MODIFY `mapping_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `competitor_market_tracking`
--
ALTER TABLE `competitor_market_tracking`
  MODIFY `competitor_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `compliance_certifications`
--
ALTER TABLE `compliance_certifications`
  MODIFY `certification_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `compliance_framework`
--
ALTER TABLE `compliance_framework`
  MODIFY `compliance_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `content_localization`
--
ALTER TABLE `content_localization`
  MODIFY `localization_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `country_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `country_pricing`
--
ALTER TABLE `country_pricing`
  MODIFY `pricing_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `data_freshness_scores`
--
ALTER TABLE `data_freshness_scores`
  MODIFY `freshness_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `data_quality_control`
--
ALTER TABLE `data_quality_control`
  MODIFY `quality_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `data_source_governance`
--
ALTER TABLE `data_source_governance`
  MODIFY `source_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealers`
--
ALTER TABLE `dealers`
  MODIFY `dealer_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealer_city_pages`
--
ALTER TABLE `dealer_city_pages`
  MODIFY `page_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealer_inquiries`
--
ALTER TABLE `dealer_inquiries`
  MODIFY `inquiry_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealer_inventory`
--
ALTER TABLE `dealer_inventory`
  MODIFY `inventory_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealer_promotions`
--
ALTER TABLE `dealer_promotions`
  MODIFY `promotion_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealer_ratings`
--
ALTER TABLE `dealer_ratings`
  MODIFY `rating_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealer_subscription_plans`
--
ALTER TABLE `dealer_subscription_plans`
  MODIFY `subscription_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealer_subscription_tiers`
--
ALTER TABLE `dealer_subscription_tiers`
  MODIFY `tier_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealer_tenants`
--
ALTER TABLE `dealer_tenants`
  MODIFY `dealer_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `drivetrain_options`
--
ALTER TABLE `drivetrain_options`
  MODIFY `drivetrain_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `duplicate_detection_registry`
--
ALTER TABLE `duplicate_detection_registry`
  MODIFY `duplicate_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `enterprise_scorecard`
--
ALTER TABLE `enterprise_scorecard`
  MODIFY `scorecard_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ev_infrastructure_support`
--
ALTER TABLE `ev_infrastructure_support`
  MODIFY `infra_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ev_specs`
--
ALTER TABLE `ev_specs`
  MODIFY `ev_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `executive_dashboard_cache`
--
ALTER TABLE `executive_dashboard_cache`
  MODIFY `dashboard_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expert_reviews`
--
ALTER TABLE `expert_reviews`
  MODIFY `review_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `external_api_registry`
--
ALTER TABLE `external_api_registry`
  MODIFY `api_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fake_review_detection`
--
ALTER TABLE `fake_review_detection`
  MODIFY `detection_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fcev_specs`
--
ALTER TABLE `fcev_specs`
  MODIFY `fcev_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `features`
--
ALTER TABLE `features`
  MODIFY `feature_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `feature_groups`
--
ALTER TABLE `feature_groups`
  MODIFY `group_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `feature_packages`
--
ALTER TABLE `feature_packages`
  MODIFY `package_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `finance_quote_requests`
--
ALTER TABLE `finance_quote_requests`
  MODIFY `quote_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `financing_products`
--
ALTER TABLE `financing_products`
  MODIFY `finance_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fintech_lenders`
--
ALTER TABLE `fintech_lenders`
  MODIFY `lender_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fleet_management_data`
--
ALTER TABLE `fleet_management_data`
  MODIFY `fleet_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fleet_operations`
--
ALTER TABLE `fleet_operations`
  MODIFY `fleet_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fleet_profitability_scores`
--
ALTER TABLE `fleet_profitability_scores`
  MODIFY `score_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `global_attribute_taxonomy`
--
ALTER TABLE `global_attribute_taxonomy`
  MODIFY `taxonomy_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hybrid_specs`
--
ALTER TABLE `hybrid_specs`
  MODIFY `hybrid_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ice_engine_specs`
--
ALTER TABLE `ice_engine_specs`
  MODIFY `engine_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `insurance_finance_marketplace`
--
ALTER TABLE `insurance_finance_marketplace`
  MODIFY `offer_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `insurance_products`
--
ALTER TABLE `insurance_products`
  MODIFY `insurance_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `insurance_quote_requests`
--
ALTER TABLE `insurance_quote_requests`
  MODIFY `quote_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `interior_specs`
--
ALTER TABLE `interior_specs`
  MODIFY `interior_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_live`
--
ALTER TABLE `inventory_live`
  MODIFY `stock_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lead_funnel`
--
ALTER TABLE `lead_funnel`
  MODIFY `lead_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lead_management`
--
ALTER TABLE `lead_management`
  MODIFY `lead_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lender_products`
--
ALTER TABLE `lender_products`
  MODIFY `lender_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `maintenance_guides`
--
ALTER TABLE `maintenance_guides`
  MODIFY `guide_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manual_audit_queue`
--
ALTER TABLE `manual_audit_queue`
  MODIFY `audit_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `market_demand_forecasts`
--
ALTER TABLE `market_demand_forecasts`
  MODIFY `forecast_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `market_regions`
--
ALTER TABLE `market_regions`
  MODIFY `region_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `market_trend_forecasting`
--
ALTER TABLE `market_trend_forecasting`
  MODIFY `trend_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migration_audit_log`
--
ALTER TABLE `migration_audit_log`
  MODIFY `audit_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `models`
--
ALTER TABLE `models`
  MODIFY `model_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `oem_partnership_registry`
--
ALTER TABLE `oem_partnership_registry`
  MODIFY `partnership_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `optional_accessories`
--
ALTER TABLE `optional_accessories`
  MODIFY `accessory_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ownership_cost_history`
--
ALTER TABLE `ownership_cost_history`
  MODIFY `cost_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ownership_financial_forecasting`
--
ALTER TABLE `ownership_financial_forecasting`
  MODIFY `forecast_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ownership_specs`
--
ALTER TABLE `ownership_specs`
  MODIFY `ownership_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `performance_specs`
--
ALTER TABLE `performance_specs`
  MODIFY `performance_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `platform_global_score`
--
ALTER TABLE `platform_global_score`
  MODIFY `score_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `popular_comparison_cache`
--
ALTER TABLE `popular_comparison_cache`
  MODIFY `comparison_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `powertrain_configs`
--
ALTER TABLE `powertrain_configs`
  MODIFY `config_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `powertrain_types`
--
ALTER TABLE `powertrain_types`
  MODIFY `powertrain_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `predictive_maintenance_data`
--
ALTER TABLE `predictive_maintenance_data`
  MODIFY `maintenance_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `raw_vehicle_data`
--
ALTER TABLE `raw_vehicle_data`
  MODIFY `raw_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recall_history`
--
ALTER TABLE `recall_history`
  MODIFY `recall_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recommendation_personalization`
--
ALTER TABLE `recommendation_personalization`
  MODIFY `recommendation_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `regional_market_data`
--
ALTER TABLE `regional_market_data`
  MODIFY `market_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reliability_scores`
--
ALTER TABLE `reliability_scores`
  MODIFY `reliability_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `route_profitability_data`
--
ALTER TABLE `route_profitability_data`
  MODIFY `route_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `safety_specs`
--
ALTER TABLE `safety_specs`
  MODIFY `safety_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `saved_searches`
--
ALTER TABLE `saved_searches`
  MODIFY `search_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schema_change_log`
--
ALTER TABLE `schema_change_log`
  MODIFY `change_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schema_versions`
--
ALTER TABLE `schema_versions`
  MODIFY `version_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `schema_version_control`
--
ALTER TABLE `schema_version_control`
  MODIFY `version_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `scraper_orchestration_registry`
--
ALTER TABLE `scraper_orchestration_registry`
  MODIFY `scraper_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scrape_logs`
--
ALTER TABLE `scrape_logs`
  MODIFY `log_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `scrape_sources`
--
ALTER TABLE `scrape_sources`
  MODIFY `source_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `search_analytics_cache`
--
ALTER TABLE `search_analytics_cache`
  MODIFY `cache_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seo_content_pages`
--
ALTER TABLE `seo_content_pages`
  MODIFY `page_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seo_content_registry`
--
ALTER TABLE `seo_content_registry`
  MODIFY `page_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seo_page_performance`
--
ALTER TABLE `seo_page_performance`
  MODIFY `performance_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `software_capabilities`
--
ALTER TABLE `software_capabilities`
  MODIFY `software_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `source_conflict_resolution`
--
ALTER TABLE `source_conflict_resolution`
  MODIFY `conflict_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `spec_attributes`
--
ALTER TABLE `spec_attributes`
  MODIFY `attribute_id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5009;

--
-- AUTO_INCREMENT for table `spec_categories`
--
ALTER TABLE `spec_categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- AUTO_INCREMENT for table `spec_definition`
--
ALTER TABLE `spec_definition`
  MODIFY `spec_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `spec_validation_queue`
--
ALTER TABLE `spec_validation_queue`
  MODIFY `audit_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sponsored_listings`
--
ALTER TABLE `sponsored_listings`
  MODIFY `sponsor_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_health_monitor`
--
ALTER TABLE `system_health_monitor`
  MODIFY `health_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `taxation_rules`
--
ALTER TABLE `taxation_rules`
  MODIFY `tax_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `test_drive_requests`
--
ALTER TABLE `test_drive_requests`
  MODIFY `request_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transmission_options`
--
ALTER TABLE `transmission_options`
  MODIFY `transmission_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_behavior_tracking`
--
ALTER TABLE `user_behavior_tracking`
  MODIFY `event_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_reviews`
--
ALTER TABLE `user_reviews`
  MODIFY `user_review_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_saved_comparisons`
--
ALTER TABLE `user_saved_comparisons`
  MODIFY `comparison_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_wishlist`
--
ALTER TABLE `user_wishlist`
  MODIFY `wishlist_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variants`
--
ALTER TABLE `variants`
  MODIFY `variant_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variant_accessory_map`
--
ALTER TABLE `variant_accessory_map`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variant_color_map`
--
ALTER TABLE `variant_color_map`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variant_configurations`
--
ALTER TABLE `variant_configurations`
  MODIFY `config_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variant_feature_map`
--
ALTER TABLE `variant_feature_map`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variant_feature_package_map`
--
ALTER TABLE `variant_feature_package_map`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variant_price_history`
--
ALTER TABLE `variant_price_history`
  MODIFY `price_history_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variant_spec_ledger`
--
ALTER TABLE `variant_spec_ledger`
  MODIFY `value_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variant_spec_values`
--
ALTER TABLE `variant_spec_values`
  MODIFY `value_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vehicle_media`
--
ALTER TABLE `vehicle_media`
  MODIFY `media_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `verified_user_reviews`
--
ALTER TABLE `verified_user_reviews`
  MODIFY `review_id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ai_metadata`
--
ALTER TABLE `ai_metadata`
  ADD CONSTRAINT `ai_metadata_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ai_training_feedback`
--
ALTER TABLE `ai_training_feedback`
  ADD CONSTRAINT `ai_training_feedback_ibfk_1` FOREIGN KEY (`extraction_id`) REFERENCES `ai_attribute_extraction` (`extraction_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `chassis_specs`
--
ALTER TABLE `chassis_specs`
  ADD CONSTRAINT `chassis_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `competitor_mapping`
--
ALTER TABLE `competitor_mapping`
  ADD CONSTRAINT `competitor_mapping_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `competitor_mapping_ibfk_2` FOREIGN KEY (`competitor_variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `compliance_certifications`
--
ALTER TABLE `compliance_certifications`
  ADD CONSTRAINT `compliance_certifications_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `country_pricing`
--
ALTER TABLE `country_pricing`
  ADD CONSTRAINT `country_pricing_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `dealers`
--
ALTER TABLE `dealers`
  ADD CONSTRAINT `dealers_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `dealer_inventory`
--
ALTER TABLE `dealer_inventory`
  ADD CONSTRAINT `dealer_inventory_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_dealer_inventory_dealer` FOREIGN KEY (`dealer_id`) REFERENCES `dealers` (`dealer_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `dealer_tenants`
--
ALTER TABLE `dealer_tenants`
  ADD CONSTRAINT `fk_dealer_tenants_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `ev_specs`
--
ALTER TABLE `ev_specs`
  ADD CONSTRAINT `ev_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `expert_reviews`
--
ALTER TABLE `expert_reviews`
  ADD CONSTRAINT `expert_reviews_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `fcev_specs`
--
ALTER TABLE `fcev_specs`
  ADD CONSTRAINT `fcev_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `features`
--
ALTER TABLE `features`
  ADD CONSTRAINT `fk_features_group` FOREIGN KEY (`group_id`) REFERENCES `feature_groups` (`group_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_features_parent` FOREIGN KEY (`parent_feature_id`) REFERENCES `features` (`feature_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `financing_products`
--
ALTER TABLE `financing_products`
  ADD CONSTRAINT `financing_products_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `hybrid_specs`
--
ALTER TABLE `hybrid_specs`
  ADD CONSTRAINT `hybrid_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ice_engine_specs`
--
ALTER TABLE `ice_engine_specs`
  ADD CONSTRAINT `ice_engine_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `insurance_products`
--
ALTER TABLE `insurance_products`
  ADD CONSTRAINT `insurance_products_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `interior_specs`
--
ALTER TABLE `interior_specs`
  ADD CONSTRAINT `interior_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `inventory_live`
--
ALTER TABLE `inventory_live`
  ADD CONSTRAINT `fk_inventory_live_variant` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `inventory_live_ibfk_1` FOREIGN KEY (`dealer_id`) REFERENCES `dealer_tenants` (`dealer_id`);

--
-- Constraints for table `legacy_car_models_backup`
--
ALTER TABLE `legacy_car_models_backup`
  ADD CONSTRAINT `fk_car_models_make` FOREIGN KEY (`make_id`) REFERENCES `brands` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `legacy_car_variants_backup`
--
ALTER TABLE `legacy_car_variants_backup`
  ADD CONSTRAINT `fk_car_variants_make` FOREIGN KEY (`make_id`) REFERENCES `brands` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_car_variants_model` FOREIGN KEY (`model_id`) REFERENCES `legacy_car_models_backup` (`model_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `models`
--
ALTER TABLE `models`
  ADD CONSTRAINT `models_ibfk_1` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ownership_cost_history`
--
ALTER TABLE `ownership_cost_history`
  ADD CONSTRAINT `ownership_cost_history_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ownership_cost_history_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `market_regions` (`region_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `ownership_specs`
--
ALTER TABLE `ownership_specs`
  ADD CONSTRAINT `ownership_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `performance_specs`
--
ALTER TABLE `performance_specs`
  ADD CONSTRAINT `performance_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `powertrain_configs`
--
ALTER TABLE `powertrain_configs`
  ADD CONSTRAINT `fk_powertrain_variant` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `powertrain_ev_details`
--
ALTER TABLE `powertrain_ev_details`
  ADD CONSTRAINT `powertrain_ev_details_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `powertrain_configs` (`config_id`);

--
-- Constraints for table `powertrain_fcev_details`
--
ALTER TABLE `powertrain_fcev_details`
  ADD CONSTRAINT `powertrain_fcev_details_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `powertrain_configs` (`config_id`);

--
-- Constraints for table `recall_history`
--
ALTER TABLE `recall_history`
  ADD CONSTRAINT `recall_history_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `reliability_scores`
--
ALTER TABLE `reliability_scores`
  ADD CONSTRAINT `reliability_scores_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `safety_specs`
--
ALTER TABLE `safety_specs`
  ADD CONSTRAINT `safety_specs_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `variant_configurations` (`config_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `scrape_logs`
--
ALTER TABLE `scrape_logs`
  ADD CONSTRAINT `scrape_logs_ibfk_1` FOREIGN KEY (`source_id`) REFERENCES `scrape_sources` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `search_optimized_variants`
--
ALTER TABLE `search_optimized_variants`
  ADD CONSTRAINT `search_optimized_variants_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variant_master` (`variant_id`);

--
-- Constraints for table `spec_attributes`
--
ALTER TABLE `spec_attributes`
  ADD CONSTRAINT `fk_spec_attributes_category` FOREIGN KEY (`category_id`) REFERENCES `spec_categories` (`category_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `spec_chassis_dimensions`
--
ALTER TABLE `spec_chassis_dimensions`
  ADD CONSTRAINT `spec_chassis_dimensions_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variant_master` (`variant_id`) ON DELETE CASCADE;

--
-- Constraints for table `spec_ev_details`
--
ALTER TABLE `spec_ev_details`
  ADD CONSTRAINT `spec_ev_details_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `powertrain_configs` (`config_id`) ON DELETE CASCADE;

--
-- Constraints for table `spec_fcev_details`
--
ALTER TABLE `spec_fcev_details`
  ADD CONSTRAINT `spec_fcev_details_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `powertrain_configs` (`config_id`) ON DELETE CASCADE;

--
-- Constraints for table `spec_gas_details`
--
ALTER TABLE `spec_gas_details`
  ADD CONSTRAINT `spec_gas_details_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `powertrain_configs` (`config_id`) ON DELETE CASCADE;

--
-- Constraints for table `spec_hybrid_details`
--
ALTER TABLE `spec_hybrid_details`
  ADD CONSTRAINT `spec_hybrid_details_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `powertrain_configs` (`config_id`) ON DELETE CASCADE;

--
-- Constraints for table `spec_ice_details`
--
ALTER TABLE `spec_ice_details`
  ADD CONSTRAINT `spec_ice_details_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `powertrain_configs` (`config_id`) ON DELETE CASCADE;

--
-- Constraints for table `spec_performance_efficiency`
--
ALTER TABLE `spec_performance_efficiency`
  ADD CONSTRAINT `spec_performance_efficiency_ibfk_1` FOREIGN KEY (`config_id`) REFERENCES `powertrain_configs` (`config_id`) ON DELETE CASCADE;

--
-- Constraints for table `suitability_scores`
--
ALTER TABLE `suitability_scores`
  ADD CONSTRAINT `suitability_scores_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variant_master` (`variant_id`),
  ADD CONSTRAINT `suitability_scores_ibfk_2` FOREIGN KEY (`persona_id`) REFERENCES `buyer_personas` (`persona_id`);

--
-- Constraints for table `user_reviews`
--
ALTER TABLE `user_reviews`
  ADD CONSTRAINT `user_reviews_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `user_saved_comparisons`
--
ALTER TABLE `user_saved_comparisons`
  ADD CONSTRAINT `user_saved_comparisons_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `variants`
--
ALTER TABLE `variants`
  ADD CONSTRAINT `variants_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `models` (`model_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `variant_accessory_map`
--
ALTER TABLE `variant_accessory_map`
  ADD CONSTRAINT `variant_accessory_map_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `variant_accessory_map_ibfk_2` FOREIGN KEY (`accessory_id`) REFERENCES `optional_accessories` (`accessory_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `variant_color_map`
--
ALTER TABLE `variant_color_map`
  ADD CONSTRAINT `variant_color_map_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `variant_color_map_ibfk_2` FOREIGN KEY (`color_id`) REFERENCES `color_options` (`color_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `variant_configurations`
--
ALTER TABLE `variant_configurations`
  ADD CONSTRAINT `variant_configurations_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `variant_configurations_ibfk_2` FOREIGN KEY (`powertrain_type_id`) REFERENCES `powertrain_types` (`powertrain_type_id`),
  ADD CONSTRAINT `variant_configurations_ibfk_3` FOREIGN KEY (`drivetrain_id`) REFERENCES `drivetrain_options` (`drivetrain_id`),
  ADD CONSTRAINT `variant_configurations_ibfk_4` FOREIGN KEY (`transmission_id`) REFERENCES `transmission_options` (`transmission_id`);

--
-- Constraints for table `variant_feature_map`
--
ALTER TABLE `variant_feature_map`
  ADD CONSTRAINT `variant_feature_map_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `variant_feature_map_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `features` (`feature_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `variant_feature_matrix`
--
ALTER TABLE `variant_feature_matrix`
  ADD CONSTRAINT `variant_feature_matrix_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variant_master` (`variant_id`),
  ADD CONSTRAINT `variant_feature_matrix_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `feature_master` (`feature_id`);

--
-- Constraints for table `variant_feature_package_map`
--
ALTER TABLE `variant_feature_package_map`
  ADD CONSTRAINT `variant_feature_package_map_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `variant_feature_package_map_ibfk_2` FOREIGN KEY (`package_id`) REFERENCES `feature_packages` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `variant_price_history`
--
ALTER TABLE `variant_price_history`
  ADD CONSTRAINT `fk_variant_price_country` FOREIGN KEY (`country_id`) REFERENCES `countries` (`country_id`),
  ADD CONSTRAINT `variant_price_history_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `variant_price_history_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `market_regions` (`region_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `variant_spec_ledger`
--
ALTER TABLE `variant_spec_ledger`
  ADD CONSTRAINT `variant_spec_ledger_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variant_master` (`variant_id`),
  ADD CONSTRAINT `variant_spec_ledger_ibfk_2` FOREIGN KEY (`spec_id`) REFERENCES `spec_definition` (`spec_id`);

--
-- Constraints for table `variant_spec_values`
--
ALTER TABLE `variant_spec_values`
  ADD CONSTRAINT `fk_vsv_attribute` FOREIGN KEY (`attribute_id`) REFERENCES `spec_attributes` (`attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_vsv_source` FOREIGN KEY (`source_id`) REFERENCES `scrape_sources` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_vsv_variant` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `variant_suitability_scores`
--
ALTER TABLE `variant_suitability_scores`
  ADD CONSTRAINT `variant_suitability_scores_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variant_master` (`variant_id`),
  ADD CONSTRAINT `variant_suitability_scores_ibfk_2` FOREIGN KEY (`persona_id`) REFERENCES `buyer_personas` (`persona_id`);

--
-- Constraints for table `vehicle_media`
--
ALTER TABLE `vehicle_media`
  ADD CONSTRAINT `vehicle_media_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`variant_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `vehicle_media_ibfk_2` FOREIGN KEY (`source_id`) REFERENCES `scrape_sources` (`source_id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
