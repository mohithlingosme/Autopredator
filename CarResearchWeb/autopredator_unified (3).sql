-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 28, 2025 at 03:44 PM
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
-- Database: `autopredator_unified`
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
(1, 'Airbags', 'Safety'),
(2, 'ABS', 'Safety'),
(3, 'Cruise Control', 'Comfort & Convenience'),
(4, 'Alloy Wheels', 'Exterior'),
(5, 'Touchscreen Infotainment', 'Infotainment'),
(6, 'Parking Sensors', 'Comfort & Convenience'),
(7, 'Automatic Headlights', 'Lighting'),
(8, 'Apple CarPlay', 'Infotainment');

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
(1, 'Maruti Suzuki', 'India'),
(2, 'Toyota', 'Japan');

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
(1, 1, 4, 'Vitara Brezza', '2016'),
(2, 1, 1, 'Swift', '2005'),
(3, 1, 2, 'Baleno', '2015'),
(4, 1, 3, 'Celerio', '2014'),
(5, 1, 5, 'Wagon R', '1999'),
(6, 1, 6, 'Ertiga', '2012'),
(7, 1, 10, 'Swift Dzire', '2008'),
(8, 1, 11, 'Alto K10', '2022'),
(9, 1, 16, 'Ignis', '2017'),
(10, 1, 23, 'Fronx', '2023'),
(11, 1, 15, 'Grand Vitara', '2022'),
(12, 1, 39, 'Victoris', '2025'),
(13, 1, 29, 'Jimny', '2023'),
(14, 1, 12, 'XL6', '2019'),
(15, 1, 31, 'Invicto', '2023'),
(16, 1, 13, 'Eeco', '2010'),
(17, 1, 18, 'S-Presso', '2019');

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
  `fuel_scope` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `model_families`
--

INSERT INTO `model_families` (`id`, `manufacturer_id`, `nameplate`, `body_type`, `segment`, `fuel_scope`) VALUES
(1, 1, 'Swift', 'Hatchback', 'B2', 'Petrol, Diesel, CNG'),
(2, 1, 'Baleno', 'Hatchback', 'Premium Hatchback', 'Petrol, CNG, Diesel'),
(3, 1, 'Celerio', 'Hatchback', 'A-segment', 'Petrol, CNG, Diesel'),
(4, 1, 'Vitara Brezza', 'SUV', 'Compact SUV', 'Petrol'),
(5, 1, 'WagonR', 'Hatchback', 'Tallboy', 'Petrol, CNG'),
(6, 1, 'Ertiga', 'MPV', 'MUV', 'Petrol, CNG'),
(7, 1, 'Dzire', 'Sedan', 'Compact Sedan', 'Petrol, Diesel'),
(8, 1, 'Alto 800', 'Hatchback', 'Entry Hatchback', 'Petrol'),
(9, 1, 'Ciaz', 'Sedan', 'Mid-size Sedan', 'Petrol, Diesel'),
(10, 1, 'Swift Dzire', 'Sedan', 'Compact Sedan', 'Petrol, Diesel'),
(11, 1, 'Alto K10', 'Hatchback', 'A-segment Hatchback', 'Petrol'),
(12, 1, 'XL6', 'MPV', 'MUV', 'Petrol'),
(13, 1, 'Eeco', 'Van', 'Van', 'Petrol, CNG'),
(14, 1, 'Ritz', 'Hatchback', 'B-segment', 'Petrol, Diesel'),
(15, 1, 'Grand Vitara', 'SUV', 'C-segment SUV', 'Petrol, Diesel'),
(16, 1, 'Ignis', 'Hatchback', 'A-segment CUV', 'Petrol, CNG'),
(17, 1, 'S-Cross', 'SUV', 'C-segment SUV', 'Petrol, Diesel'),
(18, 1, 'S-Presso', 'Mini SUV', 'A-segment', 'Petrol, CNG'),
(19, 1, 'SX4', 'Hatchback', 'C-segment', 'Petrol, Diesel'),
(20, 1, 'Omni', 'Van', 'Van', 'Petrol'),
(21, 1, 'A-Star', 'Hatchback', 'Subcompact', 'Petrol'),
(22, 1, 'Zen Estilo', 'Hatchback', 'Mid-size', 'Petrol'),
(23, 1, 'Fronx', 'SUV', 'Subcompact SUV', 'Petrol, CNG'),
(24, 1, 'Celerio X', 'Hatchback', 'Cross Hatchback', 'Petrol, CNG'),
(25, 1, 'Baleno Sedan', 'Sedan', 'Compact Sedan', 'Petrol, Diesel'),
(26, 1, '800', 'Hatchback', 'A-segment', 'Petrol'),
(27, 1, 'Zen', 'Hatchback', 'Mid-size', 'Petrol'),
(28, 1, 'Esteem', 'Sedan', 'Compact Sedan', 'Petrol'),
(29, 1, 'Jimny', 'SUV', 'Mini SUV', 'Petrol'),
(30, 1, 'Gypsy', 'SUV', 'Off-road', 'Petrol'),
(31, 1, 'Invicto', 'MPV', 'Luxury MPV', 'Diesel'),
(32, 1, 'Versa', 'Hatchback', 'Subcompact', 'Petrol'),
(33, 1, 'Grand Vitara XL7', 'SUV', 'Large SUV', 'Petrol'),
(34, 1, 'Baleno Altura', 'Sedan', 'Compact Sedan', 'Petrol'),
(35, 1, 'Baleno RS', 'Hatchback', 'Premium Hatchback', 'Petrol'),
(36, 1, 'Victoris', 'MPV', 'Luxury MPV', 'Petrol'),
(37, 1, 'e-Vitara', 'SUV', 'Compact Electric SUV', 'Electric'),
(38, 1, 'Gypsy E', 'SUV', 'Off-road', 'Petrol'),
(39, 1, 'Gypsy King', 'SUV', 'Off-road', 'Petrol');

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
  `status` enum('Current','Discontinued','Upcoming') NOT NULL DEFAULT 'Current',
  `region` varchar(50) DEFAULT 'India',
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `model_lifecycle`
--

