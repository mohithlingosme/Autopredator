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
-- Database: `blogs`
--

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
(16, 'dmekfmwefmfme', '', '', '', 'draft', 'Admin', '', '', '', 0, NULL, '2025-03-25 04:04:18');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
