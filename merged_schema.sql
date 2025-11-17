-- Unified Normalized Schema for Autopredator Project
-- Merges autopredator (users), car (vehicles, features, etc.), and blogs (blogs) into a single database schema.
-- Database: autopredator_unified

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Unified Users Table (merged from autopredator and car users)
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

-- Vehicle-related tables from car (3).sql
CREATE TABLE `manufacturers` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `country` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `models` (
  `id` int(11) NOT NULL,
  `manufacturer_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `launch_year` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `variants` (
  `id` int(11) NOT NULL,
  `model_id` int(11) NOT NULL,
  `variant_name` varchar(100) NOT NULL,
  `fuel_type` enum('Petrol','Diesel','CNG','Electric','Hybrid') NOT NULL,
  `transmission` enum('Manual','Automatic','AMT','CVT') NOT NULL,
  `power` varchar(20) DEFAULT NULL,
  `mileage` varchar(20) DEFAULT NULL,
  `ex_showroom_price` decimal(10,2) DEFAULT NULL,
  `on_road_price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `features` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `variant_features` (
  `variant_id` int(11) NOT NULL,
  `feature_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

CREATE TABLE `images` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_thumbnail` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `price_history` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `rating` tinyint(4) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Blogs table from blogs (2).sql
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

-- Basic Insurance Table (for future links)
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

-- User Vehicles (Ownership)
CREATE TABLE `user_vehicles` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `vin` varchar(50) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL,
  `mileage` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Maintenance
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

-- Fleet (for fleet management)
CREATE TABLE `fleet` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,  -- Dealer or company
  `name` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Fleet Vehicles
CREATE TABLE `fleet_vehicles` (
  `id` int(11) NOT NULL,
  `fleet_id` int(11) NOT NULL,
  `user_vehicle_id` int(11) NOT NULL,
  `assigned_driver` varchar(100) DEFAULT NULL,
  `status` enum('Active','Inactive','Maintenance') DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Indexes and Constraints
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`);

ALTER TABLE `manufacturers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

ALTER TABLE `models`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manufacturer_id` (`manufacturer_id`);

ALTER TABLE `variants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `model_id` (`model_id`);

ALTER TABLE `features`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

ALTER TABLE `variant_features`
  ADD PRIMARY KEY (`variant_id`,`feature_id`),
  ADD KEY `feature_id` (`feature_id`);

ALTER TABLE `vehicle_specs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

ALTER TABLE `images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

ALTER TABLE `price_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `variant_id` (`variant_id`);

ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`);

ALTER TABLE `blogs`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `insurance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`);

ALTER TABLE `user_vehicles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `variant_id` (`variant_id`);

ALTER TABLE `maintenance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_vehicle_id` (`user_vehicle_id`);

ALTER TABLE `fleet`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `fleet_vehicles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fleet_id` (`fleet_id`),
  ADD KEY `user_vehicle_id` (`user_vehicle_id`);

-- Foreign Key Constraints
ALTER TABLE `models`
  ADD CONSTRAINT `models_ibfk_1` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`);

ALTER TABLE `variants`
  ADD CONSTRAINT `variants_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`);

ALTER TABLE `variant_features`
  ADD CONSTRAINT `variant_features_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`),
  ADD CONSTRAINT `variant_features_ibfk_2` FOREIGN KEY (`feature_id`) REFERENCES `features` (`id`);

ALTER TABLE `vehicle_specs`
  ADD CONSTRAINT `vehicle_specs_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE CASCADE;

ALTER TABLE `images`
  ADD CONSTRAINT `images_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

ALTER TABLE `price_history`
  ADD CONSTRAINT `price_history_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

ALTER TABLE `insurance`
  ADD CONSTRAINT `insurance_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `insurance_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE SET NULL;

ALTER TABLE `user_vehicles`
  ADD CONSTRAINT `user_vehicles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `user_vehicles_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

ALTER TABLE `maintenance`
  ADD CONSTRAINT `maintenance_ibfk_1` FOREIGN KEY (`user_vehicle_id`) REFERENCES `user_vehicles` (`id`) ON DELETE CASCADE;

ALTER TABLE `fleet`
  ADD CONSTRAINT `fleet_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `fleet_vehicles`
  ADD CONSTRAINT `fleet_vehicles_ibfk_1` FOREIGN KEY (`fleet_id`) REFERENCES `fleet` (`id`),
  ADD CONSTRAINT `fleet_vehicles_ibfk_2` FOREIGN KEY (`user_vehicle_id`) REFERENCES `user_vehicles` (`id`);