INSERT INTO `model_lifecycle` (`id`, `family_id`, `generation_no`, `facelift_no`, `internal_code`, `market_name`, `launch_date`, `discontinue_date`, `status`, `region`, `notes`) VALUES
(1, 1, 1, 0, 'MZ-Swift-Gen1', 'Swift (1st Gen)', '2005-05-01', '2009-01-01', 'Discontinued', 'India', 'First-gen Swift'),
(2, 1, 2, 0, 'MZ-Swift-Gen2', 'Swift (2nd Gen)', '2011-08-01', '2018-02-01', 'Discontinued', 'India', 'Second-gen Swift'),
(3, 1, 3, 0, 'MZ-Swift-Gen3', 'Swift (3rd Gen)', '2018-02-01', '2024-02-01', 'Discontinued', 'India', 'Third-gen Swift'),
(4, 1, 4, 0, 'MZ-Swift-Gen4', 'Swift (4th Gen)', '2024-05-01', NULL, 'Current', 'India', 'Fourth-gen Swift'),
(5, 4, 1, 0, 'YBA', 'Vitara Brezza (1st Gen)', '2016-01-01', '2022-06-30', 'Discontinued', 'India', 'First-gen Brezza'),
(6, 4, 2, 0, 'YDM', 'Vitara Brezza (2nd Gen)', '2022-07-01', NULL, 'Current', 'India', 'Second-gen Brezza'),
(7, 2, 1, 0, 'EM10', 'Baleno (1st Gen)', '2015-08-01', '2022-09-15', 'Discontinued', 'India', 'First-gen Baleno'),
(8, 2, 2, 0, 'EW1A', 'Baleno (2nd Gen)', '2022-09-15', NULL, 'Current', 'India', 'Second-gen Baleno'),
(9, 3, 1, 0, 'K10C', 'Celerio (1st Gen)', '2014-01-01', '2021-12-01', 'Discontinued', 'India', 'First-gen Celerio'),
(10, 3, 2, 0, 'K14D', 'Celerio (2nd Gen)', '2022-01-01', NULL, 'Current', 'India', 'Second-gen Celerio'),
(11, 5, 1, 0, NULL, 'Wagon R (Orig)', '1999-07-01', '2019-07-01', 'Discontinued', 'India', 'Original Wagon R'),
(12, 5, 2, 0, NULL, 'Wagon R (2nd Gen)', '2019-07-01', NULL, 'Current', 'India', 'Second-gen Wagon R'),
(13, 6, 1, 0, NULL, 'Ertiga (1st Gen)', '2012-05-01', '2018-05-01', 'Discontinued', 'India', 'First-gen Ertiga'),
(14, 6, 2, 0, NULL, 'Ertiga (2nd Gen)', '2018-05-01', '2022-07-01', 'Discontinued', 'India', 'Second-gen Ertiga'),
(15, 6, 3, 0, NULL, 'Ertiga (3rd Gen)', '2022-07-01', NULL, 'Current', 'India', 'Third-gen Ertiga'),
(16, 10, 1, 0, 'MZ-SwiftD-Gen1', 'Swift Dzire (1st Gen)', '2008-08-01', '2012-06-01', 'Discontinued', 'India', 'First-gen Swift Dzire'),
(17, 10, 2, 0, 'MZ-SwiftD-Gen2', 'Swift Dzire (2nd Gen)', '2012-06-01', '2017-03-01', 'Discontinued', 'India', 'Second-gen Swift Dzire'),
(18, 10, 3, 0, 'MZ-SwiftD-Gen3', 'Swift Dzire (3rd Gen)', '2017-03-01', '2024-01-01', 'Discontinued', 'India', 'Third-gen Swift Dzire'),
(19, 10, 4, 0, 'MZ-SwiftD-Gen4', 'Swift Dzire (4th Gen)', '2024-01-01', NULL, 'Current', 'India', 'Fourth-gen Swift Dzire'),
(20, 11, 1, 0, NULL, 'Alto K10', '2022-03-01', NULL, 'Current', 'India', 'Maruti Alto K10'),
(21, 16, 1, 0, NULL, 'Ignis', '2017-01-01', NULL, 'Current', 'India', 'Maruti Ignis'),
(22, 23, 1, 0, NULL, 'Fronx', '2023-09-01', NULL, 'Current', 'India', 'Maruti Fronx'),
(23, 15, 1, 0, NULL, 'Grand Vitara', '2022-04-01', NULL, 'Current', 'India', 'Maruti Grand Vitara'),
(24, 39, 1, 0, NULL, 'Victoris', '2025-02-01', NULL, 'Upcoming', 'India', 'Maruti Victoris (upcoming)'),
(25, 29, 1, 0, NULL, 'Jimny', '2023-03-01', NULL, 'Current', 'India', 'Maruti Jimny'),
(26, 12, 1, 0, NULL, 'XL6', '2019-09-01', NULL, 'Current', 'India', 'Maruti XL6'),
(27, 31, 1, 0, NULL, 'Invicto', '2023-10-01', NULL, 'Current', 'India', 'Maruti Invicto'),
(28, 13, 1, 0, NULL, 'Eeco', '2010-08-01', NULL, 'Current', 'India', 'Maruti Eeco'),
(29, 18, 1, 0, NULL, 'S-Presso', '2019-01-01', NULL, 'Current', 'India', 'Maruti S-Presso'),
(30, 20, 1, 0, NULL, 'Omni', '1984-08-01', '2019-07-01', 'Discontinued', 'India', 'Maruti Omni'),
(31, 9, 1, 0, NULL, 'Ciaz', '2014-06-01', '2025-03-01', 'Discontinued', 'India', 'Maruti Ciaz'),
(32, 17, 1, 0, NULL, 'S-Cross', '2015-05-01', '2022-12-01', 'Discontinued', 'India', 'Maruti S-Cross'),
(33, 8, 1, 0, NULL, 'Alto 800', '2000-03-01', '2014-04-01', 'Discontinued', 'India', 'Maruti Alto 800'),
(34, 21, 1, 0, NULL, 'A-Star', '2008-07-01', '2014-04-01', 'Discontinued', 'India', 'Maruti A-Star'),
(35, 14, 1, 0, NULL, 'Ritz', '2009-10-01', '2017-06-01', 'Discontinued', 'India', 'Maruti Ritz'),
(36, 28, 1, 0, NULL, 'Zen', '1993-08-01', '2006-04-01', 'Discontinued', 'India', 'Maruti Zen'),
(37, 38, 1, 0, NULL, 'Baleno Altura', '2000-04-01', '2006-07-01', 'Discontinued', 'India', 'Maruti Baleno Altura'),
(38, 35, 1, 0, NULL, 'Baleno RS', '2017-01-01', '2020-06-01', 'Discontinued', 'India', 'Maruti Baleno RS'),
(39, 33, 1, 0, NULL, 'Grand Vitara XL-7', '2003-06-01', '2007-11-01', 'Discontinued', 'India', 'Maruti Grand Vitara XL-7'),
(40, 30, 1, 0, NULL, 'Gypsy', '1985-01-01', '2019-03-01', 'Discontinued', 'India', 'Maruti Gypsy'),
(41, 34, 1, 0, NULL, '1000', '1990-05-01', '2000-01-01', 'Discontinued', 'India', 'Maruti 1000'),
(42, 29, 1, 0, NULL, 'Esteem', '1994-09-01', '2007-05-01', 'Discontinued', 'India', 'Maruti Esteem'),
(43, 22, 1, 0, NULL, 'Zen Estilo', '2006-03-01', '2013-07-01', 'Discontinued', 'India', 'Maruti Zen Estilo'),
(44, 36, 1, 0, NULL, 'Versa', '2001-06-01', '2010-01-01', 'Discontinued', 'India', 'Maruti Versa');

