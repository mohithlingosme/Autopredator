USE autopredator_cars_research;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Reference data
INSERT INTO segments (id, name, code, description)
VALUES
  (1, 'Entry Hatchback', 'SEG_A', 'Affordable small cars'),
  (2, 'Premium Hatchback', 'SEG_B', 'Feature-rich hatchbacks'),
  (3, 'Compact SUV', 'SEG_CSUV', 'Sub-4m SUVs/Crossovers'),
  (4, 'Midsize Sedan', 'SEG_C', 'C-segment sedans'),
  (5, 'Full-size SUV', 'SEG_D', 'Large SUVs')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO body_types (id, name, code, description)
VALUES
  (1, 'Hatchback', 'HATCH', '2-box hatchback'),
  (2, 'Sedan', 'SEDAN', 'Three-box sedan'),
  (3, 'SUV', 'SUV', 'Sport utility vehicle'),
  (4, 'MPV', 'MPV', 'Multi-purpose vehicle'),
  (5, 'Coupe', 'COUPE', 'Two-door coupe')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO fuel_types (id, name, code, description)
VALUES
  (1, 'Petrol', 'PETROL', 'Gasoline'),
  (2, 'Diesel', 'DIESEL', 'Diesel fuel'),
  (3, 'Electric', 'ELECTRIC', 'Battery electric'),
  (4, 'Hybrid', 'HYBRID', 'Hybrid powertrain'),
  (5, 'CNG', 'CNG', 'Compressed natural gas')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO transmissions (id, name, code, description)
VALUES
  (1, 'Manual', 'MT', 'Manual transmission'),
  (2, 'Automatic', 'AT', 'Torque-converter automatic'),
  (3, 'CVT', 'CVT', 'Continuously variable transmission'),
  (4, 'DCT', 'DCT', 'Dual-clutch transmission'),
  (5, 'AMT', 'AMT', 'Automated manual transmission')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO manufacturers (id, name, slug, country, founded_year)
VALUES
  (1, 'Falcon Motors', 'falcon', 'India', 1998),
  (2, 'Orion Auto', 'orion', 'India', 2005)
ON DUPLICATE KEY UPDATE name = VALUES(name), country = VALUES(country), founded_year = VALUES(founded_year);

INSERT INTO model_families (id, manufacturer_id, name, code, description)
VALUES
  (1, 1, 'Falcon Swift Series', 'FAL-SW', 'Falcon hatchback line'),
  (2, 2, 'Orion Trail Series', 'ORI-TR', 'Orion SUV line')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO models (id, manufacturer_id, family_id, segment_id, body_type_id, name, slug, year_start, year_end, status)
VALUES
  (1, 1, 1, 1, 1, 'Falcon Swiftline', 'falcon-swiftline', 2022, NULL, 'on_sale'),
  (2, 1, 1, 4, 2, 'Falcon Tourer', 'falcon-tourer', 2023, NULL, 'on_sale'),
  (3, 2, 2, 5, 3, 'Orion Trailblazer', 'orion-trailblazer', 2023, NULL, 'on_sale')
ON DUPLICATE KEY UPDATE name = VALUES(name), segment_id = VALUES(segment_id), body_type_id = VALUES(body_type_id);

INSERT INTO model_lifecycle (id, model_id, phase, start_date, end_date, notes)
VALUES
  (1, 1, 'on_sale', '2022-01-01', NULL, 'Initial launch'),
  (2, 2, 'on_sale', '2023-03-01', NULL, 'Sedan launch'),
  (3, 3, 'on_sale', '2023-06-01', NULL, 'SUV launch')
ON DUPLICATE KEY UPDATE phase = VALUES(phase), end_date = VALUES(end_date), notes = VALUES(notes);

