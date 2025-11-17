-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 10, 2025 at 03:09 AM
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
-- Database: `car`
--

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