-- --------------------------------------------------------

--
-- Table structure for table `price_history`
--

CREATE TABLE `price_history` (
  `id` int(11) NOT NULL,
  `variant_id` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `price_history`
--

INSERT INTO `price_history` (`id`, `variant_id`, `price`, `updated_at`) VALUES
(1, 1, 600000.00, '2025-11-25 12:00:00'),
(2, 2, 700000.00, '2025-11-25 12:00:00'),
(3, 3, 800000.00, '2025-11-25 12:00:00'),
(4, 4, 700000.00, '2025-11-25 12:00:00'),
(5, 5, 800000.00, '2025-11-25 12:00:00'),
(6, 6, 850000.00, '2025-11-25 12:00:00'),
(7, 7, 950000.00, '2025-11-25 12:00:00'),
(8, 10, 400000.00, '2025-11-25 12:00:00'),
(9, 11, 450000.00, '2025-11-25 12:00:00'),
(10, 16, 2000000.00, '2025-11-25 12:00:00'),
(11, 17, 2400000.00, '2025-11-25 12:00:00'),
(12, 20, 950000.00, '2025-11-25 12:00:00'),
(13, 21, 1100000.00, '2025-11-25 12:00:00'),
(14, 28, 400000.00, '2025-11-25 12:00:00'),
(15, 29, 450000.00, '2025-11-25 12:00:00');

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
  `transmission` enum('Manual','Automatic','AMT','CVT','DCT') NOT NULL,
  `power` varchar(20) DEFAULT NULL,
  `mileage` varchar(20) DEFAULT NULL,
  `ex_showroom_price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `variants`
--

INSERT INTO `variants` (`id`, `model_id`, `lifecycle_id`, `variant_name`, `fuel_type`, `transmission`, `power`, `mileage`, `ex_showroom_price`) VALUES
(1, 2, 4, 'LXI', 'Petrol', 'Manual', '90 bhp', '22 kmpl', 600000.00),
(2, 2, 4, 'VXI', 'Petrol', 'Manual', '90 bhp', '22 kmpl', 700000.00),
(3, 2, 4, 'ZXI', 'Petrol', 'Automatic', '90 bhp', '22 kmpl', 800000.00),
(4, 3, 8, 'Sigma', 'Petrol', 'Manual', '77 bhp', '24 kmpl', 700000.00),
(5, 3, 8, 'Zeta', 'Petrol', 'AMT', '77 bhp', '24 kmpl', 800000.00),
(6, 1, 6, 'LXI', 'Petrol', 'Manual', '105 bhp', '18 kmpl', 850000.00),
(7, 1, 6, 'VXI', 'Petrol', 'Manual', '105 bhp', '18 kmpl', 950000.00),
(8, 4, 10, 'LXI', 'Petrol', 'Manual', '66 bhp', '25 kmpl', 500000.00),
(9, 4, 10, 'VXI', 'Petrol', 'AMT', '66 bhp', '25 kmpl', 550000.00),
(10, 5, 12, 'STD', 'Petrol', 'Manual', '59 bhp', '25 kmpl', 400000.00),
(11, 5, 12, 'VXI', 'Petrol', 'Manual', '59 bhp', '25 kmpl', 450000.00),
(12, 9, 21, 'VXI', 'Petrol', 'Manual', '67 bhp', '23 kmpl', 550000.00),
(13, 9, 21, 'ZXI', 'Petrol', 'Automatic', '67 bhp', '23 kmpl', 650000.00),
(14, 10, 22, 'Sigma', 'Petrol', 'Manual', '89 bhp', '20 kmpl', 700000.00),
(15, 10, 22, 'Zeta', 'Petrol', 'Manual', '89 bhp', '20 kmpl', 800000.00),
(16, 11, 23, 'Sigma', 'Petrol', 'Manual', '103 bhp', '18 kmpl', 2000000.00),
(17, 11, 23, 'Alpha', 'Petrol', 'Automatic', '103 bhp', '18 kmpl', 2400000.00),
(18, 12, 24, 'Base', 'Petrol', 'Manual', '75 bhp', '25 kmpl', 1000000.00),
(19, 12, 24, 'Top', 'Petrol', 'AMT', '75 bhp', '25 kmpl', 1200000.00),
(20, 13, 25, 'Base', 'Petrol', 'Manual', '101 bhp', '16 kmpl', 950000.00),
(21, 13, 25, 'ZX4', 'Petrol', 'Manual', '101 bhp', '16 kmpl', 1100000.00),
(22, 14, 26, 'Zeta', 'Petrol', 'Manual', '105 bhp', '18 kmpl', 1300000.00),
(23, 14, 26, 'Alpha', 'Petrol', 'Automatic', '105 bhp', '18 kmpl', 1500000.00),
(24, 15, 27, 'GX', 'Diesel', 'Manual', '95 bhp', '18 kmpl', 1800000.00),
(25, 15, 27, 'ZX', 'Diesel', 'Automatic', '95 bhp', '18 kmpl', 2200000.00),
(26, 16, 28, 'STD', 'Petrol', 'Manual', '50 bhp', '20 kmpl', 400000.00),
(27, 16, 28, 'STD CNG', 'CNG', 'Manual', '50 bhp', '20 km/kg', 450000.00),
(28, 17, 29, 'STD', 'Petrol', 'Manual', '67 bhp', '24 kmpl', 400000.00),
(29, 17, 29, 'Bold', 'Petrol', 'Manual', '67 bhp', '24 kmpl', 450000.00);

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
(1, 1),
(1, 2),
(1, 4),
(2, 1),
(2, 2),
(2, 4),
(2, 7),
(3, 1),
(3, 2),
(3, 3),
(3, 4),
(3, 7),
(4, 1),
(4, 2),
(4, 3),
(4, 5),
(5, 1),
(5, 2),
(5, 4),
(5, 5),
(5, 8),
(6, 1),
(6, 2),
(6, 4),
(6, 6),
(7, 1),
(7, 2),
(7, 3),
(7, 4),
(7, 6),
(8, 1),
(8, 2),
(8, 6),
(9, 1),
(9, 2),
(9, 3),
(9, 4),
(9, 6),
(10, 1),
(10, 2),
(10, 6),
(11, 1),
(11, 2),
(11, 3),
(11, 6),
(12, 1),
(12, 2),
(12, 4),
(13, 1),
(13, 2),
(13, 3),
(13, 4),
(14, 1),
(14, 2),
(14, 3),
(14, 4),
(15, 1),
(15, 2),
(15, 4),
(15, 8),
(16, 1),
(16, 2),
(16, 4),
(16, 5),
(17, 1),
(17, 2),
(17, 4),
(17, 8),
(18, 1),
(18, 2),
(18, 3),
(18, 4),
(19, 1),
(19, 2),
(19, 4),
(19, 8),
(20, 1),
(20, 2),
(20, 3),
(20, 4),
(21, 1),
(21, 2),
(21, 4),
(21, 7),
(22, 1),
(22, 2),
(22, 4),
(22, 5),
(23, 1),
(23, 2),
(23, 4),
(23, 8),
(24, 1),
(24, 2),
(24, 6),
(24, 7),
(25, 1),
(25, 2),
(25, 4),
(25, 7),
(26, 1),
(26, 2),
(26, 6),
(27, 1),
(27, 2),
(27, 6),
(27, 7),
(28, 1),
(28, 2),
(28, 3),
(28, 6),
(29, 1),
(29, 2),
(29, 3),
(29, 8);

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
  `seating_capacity` tinyint(4) DEFAULT NULL,
  `kerb_weight_kg` int(11) DEFAULT NULL,
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
-- Dumping data for table `vehicle_specs`
--

INSERT INTO `vehicle_specs` (`id`, `variant_id`, `engine_type`, `engine_displacement_cc`, `max_power_bhp`, `max_torque_nm`, `cylinders`, `transmission_type`, `drivetrain`, `fuel_type`, `fuel_tank_capacity_ltr`, `top_speed_kmph`, `acceleration_0_100_kmph`, `mileage_city_kmpl`, `mileage_highway_kmpl`, `length_mm`, `width_mm`, `height_mm`, `wheelbase_mm`, `ground_clearance_mm`, `boot_space_ltr`, `seating_capacity`, `kerb_weight_kg`, `turning_radius_m`, `body_type`, `number_of_doors`, `lighting_type`, `alloy_wheels`, `sunroof_type`, `front_tyre_size`, `rear_tyre_size`, `spare_tyre_size`, `suspension_front`, `suspension_rear`, `brake_type_front`, `brake_type_rear`) VALUES
(1, 1, 'K12N Petrol', 1197, '90', '113', 4, 'Manual', 'FWD', 'Petrol', 37.00, 160, 11.20, 18.90, 24.80, 3840, 1730, 1530, 2450, 170, 315, 5, 855, 4.80, 'Hatchback', 5, 'LED', 1, 'None', '165/80 R14', '165/80 R14', '165/80 R14', 'MacPherson strut', 'Torsion beam', 'Disc', 'Drum'),
(2, 2, 'K12N Petrol', 1197, '90', '113', 4, 'Automatic', 'FWD', 'Petrol', 37.00, 160, 11.50, 18.90, 24.80, 3840, 1730, 1530, 2450, 170, 315, 5, 880, 4.80, 'Hatchback', 5, 'LED', 1, 'None', '165/80 R14', '165/80 R14', '165/80 R14', 'MacPherson strut', 'Torsion beam', 'Disc', 'Drum'),
(3, 4, 'K12B Petrol', 1197, '77', '101', 4, 'Manual', 'FWD', 'Petrol', 37.00, 160, 11.90, 18.60, 23.40, 3995, 1745, 1505, 2520, 170, 328, 5, 945, 4.90, 'Hatchback', 5, 'Halogen', 1, 'None', '165/80 R14', '165/80 R14', '165/80 R14', 'MacPherson strut', 'Torsion beam', 'Disc', 'Drum'),
(4, 6, 'K15B Petrol', 1462, '77', '138', 4, 'Manual', 'FWD', 'Petrol', 45.00, 170, 13.00, 16.00, 22.00, 3990, 1735, 1690, 2740, 185, 550, 7, 950, 5.00, 'SUV', 5, 'LED', 1, 'None', '205/55 R16', '205/55 R16', '175/65 R15', 'MacPherson strut', 'Torsion beam', 'Disc', 'Drum'),
(5, 16, 'Z15S Petrol', 1462, '103', '138', 4, 'Automatic', 'FWD', 'Petrol', 37.00, 170, 13.50, 16.00, 22.00, 4015, 1795, 1690, 2850, 180, 587, 5, 1100, 5.10, 'SUV', 5, 'LED', 1, 'Panoramic', '205/55 R16', '205/55 R16', '175/65 R15', 'MacPherson strut', 'Torsion beam', 'Disc', 'Drum');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `features`
--
ALTER TABLE `features`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `manufacturers`
--
ALTER TABLE `manufacturers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `models`
--
ALTER TABLE `models`
  ADD PRIMARY KEY (`id`),
  ADD KEY `manufacturer_id` (`manufacturer_id`),
  ADD KEY `family_id` (`family_id`);

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
-- Indexes for table `variants`
--
ALTER TABLE `variants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `model_id` (`model_id`),
  ADD KEY `lifecycle_id` (`lifecycle_id`);

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
-- Constraints for dumped tables
--

--
-- Constraints for table `models`
--
ALTER TABLE `models`
  ADD CONSTRAINT `models_ibfk_1` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`),
  ADD CONSTRAINT `models_ibfk_2` FOREIGN KEY (`family_id`) REFERENCES `model_families` (`id`);

--
-- Constraints for table `model_families`
--
ALTER TABLE `model_families`
  ADD CONSTRAINT `model_families_ibfk_1` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`);

--
-- Constraints for table `model_lifecycle`
--
ALTER TABLE `model_lifecycle`
  ADD CONSTRAINT `model_lifecycle_ibfk_1` FOREIGN KEY (`family_id`) REFERENCES `model_families` (`id`);

--
-- Constraints for table `price_history`
--
ALTER TABLE `price_history`
  ADD CONSTRAINT `price_history_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);

--
-- Constraints for table `variants`
--
ALTER TABLE `variants`
  ADD CONSTRAINT `variants_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `models` (`id`),
  ADD CONSTRAINT `variants_ibfk_2` FOREIGN KEY (`lifecycle_id`) REFERENCES `model_lifecycle` (`id`);

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
  ADD CONSTRAINT `vehicle_specs_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