INSERT INTO variants (id, model_id, fuel_type_id, transmission_id, body_type_id, name, code, slug, year_start, year_end, drivetrain, seating_capacity)
VALUES
  (1, 1, 1, 1, 1, 'Swiftline Base', 'SWIFT-B', 'swiftline-base', 2022, NULL, 'FWD', 5),
  (2, 1, 1, 2, 1, 'Swiftline Premium', 'SWIFT-P', 'swiftline-premium', 2022, NULL, 'FWD', 5),
  (3, 2, 2, 1, 2, 'Tourer Diesel', 'TOURER-D', 'tourer-diesel', 2023, NULL, 'FWD', 5),
  (4, 2, 4, 2, 2, 'Tourer Hybrid', 'TOURER-H', 'tourer-hybrid', 2023, NULL, 'FWD', 5),
  (5, 3, 3, 2, 3, 'Trailblazer EV', 'TRAIL-E', 'trailblazer-ev', 2023, NULL, 'AWD', 5),
  (6, 3, 2, 4, 3, 'Trailblazer Diesel AWD', 'TRAIL-DA', 'trailblazer-diesel-awd', 2023, NULL, 'AWD', 7)
ON DUPLICATE KEY UPDATE name = VALUES(name), drivetrain = VALUES(drivetrain), seating_capacity = VALUES(seating_capacity);

INSERT INTO variant_lifecycle (id, variant_id, phase, start_date, end_date, notes)
VALUES
  (1, 1, 'on_sale', '2022-01-01', NULL, 'Intro trim'),
  (2, 2, 'on_sale', '2022-01-01', NULL, 'Premium trim'),
  (3, 3, 'on_sale', '2023-03-15', NULL, 'Diesel launch'),
  (4, 4, 'on_sale', '2023-04-01', NULL, 'Hybrid launch'),
  (5, 5, 'on_sale', '2023-06-15', NULL, 'EV launch'),
  (6, 6, 'on_sale', '2023-07-01', NULL, 'Diesel AWD launch')
ON DUPLICATE KEY UPDATE phase = VALUES(phase), end_date = VALUES(end_date);

-- Specification metadata
INSERT INTO spec_categories (id, name, sort_order)
VALUES
  (1, 'Performance', 1),
  (2, 'Dimensions', 2),
  (3, 'Engine & Powertrain', 3),
  (4, 'Safety', 4),
  (5, 'Comfort & Tech', 5)
ON DUPLICATE KEY UPDATE name = VALUES(name), sort_order = VALUES(sort_order);

INSERT INTO spec_definitions (id, category_id, spec_key, name, data_type, unit, is_comparable, sort_order)
VALUES
  (1, 1, 'top_speed_kph', 'Top Speed', 'number', 'kph', 1, 1),
  (2, 1, 'zero_to_hundred_s', '0-100 km/h', 'number', 's', 1, 2),
  (3, 1, 'mileage_kmpl', 'Claimed Mileage', 'number', 'kmpl', 1, 3),
  (4, 1, 'range_km', 'Claimed Range', 'number', 'km', 1, 4),
  (5, 2, 'length_mm', 'Length', 'number', 'mm', 1, 1),
  (6, 2, 'width_mm', 'Width', 'number', 'mm', 1, 2),
  (7, 2, 'height_mm', 'Height', 'number', 'mm', 1, 3),
  (8, 2, 'wheelbase_mm', 'Wheelbase', 'number', 'mm', 1, 4),
  (9, 2, 'boot_capacity_l', 'Boot Capacity', 'number', 'L', 1, 5),
  (10, 3, 'engine_displacement_cc', 'Engine Displacement', 'number', 'cc', 1, 1),
  (11, 3, 'max_power_bhp', 'Max Power', 'number', 'bhp', 1, 2),
  (12, 3, 'max_torque_nm', 'Max Torque', 'number', 'Nm', 1, 3),
  (13, 3, 'cylinders', 'Cylinders', 'number', NULL, 1, 4),
  (14, 3, 'fuel_tank_capacity_l', 'Fuel Tank', 'number', 'L', 1, 5),
  (15, 4, 'airbags_count', 'Airbags', 'number', NULL, 1, 1),
  (16, 4, 'abs', 'ABS', 'boolean', NULL, 1, 2),
  (17, 4, 'esc', 'ESC', 'boolean', NULL, 1, 3),
  (18, 4, 'parking_camera', 'Parking Camera', 'boolean', NULL, 1, 4),
  (19, 4, 'safety_rating', 'Safety Rating', 'number', 'stars', 1, 5),
  (20, 5, 'infotainment_size_in', 'Infotainment Screen', 'number', 'in', 1, 1),
  (21, 5, 'climate_control', 'Climate Control', 'text', NULL, 1, 2),
  (22, 5, 'seat_material', 'Seat Material', 'text', NULL, 1, 3),
  (23, 5, 'sunroof', 'Sunroof', 'boolean', NULL, 1, 4),
  (24, 5, 'speakers_count', 'Speakers', 'number', NULL, 1, 5)