-- AUTO_INCREMENT
ALTER TABLE `users` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `manufacturers` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
ALTER TABLE `models` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
ALTER TABLE `variants` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
ALTER TABLE `features` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=180;
ALTER TABLE `vehicle_specs` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
ALTER TABLE `images` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `price_history` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `reviews` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `blogs` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
ALTER TABLE `insurance` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `user_vehicles` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `maintenance` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `fleet` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
ALTER TABLE `fleet_vehicles` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

-- Sample Data Inserts (from original files)
-- Users (merged sample data)
INSERT INTO `users` (`name`, `email`, `username`, `password_hash`, `phone_number`, `address`, `user_type`) VALUES
('John Doe', 'john@example.com', 'johndoe', '$2y$10$examplehash1', '1234567890', '123 Main St, City', 'Buyer'),
('Jane Smith', 'jane@example.com', 'janesmith', '$2y$10$examplehash2', '0987654321', '456 Elm St, City', 'Seller'),
('Auto Dealer', 'dealer@example.com', 'autodealer', '$2y$10$examplehash3', '1122334455', '789 Oak St, City', 'Dealer')
ON DUPLICATE KEY UPDATE name=VALUES(name), username=VALUES(username), password_hash=VALUES(password_hash), phone_number=VALUES(phone_number), address=VALUES(address), user_type=VALUES(user_type);

-- Manufacturers
INSERT INTO `manufacturers` (`id`, `name`, `country`) VALUES
(1, 'Maruti Suzuki', 'India');

-- Models
INSERT INTO `models` (`id`, `manufacturer_id`, `name`, `launch_year`) VALUES
(1, 1, 'Brezza', '2023');

-- Variants
INSERT INTO `variants` (`id`, `model_id`, `variant_name`, `fuel_type`, `transmission`, `power`, `mileage`, `ex_showroom_price`, `on_road_price`) VALUES
(1, 1, 'LXI', 'Petrol', 'Manual', '103 HP', '20 km/l', 850000.00, 950000.00),
(2, 1, 'VXI CNG', 'CNG', 'Manual', '88 HP', '25 km/kg', 950000.00, 1050000.00);

-- Features (sample)
INSERT INTO `features` (`id`, `name`, `category`) VALUES
(1, 'Acceleration (0-100 kmph)', 'Drive Train'),
(2, 'Drivetrain', 'Drive Train');

-- Variant Features
INSERT INTO `variant_features` (`variant_id`, `feature_id`) VALUES
(1, 2),
(2, 1),
(2, 2);

-- Blogs (sample)
INSERT INTO `blogs` (`title`, `content`, `image_url`, `yt_link`, `status`, `author`, `excerpt`, `meta_title`, `meta_description`, `featured`, `publish_at`) VALUES
('Sample Blog 1', 'This is a sample blog post about cars.', 'uploads/sample1.jpg', 'https://youtube.com/sample1', 'published', 'Admin', 'Sample excerpt', 'Sample Title', 'Sample description', 1, NOW()),
('Sample Blog 2', 'Another sample blog post.', 'uploads/sample2.jpg', 'https://youtube.com/sample2', 'published', 'Admin', 'Another excerpt', 'Another Title', 'Another description', 0, NOW())
ON DUPLICATE KEY UPDATE content=VALUES(content), image_url=VALUES(image_url), yt_link=VALUES(yt_link), status=VALUES(status), author=VALUES(author), excerpt=VALUES(excerpt), meta_title=VALUES(meta_title), meta_description=VALUES(meta_description), featured=VALUES(featured), publish_at=VALUES(publish_at);

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
