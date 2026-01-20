USE autopredator_marketplace;
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

INSERT INTO listings (id, org_id, user_id, model_id, variant_id, city_id, year, kms_driven, price, currency, listing_type, condition_state, status, description)
VALUES
  (1, NULL, NULL, 1, 1, 1, 2022, 12000, 620000, 'INR', 'sell', 'used', 'published', 'Well maintained Swiftline Base'),
  (2, NULL, NULL, 3, 5, 6, 2024, 5000, 2300000, 'INR', 'sell', 'used', 'published', 'Trailblazer EV single-owner')
ON DUPLICATE KEY UPDATE price = VALUES(price), status = VALUES(status), kms_driven = VALUES(kms_driven);

INSERT INTO leads (id, listing_id, model_id, variant_id, buyer_name, buyer_email, buyer_phone, source, status, notes)
VALUES
  (1, 1, 1, 1, 'Ravi Kumar', 'ravi@example.com', '+91-9000000001', 'site_form', 'new', 'Interested in test drive'),
  (2, 2, 3, 5, 'Anita Sharma', 'anita@example.com', '+91-9000000002', 'site_form', 'contacted', 'Requested financing options')
ON DUPLICATE KEY UPDATE status = VALUES(status), notes = VALUES(notes);

INSERT INTO lead_status_history (id, lead_id, status, changed_at, changed_by_user_id, note)
VALUES
  (1, 1, 'new', NOW(), NULL, 'Lead captured'),
  (2, 2, 'new', DATE_ADD(NOW(), INTERVAL -1 DAY), NULL, 'Lead captured'),
  (3, 2, 'contacted', NOW(), NULL, 'Called and sent brochure')
ON DUPLICATE KEY UPDATE status = VALUES(status), changed_at = VALUES(changed_at), note = VALUES(note);