ON DUPLICATE KEY UPDATE name = VALUES(name), data_type = VALUES(data_type), unit = VALUES(unit);

-- Variant specification values
INSERT INTO variant_specs (id, variant_id, spec_definition_id, value_number, value_boolean, value_text, captured_at)
VALUES
  (1, 1, 10, 1199, NULL, NULL, '2025-01-01'),
  (2, 1, 11, 85, NULL, NULL, '2025-01-01'),
  (3, 1, 12, 110, NULL, NULL, '2025-01-01'),
  (4, 1, 3, 18.5, NULL, NULL, '2025-01-01'),
  (5, 1, 15, 2, NULL, NULL, '2025-01-01'),
  (6, 1, 16, NULL, 1, NULL, '2025-01-01'),
  (7, 1, 17, NULL, 0, NULL, '2025-01-01'),
  (8, 1, 20, 7, NULL, NULL, '2025-01-01'),
  (9, 1, 21, NULL, NULL, 'manual ac', '2025-01-01'),
  (10, 1, 22, NULL, NULL, 'fabric', '2025-01-01'),
  (11, 1, 23, NULL, 0, NULL, '2025-01-01'),
  (12, 1, 24, 4, NULL, NULL, '2025-01-01'),

  (13, 2, 10, 1199, NULL, NULL, '2025-01-01'),
  (14, 2, 11, 100, NULL, NULL, '2025-01-01'),
  (15, 2, 12, 120, NULL, NULL, '2025-01-01'),
  (16, 2, 3, 17, NULL, NULL, '2025-01-01'),
  (17, 2, 15, 4, NULL, NULL, '2025-01-01'),
  (18, 2, 16, NULL, 1, NULL, '2025-01-01'),
  (19, 2, 17, NULL, 1, NULL, '2025-01-01'),
  (20, 2, 20, 9, NULL, NULL, '2025-01-01'),
  (21, 2, 21, NULL, NULL, 'auto', '2025-01-01'),
  (22, 2, 22, NULL, NULL, 'fabric + leatherette', '2025-01-01'),
  (23, 2, 23, NULL, 0, NULL, '2025-01-01'),
  (24, 2, 24, 6, NULL, NULL, '2025-01-01'),

  (25, 3, 10, 1498, NULL, NULL, '2025-01-01'),
  (26, 3, 11, 115, NULL, NULL, '2025-01-01'),
  (27, 3, 12, 240, NULL, NULL, '2025-01-01'),
  (28, 3, 3, 20, NULL, NULL, '2025-01-01'),
  (29, 3, 15, 4, NULL, NULL, '2025-01-01'),
  (30, 3, 16, NULL, 1, NULL, '2025-01-01'),
  (31, 3, 17, NULL, 1, NULL, '2025-01-01'),
  (32, 3, 20, 8, NULL, NULL, '2025-01-01'),
  (33, 3, 21, NULL, NULL, 'auto', '2025-01-01'),
  (34, 3, 22, NULL, NULL, 'fabric', '2025-01-01'),
  (35, 3, 23, NULL, 0, NULL, '2025-01-01'),
  (36, 3, 24, 6, NULL, NULL, '2025-01-01'),

  (37, 4, 10, 1399, NULL, NULL, '2025-01-01'),
  (38, 4, 11, 140, NULL, NULL, '2025-01-01'),
  (39, 4, 12, 250, NULL, NULL, '2025-01-01'),
  (40, 4, 3, 22, NULL, NULL, '2025-01-01'),
  (41, 4, 15, 6, NULL, NULL, '2025-01-01'),
  (42, 4, 16, NULL, 1, NULL, '2025-01-01'),
  (43, 4, 17, NULL, 1, NULL, '2025-01-01'),
  (44, 4, 20, 10, NULL, NULL, '2025-01-01'),
  (45, 4, 21, NULL, NULL, 'dual-zone auto', '2025-01-01'),
  (46, 4, 22, NULL, NULL, 'leatherette', '2025-01-01'),
  (47, 4, 23, NULL, 1, NULL, '2025-01-01'),
  (48, 4, 24, 8, NULL, NULL, '2025-01-01'),

  (49, 5, 4, 450, NULL, NULL, '2025-01-01'),
  (50, 5, 11, 200, NULL, NULL, '2025-01-01'),
  (51, 5, 12, 400, NULL, NULL, '2025-01-01'),
  (52, 5, 15, 6, NULL, NULL, '2025-01-01'),
  (53, 5, 16, NULL, 1, NULL, '2025-01-01'),
  (54, 5, 17, NULL, 1, NULL, '2025-01-01'),
  (55, 5, 20, 12, NULL, NULL, '2025-01-01'),
  (56, 5, 21, NULL, NULL, 'auto', '2025-01-01'),
  (57, 5, 22, NULL, NULL, 'vegan leather', '2025-01-01'),
  (58, 5, 23, NULL, 1, NULL, '2025-01-01'),
  (59, 5, 24, 10, NULL, NULL, '2025-01-01'),

  (60, 6, 10, 1998, NULL, NULL, '2025-01-01'),
  (61, 6, 11, 180, NULL, NULL, '2025-01-01'),
  (62, 6, 12, 420, NULL, NULL, '2025-01-01'),
  (63, 6, 3, 15, NULL, NULL, '2025-01-01'),
  (64, 6, 15, 6, NULL, NULL, '2025-01-01'),
  (65, 6, 16, NULL, 1, NULL, '2025-01-01'),
  (66, 6, 17, NULL, 1, NULL, '2025-01-01'),
  (67, 6, 20, 10, NULL, NULL, '2025-01-01'),
  (68, 6, 21, NULL, NULL, 'auto', '2025-01-01'),
  (69, 6, 22, NULL, NULL, 'leather', '2025-01-01'),
  (70, 6, 23, NULL, 1, NULL, '2025-01-01'),
  (71, 6, 24, 8, NULL, NULL, '2025-01-01')
