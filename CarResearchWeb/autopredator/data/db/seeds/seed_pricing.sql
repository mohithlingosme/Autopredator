USE autopredator_pricing;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO states (id, name, code)
VALUES
  (1, 'Maharashtra', 'MH'),
  (2, 'Karnataka', 'KA')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO cities (id, state_id, name, code)
VALUES
  (1, 1, 'Mumbai', 'MUM'),
  (2, 1, 'Pune', 'PUN'),
  (3, 1, 'Nagpur', 'NAG'),
  (4, 1, 'Nashik', 'NAS'),
  (5, 1, 'Thane', 'THA'),
  (6, 2, 'Bengaluru', 'BLR'),
  (7, 2, 'Mysuru', 'MYS'),
  (8, 2, 'Mangaluru', 'MAN'),
  (9, 2, 'Hubballi', 'HUB'),
  (10, 2, 'Belagavi', 'BEL')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO price_history (id, variant_id, city_id, price_type, captured_on, price_amount, currency, source, notes)
VALUES
  (1, 1, 1, 'ex_showroom', '2025-01-05', 550000, 'INR', 'dealer_feed', NULL),
  (2, 1, 2, 'ex_showroom', '2025-01-06', 545000, 'INR', 'dealer_feed', NULL),
  (3, 1, 6, 'ex_showroom', '2025-01-07', 560000, 'INR', 'market_survey', NULL),
  (4, 1, 1, 'on_road', '2025-01-08', 660000, 'INR', 'dealer_feed', NULL),
  (5, 1, 7, 'on_road', '2025-01-09', 640000, 'INR', 'market_survey', NULL),

  (6, 2, 1, 'ex_showroom', '2025-01-05', 650000, 'INR', 'dealer_feed', NULL),
  (7, 2, 2, 'ex_showroom', '2025-01-06', 645000, 'INR', 'dealer_feed', NULL),
  (8, 2, 6, 'ex_showroom', '2025-01-07', 665000, 'INR', 'market_survey', NULL),
  (9, 2, 1, 'on_road', '2025-01-08', 770000, 'INR', 'dealer_feed', NULL),
  (10, 2, 7, 'on_road', '2025-01-09', 750000, 'INR', 'market_survey', NULL),

  (11, 3, 1, 'ex_showroom', '2025-01-10', 950000, 'INR', 'dealer_feed', NULL),
  (12, 3, 2, 'ex_showroom', '2025-01-11', 940000, 'INR', 'dealer_feed', NULL),
  (13, 3, 6, 'ex_showroom', '2025-01-12', 965000, 'INR', 'market_survey', NULL),
  (14, 3, 3, 'on_road', '2025-01-13', 1090000, 'INR', 'dealer_feed', NULL),
  (15, 3, 6, 'on_road', '2025-01-14', 1120000, 'INR', 'market_survey', NULL),

  (16, 4, 1, 'ex_showroom', '2025-01-10', 1180000, 'INR', 'dealer_feed', NULL),
  (17, 4, 2, 'ex_showroom', '2025-01-11', 1170000, 'INR', 'dealer_feed', NULL),
  (18, 4, 6, 'ex_showroom', '2025-01-12', 1200000, 'INR', 'market_survey', NULL),
  (19, 4, 4, 'on_road', '2025-01-13', 1320000, 'INR', 'dealer_feed', NULL),
  (20, 4, 8, 'on_road', '2025-01-14', 1310000, 'INR', 'market_survey', NULL),

  (21, 5, 1, 'ex_showroom', '2025-01-15', 2200000, 'INR', 'dealer_feed', NULL),
  (22, 5, 2, 'ex_showroom', '2025-01-16', 2180000, 'INR', 'dealer_feed', NULL),
  (23, 5, 6, 'ex_showroom', '2025-01-17', 2230000, 'INR', 'market_survey', NULL),
  (24, 5, 5, 'on_road', '2025-01-18', 2450000, 'INR', 'dealer_feed', NULL),
  (25, 5, 6, 'on_road', '2025-01-19', 2470000, 'INR', 'market_survey', NULL),

  (26, 6, 1, 'ex_showroom', '2025-01-15', 1850000, 'INR', 'dealer_feed', NULL),
  (27, 6, 2, 'ex_showroom', '2025-01-16', 1830000, 'INR', 'dealer_feed', NULL),
  (28, 6, 6, 'ex_showroom', '2025-01-17', 1880000, 'INR', 'market_survey', NULL),
  (29, 6, 9, 'on_road', '2025-01-18', 2010000, 'INR', 'dealer_feed', NULL),
  (30, 6, 10, 'on_road', '2025-01-19', 2000000, 'INR', 'market_survey', NULL)
ON DUPLICATE KEY UPDATE price_amount = VALUES(price_amount), captured_on = VALUES(captured_on), source = VALUES(source);

INSERT INTO onroad_components (id, name, code, description)
VALUES
  (1, 'Base Ex-Showroom', 'BASE_PRICE', 'Ex-showroom component'),
  (2, 'Road Tax', 'ROAD_TAX', 'State road tax'),
  (3, 'Insurance', 'INSURANCE', 'First year insurance'),
  (4, 'Registration', 'REGISTRATION', 'Registration + plates'),
  (5, 'Handling', 'HANDLING', 'Logistics and handling')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO onroad_price_components (id, price_history_id, component_id, amount)
VALUES
  (1, 4, 1, 550000),
  (2, 4, 2, 55000),
  (3, 4, 3, 32000),
  (4, 4, 4, 23000),

  (5, 5, 1, 545000),
  (6, 5, 2, 52000),
  (7, 5, 3, 30000),
  (8, 5, 4, 13000),

  (9, 9, 1, 650000),
  (10, 9, 2, 70000),
  (11, 9, 3, 35000),
  (12, 9, 4, 15000),

  (13, 10, 1, 645000),
  (14, 10, 2, 65000),
  (15, 10, 3, 33000),
  (16, 10, 4, 12000),

  (17, 14, 1, 950000),
  (18, 14, 2, 80000),
  (19, 14, 3, 50000),
  (20, 14, 4, 9000),

  (21, 15, 1, 965000),
  (22, 15, 2, 82000),
  (23, 15, 3, 52000),
  (24, 15, 4, 9500),

  (25, 19, 1, 1180000),
  (26, 19, 2, 95000),
  (27, 19, 3, 60000),
  (28, 19, 4, 9500),

  (29, 20, 1, 1200000),
  (30, 20, 2, 97000),
  (31, 20, 3, 62000),
  (32, 20, 4, 8500),

  (33, 24, 1, 2200000),
  (34, 24, 2, 180000),
  (35, 24, 3, 95000),
  (36, 24, 4, 6500),

  (37, 25, 1, 2230000),
  (38, 25, 2, 182000),
  (39, 25, 3, 98000),
  (40, 25, 4, 8000),

  (41, 29, 1, 1850000),
  (42, 29, 2, 150000),
  (43, 29, 3, 82000),
  (44, 29, 4, 9000),

  (45, 30, 1, 1830000),
  (46, 30, 2, 148000),
  (47, 30, 3, 80000),
  (48, 30, 4, 9000)
ON DUPLICATE KEY UPDATE amount = VALUES(amount);
