-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 24, 2025 at 08:29 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `autopredator`
--
CREATE DATABASE IF NOT EXISTS `autopredator` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `autopredator`;

-- --------------------------------------------------------

--
-- Table structure for table `features`
--

CREATE TABLE `features` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `two_wheeler_manufacturers`
--

CREATE TABLE `two_wheeler_manufacturers` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `country` varchar(50) DEFAULT NULL,
  `parent_brand` varchar(100) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `two_wheeler_models`
--

CREATE TABLE `two_wheeler_models` (
  `id` int(11) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `vehicle_type` enum('Motorcycle','Scooter','Moped','EV_Scooter') NOT NULL,
  `segment` varchar(50) DEFAULT NULL,
  `body_style` varchar(50) DEFAULT NULL,
  `launch_year` year(4) DEFAULT NULL,
  `discontinue_year` year(4) DEFAULT NULL,
  `bs_norm` enum('BS3','BS4','BS6','BS6_2','Other') DEFAULT NULL,
  `status` enum('Current','Discontinued','Upcoming') DEFAULT 'Current',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `two_wheeler_specs`
--

CREATE TABLE `two_wheeler_specs` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `engine_type` varchar(100) DEFAULT NULL,
  `engine_displacement_cc` int(11) DEFAULT NULL,
  `engine_configuration` enum('Single','ParallelTwin','VTwin','Inline3','Inline4','Other') DEFAULT 'Single',
  `cooling_type` enum('Air','Oil','Liquid','AirOil','Other') DEFAULT NULL,
  `max_power_bhp` varchar(50) DEFAULT NULL,
  `max_torque_nm` varchar(50) DEFAULT NULL,
  `compression_ratio` varchar(20) DEFAULT NULL,
  `number_of_gears` tinyint(4) DEFAULT NULL,
  `final_drive_type` enum('Chain','Belt','Shaft') DEFAULT NULL,
  `ignition_type` varchar(50) DEFAULT NULL,
  `starting_mechanism` enum('Kick','Self','KickAndSelf') DEFAULT NULL,
  `emission_standard` enum('BS3','BS4','BS6','BS6_2','Other') DEFAULT NULL,
  `clutch_type` enum('Wet','Dry','Slipper','AssistSlipper','Automatic') DEFAULT NULL,
  `fuel_system` varchar(50) DEFAULT NULL,
  `battery_capacity_kwh` decimal(5,2) DEFAULT NULL,
  `battery_type` varchar(50) DEFAULT NULL,
  `ev_range_km` int(11) DEFAULT NULL,
  `electric_motor_power_kw` decimal(5,2) DEFAULT NULL,
  `electric_motor_torque_nm` decimal(5,2) DEFAULT NULL,
  `charging_time_0_80_hr` decimal(4,2) DEFAULT NULL,
  `charging_standard` varchar(50) DEFAULT NULL,
  `top_speed_kmph` int(11) DEFAULT NULL,
  `acceleration_0_60_kmph` decimal(4,2) DEFAULT NULL,
  `city_mileage_kmpl` decimal(5,2) DEFAULT NULL,
  `highway_mileage_kmpl` decimal(5,2) DEFAULT NULL,
  `frame_type` varchar(100) DEFAULT NULL,
  `front_suspension` varchar(100) DEFAULT NULL,
  `rear_suspension` varchar(100) DEFAULT NULL,
  `front_brake_type` enum('Disc','Drum') DEFAULT NULL,
  `rear_brake_type` enum('Disc','Drum') DEFAULT NULL,
  `front_brake_diameter_mm` int(11) DEFAULT NULL,
  `rear_brake_diameter_mm` int(11) DEFAULT NULL,
  `has_abs` tinyint(1) DEFAULT NULL,
  `has_cornering_abs` tinyint(1) DEFAULT NULL,
  `has_traction_control` tinyint(1) DEFAULT NULL,
  `has_wheelie_control` tinyint(1) DEFAULT NULL,
  `has_ride_by_wire` tinyint(1) DEFAULT NULL,
  `has_slipper_clutch` tinyint(1) DEFAULT NULL,
  `has_quickshifter_up` tinyint(1) DEFAULT NULL,
  `has_quickshifter_down` tinyint(1) DEFAULT NULL,
  `has_cruise_control` tinyint(1) DEFAULT NULL,
  `has_engine_idle_start_stop` tinyint(1) DEFAULT NULL,
  `has_hill_hold_control` tinyint(1) DEFAULT NULL,
  `riding_modes` varchar(255) DEFAULT NULL,
  `front_tyre_size` varchar(50) DEFAULT NULL,
  `front_tyre_type` enum('Tubeless','Tube','RadialTubeless','RadialTube','Other') DEFAULT NULL,
  `rear_tyre_size` varchar(50) DEFAULT NULL,
  `rear_tyre_type` enum('Tubeless','Tube','RadialTubeless','RadialTube','Other') DEFAULT NULL,
  `tyre_usage_category` enum('Road','Offroad','DualPurpose','Track','Scooter','Touring') DEFAULT NULL,
  `wheel_type` enum('Alloy','Spoke','Steel') DEFAULT NULL,
  `front_wheel_size_inch` decimal(4,1) DEFAULT NULL,
  `rear_wheel_size_inch` decimal(4,1) DEFAULT NULL,
  `length_mm` int(11) DEFAULT NULL,
  `width_mm` int(11) DEFAULT NULL,
  `height_mm` int(11) DEFAULT NULL,
  `wheelbase_mm` int(11) DEFAULT NULL,
  `ground_clearance_mm` int(11) DEFAULT NULL,
  `seat_height_mm` int(11) DEFAULT NULL,
  `seat_type` enum('SinglePiece','SplitSeat','StepUp','ScooterLong','CruiserWide','Other') DEFAULT NULL,
  `pillion_grabrail` tinyint(1) DEFAULT NULL,
  `pillion_backrest` tinyint(1) DEFAULT NULL,
  `handlebar_type` varchar(50) DEFAULT NULL,
  `footpeg_position` enum('Neutral','RearSet','ForwardSet','MidSet') DEFAULT NULL,
  `windshield_type` varchar(100) DEFAULT NULL,
  `kerb_weight_kg` int(11) DEFAULT NULL,
  `fuel_tank_capacity_ltr` decimal(5,2) DEFAULT NULL,
  `underseat_storage_ltr` decimal(5,2) DEFAULT NULL,
  `front_storage_pockets` tinyint(1) DEFAULT NULL,
  `helmet_hook` tinyint(1) DEFAULT NULL,
  `luggage_mount_points` tinyint(1) DEFAULT NULL,
  `warranty_years` decimal(3,1) DEFAULT NULL,
  `warranty_km` int(11) DEFAULT NULL,
  `service_interval_km` int(11) DEFAULT NULL,
  `service_interval_months` int(11) DEFAULT NULL,
  `lighting_type` enum('Halogen','LED','Projector','Xenon') DEFAULT NULL,
  `instrument_cluster` varchar(100) DEFAULT NULL,
  `has_bluetooth_connectivity` tinyint(1) DEFAULT NULL,
  `has_navigation` tinyint(1) DEFAULT NULL,
  `has_usb_charging` tinyint(1) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `two_wheeler_variants`
--

CREATE TABLE `two_wheeler_variants` (
  `id` int(11) NOT NULL,
  `model_id` int(11) NOT NULL,
  `variant_name` varchar(100) NOT NULL,
  `fuel_type` enum('Petrol','Electric','Hybrid','FuelCell') NOT NULL DEFAULT 'Petrol',
  `transmission` enum('Manual','Automatic','CVT','Belt','DirectDrive') NOT NULL,
  `power` varchar(30) DEFAULT NULL,
  `mileage_or_range` varchar(30) DEFAULT NULL,
  `ex_showroom_price` decimal(10,2) DEFAULT NULL,
  `on_road_price` decimal(10,2) DEFAULT NULL,
  `abs_type` enum('None','SingleChannel','DualChannel','Cornering') DEFAULT 'None',
  `status` enum('Current','Discontinued') DEFAULT 'Current',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `two_wheeler_variant_features`
--

CREATE TABLE `two_wheeler_variant_features` (
  `variant_id` int(11) NOT NULL,
  `feature_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `user_type` enum('Buyer','Seller','Dealer') DEFAULT NULL,
  `registration_date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `email`, `password_hash`, `phone_number`, `address`, `user_type`, `registration_date`) VALUES
(1, 'John Doe', 'john@example.com', '$2y$10$examplehash1', '1234567890', '123 Main St, City', 'Buyer', '2025-10-25 11:35:11'),
(2, 'Jane Smith', 'jane@example.com', '$2y$10$examplehash2', '0987654321', '456 Elm St, City', 'Seller', '2025-10-25 11:35:11'),
(3, 'Auto Dealer', 'dealer@example.com', '$2y$10$examplehash3', '1122334455', '789 Oak St, City', 'Dealer', '2025-10-25 11:35:11');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `features`
--
ALTER TABLE `features`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `two_wheeler_manufacturers`
--
ALTER TABLE `two_wheeler_manufacturers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tw_manufacturer_name` (`name`);

--
-- Indexes for table `two_wheeler_models`
--
ALTER TABLE `two_wheeler_models`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tw_models_manufacturer_id` (`manufacturer_id`);

--
-- Indexes for table `two_wheeler_specs`
--
ALTER TABLE `two_wheeler_specs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tw_specs_variant_id` (`variant_id`);

--
-- Indexes for table `two_wheeler_variants`
--
ALTER TABLE `two_wheeler_variants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tw_variants_model_id` (`model_id`);

--
-- Indexes for table `two_wheeler_variant_features`
--
ALTER TABLE `two_wheeler_variant_features`
  ADD PRIMARY KEY (`variant_id`,`feature_id`),
  ADD KEY `feature_id` (`feature_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `two_wheeler_manufacturers`
--
ALTER TABLE `two_wheeler_manufacturers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `two_wheeler_models`
--
ALTER TABLE `two_wheeler_models`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `two_wheeler_specs`
--
ALTER TABLE `two_wheeler_specs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `two_wheeler_variants`
--
ALTER TABLE `two_wheeler_variants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `two_wheeler_models`
--
ALTER TABLE `two_wheeler_models`
  ADD CONSTRAINT `fk_tw_models_manufacturer` FOREIGN KEY (`manufacturer_id`) REFERENCES `two_wheeler_manufacturers` (`id`);

--
-- Constraints for table `two_wheeler_specs`
--
ALTER TABLE `two_wheeler_specs`
  ADD CONSTRAINT `fk_tw_specs_variant` FOREIGN KEY (`variant_id`) REFERENCES `two_wheeler_variants` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `two_wheeler_variants`
--
ALTER TABLE `two_wheeler_variants`
  ADD CONSTRAINT `fk_tw_variants_model` FOREIGN KEY (`model_id`) REFERENCES `two_wheeler_models` (`id`);

--
-- Constraints for table `two_wheeler_variant_features`
--
ALTER TABLE `two_wheeler_variant_features`
  ADD CONSTRAINT `fk_tw_variant_features_feature` FOREIGN KEY (`feature_id`) REFERENCES `features` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tw_variant_features_variant` FOREIGN KEY (`variant_id`) REFERENCES `two_wheeler_variants` (`id`) ON DELETE CASCADE;
--
-- Database: `autopredator_unified`
--
CREATE DATABASE IF NOT EXISTS `autopredator_unified` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `autopredator_unified`;

-- --------------------------------------------------------

--
-- Table structure for table `blogs`
--

CREATE TABLE `blogs` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `yt_link` varchar(255) DEFAULT NULL,
  `status` enum('draft','published') DEFAULT 'draft',
  `author` varchar(255) DEFAULT 'Admin',
  `excerpt` text DEFAULT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `featured` tinyint(1) DEFAULT 0,
  `publish_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `blogs`
--

INSERT INTO `blogs` (`id`, `title`, `content`, `image_url`, `yt_link`, `status`, `author`, `excerpt`, `meta_title`, `meta_description`, `featured`, `publish_at`, `created_at`) VALUES
(17, 'Sample Blog 1', 'This is a sample blog post about cars.', 'uploads/sample1.jpg', 'https://youtube.com/sample1', 'published', 'Admin', 'Sample excerpt', 'Sample Title', 'Sample description', 1, '2025-10-25 09:15:14', '2025-10-25 09:15:14'),
(18, 'Sample Blog 2', 'Another sample blog post.', 'uploads/sample2.jpg', 'https://youtube.com/sample2', 'published', 'Admin', 'Another excerpt', 'Another Title', 'Another description', 0, '2025-10-25 09:15:14', '2025-10-25 09:15:14');

-- --------------------------------------------------------

--
-- Table structure for table `features`
--

CREATE TABLE `features` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `features`
--

INSERT INTO `features` (`id`, `name`, `category`) VALUES
(1, 'Acceleration (0-100 kmph)', 'Drive Train'),
(2, 'Drivetrain', 'Drive Train');

-- --------------------------------------------------------

--
-- Table structure for table `fleet`
--

CREATE TABLE `fleet` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fleet_vehicles`
--

CREATE TABLE `fleet_vehicles` (
  `id` int(11) NOT NULL,
  `fleet_id` int(11) NOT NULL,
  `user_vehicle_id` int(11) NOT NULL,
  `assigned_driver` varchar(100) DEFAULT NULL,
  `status` enum('Active','Inactive','Maintenance') DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `images`
--

CREATE TABLE `images` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_thumbnail` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `insurance`
--

CREATE TABLE `insurance` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `variant_id` int(11) DEFAULT NULL,
  `provider` varchar(100) DEFAULT NULL,
  `policy_number` varchar(50) DEFAULT NULL,
  `coverage_amount` decimal(10,2) DEFAULT NULL,
  `premium` decimal(10,2) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `maintenance`
--

CREATE TABLE `maintenance` (
  `id` int(11) NOT NULL,
  `user_vehicle_id` int(11) NOT NULL,
  `maintenance_date` date DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT NULL,
  `next_due_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manufacturers`
--

CREATE TABLE `manufacturers` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `country` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `manufacturers`
--

INSERT INTO `manufacturers` (`id`, `name`, `country`) VALUES
(1, 'Maruti Suzuki', 'India');

-- --------------------------------------------------------

--
-- Table structure for table `models`
--

CREATE TABLE `models` (
  `id` int(11) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `family_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `launch_year` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `models`
--

INSERT INTO `models` (`id`, `manufacturer_id`, `family_id`, `name`, `launch_year`) VALUES
(1, 1, NULL, 'Brezza', '2023');

-- --------------------------------------------------------

--
-- Table structure for table `model_families`
--

CREATE TABLE `model_families` (
  `id` int(11) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `nameplate` varchar(100) NOT NULL,
  `body_type` varchar(50) DEFAULT NULL,
  `segment` varchar(50) DEFAULT NULL,
  `fuel_scope` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `model_lifecycle`
--

CREATE TABLE `model_lifecycle` (
  `id` int(11) NOT NULL,
  `family_id` int(11) NOT NULL,
  `generation_no` tinyint(4) NOT NULL,
  `facelift_no` tinyint(4) NOT NULL DEFAULT 0,
  `internal_code` varchar(50) DEFAULT NULL,
  `market_name` varchar(100) NOT NULL,
  `launch_date` date DEFAULT NULL,
  `discontinue_date` date DEFAULT NULL,
  `status` enum('Past','Current','Future') NOT NULL DEFAULT 'Current',
  `region` varchar(50) DEFAULT 'India',
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `price_history`
--

CREATE TABLE `price_history` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `rating` tinyint(4) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone_number` varchar(15) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `user_type` enum('Buyer','Seller','Dealer','Admin','Mechanic','Customer') DEFAULT 'Customer',
  `registration_date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `username`, `password_hash`, `phone_number`, `address`, `user_type`, `registration_date`) VALUES
(1, 'John Doe', 'john@example.com', 'johndoe', '$2y$10$examplehash1', '1234567890', '123 Main St, City', 'Buyer', '2025-10-25 09:15:14'),
(2, 'Jane Smith', 'jane@example.com', 'janesmith', '$2y$10$examplehash2', '0987654321', '456 Elm St, City', 'Seller', '2025-10-25 09:15:14'),
(3, 'Auto Dealer', 'dealer@example.com', 'autodealer', '$2y$10$examplehash3', '1122334455', '789 Oak St, City', 'Dealer', '2025-10-25 09:15:14');

-- --------------------------------------------------------

--
-- Table structure for table `user_vehicles`
--

CREATE TABLE `user_vehicles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `vin` varchar(50) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `mileage` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variants`
--

CREATE TABLE `variants` (
  `id` int(11) NOT NULL,
  `model_id` int(11) NOT NULL,
  `lifecycle_id` int(11) DEFAULT NULL,
  `variant_name` varchar(100) NOT NULL,
  `fuel_type` enum('Petrol','Diesel','CNG','Electric','Hybrid') NOT NULL,
  `transmission` enum('Manual','Automatic','AMT','CVT') NOT NULL,
  `power` varchar(20) DEFAULT NULL,
  `mileage` varchar(20) DEFAULT NULL,
  `ex_showroom_price` decimal(10,2) DEFAULT NULL,
  `on_road_price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `variants`
--

INSERT INTO `variants` (`id`, `model_id`, `lifecycle_id`, `variant_name`, `fuel_type`, `transmission`, `power`, `mileage`, `ex_showroom_price`, `on_road_price`) VALUES
(1, 1, NULL, 'LXI', 'Petrol', 'Manual', '103 HP', '20 km/l', 850000.00, 950000.00),
(2, 1, NULL, 'VXI CNG', 'CNG', 'Manual', '88 HP', '25 km/kg', 950000.00, 1050000.00);

-- --------------------------------------------------------

--
-- Table structure for table `variant_features`
--

CREATE TABLE `variant_features` (
  `variant_id` int(11) NOT NULL,
  `feature_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `variant_features`
--

INSERT INTO `variant_features` (`variant_id`, `feature_id`) VALUES
(1, 2),
(2, 1),
(2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_specs`
--

CREATE TABLE `vehicle_specs` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `engine_type` varchar(100) DEFAULT NULL,
  `engine_displacement_cc` int(11) DEFAULT NULL,
  `max_power_bhp` varchar(50) DEFAULT NULL,
  `max_torque_nm` varchar(50) DEFAULT NULL,
  `cylinders` int(11) DEFAULT NULL,
  `transmission_type` enum('Manual','Automatic','CVT','AMT','DCT') DEFAULT NULL,
  `drivetrain` enum('FWD','RWD','AWD','4WD') DEFAULT NULL,
  `fuel_type` enum('Petrol','Diesel','CNG','Electric','Hybrid') DEFAULT NULL,
  `fuel_tank_capacity_ltr` decimal(5,2) DEFAULT NULL,
  `top_speed_kmph` int(11) DEFAULT NULL,
  `acceleration_0_100_kmph` decimal(4,2) DEFAULT NULL,
  `mileage_city_kmpl` decimal(5,2) DEFAULT NULL,
  `mileage_highway_kmpl` decimal(5,2) DEFAULT NULL,
  `length_mm` int(11) DEFAULT NULL,
  `width_mm` int(11) DEFAULT NULL,
  `height_mm` int(11) DEFAULT NULL,
  `wheelbase_mm` int(11) DEFAULT NULL,
  `ground_clearance_mm` int(11) DEFAULT NULL,
  `boot_space_ltr` int(11) DEFAULT NULL,
  `kerb_weight_kg` int(11) DEFAULT NULL,
  `gross_vehicle_weight_kg` int(11) DEFAULT NULL,
  `turning_radius_m` decimal(4,2) DEFAULT NULL,
  `body_type` varchar(50) DEFAULT NULL,
  `number_of_doors` int(11) DEFAULT NULL,
  `lighting_type` enum('Halogen','LED','Xenon','Matrix','Laser') DEFAULT NULL,
  `alloy_wheels` tinyint(1) DEFAULT NULL,
  `sunroof_type` enum('None','Panoramic','Electric','Manual') DEFAULT NULL,
  `front_tyre_size` varchar(50) DEFAULT NULL,
  `rear_tyre_size` varchar(50) DEFAULT NULL,
  `spare_tyre_size` varchar(50) DEFAULT NULL,
  `suspension_front` varchar(100) DEFAULT NULL,
  `suspension_rear` varchar(100) DEFAULT NULL,
  `brake_type_front` varchar(100) DEFAULT NULL,
  `brake_type_rear` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `blogs`
--
ALTER TABLE `blogs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `features`
--
ALTER TABLE `features`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `fleet`
--
ALTER TABLE `fleet`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `fleet_vehicles`
--
ALTER TABLE `fleet_vehicles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fleet_id` (`fleet_id`),
  ADD KEY `user_vehicle_id` (`user_vehicle_id`);

--
-- Indexes for table `images`
--
ALTER TABLE `images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `insurance`
--
ALTER TABLE `insurance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `maintenance`
--
ALTER TABLE `maintenance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_vehicle_id` (`user_vehicle_id`);

--
-- Indexes for table `manufacturers`
--
ALTER TABLE `manufacturers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `models`
--
ALTER TABLE `models`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manufacturer_id` (`manufacturer_id`),
  ADD KEY `fk_models_family` (`family_id`);

--
-- Indexes for table `model_families`
--
ALTER TABLE `model_families`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manufacturer_id` (`manufacturer_id`);

--
-- Indexes for table `model_lifecycle`
--
ALTER TABLE `model_lifecycle`
  ADD PRIMARY KEY (`id`),
  ADD KEY `family_id` (`family_id`);

--
-- Indexes for table `price_history`
--
ALTER TABLE `price_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `user_vehicles`
--
ALTER TABLE `user_vehicles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `variants`
--
ALTER TABLE `variants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `model_id` (`model_id`),
  ADD KEY `fk_variants_lifecycle` (`lifecycle_id`);

--
-- Indexes for table `variant_features`
--
ALTER TABLE `variant_features`
  ADD PRIMARY KEY (`variant_id`,`feature_id`),
  ADD KEY `feature_id` (`feature_id`);

--
-- Indexes for table `vehicle_specs`
--
ALTER TABLE `vehicle_specs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `blogs`
--
ALTER TABLE `blogs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `features`
--
ALTER TABLE `features`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=180;

--
-- AUTO_INCREMENT for table `fleet`
--
ALTER TABLE `fleet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fleet_vehicles`
--
ALTER TABLE `fleet_vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `images`
--
ALTER TABLE `images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `insurance`
--
ALTER TABLE `insurance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `maintenance`
--
ALTER TABLE `maintenance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manufacturers`
--
ALTER TABLE `manufacturers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `models`
--
ALTER TABLE `models`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `model_families`
--
ALTER TABLE `model_families`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `model_lifecycle`
--
ALTER TABLE `model_lifecycle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `price_history`
--
ALTER TABLE `price_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_vehicles`
--
ALTER TABLE `user_vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variants`
--
ALTER TABLE `variants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `vehicle_specs`
--
ALTER TABLE `vehicle_specs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `fleet`
--
ALTER TABLE `fleet`
  ADD CONSTRAINT `fleet_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `fleet_vehicles`
--
ALTER TABLE `fleet_vehicles`
  ADD CONSTRAINT `fleet_vehicles_ibfk_1` FOREIGN KEY (`fleet_id`) REFERENCES `fleet` (`id`),
  ADD CONSTRAINT `fleet_vehicles_ibfk_2` FOREIGN KEY (`user_vehicle_id`) REFERENCES `user_vehicles` (`id`);

--
-- Constraints for table `images`
--
ALTER TABLE `images`
  ADD CONSTRAINT `images_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `insurance`
--
ALTER TABLE `insurance`
  ADD CONSTRAINT `insurance_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `insurance_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `maintenance`
--
ALTER TABLE `maintenance`
  ADD CONSTRAINT `maintenance_ibfk_1` FOREIGN KEY (`user_vehicle_id`) REFERENCES `user_vehicles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `models`
--
ALTER TABLE `models`
  ADD CONSTRAINT `fk_models_family` FOREIGN KEY (`family_id`) REFERENCES `model_families` (`id`),
  ADD CONSTRAINT `models_ibfk_1` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`);

--
-- Constraints for table `model_families`
--
ALTER TABLE `model_families`
  ADD CONSTRAINT `fk_families_manufacturer` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`);

--
-- Constraints for table `model_lifecycle`
--
ALTER TABLE `model_lifecycle`
  ADD CONSTRAINT `fk_lifecycle_family` FOREIGN KEY (`family_id`) REFERENCES `model_families` (`id`);

--
-- Constraints for table `price_history`
--
ALTER TABLE `price_history`
  ADD CONSTRAINT `price_history_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `user_vehicles`
--
ALTER TABLE `user_vehicles`
  ADD CONSTRAINT `user_vehicles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `user_vehicles_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `variants`
--
ALTER TABLE `variants`
  ADD CONSTRAINT `fk_variants_lifecycle` FOREIGN KEY (`lifecycle_id`) REFERENCES `model_lifecycle` (`id`),
  ADD CONSTRAINT `variants_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`);

--
-- Constraints for table `variant_features`
--
ALTER TABLE `variant_features`
  ADD CONSTRAINT `variant_features_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`),
  ADD CONSTRAINT `variant_features_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `features` (`id`);

--
-- Constraints for table `vehicle_specs`
--
ALTER TABLE `vehicle_specs`
  ADD CONSTRAINT `vehicle_specs_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE CASCADE;
--
-- Database: `blogs`
--
CREATE DATABASE IF NOT EXISTS `blogs` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `blogs`;

-- --------------------------------------------------------

--
-- Table structure for table `blogs`
--

CREATE TABLE `blogs` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `yt_link` varchar(255) DEFAULT NULL,
  `status` enum('draft','published') DEFAULT 'draft',
  `author` varchar(255) DEFAULT 'Admin',
  `excerpt` text DEFAULT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `featured` tinyint(1) DEFAULT 0,
  `publish_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `blogs`
--

INSERT INTO `blogs` (`id`, `title`, `content`, `image_url`, `yt_link`, `status`, `author`, `excerpt`, `meta_title`, `meta_description`, `featured`, `publish_at`, `created_at`) VALUES
(1, 'Top 10 Fastest Cars in the World', '<p>&nbsp;</p>\r\n<p><img class=\"mt-2\" src=\"uploads/DALL%C2%B7E%202024-11-08%2011.54.10%20-%20A%20modern%20minimalist%20logo%20representing%20centralized%20vehicle%20management.%20The%20design%20centers%20around%20a%20hub-and-spoke%20motif%20with%20a%20sleek,%20stylized%20steering%20.jpg\" width=\"150\"></p>\r\n<p>&nbsp;</p>\r\n<p>Here are the10 fastest cars in the world, featuring brands like Bugatti, Koenigsegg, ansmd Hennessey. Some of these supercars reach speeds over 300 mph! go at that speed and die&nbsp;</p>\r\n<p>&nbsp;</p>\r\n<p><img class=\"mt-2\" src=\"uploads/DALL%C2%B7E%202024-11-08%2011.54.10%20-%20A%20modern%20minimalist%20logo%20representing%20centralized%20vehicle%20management.%20The%20design%20centers%20around%20a%20hub-and-spoke%20motif%20with%20a%20sleek,%20stylized%20steering%20.jpg\" width=\"150\"></p>', 'uploads/DALL·E 2024-11-08 11.54.10 - A modern minimalist logo representing centralized vehicle management. The design centers around a hub-and-spoke motif with a sleek, stylized steering .jpg', 'https://www.youtube.com/watch?v=EXAMPLE1', 'published', 'Admin', NULL, NULL, NULL, 0, NULL, '2025-03-11 06:05:53'),
(2, 'Top 10 Slowest Cars in the World', 'Not all cars are built for speed! Here are the slowest cars in the world, including the Peel P50, Tata Nano, and Renault Twizy.', 'uploads/slowest_cars.jpg', 'https://www.youtube.com/watch?v=EXAMPLE2', 'published', 'Admin', NULL, NULL, NULL, 0, NULL, '2025-03-11 06:05:53'),
(3, 'Top 10 Fastest Motorcycles in the World', 'Want to feel the thrill of speed? These are the 10 fastest motorcycles, including the Kawasaki Ninja H2R, Ducati Panigale, and MTT Y2K.', 'uploads/fastest_motorcycles.jpg', 'https://www.youtube.com/watch?v=EXAMPLE3', 'published', 'Admin', NULL, NULL, NULL, 0, NULL, '2025-03-11 06:05:53'),
(4, 'Top 10 Slowest Motorcycles in the World', 'Not all motorcycles are speed demons! Here are some of the slowest motorcycles, including models from Honda, Royal Enfield, and Vespa.', 'uploads/slowest_motorcycles.jpg', 'https://www.youtube.com/watch?v=EXAMPLE4', 'published', 'Admin', NULL, NULL, NULL, 0, NULL, '2025-03-11 06:05:53'),
(5, 'The Rise of Electric Vehicles in 2025', '<p>Electric vehicles (EVs) are taking over roads worldwide, thanks to rapid battery technology advancements and growing charging infrastructure.</p>', 'uploads/ev_rise.jpg', 'https://www.youtube.com/watch?v=ev1', 'published', 'John Doe', 'An in-depth look at how EVs are dominating the market in 2025.', 'EV Growth in 2025', 'Explore how electric vehicles are revolutionizing transportation in 2025.', 1, '2025-03-01 10:00:00', '2025-03-25 03:47:23'),
(6, 'Top 5 Affordable Cars for Students', '<p>Budget-friendly cars that offer reliability, fuel efficiency, and style for students in 2025.</p>', 'uploads/student_cars.jpg', 'https://www.youtube.com/watch?v=car2', 'published', 'Jane Smith', 'A roundup of cheap and reliable cars perfect for students.', 'Best Cars for Students', 'Top 5 affordable and reliable cars for students in 2025.', 0, '2025-03-05 09:30:00', '2025-03-25 03:47:23'),
(7, 'Hybrid vs Electric: Which is Better?', '<p>We compare hybrid and electric cars on performance, economy, and sustainability.</p>', 'uploads/hybrid_vs_electric.jpg', 'https://www.youtube.com/watch?v=hybrid3', 'published', 'Auto Expert', 'Find out whether hybrid or fully electric cars make more sense.', 'Hybrid or EV: Pros and Cons', 'Should you buy a hybrid or go fully electric in 2025? Learn the pros and cons.', 1, '2025-03-10 14:00:00', '2025-03-25 03:47:23'),
(8, 'How to Maintain Your Car in 2025', '<p>Car maintenance tips for modern vehicles, including smart diagnostics and predictive service reminders.</p>', 'uploads/car_maintenance_2025.jpg', 'https://www.youtube.com/watch?v=car4', 'published', 'GaragePro', 'A guide to keeping your car in top shape with 2025 tech.', 'Car Maintenance Tips', 'Smart maintenance strategies to extend your car’s lifespan in 2025.', 0, '2025-03-12 11:00:00', '2025-03-25 03:47:23'),
(9, 'Top 10 Supercars of the Year', '<p>From Bugatti to Koenigsegg, here are the most powerful and luxurious supercars of 2025.</p>', 'uploads/top_supercars.jpg', 'https://www.youtube.com/watch?v=super5', 'published', 'Speed Review', 'The fastest, sexiest, and most expensive cars in 2025.', 'Best Supercars 2025', 'A list of the most impressive supercars hitting the streets this year.', 1, '2025-03-15 16:30:00', '2025-03-25 03:47:23'),
(10, 'AI in Cars: What to Expect', '<p>Explore how artificial intelligence is improving safety, navigation, and comfort in the latest vehicles.</p>', 'uploads/ai_cars.jpg', 'https://www.youtube.com/watch?v=ai6', 'published', 'TechDrive', 'AI is changing how we drive. Here’s what you should know.', 'AI in Automotive', 'Discover how AI is transforming driving experience and safety.', 1, '2025-03-20 08:00:00', '2025-03-25 03:47:23'),
(11, 'Why Used Cars Are a Smart Buy in 2025', '<p>With rising car prices, used vehicles are offering better value than ever. Here’s what to look for.</p>', 'uploads/used_cars_2025.jpg', 'https://www.youtube.com/watch?v=used7', 'published', 'Elena Auto', 'Get more for your money with smart used car choices.', 'Used Car Buying Tips', 'Reasons why buying used cars in 2025 is a smart financial decision.', 0, '2025-03-21 13:15:00', '2025-03-25 03:47:23'),
(12, 'The Future of Autonomous Vehicles', '<p>Self-driving cars are evolving fast. We break down the latest in Lidar, AI, and legislation.</p>', 'uploads/autonomous_future.jpg', 'https://www.youtube.com/watch?v=auto8', 'published', 'DriveNext', 'Are we ready to let cars take control?', 'Autonomous Vehicles 2025', 'Learn where self-driving car tech stands and what’s coming next.', 1, '2025-03-25 18:45:00', '2025-03-25 03:47:23'),
(13, 'Top 7 Family SUVs for Safety & Comfort', '<p>Looking for a safe and spacious family SUV? Here are the top-rated options in 2025.</p>', 'uploads/family_suvs.jpg', 'https://www.youtube.com/watch?v=suv9', 'published', 'SafeDrive', 'Choose the right SUV to protect your family.', 'Best Family SUVs', 'A guide to the safest and most comfortable SUVs for families.', 0, '2025-03-28 10:20:00', '2025-03-25 03:47:23'),
(14, 'How to Save Fuel with Smart Driving', '<p>Drive smarter, not harder. These techniques can boost your MPG and lower emissions.</p>', 'uploads/fuel_saving_tips.jpg', 'https://www.youtube.com/watch?v=fuel10', 'published', 'EcoAuto', 'Save money and the planet with these driving habits.', 'Fuel Efficiency Tips', 'Tips to improve mileage and reduce fuel consumption in any vehicle.', 0, '2025-04-01 07:45:00', '2025-03-25 03:47:23'),
(15, 'w;rlw;', '', '', '', 'draft', 'Admin', 'fmelf\r\n', '', '', 0, NULL, '2025-03-25 03:49:42'),
(16, 'dmekfmwefmfme', '', '', '', 'draft', 'Admin', '', '', '', 0, NULL, '2025-03-25 04:04:18'),
(17, 'Sample Blog 1', 'This is a sample blog post about cars.', 'uploads/sample1.jpg', 'https://youtube.com/sample1', 'published', 'Admin', 'Sample excerpt', 'Sample Title', 'Sample description', 1, '2025-10-25 11:41:16', '2025-10-25 06:11:16'),
(18, 'Sample Blog 2', 'Another sample blog post.', 'uploads/sample2.jpg', 'https://youtube.com/sample2', 'published', 'Admin', 'Another excerpt', 'Another Title', 'Another description', 0, '2025-10-25 11:41:16', '2025-10-25 06:11:16');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `blogs`
--
ALTER TABLE `blogs`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `blogs`
--
ALTER TABLE `blogs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- Database: `cars`
--
CREATE DATABASE IF NOT EXISTS `cars` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `cars`;

-- --------------------------------------------------------

--
-- Table structure for table `features`
--

CREATE TABLE `features` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `features`
--

INSERT INTO `features` (`id`, `name`, `category`) VALUES
(1, 'Acceleration (0-100 kmph)', 'Drive Train'),
(2, 'Drivetrain', 'Drive Train'),
(3, 'Emission Standard', 'Drive Train'),
(4, 'Engine', 'Drive Train'),
(5, 'Engine Type', 'Drive Train'),
(6, 'Fuel Type', 'Drive Train'),
(7, 'Max Power (BHP@RPM)', 'Drive Train'),
(8, 'Max Torque (BHP@RPM)', 'Drive Train'),
(9, 'Transmission', 'Drive Train'),
(10, 'Turbocharger/Supercharged', 'Drive Train'),
(11, 'Body-Colored Bumper', 'Exterior'),
(12, 'Body Kits', 'Exterior'),
(13, 'Chrome Finish Exhaust Pipe', 'Exterior'),
(14, 'Roof Rails', 'Exterior'),
(15, 'Rub Strips', 'Exterior'),
(16, 'Sunroof/Moonroof', 'Exterior'),
(17, 'Adjustable ORVMs', 'Exterior Features'),
(18, 'ORVMs (Outside Rear View Mirrors)', 'Exterior Features'),
(19, 'Turn Indicators on ORVMs', 'Exterior Features'),
(20, 'Air Conditioner', 'Comfort & Convenience'),
(21, 'Air Conditioner Type & Zones', 'Comfort & Convenience'),
(22, 'Air Purifier', 'Comfort & Convenience'),
(23, 'Anti-Glare Mirrors', 'Comfort & Convenience'),
(24, 'Cabin-to-Boot Access', 'Comfort & Convenience'),
(25, 'Cruise Control', 'Comfort & Convenience'),
(26, 'Electronic Parking Brake', 'Comfort & Convenience'),
(27, 'Front AC', 'Comfort & Convenience'),
(28, 'Heated/Cooled Cup Holder', 'Comfort & Convenience'),
(29, 'Heater', 'Comfort & Convenience'),
(30, 'Parking Assist', 'Comfort & Convenience'),
(31, 'Parking Sensors', 'Comfort & Convenience'),
(32, 'Rear AC', 'Comfort & Convenience'),
(33, 'Third Row AC Zone', 'Comfort & Convenience'),
(34, 'Vanity Mirrors on Sun Visors', 'Comfort & Convenience'),
(35, 'Ambient Interior Lighting', 'Lighting'),
(36, 'Automatic Headlamps', 'Lighting'),
(37, 'Cabin Lamps', 'Lighting'),
(38, 'Cornering Headlamps', 'Lighting'),
(39, 'Daytime Running Lights (DRL)', 'Lighting'),
(40, 'Fog Lights', 'Lighting'),
(41, 'Follow-Me-Home Headlamps', 'Lighting'),
(42, 'Glovebox Lamp', 'Lighting'),
(43, 'Headlight & Ignition On Reminder', 'Lighting'),
(44, 'Headlight Height Adjuster', 'Lighting'),
(45, 'Headlights', 'Lighting'),
(46, 'Light on Vanity Mirror', 'Lighting'),
(47, 'Puddle Lamps', 'Lighting'),
(48, 'Reading Lamps', 'Lighting'),
(49, 'Taillights', 'Lighting'),
(50, 'Child Safety Locks', 'Doors, Windows & Locks'),
(51, 'Central Locking', 'Doors, Windows & Locks'),
(52, 'Door Ajar Warning', 'Doors, Windows & Locks'),
(53, 'Door Pockets', 'Doors, Windows & Locks'),
(54, 'Engine Immobilizer', 'Doors, Windows & Locks'),
(55, 'Interior Door Handle Finish', 'Doors, Windows & Locks'),
(56, 'One-Touch Down', 'Doors, Windows & Locks'),
(57, 'One-Touch Up', 'Doors, Windows & Locks'),
(58, 'Power Windows', 'Doors, Windows & Locks'),
(59, 'Scuff Plates', 'Doors, Windows & Locks'),
(60, 'Soft-Close Doors', 'Doors, Windows & Locks'),
(61, 'Speed-Sensing Door Locks', 'Doors, Windows & Locks'),
(62, 'Bootlid Opener', 'Doors, Windows & Locks'),
(63, 'Rear Windshield Blind', 'Doors, Windows & Locks'),
(64, 'Front Brake Type', 'Brakes'),
(65, 'Rear Brake Type', 'Brakes'),
(66, 'Front Suspension', 'Suspension'),
(67, 'Rear Suspension', 'Suspension'),
(68, 'Front Tires', 'Wheels'),
(69, 'Rear Tires', 'Wheels'),
(70, 'Spare Wheel', 'Wheels'),
(71, 'Anti-lock Braking System (ABS)', 'Safety'),
(72, 'Automatic Emergency Braking (AEB)', 'Safety'),
(73, 'Blind Spot Detection', 'Safety'),
(74, 'Brake Assist (BA)', 'Safety'),
(75, 'Child Seat Anchor Points (ISOFIX)', 'Safety'),
(76, 'Dashcam', 'Safety'),
(77, 'Differential Lock', 'Safety'),
(78, 'Electronic Brake Force Distribution (EBD)', 'Safety'),
(79, 'Electronic Stability Program (ESP)', 'Safety'),
(80, 'Emergency Brake Light Flashing', 'Safety'),
(81, 'Four-Wheel Drive (4WD)', 'Safety'),
(82, 'Forward Collision Warning (FCW)', 'Safety'),
(83, 'High Beam Assist', 'Safety'),
(84, 'Hill Descent Control', 'Safety'),
(85, 'Hill Hold Control', 'Safety'),
(86, 'Lane Departure Prevention', 'Safety'),
(87, 'Lane Departure Warning', 'Safety'),
(88, 'Limited Slip Differential (LSD)', 'Safety'),
(89, 'NCAP Rating', 'Safety'),
(90, 'Overspeed Warning', 'Safety'),
(91, 'Puncture Repair Kit', 'Safety'),
(92, 'Rear Cross Traffic Assist', 'Safety'),
(93, 'Rear Middle Three-Point Seatbelt', 'Safety'),
(94, 'Rear Middle Headrest', 'Safety'),
(95, 'Ride Height Adjustment', 'Safety'),
(96, 'Seat Belt Warning', 'Safety'),
(97, 'Tire Pressure Monitoring System (TPMS)', 'Safety'),
(98, 'Traction Control System', 'Safety'),
(99, 'Airbags', 'Safety'),
(100, 'Alexa Compatibility', 'Connected Car Features'),
(101, 'Car Light Flashing & Honking via App', 'Connected Car Features'),
(102, 'Check Vehicle Status via App', 'Connected Car Features'),
(103, 'Find My Car', 'Connected Car Features'),
(104, 'Geofence & Emergency Call Button', 'Connected Car Features'),
(105, 'Over-the-Air (OTA) Updates', 'Connected Car Features'),
(106, 'Remote AC On/Off via App', 'Connected Car Features'),
(107, 'Remote Car Lock/Unlock via App', 'Connected Car Features'),
(108, 'Remote Sunroof Open/Close via App', 'Connected Car Features'),
(109, 'Apple CarPlay', 'Infotainment'),
(110, 'Android Auto', 'Infotainment'),
(111, 'AM/FM Radio', 'Infotainment'),
(112, 'Display', 'Infotainment'),
(113, 'Gesture Control', 'Infotainment'),
(114, 'GPS Navigation System', 'Infotainment'),
(115, 'Head Unit Size', 'Infotainment'),
(116, 'Infotainment Screen Size', 'Infotainment'),
(117, 'Integrated (In-Dash) Music System', 'Infotainment'),
(118, 'Internal Hard Drive', 'Infotainment'),
(119, 'iPod Compatibility', 'Infotainment'),
(120, 'Speakers', 'Infotainment'),
(121, 'Steering-Mounted Controls', 'Infotainment'),
(122, 'USB Compatibility', 'Infotainment'),
(123, 'Voice Command', 'Infotainment'),
(124, 'Wireless Charger', 'Infotainment'),
(125, 'Display Screen for Rear Passengers', 'Infotainment'),
(126, 'Adjustable Cluster Brightness', 'Instrument Cluster Features'),
(127, 'Average Fuel Consumption', 'Instrument Cluster Features'),
(128, 'Average Speed', 'Instrument Cluster Features'),
(129, 'Clock', 'Instrument Cluster Features'),
(130, 'Distance to Empty', 'Instrument Cluster Features'),
(131, 'Gear Indicator', 'Instrument Cluster Features'),
(132, 'Heads-Up Display (HUD)', 'Instrument Cluster Features'),
(133, 'Instantaneous Fuel Consumption', 'Instrument Cluster Features'),
(134, 'Instrument Cluster', 'Instrument Cluster Features'),
(135, 'Low Fuel Level Warning', 'Instrument Cluster Features'),
(136, 'Shift Indicator', 'Instrument Cluster Features'),
(137, 'Tachometer', 'Instrument Cluster Features'),
(138, 'Trip Meter', 'Instrument Cluster Features'),
(139, 'Cooled Glove Box', 'Interior Comfort & Features'),
(140, 'Headrests', 'Interior Comfort & Features'),
(141, 'Interior Colors', 'Interior Comfort & Features'),
(142, 'Massage Seats', 'Interior Comfort & Features'),
(143, 'Ventilated Seats', 'Interior Comfort & Features'),
(144, 'Ventilated Seats Type', 'Interior Comfort & Features'),
(145, 'Cup Holder Position', 'Storage & Utility'),
(146, 'Driver Armrest', 'Storage & Utility'),
(147, 'Driver Armrest Storage', 'Storage & Utility'),
(148, 'Leather-Wrapped Gear Knob', 'Storage & Utility'),
(149, 'Leather-Wrapped Steering Wheel', 'Storage & Utility'),
(150, 'Sunglass Holder', 'Storage & Utility'),
(151, 'Third Row Cup Holder', 'Storage & Utility'),
(152, 'Front Seatback Pockets', 'Storage & Utility'),
(153, 'Driver Seat Adjustments', 'Seating & Adjustments'),
(154, 'Folding Rear Seat', 'Seating & Adjustments'),
(155, 'Front Passenger Seat Adjustment', 'Seating & Adjustments'),
(156, 'Rear Passenger Armrest', 'Seating & Adjustments'),
(157, 'Second Row Seat Adjustment', 'Seating & Adjustments'),
(158, 'Seat Upholstery', 'Seating & Adjustments'),
(159, 'Split Rear Seat', 'Seating & Adjustments'),
(160, 'Split Third Row Seat', 'Seating & Adjustments'),
(161, 'Third Row Seat Adjustment', 'Seating & Adjustments'),
(162, 'Third Row Seat Type', 'Seating & Adjustments'),
(163, 'Doors', 'Dimensions'),
(164, 'Fuel Tank Capacity', 'Dimensions'),
(165, 'Ground Clearance', 'Dimensions'),
(166, 'Height', 'Dimensions'),
(167, 'Length', 'Dimensions'),
(168, 'Number of Rows', 'Dimensions'),
(169, 'Seating Capacity', 'Dimensions'),
(170, 'Wheelbase', 'Dimensions'),
(171, 'Width', 'Dimensions'),
(172, 'Keyless Start/Button Start', 'Lighting'),
(173, 'Steering Adjustment', 'Lighting'),
(174, 'Rear Defogger', 'Visibility & Wipers'),
(175, 'Rear Wiper', 'Visibility & Wipers'),
(176, 'Rain-Sensing Wipers', 'Visibility & Wipers'),
(177, 'Side Window Blinds', 'Visibility & Wipers'),
(178, 'Warranty (Years)', 'Warranty'),
(179, 'Warranty (Kilometers)', 'Warranty');

-- --------------------------------------------------------

--
-- Table structure for table `images`
--

CREATE TABLE `images` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_thumbnail` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manufacturers`
--

CREATE TABLE `manufacturers` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `country` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `manufacturers`
--

INSERT INTO `manufacturers` (`id`, `name`, `country`) VALUES
(1, 'Maruti Suzuki', 'India');

-- --------------------------------------------------------

--
-- Table structure for table `models`
--

CREATE TABLE `models` (
  `id` int(11) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `launch_year` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `models`
--

INSERT INTO `models` (`id`, `manufacturer_id`, `name`, `launch_year`) VALUES
(1, 1, 'Brezza', '2023');

-- --------------------------------------------------------

--
-- Table structure for table `price_history`
--

CREATE TABLE `price_history` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `rating` tinyint(4) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `variants`
--

CREATE TABLE `variants` (
  `id` int(11) NOT NULL,
  `model_id` int(11) NOT NULL,
  `variant_name` varchar(100) NOT NULL,
  `fuel_type` enum('Petrol','Diesel','CNG','Electric','Hybrid','FuelCell') NOT NULL,
  `transmission` enum('Manual','Automatic','AMT','CVT') NOT NULL,
  `power` varchar(20) DEFAULT NULL,
  `mileage` varchar(20) DEFAULT NULL,
  `ex_showroom_price` decimal(10,2) DEFAULT NULL,
  `on_road_price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `variants`
--

INSERT INTO `variants` (`id`, `model_id`, `variant_name`, `fuel_type`, `transmission`, `power`, `mileage`, `ex_showroom_price`, `on_road_price`) VALUES
(1, 1, 'LXI', 'Petrol', 'Manual', '103 HP', '20 km/l', 850000.00, 950000.00),
(2, 1, 'VXI CNG', 'CNG', 'Manual', '88 HP', '25 km/kg', 950000.00, 1050000.00);

-- --------------------------------------------------------

--
-- Table structure for table `variant_features`
--

CREATE TABLE `variant_features` (
  `variant_id` int(11) NOT NULL,
  `feature_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `variant_features`
--

INSERT INTO `variant_features` (`variant_id`, `feature_id`) VALUES
(1, 2),
(2, 1),
(2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_specs`
--

CREATE TABLE `vehicle_specs` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `engine_type` varchar(100) DEFAULT NULL,
  `engine_displacement_cc` int(11) DEFAULT NULL,
  `max_power_bhp` varchar(50) DEFAULT NULL,
  `max_torque_nm` varchar(50) DEFAULT NULL,
  `cylinders` int(11) DEFAULT NULL,
  `transmission_type` enum('Manual','Automatic','CVT','AMT','DCT') DEFAULT NULL,
  `drivetrain` enum('FWD','RWD','AWD','4WD') DEFAULT NULL,
  `fuel_type` enum('Petrol','Diesel','CNG','Electric','Hybrid','FuelCell') DEFAULT NULL,
  `fuel_tank_capacity_ltr` decimal(5,2) DEFAULT NULL,
  `battery_capacity_kwh` decimal(5,2) DEFAULT NULL,
  `ev_range_wltp_km` int(11) DEFAULT NULL,
  `ev_range_araikm` int(11) DEFAULT NULL,
  `electric_motor_power_kw` decimal(5,2) DEFAULT NULL,
  `electric_motor_torque_nm` decimal(6,2) DEFAULT NULL,
  `dc_fast_charging_time_10_80_min` int(11) DEFAULT NULL,
  `ac_charging_time_0_100_hr` decimal(4,2) DEFAULT NULL,
  `charging_standard` enum('None','Type2','CCS2','CHAdeMO','GB/T','Other') DEFAULT NULL,
  `regenerative_braking` tinyint(1) DEFAULT NULL,
  `hybrid_system_type` enum('Mild','Strong','Full','PlugIn','RangeExtender') DEFAULT NULL,
  `electric_only_range_km` int(11) DEFAULT NULL,
  `fuel_cell_stack_power_kw` decimal(5,2) DEFAULT NULL,
  `hydrogen_tank_capacity_kg` decimal(4,2) DEFAULT NULL,
  `fuel_cell_range_km` int(11) DEFAULT NULL,
  `top_speed_kmph` int(11) DEFAULT NULL,
  `acceleration_0_100_kmph` decimal(4,2) DEFAULT NULL,
  `mileage_city_kmpl` decimal(5,2) DEFAULT NULL,
  `mileage_highway_kmpl` decimal(5,2) DEFAULT NULL,
  `length_mm` int(11) DEFAULT NULL,
  `width_mm` int(11) DEFAULT NULL,
  `height_mm` int(11) DEFAULT NULL,
  `wheelbase_mm` int(11) DEFAULT NULL,
  `ground_clearance_mm` int(11) DEFAULT NULL,
  `boot_space_ltr` int(11) DEFAULT NULL,
  `kerb_weight_kg` int(11) DEFAULT NULL,
  `gross_vehicle_weight_kg` int(11) DEFAULT NULL,
  `turning_radius_m` decimal(4,2) DEFAULT NULL,
  `body_type` varchar(50) DEFAULT NULL,
  `number_of_doors` int(11) DEFAULT NULL,
  `lighting_type` enum('Halogen','LED','Xenon','Matrix','Laser') DEFAULT NULL,
  `alloy_wheels` tinyint(1) DEFAULT NULL,
  `sunroof_type` enum('None','Panoramic','Electric','Manual') DEFAULT NULL,
  `front_tyre_size` varchar(50) DEFAULT NULL,
  `rear_tyre_size` varchar(50) DEFAULT NULL,
  `spare_tyre_size` varchar(50) DEFAULT NULL,
  `suspension_front` varchar(100) DEFAULT NULL,
  `suspension_rear` varchar(100) DEFAULT NULL,
  `brake_type_front` varchar(100) DEFAULT NULL,
  `brake_type_rear` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `features`
--
ALTER TABLE `features`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `images`
--
ALTER TABLE `images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `manufacturers`
--
ALTER TABLE `manufacturers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `models`
--
ALTER TABLE `models`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manufacturer_id` (`manufacturer_id`);

--
-- Indexes for table `price_history`
--
ALTER TABLE `price_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `variants`
--
ALTER TABLE `variants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `model_id` (`model_id`);

--
-- Indexes for table `variant_features`
--
ALTER TABLE `variant_features`
  ADD PRIMARY KEY (`variant_id`,`feature_id`),
  ADD KEY `feature_id` (`feature_id`);

--
-- Indexes for table `vehicle_specs`
--
ALTER TABLE `vehicle_specs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `features`
--
ALTER TABLE `features`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=180;

--
-- AUTO_INCREMENT for table `images`
--
ALTER TABLE `images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manufacturers`
--
ALTER TABLE `manufacturers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `models`
--
ALTER TABLE `models`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `price_history`
--
ALTER TABLE `price_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `variants`
--
ALTER TABLE `variants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `vehicle_specs`
--
ALTER TABLE `vehicle_specs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `images`
--
ALTER TABLE `images`
  ADD CONSTRAINT `images_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `models`
--
ALTER TABLE `models`
  ADD CONSTRAINT `models_ibfk_1` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`);

--
-- Constraints for table `price_history`
--
ALTER TABLE `price_history`
  ADD CONSTRAINT `price_history_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `variants`
--
ALTER TABLE `variants`
  ADD CONSTRAINT `variants_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`);

--
-- Constraints for table `variant_features`
--
ALTER TABLE `variant_features`
  ADD CONSTRAINT `variant_features_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `vehicle_specs`
--
ALTER TABLE `vehicle_specs`
  ADD CONSTRAINT `vehicle_specs_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE CASCADE;
--
-- Database: `mindflow_db`
--
CREATE DATABASE IF NOT EXISTS `mindflow_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `mindflow_db`;

-- --------------------------------------------------------

--
-- Table structure for table `ai_project_plans`
--

CREATE TABLE `ai_project_plans` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the AI-generated plan',
  `project_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the projects table',
  `plan_content` longtext NOT NULL COMMENT 'The content of the AI-generated project plan',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the AI plan was generated and saved',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the AI plan was last updated'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores AI-generated project plans associated with projects';

--
-- Dumping data for table `ai_project_plans`
--

INSERT INTO `ai_project_plans` (`id`, `project_id`, `plan_content`, `created_at`, `updated_at`) VALUES
(1, 1, 'Mindflow.ai Generated Plan for Project ID: 1\r\n\r\nDescription: It is a AI powered project app management ai for the a Moon lighter, Freelancer and a organization \r\n\r\nPhase 1: Research & Discovery\r\n- Market analysis\r\n- Competitor analysis\r\n- User research & requirements gathering\r\n\r\nPhase 2: Planning & Design\r\n- Define project scope & objectives\r\n- Create wireframes & mockups\r\n- Database schema design\r\n\r\nPhase 3: Development\r\n- Frontend development\r\n- Backend API implementation\r\n- Integration with existing systems\r\n\r\nPhase 4: Testing & QA\r\n- Unit testing\r\n- Integration testing\r\n- User acceptance testing\r\n\r\nPhase 5: Deployment & Monitoring\r\n- Production deployment\r\n- Performance monitoring\r\n- Post-launch support\r\n\r\nThis plan is a high-level overview. Detailed tasks and timelines will be added in subsequent steps.', '2025-09-10 03:37:45', '2025-09-10 03:37:45'),
(2, 1, 'Mindflow.ai Generated Plan for Project ID: 1\r\n\r\nDescription: It is a AI powered project app management ai for the a Moon lighter, Freelancer and a organization \r\n\r\nPhase 1: Research & Discovery\r\n- Market analysis\r\n- Competitor analysis\r\n- User research & requirements gathering\r\n\r\nPhase 2: Planning & Design\r\n- Define project scope & objectives\r\n- Create wireframes & mockups\r\n- Database schema design\r\n\r\nPhase 3: Development\r\n- Frontend development\r\n- Backend API implementation\r\n- Integration with existing systems\r\n\r\nPhase 4: Testing & QA\r\n- Unit testing\r\n- Integration testing\r\n- User acceptance testing\r\n\r\nPhase 5: Deployment & Monitoring\r\n- Production deployment\r\n- Performance monitoring\r\n- Post-launch support\r\n\r\nThis plan is a high-level overview. Detailed tasks and timelines will be added in subsequent steps.', '2025-09-10 03:48:27', '2025-09-10 03:48:27'),
(3, 1, 'Mindflow.ai Generated Plan for Project ID: 1\r\n\r\nDescription: IT is a AI powered Project management app\r\n\r\nPhase 1: Research & Discovery\r\n- Market analysis\r\n- Competitor analysis\r\n- User research & requirements gathering\r\n\r\nPhase 2: Planning & Design\r\n- Define project scope & objectives\r\n- Create wireframes & mockups\r\n- Database schema design\r\n\r\nPhase 3: Development\r\n- Frontend development\r\n- Backend API implementation\r\n- Integration with existing systems\r\n\r\nPhase 4: Testing & QA\r\n- Unit testing\r\n- Integration testing\r\n- User acceptance testing\r\n\r\nPhase 5: Deployment & Monitoring\r\n- Production deployment\r\n- Performance monitoring\r\n- Post-launch support\r\n\r\nThis plan is a high-level overview. Detailed tasks and timelines will be added in subsequent steps.', '2025-09-10 04:20:54', '2025-09-10 04:20:54'),
(4, 1, 'Mindflow.ai Generated Plan for Project ID: 1\r\n\r\nDescription: AI powered Project manager \r\n\r\nPhase 1: Research & Discovery\r\n- Market analysis\r\n- Competitor analysis\r\n- User research & requirements gathering\r\n\r\nPhase 2: Planning & Design\r\n- Define project scope & objectives\r\n- Create wireframes & mockups\r\n- Database schema design\r\n\r\nPhase 3: Development\r\n- Frontend development\r\n- Backend API implementation\r\n- Integration with existing systems\r\n\r\nPhase 4: Testing & QA\r\n- Unit testing\r\n- Integration testing\r\n- User acceptance testing\r\n\r\nPhase 5: Deployment & Monitoring\r\n- Production deployment\r\n- Performance monitoring\r\n- Post-launch support\r\n\r\nThis plan is a high-level overview. Detailed tasks and timelines will be added in subsequent steps.', '2025-09-10 04:37:33', '2025-09-10 04:37:33');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'Unique identifier for the audit log entry',
  `organization_id` int(11) UNSIGNED DEFAULT NULL COMMENT 'Optional foreign key to organizations, for organization-specific logs',
  `user_id` int(11) UNSIGNED DEFAULT NULL COMMENT 'Optional foreign key to users, indicating who performed the action',
  `action` varchar(200) NOT NULL COMMENT 'Description of the action performed (e.g., user_login, project_created)',
  `object_type` varchar(100) DEFAULT NULL COMMENT 'Type of the object acted upon (e.g., project, user, task)',
  `object_id` varchar(100) DEFAULT NULL COMMENT 'ID of the object acted upon',
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Additional metadata about the action in JSON format' CHECK (json_valid(`meta`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the audit log was created'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Records critical system activities and user actions for auditing and security monitoring';

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `organization_id`, `user_id`, `action`, `object_type`, `object_id`, `meta`, `created_at`) VALUES
(1, NULL, 2, 'user:register_success', 'user', '2', '{\"username\":\"Mohith\",\"email\":\"mohithlingosme0218@gmail.com\"}', '2025-09-08 08:38:21'),
(2, NULL, 2, 'user:login_success', 'user', '2', '{\"email\":\"mohithlingosme0218@gmail.com\"}', '2025-09-08 08:38:58'),
(3, NULL, 2, 'user:login_success', 'user', '2', '{\"email\":\"mohithlingosme0218@gmail.com\"}', '2025-09-08 08:39:04'),
(4, NULL, 2, 'user:login_success', 'user', '2', '{\"email\":\"mohithlingosme0218@gmail.com\"}', '2025-09-08 08:57:17'),
(5, NULL, 2, 'user:login_success', 'user', '2', '{\"email\":\"mohithlingosme0218@gmail.com\"}', '2025-09-08 09:10:28'),
(6, NULL, 2, 'user:login_success', 'user', '2', '{\"email\":\"mohithlingosme0218@gmail.com\"}', '2025-09-08 09:10:46'),
(7, NULL, 2, 'user:login_success', 'user', '2', '{\"email\":\"mohithlingosme0218@gmail.com\"}', '2025-09-08 09:10:57'),
(8, NULL, 2, 'user:login_success', 'user', '2', '{\"email\":\"mohithlingosme0218@gmail.com\"}', '2025-09-08 09:22:45'),
(9, 1, 2, 'project:create_failed:permission_denied', 'project', NULL, '{\"reason\":\"permission_denied\"}', '2025-09-08 09:27:37'),
(10, 1, 1, 'project:list_success', 'project', NULL, '{\"num_projects\":0}', '2025-09-09 02:39:35'),
(11, 1, 1, 'project:create_success', 'project', '1', '{\"project_name\":\"MIndflow.AI\",\"visibility\":\"private\"}', '2025-09-09 02:40:12'),
(12, 1, 1, 'task:create_failed:server_error', 'task', NULL, '{\"task_name\":\"Concept of iddat \",\"project_id\":null,\"error\":\"Column \'project_id\' cannot be null\"}', '2025-09-09 02:46:12'),
(13, 1, 1, 'task:create_failed:server_error', 'task', NULL, '{\"task_name\":\"Concept of iddat \",\"project_id\":null,\"error\":\"Column \'project_id\' cannot be null\"}', '2025-09-09 02:46:15'),
(14, 1, 1, 'task:create_failed:server_error', 'task', NULL, '{\"task_name\":\"Concept of iddat \",\"project_id\":null,\"error\":\"Column \'project_id\' cannot be null\"}', '2025-09-09 02:46:20'),
(15, 1, 1, 'task:create_failed:server_error', 'task', NULL, '{\"task_name\":\"Concept of iddat \",\"project_id\":null,\"error\":\"Column \'project_id\' cannot be null\"}', '2025-09-09 02:46:29'),
(16, 1, 1, 'task:create_failed:server_error', 'task', NULL, '{\"task_name\":\"Concept of iddat \",\"project_id\":null,\"error\":\"Column \'project_id\' cannot be null\"}', '2025-09-09 02:46:33'),
(17, 1, 1, 'task:create_failed:missing_project_id', 'task', NULL, '{\"reason\":\"missing_project_id\"}', '2025-09-09 02:50:15'),
(18, 1, 1, 'task:create_failed:missing_project_id', 'task', NULL, '{\"reason\":\"missing_project_id\"}', '2025-09-09 02:50:16'),
(19, 1, 1, 'task:create_failed:missing_project_id', 'task', NULL, '{\"reason\":\"missing_project_id\"}', '2025-09-09 02:50:39'),
(20, 1, 1, 'task:create_failed:missing_project_id', 'task', NULL, '{\"reason\":\"missing_project_id\"}', '2025-09-09 03:26:04'),
(21, 1, 1, 'task:create_failed:missing_project_id', 'task', NULL, '{\"reason\":\"missing_project_id\"}', '2025-09-09 03:27:14'),
(22, 1, 1, 'project:list_simple_success', 'project', NULL, '{\"num_projects\":1}', '2025-09-10 03:25:46'),
(23, 1, 1, 'project:list_simple_success', 'project', NULL, '{\"num_projects\":1}', '2025-09-10 03:53:51'),
(24, 1, 1, 'project:list_simple_success', 'project', NULL, '{\"num_projects\":1}', '2025-09-10 04:20:24'),
(25, 1, 1, 'project:list_simple_success', 'project', NULL, '{\"num_projects\":1}', '2025-09-10 04:37:10'),
(26, 1, 1, 'project:list_simple_success', 'project', NULL, '{\"num_projects\":1}', '2025-09-10 05:19:31'),
(27, 1, 1, 'groups:list_success', 'groups', NULL, '{\"count\":2}', '2025-09-10 05:34:23'),
(28, 1, 1, 'project:list_simple_success', 'project', NULL, '{\"num_projects\":1}', '2025-09-10 05:39:15'),
(29, 1, 1, 'project:list_simple_success', 'project', NULL, '{\"num_projects\":1}', '2025-09-10 05:45:17'),
(30, 1, 1, 'project:list_simple_success', 'project', NULL, '{\"num_projects\":1}', '2025-09-10 05:45:36');

-- --------------------------------------------------------

--
-- Table structure for table `blueprints`
--

CREATE TABLE `blueprints` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the blueprint',
  `table_name` varchar(255) NOT NULL COMMENT 'Name of the generated SQL table',
  `schema_definition` text NOT NULL COMMENT 'SQL schema definition of the generated table',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the blueprint was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the blueprint was last updated'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores dynamically generated SQL table blueprints';

-- --------------------------------------------------------

--
-- Table structure for table `business_concept`
--

CREATE TABLE `business_concept` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `key_features` text DEFAULT NULL,
  `target_users` text DEFAULT NULL,
  `business_value` text DEFAULT NULL,
  `revenue_model` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores high-level business concept details for projects';

-- --------------------------------------------------------

--
-- Table structure for table `chats`
--

CREATE TABLE `chats` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the chat thread',
  `project_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the projects table, linking chat to a project',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the chat thread was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the chat thread was last updated (e.g., new message)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores chat threads, typically associated with a project';

-- --------------------------------------------------------

--
-- Table structure for table `completed_tasks`
--

CREATE TABLE `completed_tasks` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the completed task entry',
  `project_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the projects table',
  `title` varchar(200) NOT NULL COMMENT 'Title of the completed task',
  `description` text DEFAULT NULL COMMENT 'Description of the completed task',
  `status` enum('completed') NOT NULL DEFAULT 'completed' COMMENT 'Status of the task (always completed)',
  `priority_level` tinyint(3) UNSIGNED NOT NULL DEFAULT 2 COMMENT 'Priority level when the task was active',
  `deadline` datetime DEFAULT NULL COMMENT 'Deadline of the task when it was active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the task was originally created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the task was marked as completed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Archives tasks that have been marked as completed';

-- --------------------------------------------------------

--
-- Table structure for table `custom_fields`
--

CREATE TABLE `custom_fields` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the custom field definition',
  `organization_id` int(11) UNSIGNED DEFAULT NULL COMMENT 'Foreign key to organizations, for organization-specific custom fields',
  `entity_type` varchar(50) NOT NULL COMMENT 'The entity type this custom field applies to (e.g., project, task, user)',
  `name` varchar(100) NOT NULL COMMENT 'Name of the custom field',
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'JSON schema or metadata for the custom field (e.g., type, options)' CHECK (json_valid(`meta`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the custom field was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the custom field was last updated'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Defines customizable fields for various entities (projects, tasks, users)';

-- --------------------------------------------------------

--
-- Table structure for table `groups`
--

CREATE TABLE `groups` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `allow_member_project_creation` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `organization_id` int(11) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `name`, `description`, `allow_member_project_creation`, `created_at`, `updated_at`, `organization_id`) VALUES
(1, 'Development Team', 'Main development team for software projects', 1, '2025-09-09 03:13:20', '2025-09-09 03:13:20', 1),
(2, 'Marketing Team', 'Marketing and promotion team', 0, '2025-09-09 03:13:20', '2025-09-09 03:13:20', 1),
(3, 'Management Team', 'Project management and oversight', 1, '2025-09-09 03:13:20', '2025-09-09 03:13:20', 1);

-- --------------------------------------------------------

--
-- Table structure for table `group_members`
--

CREATE TABLE `group_members` (
  `id` int(11) UNSIGNED NOT NULL,
  `group_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `role` enum('admin','member') NOT NULL DEFAULT 'member',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `group_members`
--

INSERT INTO `group_members` (`id`, `group_id`, `user_id`, `role`, `joined_at`) VALUES
(6, 1, 1, 'admin', '2025-09-09 03:16:28'),
(7, 1, 2, 'member', '2025-09-09 03:16:28'),
(8, 3, 1, 'admin', '2025-09-09 03:16:28'),
(9, 3, 2, 'member', '2025-09-09 03:16:28');

-- --------------------------------------------------------

--
-- Table structure for table `market_opportunity`
--

CREATE TABLE `market_opportunity` (
  `id` int(10) UNSIGNED NOT NULL,
  `details` text DEFAULT NULL,
  `tam` decimal(15,2) DEFAULT NULL,
  `sam` decimal(15,2) DEFAULT NULL,
  `som` decimal(15,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores market opportunity analysis details';

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the message',
  `chat_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the chats table',
  `user_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the users table, indicating who sent the message',
  `message_content` text NOT NULL COMMENT 'The actual content of the message',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the message was sent'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores individual messages within chat threads';

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the notification',
  `user_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the users table, indicating the recipient',
  `message` text NOT NULL COMMENT 'The content of the notification',
  `is_read` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Flag indicating if the notification has been read',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the notification was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the notification was last updated (e.g., marked as read)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores notifications for users about system events or messages';

-- --------------------------------------------------------

--
-- Table structure for table `organizations`
--

CREATE TABLE `organizations` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the organization',
  `name` varchar(200) NOT NULL COMMENT 'Name of the organization',
  `slug` varchar(200) NOT NULL COMMENT 'URL-friendly unique identifier for the organization',
  `settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'JSON column for organization-specific settings (e.g., project defaults)' CHECK (json_valid(`settings`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the organization was created'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Supports multi-tenancy by grouping users and projects under different organizations';

--
-- Dumping data for table `organizations`
--

INSERT INTO `organizations` (`id`, `name`, `slug`, `settings`, `created_at`) VALUES
(1, 'Default Organization', 'default-org', NULL, '2025-09-08 08:37:23');

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the permission',
  `code` varchar(100) NOT NULL COMMENT 'Unique code for the permission (e.g., project:view, task:edit)',
  `description` varchar(255) DEFAULT NULL COMMENT 'Description of what the permission allows',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the permission was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the permission was last updated'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Defines granular permissions that can be assigned to roles';

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `code`, `description`, `created_at`, `updated_at`) VALUES
(1, 'org:manage', 'Manage organization settings and users', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(2, 'user:manage', 'Create, edit, delete users', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(3, 'role:manage', 'Create, edit, delete roles and assign permissions', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(4, 'project:create', 'Create new projects', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(5, 'project:view', 'View any project details', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(6, 'project:edit', 'Edit any project details', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(7, 'project:delete', 'Delete any project', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(8, 'task:create', 'Create new tasks', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(9, 'task:view', 'View any task details', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(10, 'task:edit', 'Edit any task details', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(11, 'task:delete', 'Delete any task', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(12, 'invite:create', 'Create project invite links', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(13, 'invite:revoke', 'Revoke project invite links', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(14, 'chat:send_message', 'Send messages in project chats', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(15, 'chat:view', 'View project chat history', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(16, 'blueprint:generate', 'Generate SQL table blueprints', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(17, 'blueprint:view', 'View SQL table blueprints', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(18, 'ai_plan:generate', 'Generate AI project plans', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(19, 'ai_plan:view', 'View AI project plans', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(20, 'ai_plan:save', 'Save AI project plans', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(21, 'project:view_members', 'View project members', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(22, 'project:remove_member', 'Remove members from a project', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(23, 'project:edit_member_role', 'Edit project member roles', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(24, 'role:view_permissions', 'View permissions assigned to roles', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(25, 'role:edit_permissions', 'Edit permissions assigned to roles', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(26, 'settings:view_project_defaults', 'View project default settings', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(27, 'settings:edit_project_defaults', 'Edit project default settings', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(28, 'user:view_self', 'View own user profile', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(29, 'user:edit_self', 'Edit own user profile', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(30, 'user:change_password_self', 'Change own password', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(31, 'project_template:view', 'View project templates', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(32, 'role:view', 'View roles and their descriptions', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(33, 'permission:view', 'View available permissions', '2025-09-08 08:37:24', '2025-09-08 08:37:24'),
(34, 'chat:create', 'Create new chat threads', '2025-09-08 08:37:24', '2025-09-08 08:37:24');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the project',
  `organization_id` int(11) UNSIGNED DEFAULT NULL COMMENT 'Foreign key to the organizations table, for multi-tenancy',
  `owner_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the users table, indicating the project owner',
  `name` varchar(255) NOT NULL COMMENT 'Name of the project',
  `description` text DEFAULT NULL COMMENT 'Detailed description of the project',
  `status` enum('active','archived','completed') NOT NULL DEFAULT 'active' COMMENT 'Current operational status of the project',
  `visibility` enum('private','org','public') NOT NULL DEFAULT 'private' COMMENT 'Visibility setting for the project',
  `plan_document_path` varchar(255) DEFAULT NULL COMMENT 'Path to the project plan document',
  `blueprint_document_path` varchar(255) DEFAULT NULL COMMENT 'Path to the project blueprint document',
  `dev_directory` varchar(255) DEFAULT NULL COMMENT 'Development directory for the project',
  `project_link` varchar(255) DEFAULT NULL COMMENT 'External link related to the project',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the project was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the project was last updated',
  `group_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores main project details, its owner, organization, and visibility settings';

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `organization_id`, `owner_id`, `name`, `description`, `status`, `visibility`, `plan_document_path`, `blueprint_document_path`, `dev_directory`, `project_link`, `created_at`, `updated_at`, `group_id`) VALUES
(1, 1, 1, 'MIndflow.AI', 'It is a AI powered prioject management app', 'active', 'private', NULL, NULL, NULL, NULL, '2025-09-09 02:40:12', '2025-09-09 02:40:12', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `project_invites`
--

CREATE TABLE `project_invites` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the project invite',
  `project_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the projects table, for which the invite is generated',
  `invite_code_hash` char(64) NOT NULL COMMENT 'SHA256 hash of the unique invite code',
  `created_by` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the users table, indicating who created the invite',
  `role` enum('member','viewer') NOT NULL DEFAULT 'member' COMMENT 'Default role assigned to the user upon accepting the invite',
  `expires_at` datetime DEFAULT NULL COMMENT 'Timestamp when the invite link expires',
  `max_uses` int(11) NOT NULL DEFAULT 1 COMMENT 'Maximum number of times this invite link can be used',
  `uses` int(11) NOT NULL DEFAULT 0 COMMENT 'Number of times this invite link has been used',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the invite link was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the invite link was last updated (e.g., uses incremented)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores secure invite hashes for users to join projects, with expiry and usage limits';

-- --------------------------------------------------------

--
-- Table structure for table `project_status`
--

CREATE TABLE `project_status` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the status entry',
  `project_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the projects table',
  `status_stage` enum('research','planning','design','development','testing','deployment','post_launch') NOT NULL COMMENT 'Current stage of the project lifecycle',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when this status stage was set'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Tracks the historical status stages of projects';

-- --------------------------------------------------------

--
-- Table structure for table `project_templates`
--

CREATE TABLE `project_templates` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the project template',
  `organization_id` int(11) UNSIGNED DEFAULT NULL COMMENT 'Foreign key to organizations, for organization-specific templates',
  `name` varchar(200) NOT NULL COMMENT 'Name of the template',
  `summary` text DEFAULT NULL COMMENT 'Summary or description of the template',
  `blueprint` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'JSON structure defining the template (e.g., default tasks, settings)' CHECK (json_valid(`blueprint`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the template was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the template was last updated'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores customizable project templates for quick project creation';

-- --------------------------------------------------------

--
-- Table structure for table `project_users`
--

CREATE TABLE `project_users` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the project user entry',
  `project_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the projects table',
  `user_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the users table',
  `role` enum('owner','manager','member','viewer') NOT NULL DEFAULT 'member' COMMENT 'Role of the user within this specific project',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the user joined the project'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Manages many-to-many relationships between projects and users, defining project-specific roles';

--
-- Dumping data for table `project_users`
--

INSERT INTO `project_users` (`id`, `project_id`, `user_id`, `role`, `joined_at`) VALUES
(1, 1, 1, 'owner', '2025-09-09 02:40:12');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the role',
  `organization_id` int(11) UNSIGNED DEFAULT NULL COMMENT 'Foreign key to organizations, allowing organization-specific roles',
  `name` varchar(50) NOT NULL COMMENT 'Name of the role (e.g., admin, manager, member)',
  `description` varchar(255) DEFAULT NULL COMMENT 'Description of the role',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the role was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the role was last updated'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Defines roles for role-based access control (RBAC)';

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `organization_id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, NULL, 'admin', 'Full administrative access across all organizations', '2025-09-08 08:37:23', '2025-09-08 08:37:23'),
(2, NULL, 'manager', 'Manages projects within an organization', '2025-09-08 08:37:23', '2025-09-08 08:37:23'),
(3, NULL, 'member', 'Regular project member with task access', '2025-09-08 08:37:23', '2025-09-08 08:37:23'),
(4, NULL, 'viewer', 'Can only view project details and tasks', '2025-09-08 08:37:23', '2025-09-08 08:37:23');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `role_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the roles table',
  `permission_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the permissions table'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Links roles to specific permissions, defining what each role can do';

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`role_id`, `permission_id`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(1, 9),
(1, 10),
(1, 11),
(1, 12),
(1, 13),
(1, 14),
(1, 15),
(1, 16),
(1, 17),
(1, 18),
(1, 19),
(1, 20),
(1, 21),
(1, 22),
(1, 23),
(1, 24),
(1, 25),
(1, 26),
(1, 27),
(1, 28),
(1, 29),
(1, 30),
(1, 31),
(1, 32),
(1, 33),
(1, 34),
(2, 4),
(2, 5),
(2, 6),
(2, 8),
(2, 9),
(2, 10),
(2, 12),
(2, 13),
(2, 14),
(2, 15),
(2, 16),
(2, 17),
(2, 18),
(2, 19),
(2, 20),
(2, 28),
(2, 29),
(2, 30),
(2, 31),
(2, 32),
(2, 33),
(2, 34),
(3, 5),
(3, 8),
(3, 9),
(3, 10),
(3, 14),
(3, 15),
(3, 19),
(3, 28),
(3, 29),
(3, 30),
(3, 32),
(3, 34),
(4, 5),
(4, 9),
(4, 15),
(4, 17),
(4, 19),
(4, 28),
(4, 29),
(4, 30),
(4, 32);

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the task',
  `project_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the projects table',
  `title` varchar(200) NOT NULL COMMENT 'Title or brief description of the task',
  `description` text DEFAULT NULL COMMENT 'Detailed description of the task',
  `status` enum('pending','in_progress','blocked','completed') NOT NULL DEFAULT 'pending' COMMENT 'Current status of the task',
  `priority_level` tinyint(3) UNSIGNED NOT NULL DEFAULT 2 COMMENT 'Priority level of the task (e.g., 1-5, 5 being highest)',
  `deadline` datetime DEFAULT NULL COMMENT 'Deadline for the task',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the task was created',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the task was last updated'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores individual tasks associated with projects';

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the user',
  `organization_id` int(11) UNSIGNED DEFAULT NULL COMMENT 'Foreign key to the organizations table, linking users to their organization',
  `username` varchar(100) NOT NULL COMMENT 'Unique username for login',
  `email` varchar(255) NOT NULL COMMENT 'Unique email address of the user',
  `password_hash` varchar(255) NOT NULL COMMENT 'Securely hashed password for authentication (e.g., bcrypt)',
  `is_email_verified` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Flag indicating if the user''s email has been verified',
  `job_title` varchar(255) DEFAULT NULL COMMENT 'User''s job title or position',
  `bio` text DEFAULT NULL COMMENT 'Short biography or description of the user',
  `status` enum('active','inactive','banned') NOT NULL DEFAULT 'active' COMMENT 'Current status of the user account',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the user account was created',
  `last_login_at` datetime DEFAULT NULL COMMENT 'Timestamp of the user''s last successful login',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp when the user account was last updated'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Stores user account information, including authentication credentials and organization affiliation';

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `organization_id`, `username`, `email`, `password_hash`, `is_email_verified`, `job_title`, `bio`, `status`, `created_at`, `last_login_at`, `updated_at`) VALUES
(1, 1, 'admin', 'admin@example.com', '$2y$10$S.vFp.qW.z.1.2.3.4.5.6.7.8.9.0.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F', 1, NULL, NULL, 'active', '2025-09-08 08:37:23', NULL, '2025-09-08 08:37:23'),
(2, NULL, 'Mohith', 'mohithlingosme0218@gmail.com', '$2y$10$dmQjI3AWF8B08Z.hFS4VM.cqJgeWjwrJEnD.jzu9j9EInX0zBeP9u', 0, NULL, NULL, 'active', '2025-09-08 08:38:21', '2025-09-08 14:52:45', '2025-09-08 09:22:45');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for the user-role assignment',
  `user_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the users table',
  `role_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the roles table',
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the role was assigned to the user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Assigns roles to users, enabling role-based access control';

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`id`, `user_id`, `role_id`, `assigned_at`) VALUES
(1, 1, 1, '2025-09-08 08:37:24'),
(2, 2, 3, '2025-09-08 08:38:21');

-- --------------------------------------------------------

--
-- Table structure for table `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'Unique identifier for the user session',
  `user_id` int(11) UNSIGNED NOT NULL COMMENT 'Foreign key to the users table',
  `session_token_hash` char(64) NOT NULL COMMENT 'SHA256 hash of the session token',
  `user_agent` varchar(512) DEFAULT NULL COMMENT 'User-Agent string from the client',
  `ip` varchar(45) DEFAULT NULL COMMENT 'IP address from which the session was initiated',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Timestamp when the session was created',
  `last_seen_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Timestamp of the last activity in this session',
  `expires_at` datetime DEFAULT NULL COMMENT 'Timestamp when the session token expires'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Manages user sessions, storing hashed session tokens for authentication and auditing';

--
-- Dumping data for table `user_sessions`
--

INSERT INTO `user_sessions` (`id`, `user_id`, `session_token_hash`, `user_agent`, `ip`, `created_at`, `last_seen_at`, `expires_at`) VALUES
(1, 2, '8bc59c8f76272c73f26e0b005c3ed42777a77d2b1e6bde103670f978482a6033', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '127.0.0.1', '2025-09-08 08:38:58', '2025-09-08 08:38:58', '2025-09-09 10:38:58'),
(2, 2, '30c2677f5f180568827405a3c5a9574589034f3f78bc0de6bd61bf563491613c', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '127.0.0.1', '2025-09-08 08:39:04', '2025-09-08 08:39:04', '2025-09-09 10:39:04'),
(3, 2, '5d944f58a8fe788293afb32673aa3b58df7c19c65eafe99f019ffc2fd525fc7c', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '127.0.0.1', '2025-09-08 08:57:17', '2025-09-08 08:57:17', '2025-09-09 10:57:17'),
(4, 2, 'de9a114b8ec490792381e75992ebf9de571a377b6071213200824c09dbbc67bc', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '127.0.0.1', '2025-09-08 09:10:28', '2025-09-08 09:10:28', '2025-09-09 11:10:28'),
(5, 2, 'f7cf9cfd2ddd74c10405c32f142bd4e607c9c5ec1f254be18132f0ae5a79cf80', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '127.0.0.1', '2025-09-08 09:10:46', '2025-09-08 09:10:46', '2025-09-09 11:10:46'),
(6, 2, '7838b8c99c7edea3ccb2bec329477fe59d14dab4b3692578afc9e11a92a61097', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '127.0.0.1', '2025-09-08 09:10:57', '2025-09-08 09:10:57', '2025-09-09 11:10:57'),
(7, 2, '7c61bb951555673486fd8bca330fe4e096bd652d86377ecc0600d35364c8c60b', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36', '127.0.0.1', '2025-09-08 09:22:45', '2025-09-08 09:22:45', '2025-09-09 11:22:45');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ai_project_plans`
--
ALTER TABLE `ai_project_plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project_id_ai_plans` (`project_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_organization_id_al` (`organization_id`),
  ADD KEY `idx_user_id_al` (`user_id`),
  ADD KEY `idx_action_al` (`action`);

--
-- Indexes for table `blueprints`
--
ALTER TABLE `blueprints`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `table_name` (`table_name`),
  ADD UNIQUE KEY `idx_table_name_unique` (`table_name`);

--
-- Indexes for table `business_concept`
--
ALTER TABLE `business_concept`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `chats`
--
ALTER TABLE `chats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project_id_chats` (`project_id`);

--
-- Indexes for table `completed_tasks`
--
ALTER TABLE `completed_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project_id_completed_tasks` (`project_id`);

--
-- Indexes for table `custom_fields`
--
ALTER TABLE `custom_fields`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_org_entity_name_unique` (`organization_id`,`entity_type`,`name`),
  ADD KEY `idx_organization_id_cf` (`organization_id`);

--
-- Indexes for table `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `idx_groups_organization_id` (`organization_id`);

--
-- Indexes for table `group_members`
--
ALTER TABLE `group_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_unique_group_user` (`group_id`,`user_id`),
  ADD KEY `idx_group_members_user_id` (`user_id`),
  ADD KEY `idx_group_members_group_id` (`group_id`);

--
-- Indexes for table `market_opportunity`
--
ALTER TABLE `market_opportunity`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_chat_id_messages` (`chat_id`),
  ADD KEY `idx_user_id_messages` (`user_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id_notifications` (`user_id`);

--
-- Indexes for table `organizations`
--
ALTER TABLE `organizations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD UNIQUE KEY `idx_slug_unique` (`slug`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD UNIQUE KEY `idx_permission_code_unique` (`code`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_organization_id_projects` (`organization_id`),
  ADD KEY `idx_owner_id_projects` (`owner_id`),
  ADD KEY `idx_projects_group_id` (`group_id`);

--
-- Indexes for table `project_invites`
--
ALTER TABLE `project_invites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `invite_code_hash` (`invite_code_hash`),
  ADD UNIQUE KEY `idx_invite_code_hash_unique` (`invite_code_hash`),
  ADD KEY `idx_project_id_pi` (`project_id`),
  ADD KEY `idx_created_by_pi` (`created_by`);

--
-- Indexes for table `project_status`
--
ALTER TABLE `project_status`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project_id_status` (`project_id`);

--
-- Indexes for table `project_templates`
--
ALTER TABLE `project_templates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_organization_id_pt` (`organization_id`);

--
-- Indexes for table `project_users`
--
ALTER TABLE `project_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_project_user_unique` (`project_id`,`user_id`),
  ADD KEY `idx_project_id_pu` (`project_id`),
  ADD KEY `idx_user_id_pu` (`user_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_org_role_unique` (`organization_id`,`name`),
  ADD KEY `idx_organization_id_roles` (`organization_id`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY `idx_role_id_rp` (`role_id`),
  ADD KEY `idx_permission_id_rp` (`permission_id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_project_id_tasks` (`project_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `idx_username_unique` (`username`),
  ADD UNIQUE KEY `idx_email_unique` (`email`),
  ADD KEY `idx_organization_id_users` (`organization_id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_user_role_unique` (`user_id`,`role_id`),
  ADD KEY `idx_user_id_ur` (`user_id`),
  ADD KEY `idx_role_id_ur` (`role_id`);

--
-- Indexes for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_token_hash` (`session_token_hash`),
  ADD UNIQUE KEY `idx_session_token_hash_unique` (`session_token_hash`),
  ADD KEY `idx_user_id_us` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ai_project_plans`
--
ALTER TABLE `ai_project_plans`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the AI-generated plan', AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the audit log entry', AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `blueprints`
--
ALTER TABLE `blueprints`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the blueprint';

--
-- AUTO_INCREMENT for table `business_concept`
--
ALTER TABLE `business_concept`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chats`
--
ALTER TABLE `chats`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the chat thread';

--
-- AUTO_INCREMENT for table `completed_tasks`
--
ALTER TABLE `completed_tasks`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the completed task entry';

--
-- AUTO_INCREMENT for table `custom_fields`
--
ALTER TABLE `custom_fields`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the custom field definition';

--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `group_members`
--
ALTER TABLE `group_members`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `market_opportunity`
--
ALTER TABLE `market_opportunity`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the message';

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the notification';

--
-- AUTO_INCREMENT for table `organizations`
--
ALTER TABLE `organizations`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the organization', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the permission', AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the project', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `project_invites`
--
ALTER TABLE `project_invites`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the project invite';

--
-- AUTO_INCREMENT for table `project_status`
--
ALTER TABLE `project_status`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the status entry';

--
-- AUTO_INCREMENT for table `project_templates`
--
ALTER TABLE `project_templates`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the project template';

--
-- AUTO_INCREMENT for table `project_users`
--
ALTER TABLE `project_users`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the project user entry', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the role', AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the task';

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the user', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the user-role assignment', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the user session', AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ai_project_plans`
--
ALTER TABLE `ai_project_plans`
  ADD CONSTRAINT `fk_ai_project_plans_project_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_audit_org` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `chats`
--
ALTER TABLE `chats`
  ADD CONSTRAINT `fk_chats_project_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `completed_tasks`
--
ALTER TABLE `completed_tasks`
  ADD CONSTRAINT `fk_completed_tasks_project_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `custom_fields`
--
ALTER TABLE `custom_fields`
  ADD CONSTRAINT `fk_cf_org` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `groups`
--
ALTER TABLE `groups`
  ADD CONSTRAINT `fk_groups_organization` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `group_members`
--
ALTER TABLE `group_members`
  ADD CONSTRAINT `fk_group_members_group` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_group_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `fk_messages_chat_id` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_messages_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `fk_projects_group` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_projects_org` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_projects_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `project_invites`
--
ALTER TABLE `project_invites`
  ADD CONSTRAINT `fk_pi_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pi_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `project_status`
--
ALTER TABLE `project_status`
  ADD CONSTRAINT `fk_project_status_project_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `project_templates`
--
ALTER TABLE `project_templates`
  ADD CONSTRAINT `fk_pt_org` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `project_users`
--
ALTER TABLE `project_users`
  ADD CONSTRAINT `fk_pu_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pu_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `roles`
--
ALTER TABLE `roles`
  ADD CONSTRAINT `fk_roles_org` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `fk_rp_perm` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `fk_tasks_project_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_org` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `fk_us_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
--
-- Database: `phpmyadmin`
--
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE `phpmyadmin`;

-- --------------------------------------------------------

--
-- Table structure for table `pma__bookmark`
--

CREATE TABLE `pma__bookmark` (
  `id` int(10) UNSIGNED NOT NULL,
  `dbase` varchar(255) NOT NULL DEFAULT '',
  `user` varchar(255) NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `query` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Bookmarks';

-- --------------------------------------------------------

--
-- Table structure for table `pma__central_columns`
--

CREATE TABLE `pma__central_columns` (
  `db_name` varchar(64) NOT NULL,
  `col_name` varchar(64) NOT NULL,
  `col_type` varchar(64) NOT NULL,
  `col_length` text DEFAULT NULL,
  `col_collation` varchar(64) NOT NULL,
  `col_isNull` tinyint(1) NOT NULL,
  `col_extra` varchar(255) DEFAULT '',
  `col_default` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Central list of columns';

-- --------------------------------------------------------

--
-- Table structure for table `pma__column_info`
--

CREATE TABLE `pma__column_info` (
  `id` int(5) UNSIGNED NOT NULL,
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `column_name` varchar(64) NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) NOT NULL DEFAULT '',
  `transformation_options` varchar(255) NOT NULL DEFAULT '',
  `input_transformation` varchar(255) NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Column information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__designer_settings`
--

CREATE TABLE `pma__designer_settings` (
  `username` varchar(64) NOT NULL,
  `settings_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Settings related to Designer';

-- --------------------------------------------------------

--
-- Table structure for table `pma__export_templates`
--

CREATE TABLE `pma__export_templates` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL,
  `export_type` varchar(10) NOT NULL,
  `template_name` varchar(64) NOT NULL,
  `template_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved export templates';

-- --------------------------------------------------------

--
-- Table structure for table `pma__favorite`
--

CREATE TABLE `pma__favorite` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Favorite tables';

-- --------------------------------------------------------

--
-- Table structure for table `pma__history`
--

CREATE TABLE `pma__history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db` varchar(64) NOT NULL DEFAULT '',
  `table` varchar(64) NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='SQL history for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__navigationhiding`
--

CREATE TABLE `pma__navigationhiding` (
  `username` varchar(64) NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `item_type` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Hidden items of navigation tree';

-- --------------------------------------------------------

--
-- Table structure for table `pma__pdf_pages`
--

CREATE TABLE `pma__pdf_pages` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `page_nr` int(10) UNSIGNED NOT NULL,
  `page_descr` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='PDF relation pages for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__recent`
--

CREATE TABLE `pma__recent` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Recently accessed tables';

--
-- Dumping data for table `pma__recent`
--

INSERT INTO `pma__recent` (`username`, `tables`) VALUES
('root', '[{\"db\":\"mindflow_db\",\"table\":\"ai_project_plans\"},{\"db\":\"mindflow_db\",\"table\":\"users\"}]');

-- --------------------------------------------------------

--
-- Table structure for table `pma__relation`
--

CREATE TABLE `pma__relation` (
  `master_db` varchar(64) NOT NULL DEFAULT '',
  `master_table` varchar(64) NOT NULL DEFAULT '',
  `master_field` varchar(64) NOT NULL DEFAULT '',
  `foreign_db` varchar(64) NOT NULL DEFAULT '',
  `foreign_table` varchar(64) NOT NULL DEFAULT '',
  `foreign_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Relation table';

-- --------------------------------------------------------

--
-- Table structure for table `pma__savedsearches`
--

CREATE TABLE `pma__savedsearches` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `search_name` varchar(64) NOT NULL DEFAULT '',
  `search_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved searches';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_coords`
--

CREATE TABLE `pma__table_coords` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `pdf_page_number` int(11) NOT NULL DEFAULT 0,
  `x` float UNSIGNED NOT NULL DEFAULT 0,
  `y` float UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table coordinates for phpMyAdmin PDF output';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_info`
--

CREATE TABLE `pma__table_info` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `display_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_uiprefs`
--

CREATE TABLE `pma__table_uiprefs` (
  `username` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `prefs` text NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Tables'' UI preferences';

-- --------------------------------------------------------

--
-- Table structure for table `pma__tracking`
--

CREATE TABLE `pma__tracking` (
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `version` int(10) UNSIGNED NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text NOT NULL,
  `schema_sql` text DEFAULT NULL,
  `data_sql` longtext DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') DEFAULT NULL,
  `tracking_active` int(1) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Database changes tracking for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__userconfig`
--

CREATE TABLE `pma__userconfig` (
  `username` varchar(64) NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User preferences storage for phpMyAdmin';

--
-- Dumping data for table `pma__userconfig`
--

INSERT INTO `pma__userconfig` (`username`, `timevalue`, `config_data`) VALUES
('root', '2025-11-24 06:30:23', '{\"Console\\/Mode\":\"collapse\",\"lang\":\"en_GB\",\"NavigationWidth\":0}');

-- --------------------------------------------------------

--
-- Table structure for table `pma__usergroups`
--

CREATE TABLE `pma__usergroups` (
  `usergroup` varchar(64) NOT NULL,
  `tab` varchar(64) NOT NULL,
  `allowed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User groups with configured menu items';

-- --------------------------------------------------------

--
-- Table structure for table `pma__users`
--

CREATE TABLE `pma__users` (
  `username` varchar(64) NOT NULL,
  `usergroup` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Users and their assignments to user groups';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pma__central_columns`
--
ALTER TABLE `pma__central_columns`
  ADD PRIMARY KEY (`db_name`,`col_name`);

--
-- Indexes for table `pma__column_info`
--
ALTER TABLE `pma__column_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`);

--
-- Indexes for table `pma__designer_settings`
--
ALTER TABLE `pma__designer_settings`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`);

--
-- Indexes for table `pma__favorite`
--
ALTER TABLE `pma__favorite`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__history`
--
ALTER TABLE `pma__history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`,`db`,`table`,`timevalue`);

--
-- Indexes for table `pma__navigationhiding`
--
ALTER TABLE `pma__navigationhiding`
  ADD PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`);

--
-- Indexes for table `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  ADD PRIMARY KEY (`page_nr`),
  ADD KEY `db_name` (`db_name`);

--
-- Indexes for table `pma__recent`
--
ALTER TABLE `pma__recent`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__relation`
--
ALTER TABLE `pma__relation`
  ADD PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  ADD KEY `foreign_field` (`foreign_db`,`foreign_table`);

--
-- Indexes for table `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`);

--
-- Indexes for table `pma__table_coords`
--
ALTER TABLE `pma__table_coords`
  ADD PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`);

--
-- Indexes for table `pma__table_info`
--
ALTER TABLE `pma__table_info`
  ADD PRIMARY KEY (`db_name`,`table_name`);

--
-- Indexes for table `pma__table_uiprefs`
--
ALTER TABLE `pma__table_uiprefs`
  ADD PRIMARY KEY (`username`,`db_name`,`table_name`);

--
-- Indexes for table `pma__tracking`
--
ALTER TABLE `pma__tracking`
  ADD PRIMARY KEY (`db_name`,`table_name`,`version`);

--
-- Indexes for table `pma__userconfig`
--
ALTER TABLE `pma__userconfig`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__usergroups`
--
ALTER TABLE `pma__usergroups`
  ADD PRIMARY KEY (`usergroup`,`tab`,`allowed`);

--
-- Indexes for table `pma__users`
--
ALTER TABLE `pma__users`
  ADD PRIMARY KEY (`username`,`usergroup`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__column_info`
--
ALTER TABLE `pma__column_info`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__history`
--
ALTER TABLE `pma__history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  MODIFY `page_nr` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- Database: `test`
--
CREATE DATABASE IF NOT EXISTS `test` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `test`;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