ON DUPLICATE KEY UPDATE value_number = VALUES(value_number), value_boolean = VALUES(value_boolean), value_text = VALUES(value_text), captured_at = VALUES(captured_at);

-- Features
INSERT INTO feature_categories (id, name, sort_order)
VALUES
  (1, 'Safety', 1),
  (2, 'Convenience', 2),
  (3, 'Infotainment', 3),
  (4, 'Exterior', 4),
  (5, 'Driver Assist', 5)
ON DUPLICATE KEY UPDATE name = VALUES(name), sort_order = VALUES(sort_order);

INSERT INTO features (id, category_id, name, code, description)
VALUES
  (1, 1, 'ABS', 'SAFE_ABS', 'Anti-lock braking system'),
  (2, 1, 'ESC', 'SAFE_ESC', 'Electronic stability control'),
  (3, 1, '6 Airbags', 'SAFE_AIRBAGS_6', 'Six airbags'),
  (4, 1, 'TPMS', 'SAFE_TPMS', 'Tyre pressure monitor'),
  (5, 1, 'Hill Start Assist', 'SAFE_HSA', 'Hill start assist'),
  (6, 1, 'ISOFIX', 'SAFE_ISOFIX', 'ISOFIX child seat mounts'),
  (7, 2, 'Keyless Entry', 'CONV_KEYLESS', 'Keyless entry and go'),
  (8, 2, 'Cruise Control', 'CONV_CRUISE', 'Cruise control'),
  (9, 2, 'Auto Headlamps', 'CONV_AUTO_HEADLAMPS', 'Automatic headlamps'),
  (10, 2, 'Rain Sensing Wipers', 'CONV_RAIN_SENSORS', 'Rain sensing wipers'),
  (11, 2, 'Rear AC Vents', 'CONV_REAR_AC', 'Rear AC vents'),
  (12, 2, 'Remote Start', 'CONV_REMOTE_START', 'Remote engine start'),
  (13, 3, 'Apple CarPlay', 'INFO_APPLE', 'Apple CarPlay support'),
  (14, 3, 'Android Auto', 'INFO_ANDROID', 'Android Auto support'),
  (15, 3, 'Built-in Navigation', 'INFO_NAV', 'Integrated navigation'),
  (16, 3, 'Wi-Fi Hotspot', 'INFO_WIFI', 'In-car Wi-Fi'),
  (17, 3, 'Bluetooth', 'INFO_BLUETOOTH', 'Bluetooth connectivity'),
  (18, 3, 'OTA Updates', 'INFO_OTA', 'Over-the-air updates'),
  (19, 4, 'LED Headlamps', 'EXT_LED_HEADLAMPS', 'LED projector headlamps'),
  (20, 4, 'DRLs', 'EXT_DRLS', 'LED DRLs'),
  (21, 4, 'Alloy Wheels', 'EXT_ALLOYS', 'Alloy wheels'),
  (22, 4, 'Panoramic Sunroof', 'EXT_PANORAMIC', 'Large glass roof'),
  (23, 4, 'Roof Rails', 'EXT_ROOF_RAILS', 'Functional roof rails'),
  (24, 4, 'Power Tailgate', 'EXT_POWER_TAILGATE', 'Powered tailgate'),
  (25, 5, '360 Camera', 'DRV_360CAM', '360-degree camera'),
  (26, 5, 'Adaptive Cruise Control', 'DRV_ADAPTIVE_CC', 'Adaptive cruise'),
  (27, 5, 'Lane Keep Assist', 'DRV_LANE_KEEP', 'Lane keeping assist'),
  (28, 5, 'Blind Spot Monitor', 'DRV_BLIND_SPOT', 'Blind spot detection'),
  (29, 5, 'Park Assist', 'DRV_PARK_ASSIST', 'Automated park assist'),
  (30, 5, 'Auto Park', 'DRV_AUTO_PARK', 'Self parking')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO variant_features (id, variant_id, feature_id, is_standard)
VALUES
  (1, 1, 1, 1),
  (2, 1, 6, 1),
  (3, 1, 7, 1),
  (4, 1, 13, 1),

  (5, 2, 1, 1),
  (6, 2, 2, 1),
  (7, 2, 8, 1),
  (8, 2, 14, 1),
  (9, 2, 21, 1),

  (10, 3, 1, 1),
  (11, 3, 2, 1),
  (12, 3, 4, 1),
  (13, 3, 8, 1),
  (14, 3, 15, 1),

  (15, 4, 1, 1),
  (16, 4, 2, 1),
  (17, 4, 3, 1),
  (18, 4, 27, 1),
  (19, 4, 19, 1),

  (20, 5, 2, 1),
  (21, 5, 4, 1),
  (22, 5, 26, 1),
  (23, 5, 18, 1),
  (24, 5, 22, 1),

  (25, 6, 2, 1),
  (26, 6, 5, 1),
  (27, 6, 25, 1),
  (28, 6, 29, 1),
  (29, 6, 23, 1)
ON DUPLICATE KEY UPDATE feature_id = VALUES(feature_id), is_standard = VALUES(is_standard);

-- Media samples
INSERT INTO media (id, entity_type, entity_id, media_type, url, title, is_primary, sort_order)
VALUES
  (1, 'variant', 1, 'image', 'https://cdn.autopredator.local/swiftline-base.jpg', 'Swiftline Base', 1, 1),
  (2, 'variant', 2, 'image', 'https://cdn.autopredator.local/swiftline-premium.jpg', 'Swiftline Premium', 1, 1),
  (3, 'variant', 3, 'image', 'https://cdn.autopredator.local/tourer-diesel.jpg', 'Tourer Diesel', 1, 1),
  (4, 'variant', 4, 'image', 'https://cdn.autopredator.local/tourer-hybrid.jpg', 'Tourer Hybrid', 1, 1),
  (5, 'variant', 5, 'image', 'https://cdn.autopredator.local/trailblazer-ev.jpg', 'Trailblazer EV', 1, 1),
  (6, 'variant', 6, 'image', 'https://cdn.autopredator.local/trailblazer-diesel-awd.jpg', 'Trailblazer Diesel AWD', 1, 1)
ON DUPLICATE KEY UPDATE url = VALUES(url), title = VALUES(title), is_primary = VALUES(is_primary), sort_order = VALUES(sort_order);
