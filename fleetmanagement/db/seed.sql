\set ON_ERROR_STOP on
SET client_min_messages = warning;
SET TIME ZONE 'UTC';

-- Seed realistic multi-tenant demo data for FleetCommand (OrgA + OrgB)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Reset tenant context and clear all tenant tables
SELECT clear_tenant();

TRUNCATE TABLE
  audit_log,
  notifications,
  documents,
  doc_types,
  payments,
  invoice_lines,
  invoices,
  maintenance_items,
  maintenance_tickets,
  maintenance_plans,
  expense_logs,
  fuel_logs,
  trip_events,
  trip_stops,
  trips,
  odometer_logs,
  assignments,
  drivers,
  vehicles,
  contracts,
  customers,
  user_roles,
  users,
  role_permissions,
  permissions,
  roles,
  branches,
  orgs
RESTART IDENTITY CASCADE;

-- Helper to standardize timestamps
WITH base_ts AS (
  SELECT
    (current_date - INTERVAL '45 days')::timestamptz AS ts_45d,
    (current_date - INTERVAL '30 days')::timestamptz AS ts_30d,
    (current_date - INTERVAL '15 days')::timestamptz AS ts_15d,
    current_date::timestamptz AS ts_today
)
SELECT 1;

-------------------------------------------------------------------------------
-- OrgA: Apex Logistics Pvt Ltd (India)
-------------------------------------------------------------------------------
SELECT set_tenant('11111111-1111-1111-1111-111111111111', NULL);

WITH org_row AS (
  INSERT INTO orgs (org_id, name, legal_name, code, gstin, timezone, settings_jsonb)
  VALUES (
    current_org_id(),
    'Apex Logistics Pvt Ltd',
    'Apex Logistics Private Limited',
    'APEX',
    '29AAAAA0000A1Z5',
    'Asia/Kolkata',
    jsonb_build_object('timezone', 'Asia/Kolkata', 'demo', true)
  )
  ON CONFLICT (org_id) DO UPDATE
    SET name = EXCLUDED.name,
        legal_name = EXCLUDED.legal_name,
        code = EXCLUDED.code,
        gstin = EXCLUDED.gstin,
        timezone = EXCLUDED.timezone,
        settings_jsonb = EXCLUDED.settings_jsonb
  RETURNING org_id
), branch_rows AS (
  INSERT INTO branches (org_id, name, code, address, timezone)
  VALUES
    (current_org_id(), 'Bengaluru Hub', 'BLR', 'Peenya Industrial Area, Bengaluru, KA', 'Asia/Kolkata'),
    (current_org_id(), 'Hyderabad Hub', 'HYD', 'Kukatpally Industrial Estate, Hyderabad, TS', 'Asia/Kolkata')
  RETURNING branch_id, code
), role_rows AS (
  INSERT INTO roles (org_id, name, description, is_system)
  VALUES
    (current_org_id(), 'admin', 'Full administration', TRUE),
    (current_org_id(), 'manager', 'Branch/ops manager', FALSE),
    (current_org_id(), 'operator', 'Dispatch operator', FALSE),
    (current_org_id(), 'accountant', 'Billing and payments', FALSE),
    (current_org_id(), 'driver_view', 'Read-only driver portal', FALSE)
  RETURNING role_id, name
), perm_rows AS (
  INSERT INTO permissions (org_id, code, description)
  VALUES
    (current_org_id(), 'fleet.manage', 'Manage vehicles, drivers, and assignments'),
    (current_org_id(), 'trips.manage', 'Plan and track trips'),
    (current_org_id(), 'billing.manage', 'Invoices and payments'),
    (current_org_id(), 'maintenance.manage', 'Maintenance plans and tickets'),
    (current_org_id(), 'docs.manage', 'Compliance documents')
  RETURNING permission_id, code
), role_perm_rows AS (
  INSERT INTO role_permissions (org_id, role_id, permission_id)
  SELECT current_org_id(), r.role_id, p.permission_id
  FROM role_rows r
  JOIN perm_rows p ON p.code IN ('fleet.manage', 'trips.manage', 'billing.manage', 'maintenance.manage', 'docs.manage')
  WHERE r.name = 'admin'
  UNION ALL
  SELECT current_org_id(), r.role_id, p.permission_id
  FROM role_rows r
  JOIN perm_rows p ON p.code IN ('fleet.manage', 'trips.manage', 'maintenance.manage')
  WHERE r.name = 'manager'
  UNION ALL
  SELECT current_org_id(), r.role_id, p.permission_id
  FROM role_rows r
  JOIN perm_rows p ON p.code IN ('fleet.manage', 'trips.manage')
  WHERE r.name = 'operator'
  UNION ALL
  SELECT current_org_id(), r.role_id, p.permission_id
  FROM role_rows r
  JOIN perm_rows p ON p.code IN ('billing.manage')
  WHERE r.name = 'accountant'
  UNION ALL
  SELECT current_org_id(), r.role_id, p.permission_id
  FROM role_rows r
  JOIN perm_rows p ON p.code IN ('trips.manage')
  WHERE r.name = 'driver_view'
), user_rows AS (
  INSERT INTO users (org_id, branch_id, full_name, email, phone, is_active)
  SELECT
    current_org_id(),
    b.branch_id,
    u.full_name,
    u.email,
    u.phone,
    TRUE
  FROM (VALUES
    ('Bengaluru Hub', 'Ananya Iyer', 'ananya.iyer@apexlogistics.in', '+919845012001', 'BLR'),
    ('Hyderabad Hub', 'Rohit Shetty', 'rohit.shetty@apexlogistics.in', '+919845012002', 'HYD'),
    ('Bengaluru Hub', 'Meena Kulkarni', 'meena.kulkarni@apexlogistics.in', '+919845012003', 'BLR'),
    ('Bengaluru Hub', 'Sanjay Menon', 'sanjay.menon@apexlogistics.in', '+919845012004', 'BLR'),
    ('Hyderabad Hub', 'Karthik Rao', 'karthik.rao@apexlogistics.in', '+919845012005', 'HYD')
  ) AS u(branch_name, full_name, email, phone, branch_code)
  JOIN branch_rows b ON b.code = u.branch_code
  RETURNING user_id, full_name, email, branch_id
), user_role_rows AS (
  INSERT INTO user_roles (org_id, user_id, role_id)
  SELECT current_org_id(), u.user_id, r.role_id
  FROM user_rows u
  JOIN role_rows r ON (
    (u.email LIKE 'ananya.iyer%' AND r.name = 'admin') OR
    (u.email LIKE 'rohit.shetty%' AND r.name = 'manager') OR
    (u.email LIKE 'meena.kulkarni%' AND r.name = 'operator') OR
    (u.email LIKE 'sanjay.menon%' AND r.name = 'accountant') OR
    (u.email LIKE 'karthik.rao%' AND r.name = 'driver_view')
  )
), customer_rows AS (
  INSERT INTO customers (org_id, name, code, email, phone, gstin, billing_address, shipping_address)
  VALUES
    (current_org_id(), 'Urban Fresh Retail', 'UFR', 'accounts@urbanfresh.in', '+918880012345', '29AAACU1111F1Z9', 'Whitefield, Bengaluru', 'KR Puram, Bengaluru'),
    (current_org_id(), 'Deccan Manufacturing Co', 'DMC', 'ap@deccanmfg.com', '+918880045678', '27AAACD2222C1Z5', 'Pimpri, Pune', 'Bommasandra, Bengaluru'),
    (current_org_id(), 'Sunrise Pharma Distributors', 'SPD', 'billing@sunrisepharma.in', '+918880078901', NULL, 'Balanagar, Hyderabad', 'Nacharam, Hyderabad'),
    (current_org_id(), 'Coastal Agro Traders', 'CAT', 'finance@coastalagro.in', '+918880099900', '36AAACC3333D1Z8', 'Mangaluru Port Road', 'Bidadi, Bengaluru'),
    (current_org_id(), 'Metro Appliances', 'MAP', 'ar@metroappliances.in', '+918880011122', '29AAACM4444E1Z3', 'Yeshwanthpur, Bengaluru', 'Medchal, Hyderabad'),
    (current_org_id(), 'Vistara Fashion Exports', 'VFE', 'ap@vistaraexports.in', '+918880022233', NULL, 'HSR Layout, Bengaluru', 'Narasapura, Kolar')
  RETURNING customer_id, code, name
), contract_rows AS (
  INSERT INTO contracts (org_id, customer_id, name, start_date, end_date, rate_jsonb, base_rate_paise, notes)
  SELECT
    current_org_id(),
    c.customer_id,
    contract_name,
    start_dt,
    NULL,
    jsonb_build_object(
      'rate_type', rate_type,
      'base_rate_paise', base_rate,
      'fuel_surcharge_pct', fuel_pct,
      'gst_pct', gst_pct
    ),
    base_rate,
    notes
  FROM customer_rows c
  JOIN (
    VALUES
      ('UFR', 'Bengaluru metro deliveries', 'per_trip', 320000, 8, 18, 'City drops with two-hour SLA', '2024-12-01'::date),
    ('DMC', 'Inbound raw material', 'per_km', 2250, 10, 18, 'Steel coils and machine parts', '2024-12-15'::date),
    ('SPD', 'Hyderabad pharma lanes', 'per_km', 2100, 7, 12, 'Temp-controlled cargo', '2024-12-20'::date),
    ('CAT', 'Agri bulk (ton-km)', 'per_ton_km', 950, 5, 5, 'Seasonal harvest movement', '2024-12-10'::date)
  ) AS r(cust_code, contract_name, rate_type, base_rate, fuel_pct, gst_pct, notes, start_dt)
    ON c.code = r.cust_code
  RETURNING contract_id, name, customer_id
)
SELECT 'OrgA core seeded' AS status;

-- Fleet (vehicles, drivers, assignments, odometer logs)
WITH branch_map AS (
  SELECT code, branch_id FROM branches WHERE org_id = current_org_id()
), vehicle_rows AS (
  INSERT INTO vehicles (org_id, branch_id, reg_no, vin, make, model, year, fuel_type, capacity_kg, status, purchase_date, current_odometer_km, insurance_expiry)
  SELECT current_org_id(), b.branch_id, v.*
  FROM branch_map b
  JOIN (VALUES
    ('BLR', 'KA01AX1001', 'APEXBLRVINA01', 'Tata', 'LPT 1613', 2022, 'diesel', 16000, 'active', '2022-04-10'::date, 98450.0, '2025-12-15'::date),
    ('BLR', 'KA01AX1002', 'APEXBLRVINA02', 'Ashok Leyland', 'Partner 4T', 2023, 'diesel', 7000, 'active', '2023-07-02'::date, 61230.0, '2025-10-30'::date),
    ('HYD', 'TS09HY2001', 'APEXHYDVINA01', 'Mahindra', 'Furio 11', 2021, 'diesel', 11000, 'maintenance', '2021-03-20'::date, 128900.0, '2025-08-25'::date),
    ('BLR', 'KA02BX3001', 'APEXBLRVINA03', 'Isuzu', 'D-MAX', 2020, 'diesel', 1200, 'active', '2020-11-05'::date, 84550.0, '2025-06-18'::date),
    ('HYD', 'TS07CX4001', 'APEXHYDVINA02', 'Eicher', 'Pro 2049', 2022, 'diesel', 4900, 'inactive', '2022-09-12'::date, 43210.0, '2025-09-09'::date)
  ) AS v(branch_code, reg_no, vin, make, model, year, fuel_type, capacity_kg, status, purchase_date, current_odometer_km, insurance_expiry)
    ON b.code = v.branch_code
  RETURNING vehicle_id, reg_no, branch_id
), driver_rows AS (
  INSERT INTO drivers (org_id, branch_id, full_name, license_no, phone, status, joined_at)
  SELECT current_org_id(), b.branch_id, d.full_name, d.license_no, d.phone, d.status, d.joined_at
  FROM branch_map b
  JOIN (VALUES
    ('BLR', 'Sameer Kulal', 'KA01-2020-4501234', '+919876500101', 'active', '2021-02-15'::date),
    ('HYD', 'Priya Narang', 'TS09-2021-7788123', '+919876500102', 'active', '2022-06-10'::date),
    ('BLR', 'Imran Sheikh', 'KA02-2019-3344556', '+919876500103', 'active', '2020-09-05'::date),
    ('BLR', 'Girish Gowda', 'KA03-2018-9876123', '+919876500104', 'inactive', '2019-07-22'::date),
    ('HYD', 'Nitin Verma', 'TS07-2020-1928374', '+919876500105', 'active', '2021-12-01'::date),
    ('HYD', 'Lakshmi B', 'TS09-2017-9988776', '+919876500106', 'suspended', '2018-05-14'::date)
  ) AS d(branch_code, full_name, license_no, phone, status, joined_at)
    ON b.code = d.branch_code
  RETURNING driver_id, full_name, license_no, branch_id
), assignment_rows AS (
  INSERT INTO assignments (org_id, vehicle_id, driver_id, start_at, end_at, notes)
  SELECT current_org_id(), v.vehicle_id, d.driver_id, a.start_at, a.end_at, a.notes
  FROM vehicle_rows v
  JOIN driver_rows d ON d.license_no = a.driver_license
  JOIN (
    VALUES
      ('KA01AX1001', 'KA01-2020-4501234', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '03:00', NULL, 'Primary driver'),
    ('KA01AX1002', 'KA02-2019-3344556', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '04:00', NULL, 'Long haul'),
    ('TS09HY2001', 'TS09-2021-7788123', (current_date - INTERVAL '40 days')::timestamptz + INTERVAL '05:00', NULL, 'Hyd lanes'),
    ('KA02BX3001', 'KA03-2018-9876123', (current_date - INTERVAL '200 days')::timestamptz + INTERVAL '06:00', (current_date - INTERVAL '120 days')::timestamptz + INTERVAL '15:00', 'Historical assignment'),
    ('KA02BX3001', 'KA02-2019-3344556', (current_date - INTERVAL '110 days')::timestamptz + INTERVAL '08:00', NULL, 'Current pickup driver'),
    ('TS07CX4001', 'TS07-2020-1928374', (current_date - INTERVAL '50 days')::timestamptz + INTERVAL '09:00', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '20:00', 'Returned vehicle'),
    ('TS07CX4001', 'TS09-2017-9988776', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '07:30', NULL, 'Temp assignment'),
    ('KA01AX1001', 'KA03-2018-9876123', (current_date - INTERVAL '120 days')::timestamptz + INTERVAL '05:30', (current_date - INTERVAL '90 days')::timestamptz + INTERVAL '14:00', 'Historic backup')
  ) AS a(reg_no, driver_license, start_at, end_at, notes)
    ON v.reg_no = a.reg_no
    AND d.license_no = a.driver_license
  RETURNING assignment_id
), odo_rows AS (
  INSERT INTO odometer_logs (org_id, vehicle_id, reading_km, recorded_at, source)
  SELECT current_org_id(), v.vehicle_id, o.reading_km, o.recorded_at, 'device'
  FROM vehicle_rows v
  JOIN (
    VALUES
      ('KA01AX1001', 97000.0, (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '06:00'),
      ('KA01AX1001', 98500.0, (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '06:30'),
      ('KA01AX1002', 59800.0, (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '07:00'),
      ('KA01AX1002', 61250.0, (current_date - INTERVAL '8 days')::timestamptz + INTERVAL '08:00'),
      ('TS09HY2001', 127900.0, (current_date - INTERVAL '30 days')::timestamptz + INTERVAL '09:00'),
      ('TS09HY2001', 129200.0, (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '10:00'),
      ('KA02BX3001', 83200.0, (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '11:00'),
      ('KA02BX3001', 84650.0, (current_date - INTERVAL '3 days')::timestamptz + INTERVAL '12:00'),
      ('TS07CX4001', 42000.0, (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '13:00'),
      ('TS07CX4001', 43350.0, (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '14:00')
  ) AS o(reg_no, reading_km, recorded_at)
    ON v.reg_no = o.reg_no
)
SELECT 'OrgA fleet seeded' AS status;

-- Trips, stops, events
WITH vehicle_map AS (
  SELECT reg_no, vehicle_id FROM vehicles WHERE org_id = current_org_id()
), driver_map AS (
  SELECT license_no, driver_id FROM drivers WHERE org_id = current_org_id()
), customer_map AS (
  SELECT code, customer_id FROM customers WHERE org_id = current_org_id()
), contract_map AS (
  SELECT name, contract_id FROM contracts WHERE org_id = current_org_id()
), trip_rows AS (
  INSERT INTO trips (org_id, trip_no, vehicle_id, driver_id, customer_id, contract_id, start_at, planned_end_at, end_at, origin, destination, distance_km, status, revenue_paise)
  SELECT
    current_org_id(),
    t.trip_no,
    v.vehicle_id,
    d.driver_id,
    c.customer_id,
    ct.contract_id,
    t.start_at,
    t.planned_end_at,
    t.end_at,
    t.origin,
    t.destination,
    t.distance_km,
    t.status::trip_status,
    t.revenue_paise
  FROM (VALUES
    ('APEX-TR-001', 'KA01AX1001', 'KA01-2020-4501234', 'UFR', 'Bengaluru metro deliveries', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '04:30', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '09:00', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '08:45', 'Peenya', 'HSR Layout', 42.5, 'completed', 185000),
    ('APEX-TR-002', 'KA01AX1002', 'KA02-2019-3344556', 'DMC', 'Inbound raw material', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '05:00', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '14:00', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '13:20', 'Bommasandra', 'Pimpri', 730.0, 'completed', 1685000),
    ('APEX-TR-003', 'TS09HY2001', 'TS09-2021-7788123', 'SPD', 'Hyderabad pharma lanes', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '06:00', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '15:00', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '14:30', 'Balanagar', 'Vijayawada', 300.0, 'completed', 735000),
    ('APEX-TR-004', 'KA02BX3001', 'KA02-2019-3344556', 'UFR', 'Bengaluru metro deliveries', (current_date - INTERVAL '30 days')::timestamptz + INTERVAL '07:00', (current_date - INTERVAL '30 days')::timestamptz + INTERVAL '11:00', (current_date - INTERVAL '30 days')::timestamptz + INTERVAL '10:40', 'Peenya', 'Indiranagar', 38.0, 'completed', 175000),
    ('APEX-TR-005', 'KA01AX1001', 'KA01-2020-4501234', 'CAT', 'Agri bulk (ton-km)', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:30', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '17:30', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '17:00', 'Bidadi', 'Mangaluru', 360.0, 'completed', 980000),
    ('APEX-TR-006', 'KA01AX1002', 'KA02-2019-3344556', 'MAP', 'Inbound raw material', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '04:45', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '13:45', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '13:40', 'Medchal', 'Bengaluru', 590.0, 'completed', 1387500),
    ('APEX-TR-007', 'TS07CX4001', 'TS07-2020-1928374', 'SPD', 'Hyderabad pharma lanes', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '06:15', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '10:45', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '09:50', 'Nacharam', 'Shamirpet', 65.0, 'completed', 150000),
    ('APEX-TR-008', 'KA01AX1001', 'KA01-2020-4501234', 'MAP', 'Bengaluru metro deliveries', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '07:20', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '12:20', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '11:55', 'Yeshwanthpur', 'KR Puram', 48.0, 'completed', 190000),
    ('APEX-TR-009', 'TS09HY2001', 'TS09-2021-7788123', 'SPD', 'Hyderabad pharma lanes', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:40', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '15:40', NULL, 'Balanagar', 'Guntur', 280.0, 'in_progress', 675000),
    ('APEX-TR-010', 'KA02BX3001', 'KA03-2018-9876123', 'UFR', 'Bengaluru metro deliveries', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '08:00', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '12:00', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '11:30', 'Peenya', 'Electronic City', 52.0, 'completed', 182000),
    ('APEX-TR-011', 'KA01AX1002', 'KA02-2019-3344556', 'DMC', 'Inbound raw material', (current_date - INTERVAL '18 days')::timestamptz + INTERVAL '05:00', (current_date - INTERVAL '18 days')::timestamptz + INTERVAL '15:00', (current_date - INTERVAL '18 days')::timestamptz + INTERVAL '14:20', 'Pimpri', 'Bengaluru', 730.0, 'completed', 1685000),
    ('APEX-TR-012', 'KA01AX1001', 'KA01-2020-4501234', 'VFE', 'Agri bulk (ton-km)', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '04:20', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '13:20', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '12:45', 'Narasapura', 'Chennai', 360.0, 'completed', 960000),
    ('APEX-TR-013', 'TS07CX4001', 'TS09-2017-9988776', 'SPD', 'Hyderabad pharma lanes', (current_date - INTERVAL '16 days')::timestamptz + INTERVAL '06:30', (current_date - INTERVAL '16 days')::timestamptz + INTERVAL '11:30', (current_date - INTERVAL '16 days')::timestamptz + INTERVAL '11:10', 'Nacharam', 'Shamshabad', 48.0, 'completed', 142000),
    ('APEX-TR-014', 'KA02BX3001', 'KA02-2019-3344556', 'UFR', 'Bengaluru metro deliveries', (current_date - INTERVAL '14 days')::timestamptz + INTERVAL '07:10', (current_date - INTERVAL '14 days')::timestamptz + INTERVAL '11:40', NULL, 'Peenya', 'Marathahalli', 50.0, 'in_progress', 188000),
    ('APEX-TR-015', 'KA01AX1001', 'KA01-2020-4501234', 'CAT', 'Agri bulk (ton-km)', (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '05:50', (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '16:20', (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '16:05', 'Bidadi', 'Chikkamagaluru', 220.0, 'completed', 712000),
    ('APEX-TR-016', 'TS09HY2001', 'TS09-2021-7788123', 'SPD', 'Hyderabad pharma lanes', (current_date - INTERVAL '10 days')::timestamptz + INTERVAL '06:00', (current_date - INTERVAL '10 days')::timestamptz + INTERVAL '15:00', NULL, 'Balanagar', 'Nellore', 310.0, 'in_progress', 738000),
    ('APEX-TR-017', 'KA01AX1002', 'KA02-2019-3344556', 'DMC', 'Inbound raw material', (current_date - INTERVAL '8 days')::timestamptz + INTERVAL '05:10', (current_date - INTERVAL '8 days')::timestamptz + INTERVAL '15:10', (current_date - INTERVAL '8 days')::timestamptz + INTERVAL '15:00', 'Bengaluru', 'Pimpri', 730.0, 'completed', 1685000),
    ('APEX-TR-018', 'KA02BX3001', 'KA02-2019-3344556', 'VFE', 'Bengaluru metro deliveries', (current_date - INTERVAL '6 days')::timestamptz + INTERVAL '07:40', (current_date - INTERVAL '6 days')::timestamptz + INTERVAL '11:40', NULL, 'Peenya', 'Whitefield', 44.0, 'cancelled', 0),
    ('APEX-TR-019', 'KA01AX1001', 'KA01-2020-4501234', 'MAP', 'Bengaluru metro deliveries', (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '08:00', (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '13:00', (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '12:30', 'Peenya', 'Electronic City', 50.0, 'completed', 190000),
    ('APEX-TR-020', 'TS07CX4001', 'TS09-2017-9988776', 'SPD', 'Hyderabad pharma lanes', (current_date - INTERVAL '2 days')::timestamptz + INTERVAL '06:50', (current_date - INTERVAL '2 days')::timestamptz + INTERVAL '12:50', NULL, 'Nacharam', 'Kurnool', 220.0, 'planned', 520000)
  ) AS t(trip_no, reg_no, driver_license, customer_code, contract_name, start_at, planned_end_at, end_at, origin, destination, distance_km, status, revenue_paise)
  JOIN vehicle_map v ON v.reg_no = t.reg_no
  JOIN driver_map d ON d.license_no = t.driver_license
  JOIN customer_map c ON c.code = t.customer_code
  JOIN contract_map ct ON ct.name = t.contract_name
  RETURNING trip_id, trip_no, vehicle_id
), stop_rows AS (
  INSERT INTO trip_stops (org_id, trip_id, stop_sequence, location_name, latitude, longitude, planned_at, arrival_at, departure_at)
  SELECT
    current_org_id(), tr.trip_id, s.stop_sequence, s.location_name, s.lat, s.lon, s.planned_at, s.arrival_at, s.departure_at
  FROM trip_rows tr
  JOIN (
    VALUES
      ('APEX-TR-001', 1, 'Load - Peenya', 13.0121, 77.5145, (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '04:15', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '04:20', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '04:45'),
      ('APEX-TR-001', 2, 'Drop - HSR', 12.9121, 77.6388, (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '08:40', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '08:42', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '08:55'),
      ('APEX-TR-002', 1, 'Load - Bommasandra', 12.8001, 77.7050, (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '04:30', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '04:35', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '05:10'),
      ('APEX-TR-002', 2, 'Midway - Hubballi', 15.3647, 75.1239, (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '09:30', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '09:20', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '09:50'),
      ('APEX-TR-002', 3, 'Drop - Pimpri', 18.6283, 73.7997, (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '13:30', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '13:15', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '13:35'),
      ('APEX-TR-003', 1, 'Load - Balanagar', 17.4721, 78.4371, (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '05:40', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '05:50', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '06:10'),
      ('APEX-TR-003', 2, 'Drop - Vijayawada', 16.5062, 80.6480, (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '14:30', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '14:35', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '14:50'),
      ('APEX-TR-005', 1, 'Load - Bidadi', 12.7786, 77.4007, (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:15', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:20', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:40'),
      ('APEX-TR-005', 2, 'Drop - Mangaluru', 12.9141, 74.8560, (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '17:00', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '17:00', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '17:20'),
      ('APEX-TR-006', 1, 'Load - Medchal', 17.6290, 78.4814, (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '04:30', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '04:40', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '04:50'),
      ('APEX-TR-006', 2, 'Drop - Bengaluru', 12.9716, 77.5946, (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '13:40', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '13:40', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '14:00'),
      ('APEX-TR-007', 1, 'Load - Nacharam', 17.4695, 78.5609, (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '06:00', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '06:05', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '06:15'),
      ('APEX-TR-007', 2, 'Drop - Shamirpet', 17.6310, 78.5450, (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '09:40', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '09:42', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '10:00'),
      ('APEX-TR-009', 1, 'Load - Balanagar', 17.4721, 78.4371, (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:20', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:25', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:45'),
      ('APEX-TR-009', 2, 'Midway - Suryapet', 17.1416, 79.6209, (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '09:30', NULL, NULL)
  ) AS s(trip_no, stop_sequence, location_name, lat, lon, planned_at, arrival_at, departure_at)
    ON tr.trip_no = s.trip_no
  RETURNING trip_stop_id
), event_rows AS (
  INSERT INTO trip_events (org_id, trip_id, event_type, event_at, payload_jsonb)
  SELECT
    current_org_id(),
    tr.trip_id,
    e.event_type,
    e.event_at,
    e.payload
  FROM trip_rows tr
  JOIN (
    VALUES
      ('APEX-TR-001', 'status_change', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '04:20', jsonb_build_object('status', 'departed')),
      ('APEX-TR-001', 'gps', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '07:30', jsonb_build_object('lat', 12.95, 'lng', 77.60)),
      ('APEX-TR-002', 'status_change', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '09:20', jsonb_build_object('status', 'in_transit')),
      ('APEX-TR-002', 'gps', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '12:00', jsonb_build_object('lat', 16.30, 'lng', 74.60)),
      ('APEX-TR-003', 'status_change', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '06:15', jsonb_build_object('status', 'departed')),
      ('APEX-TR-003', 'gps', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '10:45', jsonb_build_object('lat', 16.90, 'lng', 79.60)),
      ('APEX-TR-005', 'status_change', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:20', jsonb_build_object('status', 'departed')),
      ('APEX-TR-005', 'gps', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '12:00', jsonb_build_object('lat', 12.90, 'lng', 76.70)),
      ('APEX-TR-006', 'status_change', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '04:45', jsonb_build_object('status', 'departed')),
      ('APEX-TR-006', 'gps', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '11:30', jsonb_build_object('lat', 15.90, 'lng', 77.90)),
      ('APEX-TR-007', 'status_change', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '06:10', jsonb_build_object('status', 'departed')),
      ('APEX-TR-009', 'gps', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '10:00', jsonb_build_object('lat', 17.20, 'lng', 79.20)),
      ('APEX-TR-010', 'status_change', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '08:00', jsonb_build_object('status', 'departed')),
      ('APEX-TR-010', 'gps', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '10:00', jsonb_build_object('lat', 12.95, 'lng', 77.60)),
      ('APEX-TR-011', 'status_change', (current_date - INTERVAL '18 days')::timestamptz + INTERVAL '05:10', jsonb_build_object('status', 'departed')),
      ('APEX-TR-012', 'gps', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '09:30', jsonb_build_object('lat', 12.90, 'lng', 79.90)),
      ('APEX-TR-014', 'status_change', (current_date - INTERVAL '14 days')::timestamptz + INTERVAL '07:15', jsonb_build_object('status', 'departed')),
      ('APEX-TR-015', 'gps', (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '12:00', jsonb_build_object('lat', 13.10, 'lng', 76.50)),
      ('APEX-TR-017', 'status_change', (current_date - INTERVAL '8 days')::timestamptz + INTERVAL '05:00', jsonb_build_object('status', 'departed')),
      ('APEX-TR-019', 'gps', (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '10:00', jsonb_build_object('lat', 12.90, 'lng', 77.70))
  ) AS e(trip_no, event_type, event_at, payload)
    ON tr.trip_no = e.trip_no
)
SELECT 'OrgA trips seeded' AS status;

-- Fuel logs (25) and expense logs (30)
WITH vehicle_map AS (
  SELECT reg_no, vehicle_id FROM vehicles WHERE org_id = current_org_id()
), driver_map AS (
  SELECT license_no, driver_id FROM drivers WHERE org_id = current_org_id()
), trip_map AS (
  SELECT trip_no, trip_id FROM trips WHERE org_id = current_org_id()
), fuel_rows AS (
  INSERT INTO fuel_logs (org_id, vehicle_id, driver_id, trip_id, filled_at, odometer_km, volume_liters, price_per_liter_paise, total_amount_paise, vendor, payment_method)
  SELECT
    current_org_id(),
    v.vehicle_id,
    d.driver_id,
    t.trip_id,
    f.filled_at,
    f.odometer_km,
    f.volume_liters,
    f.price_per_liter_paise,
    ROUND(f.volume_liters * f.price_per_liter_paise)::bigint,
    f.vendor,
    f.payment_method
  FROM (VALUES
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-001', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '05:00', 97200.0, 45.5, 9800, 'HPCL Peenya', 'upi'),
    ('KA01AX1002', 'KA02-2019-3344556', 'APEX-TR-002', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '07:00', 60020.0, 60.0, 9700, 'IOCL Tumkur', 'card'),
    ('TS09HY2001', 'TS09-2021-7788123', 'APEX-TR-003', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '08:00', 128200.0, 70.0, 9600, 'BPCL Suryapet', 'card'),
    ('KA02BX3001', 'KA02-2019-3344556', 'APEX-TR-004', (current_date - INTERVAL '30 days')::timestamptz + INTERVAL '08:30', 83300.0, 35.0, 9900, 'Shell Hebbal', 'upi'),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-005', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '09:00', 97500.0, 65.0, 9750, 'HPCL Kunigal', 'cash'),
    ('KA01AX1002', 'KA02-2019-3344556', 'APEX-TR-006', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '09:20', 60600.0, 58.0, 9780, 'Reliance Kurnool', 'upi'),
    ('TS07CX4001', 'TS07-2020-1928374', 'APEX-TR-007', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '07:00', 42100.0, 40.0, 9550, 'HP Nacharam', 'card'),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-008', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '08:30', 97900.0, 42.0, 9825, 'IOCL HSR', 'upi'),
    ('TS09HY2001', 'TS09-2021-7788123', 'APEX-TR-009', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '08:10', 128950.0, 68.0, 9700, 'BPCL Suryapet', 'card'),
    ('KA02BX3001', 'KA02-2019-3344556', 'APEX-TR-010', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '09:10', 83750.0, 33.0, 9900, 'Shell Yeshwanthpur', 'upi'),
    ('KA01AX1002', 'KA02-2019-3344556', 'APEX-TR-011', (current_date - INTERVAL '18 days')::timestamptz + INTERVAL '07:00', 60500.0, 60.0, 9720, 'IOCL Satara', 'card'),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-012', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '06:30', 98250.0, 55.0, 9800, 'HPCL Krishnagiri', 'upi'),
    ('TS07CX4001', 'TS09-2017-9988776', 'APEX-TR-013', (current_date - INTERVAL '16 days')::timestamptz + INTERVAL '07:40', 42450.0, 41.0, 9520, 'IOCL Uppal', 'cash'),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-015', (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '09:00', 98850.0, 60.0, 9780, 'HPCL Hassan', 'card'),
    ('TS09HY2001', 'TS09-2021-7788123', 'APEX-TR-016', (current_date - INTERVAL '10 days')::timestamptz + INTERVAL '07:20', 128400.0, 65.0, 9650, 'BPCL Ongole', 'upi'),
    ('KA01AX1002', 'KA02-2019-3344556', 'APEX-TR-017', (current_date - INTERVAL '8 days')::timestamptz + INTERVAL '08:00', 61000.0, 62.0, 9700, 'IOCL Hubballi', 'upi'),
    ('KA02BX3001', 'KA02-2019-3344556', 'APEX-TR-018', (current_date - INTERVAL '6 days')::timestamptz + INTERVAL '09:00', 84200.0, 32.0, 9950, 'Shell Peenya', 'card'),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-019', (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '09:10', 98990.0, 48.0, 9850, 'HPCL NICE Road', 'upi'),
    ('TS07CX4001', 'TS09-2017-9988776', 'APEX-TR-020', (current_date - INTERVAL '2 days')::timestamptz + INTERVAL '08:10', 43200.0, 44.0, 9600, 'IOCL Kurnool', 'card'),
    -- Unlinked refuels for RLS coverage
    ('KA01AX1002', 'KA02-2019-3344556', NULL, (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '07:00', 60150.0, 30.0, 9750, 'HPCL Tumkur', 'cash'),
    ('TS09HY2001', 'TS09-2021-7788123', NULL, (current_date - INTERVAL '14 days')::timestamptz + INTERVAL '10:00', 128700.0, 50.0, 9700, 'HPCL Vanasthalipuram', 'upi'),
    ('KA02BX3001', 'KA02-2019-3344556', NULL, (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '08:00', 83900.0, 36.0, 9950, 'Shell ORR', 'card'),
    ('TS07CX4001', 'TS09-2017-9988776', NULL, (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '06:50', 42300.0, 39.0, 9520, 'IOCL ECIL', 'upi'),
    ('KA01AX1001', 'KA01-2020-4501234', NULL, (current_date - INTERVAL '1 day')::timestamptz + INTERVAL '07:30', 99300.0, 46.0, 9860, 'HPCL Electronic City', 'card')
  ) AS f(reg_no, driver_license, trip_no, filled_at, odometer_km, volume_liters, price_per_liter_paise, vendor, payment_method)
  LEFT JOIN vehicle_map v ON v.reg_no = f.reg_no
  LEFT JOIN driver_map d ON d.license_no = f.driver_license
  LEFT JOIN trip_map t ON t.trip_no = f.trip_no
  RETURNING fuel_log_id
), expense_rows AS (
  INSERT INTO expense_logs (org_id, vehicle_id, driver_id, trip_id, customer_id, expense_type, description, incurred_at, amount_paise, gst_amount_paise)
  SELECT
    current_org_id(),
    v.vehicle_id,
    d.driver_id,
    t.trip_id,
    c.customer_id,
    e.expense_type,
    e.description,
    e.incurred_at,
    e.amount_paise,
    e.gst_amount_paise
  FROM (VALUES
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-001', 'UFR', 'toll', 'NICE road toll (paid_by=driver)', (current_date - INTERVAL '35 days')::timestamptz + INTERVAL '05:30', 45000, 8100),
    ('KA01AX1002', 'KA02-2019-3344556', 'APEX-TR-002', 'DMC', 'toll', 'Expressway toll receipts', (current_date - INTERVAL '33 days')::timestamptz + INTERVAL '08:15', 182000, 32760),
    ('TS09HY2001', 'TS09-2021-7788123', 'APEX-TR-003', 'SPD', 'food', 'Driver meals (paid_by=company)', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '11:30', 15000, 2700),
    ('KA02BX3001', 'KA02-2019-3344556', 'APEX-TR-004', 'UFR', 'parking', 'City parking slip', (current_date - INTERVAL '30 days')::timestamptz + INTERVAL '11:00', 12000, 2160),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-005', 'CAT', 'lodging', 'Driver lodge near Hassan', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '21:00', 220000, 39600),
    ('KA01AX1002', 'KA02-2019-3344556', 'APEX-TR-006', 'MAP', 'repair', 'Puncture repair (receipt_doc_id=D1)', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '12:10', 18000, 3240),
    ('TS07CX4001', 'TS07-2020-1928374', 'APEX-TR-007', 'SPD', 'toll', 'ORR toll (paid_by=driver)', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '08:15', 24000, 4320),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-008', 'MAP', 'food', 'Breakfast for crew', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '09:30', 9000, 1620),
    ('TS09HY2001', 'TS09-2021-7788123', 'APEX-TR-009', 'SPD', 'repair', 'Brake pad check (paid_by=company)', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '11:40', 320000, 57600),
    ('KA02BX3001', 'KA02-2019-3344556', 'APEX-TR-010', 'UFR', 'parking', 'Mall parking slip', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '10:40', 8000, 1440),
    ('KA01AX1002', 'KA02-2019-3344556', 'APEX-TR-011', 'DMC', 'toll', 'Pune expressway tolls', (current_date - INTERVAL '18 days')::timestamptz + INTERVAL '07:30', 176000, 31680),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-012', 'VFE', 'food', 'Snacks for loaders', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '06:20', 7000, 1260),
    ('TS07CX4001', 'TS09-2017-9988776', 'APEX-TR-013', 'SPD', 'parking', 'Airport parking', (current_date - INTERVAL '16 days')::timestamptz + INTERVAL '09:50', 15000, 2700),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-015', 'CAT', 'food', 'Lunch for crew', (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '13:00', 10000, 1800),
    ('TS09HY2001', 'TS09-2021-7788123', 'APEX-TR-016', 'SPD', 'toll', 'Highway tolls (paid_by=company)', (current_date - INTERVAL '10 days')::timestamptz + INTERVAL '08:40', 142000, 25560),
    ('KA01AX1002', 'KA02-2019-3344556', 'APEX-TR-017', 'DMC', 'lodging', 'Night halt Hubballi', (current_date - INTERVAL '8 days')::timestamptz + INTERVAL '22:00', 180000, 32400),
    ('KA02BX3001', 'KA02-2019-3344556', 'APEX-TR-018', 'VFE', 'toll', 'BETL toll (paid_by=driver)', (current_date - INTERVAL '6 days')::timestamptz + INTERVAL '08:20', 13500, 2430),
    ('KA01AX1001', 'KA01-2020-4501234', 'APEX-TR-019', 'MAP', 'toll', 'NICE road toll', (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '09:30', 18000, 3240),
    ('TS07CX4001', 'TS09-2017-9988776', 'APEX-TR-020', 'SPD', 'toll', 'ORR toll - prepaid', (current_date - INTERVAL '2 days')::timestamptz + INTERVAL '07:30', 16000, 2880),
    -- Non-trip expenses
    ('KA01AX1002', 'KA02-2019-3344556', NULL, NULL, 'repair', 'AC gas top-up (paid_by=company)', (current_date - INTERVAL '29 days')::timestamptz + INTERVAL '10:00', 85000, 15300),
    ('TS09HY2001', 'TS09-2021-7788123', NULL, 'SPD', 'repair', 'Tyre replacement (receipt_doc_id=D2)', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '15:00', 520000, 93600),
    ('KA02BX3001', 'KA02-2019-3344556', NULL, 'UFR', 'parking', 'Depot parking fee', (current_date - INTERVAL '21 days')::timestamptz + INTERVAL '18:00', 6000, 1080),
    ('TS07CX4001', 'TS07-2020-1928374', NULL, 'SPD', 'food', 'Team lunch (paid_by=company)', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '13:00', 24000, 4320),
    ('KA01AX1001', 'KA01-2020-4501234', NULL, 'CAT', 'fine', 'Traffic fine - overspeed', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '12:00', 20000, 0),
    ('KA01AX1002', 'KA02-2019-3344556', NULL, 'MAP', 'repair', 'Tail-lift service', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '10:00', 260000, 46800),
    ('TS09HY2001', 'TS09-2021-7788123', NULL, 'SPD', 'lodging', 'Night halt - Ongole', (current_date - INTERVAL '11 days')::timestamptz + INTERVAL '21:30', 135000, 24300),
    ('KA02BX3001', 'KA02-2019-3344556', NULL, 'VFE', 'repair', 'Brake pad change', (current_date - INTERVAL '7 days')::timestamptz + INTERVAL '14:00', 185000, 33300),
    ('TS07CX4001', 'TS09-2017-9988776', NULL, 'SPD', 'parking', 'Yard parking', (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '19:00', 7000, 1260),
    ('KA01AX1001', 'KA01-2020-4501234', NULL, 'MAP', 'toll', 'Monthly FASTag top-up', (current_date - INTERVAL '3 days')::timestamptz + INTERVAL '08:00', 500000, 90000),
    ('KA01AX1002', 'KA02-2019-3344556', NULL, 'DMC', 'parking', 'Warehouse parking pass', (current_date - INTERVAL '1 day')::timestamptz + INTERVAL '18:00', 12000, 2160)
  ) AS e(reg_no, driver_license, trip_no, customer_code, expense_type, description, incurred_at, amount_paise, gst_amount_paise)
  LEFT JOIN vehicle_map v ON v.reg_no = e.reg_no
  LEFT JOIN driver_map d ON d.license_no = e.driver_license
  LEFT JOIN trip_map t ON t.trip_no = e.trip_no
  LEFT JOIN customer_map c ON c.code = e.customer_code
  RETURNING expense_log_id
)
SELECT 'OrgA fuel & expenses seeded' AS status;

-- Maintenance
WITH vehicle_map AS (
  SELECT reg_no, vehicle_id FROM vehicles WHERE org_id = current_org_id()
), plan_rows AS (
  INSERT INTO maintenance_plans (org_id, vehicle_id, name, interval_km, interval_days, last_service_at, last_service_odometer_km, notes)
  SELECT
    current_org_id(),
    v.vehicle_id,
    p.name,
    p.interval_km,
    p.interval_days,
    p.last_service_at,
    p.last_service_odometer_km,
    p.notes
  FROM (VALUES
    ('KA01AX1001', 'Engine oil & filters', 12000.0, 90, (current_date - INTERVAL '60 days')::timestamptz, 94000.0, 'Semi-synthetic oil'),
    ('KA01AX1002', 'Brake inspection', 8000.0, NULL, (current_date - INTERVAL '45 days')::timestamptz, 57000.0, 'Pad thickness check'),
    ('TS09HY2001', 'Coolant change', 15000.0, 180, (current_date - INTERVAL '80 days')::timestamptz, 122000.0, 'Long haul coolant'),
    ('KA02BX3001', 'General service', 10000.0, 120, (current_date - INTERVAL '70 days')::timestamptz, 82000.0, 'Minor dents noted'),
    ('TS07CX4001', 'PUC renewal reminder', NULL, 180, (current_date - INTERVAL '150 days')::timestamptz, 40000.0, 'Align with PUC renewal')
  ) AS p(reg_no, name, interval_km, interval_days, last_service_at, last_service_odometer_km, notes)
  JOIN vehicle_map v ON v.reg_no = p.reg_no
  RETURNING maintenance_plan_id, vehicle_id, name
), ticket_rows AS (
  INSERT INTO maintenance_tickets (org_id, vehicle_id, maintenance_plan_id, opened_at, closed_at, status, issue_summary, issue_detail, odometer_km, cost_estimate_paise, actual_cost_paise)
  SELECT
    current_org_id(),
    v.vehicle_id,
    p.maintenance_plan_id,
    t.opened_at,
    t.closed_at,
    t.status::ticket_status,
    t.issue_summary,
    t.issue_detail,
    t.odometer_km,
    t.cost_estimate_paise,
    t.actual_cost_paise
  FROM (VALUES
    ('KA01AX1001', 'Engine oil & filters', (current_date - INTERVAL '14 days')::timestamptz, NULL, 'in_progress', 'Engine oil due', 'Schedule oil + filter change', 99000.0, 850000, NULL),
    ('KA01AX1002', 'Brake inspection', (current_date - INTERVAL '20 days')::timestamptz, (current_date - INTERVAL '18 days')::timestamptz, 'completed', 'Front brake squeal', 'Pads replaced', 60000.0, 420000, 430000),
    ('TS09HY2001', 'Coolant change', (current_date - INTERVAL '25 days')::timestamptz, NULL, 'open', 'Coolant level low', 'Flush + refill coolant', 128000.0, 380000, NULL),
    ('KA02BX3001', 'General service', (current_date - INTERVAL '10 days')::timestamptz, NULL, 'in_progress', 'Minor dent repair', 'Left door dent from dock', 84500.0, 260000, NULL),
    ('TS07CX4001', 'PUC renewal reminder', (current_date - INTERVAL '5 days')::timestamptz, NULL, 'open', 'PUC expiring soon', 'Renew PUC certificate', 43000.0, 50000, NULL),
    ('KA01AX1001', NULL, (current_date - INTERVAL '40 days')::timestamptz, (current_date - INTERVAL '35 days')::timestamptz, 'completed', 'Tyre rotation', 'Rotation + balancing', 97000.0, 150000, 148000),
    ('TS09HY2001', NULL, (current_date - INTERVAL '12 days')::timestamptz, NULL, 'open', 'Check engine light', 'Diagnostics required', 129000.0, 300000, NULL),
    ('KA02BX3001', NULL, (current_date - INTERVAL '3 days')::timestamptz, NULL, 'open', 'AC not cooling', 'Gas top-up and leak test', 84600.0, 180000, NULL)
  ) AS t(reg_no, plan_name, opened_at, closed_at, status, issue_summary, issue_detail, odometer_km, cost_estimate_paise, actual_cost_paise)
  JOIN vehicle_map v ON v.reg_no = t.reg_no
  LEFT JOIN plan_rows p ON p.name = t.plan_name AND p.vehicle_id = v.vehicle_id
  RETURNING maintenance_ticket_id
), item_rows AS (
  INSERT INTO maintenance_items (org_id, maintenance_ticket_id, description, quantity, unit_cost_paise, total_cost_paise)
  SELECT
    current_org_id(),
    mt.maintenance_ticket_id,
    i.description,
    i.quantity,
    i.unit_cost_paise,
    (i.quantity * i.unit_cost_paise)::bigint
  FROM ticket_rows mt
  JOIN (
    VALUES
      ('Engine oil due', 'Engine oil 15W40', 1.0, 420000),
      ('Engine oil due', 'Oil filter', 1.0, 120000),
      ('Engine oil due', 'Labour', 1.0, 180000),
      ('Front brake squeal', 'Brake pads front set', 1.0, 280000),
      ('Front brake squeal', 'Brake fluid', 1.0, 45000),
      ('Front brake squeal', 'Labour', 1.0, 105000),
      ('Coolant level low', 'Coolant concentrate', 1.0, 220000),
      ('Coolant level low', 'Distilled water', 1.0, 30000),
      ('Coolant level low', 'Labour', 1.0, 130000),
      ('Minor dent repair', 'Dent pulling and paint', 1.0, 210000),
      ('Minor dent repair', 'Door beading', 1.0, 25000),
      ('Minor dent repair', 'Labour', 1.0, 55000),
      ('PUC expiring soon', 'PUC certificate', 1.0, 50000),
      ('Tyre rotation', 'Wheel balancing', 1.0, 70000),
      ('Tyre rotation', 'Weights and consumables', 1.0, 18000),
      ('Check engine light', 'Diagnostic scan', 1.0, 65000),
      ('Check engine light', 'Sensor check', 1.0, 45000),
      ('AC not cooling', 'Refrigerant gas', 1.0, 90000),
      ('AC not cooling', 'Leak test', 1.0, 40000),
      ('AC not cooling', 'Labour', 1.0, 50000)
  ) AS i(issue_summary, description, quantity, unit_cost_paise)
    ON mt.issue_summary = i.issue_summary
)
SELECT 'OrgA maintenance seeded' AS status;

-- Documents & compliance
WITH doc_type_rows AS (
  INSERT INTO doc_types (org_id, name, entity_type, validity_days)
  VALUES
    (current_org_id(), 'rc', 'vehicle', 3650),
    (current_org_id(), 'insurance', 'vehicle', 365),
    (current_org_id(), 'permit', 'vehicle', 365),
    (current_org_id(), 'fitness', 'vehicle', 365),
    (current_org_id(), 'puc', 'vehicle', 180),
    (current_org_id(), 'tax_receipt', 'vehicle', 365),
    (current_org_id(), 'driver_license', 'driver', 1825)
  RETURNING doc_type_id, name, entity_type
), vehicle_map AS (
  SELECT reg_no, vehicle_id FROM vehicles WHERE org_id = current_org_id()
), driver_map AS (
  SELECT license_no, driver_id, full_name FROM drivers WHERE org_id = current_org_id()
), doc_rows AS (
  INSERT INTO documents (org_id, doc_type_id, entity_type, entity_id, file_url, file_name, mime_type, size_bytes, issued_date, expiry_date, metadata)
  SELECT
    current_org_id(),
    dt.doc_type_id,
    d.entity_type,
    d.entity_id,
    d.file_url,
    d.file_name,
    'application/pdf',
    d.size_bytes,
    d.issued_date,
    d.expiry_date,
    d.metadata
  FROM (
    VALUES
      ('rc', 'vehicle', 'KA01AX1001', 's3://fleet-docs/orgA/vehicles/KA01AX1001/rc.pdf', 'KA01AX1001_RC.pdf', 102400, (current_date - INTERVAL '600 days')::date, (current_date + INTERVAL '900 days')::date, jsonb_build_object('state', 'KA')),
      ('insurance', 'vehicle', 'KA01AX1001', 's3://fleet-docs/orgA/vehicles/KA01AX1001/insurance.pdf', 'KA01AX1001_INS.pdf', 98400, (current_date - INTERVAL '200 days')::date, (current_date + INTERVAL '30 days')::date, jsonb_build_object('insurer', 'ICICI Lombard')),
      ('permit', 'vehicle', 'KA01AX1001', 's3://fleet-docs/orgA/vehicles/KA01AX1001/permit.pdf', 'KA01AX1001_PERMIT.pdf', 90500, (current_date - INTERVAL '250 days')::date, (current_date + INTERVAL '120 days')::date, jsonb_build_object('type', 'National')),
      ('fitness', 'vehicle', 'KA01AX1002', 's3://fleet-docs/orgA/vehicles/KA01AX1002/fitness.pdf', 'KA01AX1002_FIT.pdf', 88400, (current_date - INTERVAL '400 days')::date, (current_date + INTERVAL '25 days')::date, jsonb_build_object('center', 'KA RTO')),
      ('puc', 'vehicle', 'KA01AX1002', 's3://fleet-docs/orgA/vehicles/KA01AX1002/puc.pdf', 'KA01AX1002_PUC.pdf', 64000, (current_date - INTERVAL '120 days')::date, (current_date + INTERVAL '50 days')::date, jsonb_build_object('station', 'IOCL PUC')),
      ('insurance', 'vehicle', 'TS09HY2001', 's3://fleet-docs/orgA/vehicles/TS09HY2001/insurance.pdf', 'TS09HY2001_INS.pdf', 100200, (current_date - INTERVAL '250 days')::date, (current_date + INTERVAL '200 days')::date, jsonb_build_object('insurer', 'Tata AIG')),
      ('rc', 'vehicle', 'TS09HY2001', 's3://fleet-docs/orgA/vehicles/TS09HY2001/rc.pdf', 'TS09HY2001_RC.pdf', 105000, (current_date - INTERVAL '800 days')::date, (current_date + INTERVAL '600 days')::date, jsonb_build_object('state', 'TS')),
      ('permit', 'vehicle', 'KA02BX3001', 's3://fleet-docs/orgA/vehicles/KA02BX3001/permit.pdf', 'KA02BX3001_PERMIT.pdf', 87000, (current_date - INTERVAL '220 days')::date, (current_date + INTERVAL '15 days')::date, jsonb_build_object('type', 'City')),
      ('tax_receipt', 'vehicle', 'KA02BX3001', 's3://fleet-docs/orgA/vehicles/KA02BX3001/tax.pdf', 'KA02BX3001_TAX.pdf', 72000, (current_date - INTERVAL '200 days')::date, (current_date + INTERVAL '160 days')::date, jsonb_build_object('amount_paise', 2500000)),
      ('fitness', 'vehicle', 'TS07CX4001', 's3://fleet-docs/orgA/vehicles/TS07CX4001/fitness.pdf', 'TS07CX4001_FIT.pdf', 93000, (current_date - INTERVAL '500 days')::date, (current_date + INTERVAL '10 days')::date, jsonb_build_object('center', 'TS RTO')),
      ('puc', 'vehicle', 'TS07CX4001', 's3://fleet-docs/orgA/vehicles/TS07CX4001/puc.pdf', 'TS07CX4001_PUC.pdf', 58000, (current_date - INTERVAL '150 days')::date, (current_date + INTERVAL '5 days')::date, jsonb_build_object('station', 'BP PUC')),
      ('driver_license', 'driver', 'KA01-2020-4501234', 's3://fleet-docs/orgA/drivers/Sameer_Kulal/license.pdf', 'SAM_KULAL_DL.pdf', 69000, (current_date - INTERVAL '900 days')::date, (current_date + INTERVAL '800 days')::date, jsonb_build_object('state', 'KA')),
      ('driver_license', 'driver', 'TS09-2021-7788123', 's3://fleet-docs/orgA/drivers/Priya_Narang/license.pdf', 'PRIYA_NARANG_DL.pdf', 71000, (current_date - INTERVAL '600 days')::date, (current_date + INTERVAL '400 days')::date, jsonb_build_object('state', 'TS')),
      ('driver_license', 'driver', 'KA02-2019-3344556', 's3://fleet-docs/orgA/drivers/Imran_Sheikh/license.pdf', 'IMRAN_SHEIKH_DL.pdf', 70000, (current_date - INTERVAL '1200 days')::date, (current_date + INTERVAL '200 days')::date, jsonb_build_object('state', 'KA')),
      ('driver_license', 'driver', 'TS09-2017-9988776', 's3://fleet-docs/orgA/drivers/Lakshmi_B/license.pdf', 'LAKSHMI_B_DL.pdf', 69000, (current_date - INTERVAL '2000 days')::date, (current_date + INTERVAL '25 days')::date, jsonb_build_object('state', 'TS'))
  ) AS d(doc_type_name, entity_type, entity_key, file_url, file_name, size_bytes, issued_date, expiry_date, metadata)
  JOIN doc_type_rows dt ON dt.name = d.doc_type_name AND dt.entity_type = d.entity_type
  LEFT JOIN vehicle_map vm ON vm.reg_no = d.entity_key AND d.entity_type = 'vehicle'
  LEFT JOIN driver_map dm ON dm.license_no = d.entity_key AND d.entity_type = 'driver'
  CROSS JOIN LATERAL (
    SELECT CASE WHEN d.entity_type = 'vehicle' THEN vm.vehicle_id ELSE dm.driver_id END AS entity_id
  ) d
)
SELECT 'OrgA documents seeded' AS status;

-- Billing: invoices, lines, payments
WITH customer_map AS (
  SELECT code, customer_id FROM customers WHERE org_id = current_org_id()
), contract_map AS (
  SELECT name, contract_id FROM contracts WHERE org_id = current_org_id()
), invoice_meta AS (
  SELECT * FROM (VALUES
    ('APEX-INV-001', 'UFR', 'Bengaluru metro deliveries', 'issued', current_date - INTERVAL '25 days', current_date - INTERVAL '15 days', 'January city distribution'),
    ('APEX-INV-002', 'DMC', 'Inbound raw material', 'paid', current_date - INTERVAL '23 days', current_date - INTERVAL '13 days', 'Raw material haulage'),
    ('APEX-INV-003', 'SPD', 'Hyderabad pharma lanes', 'overdue', current_date - INTERVAL '22 days', current_date - INTERVAL '5 days', 'Cold chain runs'),
    ('APEX-INV-004', 'CAT', 'Agri bulk (ton-km)', 'issued', current_date - INTERVAL '20 days', current_date - INTERVAL '7 days', 'Harvest season lanes'),
    ('APEX-INV-005', 'MAP', 'Bengaluru metro deliveries', 'paid', current_date - INTERVAL '18 days', current_date - INTERVAL '8 days', 'Appliance distribution'),
    ('APEX-INV-006', 'VFE', 'Agri bulk (ton-km)', 'draft', current_date - INTERVAL '14 days', current_date - INTERVAL '4 days', 'Fashion export shuttles'),
    ('APEX-INV-007', 'SPD', 'Hyderabad pharma lanes', 'issued', current_date - INTERVAL '12 days', current_date + INTERVAL '5 days', 'Mid-month pharma'),
    ('APEX-INV-008', 'DMC', 'Inbound raw material', 'issued', current_date - INTERVAL '10 days', current_date + INTERVAL '7 days', 'Steel consignment'),
    ('APEX-INV-009', 'UFR', 'Bengaluru metro deliveries', 'cancelled', current_date - INTERVAL '8 days', current_date + INTERVAL '12 days', 'Cancelled run'),
    ('APEX-INV-010', 'SPD', 'Hyderabad pharma lanes', 'issued', current_date - INTERVAL '5 days', current_date + INTERVAL '20 days', 'Late-month pharma')
  ) AS v(invoice_no, cust_code, contract_name, status, invoice_date, due_date, notes)
), invoice_line_seed AS (
  SELECT * FROM (VALUES
    ('APEX-INV-001', 'Trip APEX-TR-001 & 004', 2.0, 95000, 18.0),
    ('APEX-INV-001', 'Waiting charges', 1.0, 15000, 18.0),
    ('APEX-INV-002', 'Trip APEX-TR-002', 1.0, 1685000, 18.0),
    ('APEX-INV-002', 'Fuel surcharge', 1.0, 135000, 18.0),
    ('APEX-INV-003', 'Trips APEX-TR-003 & 007', 2.0, 400000, 12.0),
    ('APEX-INV-003', 'Cold chain surcharge', 1.0, 90000, 12.0),
    ('APEX-INV-004', 'Trips APEX-TR-005 & 015', 2.0, 846000, 5.0),
    ('APEX-INV-004', 'Handling charges', 1.0, 55000, 5.0),
    ('APEX-INV-005', 'Trips APEX-TR-008 & 019', 2.0, 190000, 18.0),
    ('APEX-INV-005', 'Toll recovery', 1.0, 45000, 18.0),
    ('APEX-INV-006', 'Trip APEX-TR-012', 1.0, 960000, 5.0),
    ('APEX-INV-006', 'Fuel surcharge', 1.0, 78000, 5.0),
    ('APEX-INV-007', 'Trip APEX-TR-016', 1.0, 738000, 12.0),
    ('APEX-INV-007', 'Insurance markup', 1.0, 52000, 12.0),
    ('APEX-INV-008', 'Trip APEX-TR-017', 1.0, 1685000, 18.0),
    ('APEX-INV-008', 'Loading detain', 1.0, 60000, 18.0),
    ('APEX-INV-009', 'Cancelled trip charge', 1.0, 25000, 18.0),
    ('APEX-INV-010', 'Trip APEX-TR-020 advance', 1.0, 520000, 12.0),
    ('APEX-INV-010', 'Fuel surcharge', 1.0, 45000, 12.0),
    ('APEX-INV-010', 'GST adjustment', 1.0, 5000, 12.0),
    ('APEX-INV-003', 'Late night handling', 1.0, 30000, 12.0),
    ('APEX-INV-004', 'Demurrage', 1.0, 22000, 5.0),
    ('APEX-INV-005', 'Express delivery premium', 1.0, 32000, 18.0),
    ('APEX-INV-001', 'Fuel surcharge', 1.0, 18000, 18.0),
    ('APEX-INV-008', 'Fuel surcharge', 1.0, 95000, 18.0)
  ) AS v(invoice_no, description, quantity, unit_price_paise, tax_rate)
), invoice_totals AS (
  SELECT
    invoice_no,
    SUM(quantity * unit_price_paise)::bigint AS subtotal_paise,
    SUM(ROUND(quantity * unit_price_paise * tax_rate / 100.0))::bigint AS tax_paise
  FROM invoice_line_seed
  GROUP BY invoice_no
), invoice_rows AS (
  INSERT INTO invoices (org_id, customer_id, contract_id, invoice_no, invoice_date, due_date, status, subtotal_paise, tax_paise, total_paise, notes)
  SELECT
    current_org_id(),
    c.customer_id,
    ct.contract_id,
    m.invoice_no,
    m.invoice_date::date,
    m.due_date::date,
    m.status::invoice_status,
    t.subtotal_paise,
    t.tax_paise,
    t.subtotal_paise + t.tax_paise,
    m.notes
  FROM invoice_meta m
  JOIN customer_map c ON c.code = m.cust_code
  JOIN contract_map ct ON ct.name = m.contract_name
  JOIN invoice_totals t ON t.invoice_no = m.invoice_no
  RETURNING invoice_id, invoice_no
), invoice_line_rows AS (
  INSERT INTO invoice_lines (org_id, invoice_id, description, quantity, unit_price_paise, tax_rate, amount_paise, tax_amount_paise)
  SELECT
    current_org_id(),
    ir.invoice_id,
    ils.description,
    ils.quantity,
    ils.unit_price_paise,
    ils.tax_rate,
    (ils.quantity * ils.unit_price_paise)::bigint,
    ROUND(ils.quantity * ils.unit_price_paise * ils.tax_rate / 100.0)::bigint
  FROM invoice_line_seed ils
  JOIN invoice_rows ir ON ir.invoice_no = ils.invoice_no
  RETURNING invoice_line_id, invoice_id
), payment_rows AS (
  INSERT INTO payments (org_id, invoice_id, payment_date, amount_paise, method, reference_no, received_by)
  SELECT
    current_org_id(),
    ir.invoice_id,
    p.payment_date,
    p.amount_paise,
    p.method,
    p.reference_no,
    p.received_by
  FROM (VALUES
    ('APEX-INV-001', current_date - INTERVAL '12 days', 600000, 'neft', 'UTRAPEX001', 'Sanjay Menon'),
    ('APEX-INV-002', current_date - INTERVAL '15 days', 1820000, 'neft', 'UTRAPEX002', 'Sanjay Menon'),
    ('APEX-INV-003', current_date - INTERVAL '10 days', 350000, 'upi', 'APEX003UPI', 'Ananya Iyer'),
    ('APEX-INV-004', current_date - INTERVAL '6 days', 500000, 'cash', 'CASH-APEX004', 'Meena Kulkarni'),
    ('APEX-INV-005', current_date - INTERVAL '7 days', 430000, 'upi', 'APEX005UPI', 'Sanjay Menon'),
    ('APEX-INV-005', current_date - INTERVAL '5 days', 320000, 'upi', 'APEX005UPI2', 'Sanjay Menon'),
    ('APEX-INV-006', current_date - INTERVAL '3 days', 200000, 'upi', 'APEX006UPI', 'Meena Kulkarni'),
    ('APEX-INV-007', current_date - INTERVAL '2 days', 250000, 'neft', 'UTRAPEX007', 'Ananya Iyer'),
    ('APEX-INV-008', current_date - INTERVAL '1 day', 600000, 'neft', 'UTRAPEX008', 'Sanjay Menon'),
    ('APEX-INV-002', current_date - INTERVAL '14 days', 150000, 'cash', 'CASH-APEX002', 'Rohit Shetty'),
    ('APEX-INV-003', current_date - INTERVAL '2 days', 125000, 'upi', 'APEX003UPI2', 'Priya Narang'),
    ('APEX-INV-010', current_date - INTERVAL '1 day', 200000, 'upi', 'APEX010UPI', 'Meena Kulkarni')
  ) AS p(invoice_no, payment_date, amount_paise, method, reference_no, received_by)
  JOIN invoice_rows ir ON ir.invoice_no = p.invoice_no
  RETURNING payment_id
)
SELECT 'OrgA billing seeded' AS status;

-- Notifications & audit log
WITH doc_map AS (
  SELECT file_name, document_id FROM documents WHERE org_id = current_org_id()
), invoice_map AS (
  SELECT invoice_no, invoice_id FROM invoices WHERE org_id = current_org_id()
), ticket_map AS (
  SELECT issue_summary, maintenance_ticket_id FROM maintenance_tickets WHERE org_id = current_org_id()
), notification_rows AS (
  INSERT INTO notifications (org_id, entity_type, entity_id, channel, status, send_after, sent_at, payload)
  SELECT
    current_org_id(),
    n.entity_type,
    n.entity_id,
    n.channel::notification_channel,
    n.status::notification_status,
    n.send_after,
    n.sent_at,
    n.payload
  FROM (VALUES
    ('document', (SELECT document_id FROM doc_map WHERE file_name = 'KA01AX1002_FIT.pdf'), 'email', 'scheduled', current_timestamp - INTERVAL '1 day', NULL, jsonb_build_object('type', 'DOC_EXPIRY', 'days_remaining', 25)),
    ('document', (SELECT document_id FROM doc_map WHERE file_name = 'TS07CX4001_PUC.pdf'), 'sms', 'scheduled', current_timestamp - INTERVAL '2 days', NULL, jsonb_build_object('type', 'DOC_EXPIRY', 'days_remaining', 5)),
    ('invoice', (SELECT invoice_id FROM invoice_map WHERE invoice_no = 'APEX-INV-003'), 'email', 'sent', current_timestamp - INTERVAL '10 days', current_timestamp - INTERVAL '9 days', jsonb_build_object('type', 'INVOICE_DUE')),
    ('invoice', (SELECT invoice_id FROM invoice_map WHERE invoice_no = 'APEX-INV-007'), 'push', 'scheduled', current_timestamp + INTERVAL '1 day', NULL, jsonb_build_object('type', 'INVOICE_DUE')),
    ('maintenance_ticket', (SELECT maintenance_ticket_id FROM ticket_map WHERE issue_summary = 'Engine oil due'), 'email', 'pending', current_timestamp, NULL, jsonb_build_object('type', 'MAINT_DUE')),
    ('maintenance_ticket', (SELECT maintenance_ticket_id FROM ticket_map WHERE issue_summary = 'Coolant level low'), 'sms', 'scheduled', current_timestamp + INTERVAL '2 days', NULL, jsonb_build_object('type', 'MAINT_DUE')),
    ('document', (SELECT document_id FROM doc_map WHERE file_name = 'KA02BX3001_PERMIT.pdf'), 'email', 'sent', current_timestamp - INTERVAL '12 days', current_timestamp - INTERVAL '12 days', jsonb_build_object('type', 'DOC_EXPIRY')),
    ('document', (SELECT document_id FROM doc_map WHERE file_name = 'LAKSHMI_B_DL.pdf'), 'email', 'scheduled', current_timestamp, NULL, jsonb_build_object('type', 'DOC_EXPIRY', 'days_remaining', 25)),
    ('invoice', (SELECT invoice_id FROM invoice_map WHERE invoice_no = 'APEX-INV-001'), 'email', 'sent', current_timestamp - INTERVAL '20 days', current_timestamp - INTERVAL '19 days', jsonb_build_object('type', 'INVOICE_DUE')),
    ('invoice', (SELECT invoice_id FROM invoice_map WHERE invoice_no = 'APEX-INV-010'), 'push', 'scheduled', current_timestamp + INTERVAL '5 days', NULL, jsonb_build_object('type', 'INVOICE_DUE'))
  ) AS n(entity_type, entity_id, channel, status, send_after, sent_at, payload)
  RETURNING notification_id
), audit_rows AS (
  INSERT INTO audit_log (org_id, user_id, action, entity_type, entity_id, request_id, ip_address, created_at, payload)
  SELECT
    current_org_id(),
    (SELECT user_id FROM users WHERE email = 'ananya.iyer@apexlogistics.in'),
    'trip_completed',
    'trip',
    (SELECT trip_id FROM trips WHERE trip_no = 'APEX-TR-019'),
    'req-apex-001',
    '203.0.113.10',
    current_timestamp,
    jsonb_build_object('status', 'completed', 'notes', 'Auto seeded')
)
SELECT 'OrgA notifications & audit seeded' AS status;

-------------------------------------------------------------------------------
-- OrgB: Bharat Transport Services (India)
-------------------------------------------------------------------------------
SELECT set_tenant('22222222-2222-2222-2222-222222222222', NULL);

WITH org_row AS (
  INSERT INTO orgs (org_id, name, legal_name, code, gstin, timezone, settings_jsonb)
  VALUES (
    current_org_id(),
    'Bharat Transport Services',
    'Bharat Transport Services',
    'BTS',
    '27BBBBB0000B1Z6',
    'Asia/Kolkata',
    jsonb_build_object('timezone', 'Asia/Kolkata', 'demo', true)
  )
  ON CONFLICT (org_id) DO UPDATE
    SET name = EXCLUDED.name,
        legal_name = EXCLUDED.legal_name,
        code = EXCLUDED.code,
        gstin = EXCLUDED.gstin,
        timezone = EXCLUDED.timezone,
        settings_jsonb = EXCLUDED.settings_jsonb
  RETURNING org_id
), branch_rows AS (
  INSERT INTO branches (org_id, name, code, address, timezone)
  VALUES
    (current_org_id(), 'Pune Hub', 'PUN', 'Chakan MIDC, Pune, MH', 'Asia/Kolkata'),
    (current_org_id(), 'Chennai Hub', 'CHE', 'Oragadam Industrial Area, Chennai, TN', 'Asia/Kolkata')
  RETURNING branch_id, code
), role_rows AS (
  INSERT INTO roles (org_id, name, description, is_system)
  VALUES
    (current_org_id(), 'admin', 'Full administration', TRUE),
    (current_org_id(), 'manager', 'Branch/ops manager', FALSE),
    (current_org_id(), 'operator', 'Dispatch operator', FALSE),
    (current_org_id(), 'accountant', 'Billing and payments', FALSE),
    (current_org_id(), 'driver_view', 'Read-only driver portal', FALSE)
  RETURNING role_id, name
), perm_rows AS (
  INSERT INTO permissions (org_id, code, description)
  VALUES
    (current_org_id(), 'fleet.manage', 'Manage fleet'),
    (current_org_id(), 'trips.manage', 'Manage trips'),
    (current_org_id(), 'billing.manage', 'Manage billing'),
    (current_org_id(), 'maintenance.manage', 'Maintenance'),
    (current_org_id(), 'docs.manage', 'Compliance docs')
  RETURNING permission_id, code
), role_perm_rows AS (
  INSERT INTO role_permissions (org_id, role_id, permission_id)
  SELECT current_org_id(), r.role_id, p.permission_id
  FROM role_rows r
  JOIN perm_rows p ON p.code IN ('fleet.manage', 'trips.manage', 'billing.manage', 'maintenance.manage', 'docs.manage')
  WHERE r.name = 'admin'
  UNION ALL
  SELECT current_org_id(), r.role_id, p.permission_id FROM role_rows r JOIN perm_rows p ON p.code IN ('fleet.manage', 'trips.manage') WHERE r.name = 'manager'
  UNION ALL
  SELECT current_org_id(), r.role_id, p.permission_id FROM role_rows r JOIN perm_rows p ON p.code IN ('trips.manage') WHERE r.name = 'operator'
  UNION ALL
  SELECT current_org_id(), r.role_id, p.permission_id FROM role_rows r JOIN perm_rows p ON p.code IN ('billing.manage') WHERE r.name = 'accountant'
  UNION ALL
  SELECT current_org_id(), r.role_id, p.permission_id FROM role_rows r JOIN perm_rows p ON p.code IN ('trips.manage') WHERE r.name = 'driver_view'
), user_rows AS (
  INSERT INTO users (org_id, branch_id, full_name, email, phone, is_active)
  SELECT
    current_org_id(),
    b.branch_id,
    u.full_name,
    u.email,
    u.phone,
    TRUE
  FROM (VALUES
    ('Pune Hub', 'Neha Patil', 'neha.patil@bharattransport.in', '+919223300101', 'PUN'),
    ('Pune Hub', 'Siddharth Joshi', 'siddharth.joshi@bharattransport.in', '+919223300102', 'PUN'),
    ('Chennai Hub', 'Vignesh Ravi', 'vignesh.ravi@bharattransport.in', '+919223300103', 'CHE'),
    ('Pune Hub', 'Aditi Kulkarni', 'aditi.kulkarni@bharattransport.in', '+919223300104', 'PUN'),
    ('Chennai Hub', 'Harish Kumar', 'harish.kumar@bharattransport.in', '+919223300105', 'CHE')
  ) AS u(branch_name, full_name, email, phone, branch_code)
  JOIN branch_rows b ON b.code = u.branch_code
  RETURNING user_id, email
), user_role_rows AS (
  INSERT INTO user_roles (org_id, user_id, role_id)
  SELECT current_org_id(), u.user_id, r.role_id
  FROM user_rows u
  JOIN role_rows r ON (
    (u.email LIKE 'neha.patil%' AND r.name = 'admin') OR
    (u.email LIKE 'siddharth.joshi%' AND r.name = 'manager') OR
    (u.email LIKE 'vignesh.ravi%' AND r.name = 'operator') OR
    (u.email LIKE 'aditi.kulkarni%' AND r.name = 'accountant') OR
    (u.email LIKE 'harish.kumar%' AND r.name = 'driver_view')
  )
), customer_rows AS (
  INSERT INTO customers (org_id, name, code, email, phone, gstin, billing_address, shipping_address)
  VALUES
    (current_org_id(), 'Western Auto Parts', 'WAP', 'ap@westernauto.in', '+919820110001', '27AAACW5555F1Z7', 'Chakan, Pune', 'Hinjewadi, Pune'),
    (current_org_id(), 'Sahyadri Foods', 'SHF', 'finance@sahyadrifoods.in', '+919820110002', '27AAACS6666G1Z8', 'Baner, Pune', 'Kothrud, Pune'),
    (current_org_id(), 'Delta Steel Ltd', 'DSL', 'billing@deltasteel.in', '+919820110003', '27AAACD7777H1Z9', 'Khopoli, Maharashtra', 'Waluj, Aurangabad'),
    (current_org_id(), 'Coromandel Textiles', 'CTX', 'accounts@corotex.in', '+919820110004', '33AAACC8888I1Z5', 'Ambattur, Chennai', 'Sriperumbudur, TN'),
    (current_org_id(), 'Bright Electronics', 'BEL', 'ap@brightelec.in', '+919820110005', NULL, 'Tambaram, Chennai', 'Tiruvallur, TN'),
    (current_org_id(), 'Maratha Cement', 'MRC', 'billing@marathacement.in', '+919820110006', '27AAACM9999J1Z2', 'Solapur, MH', 'Chakan, Pune')
  RETURNING customer_id, code
), contract_rows AS (
  INSERT INTO contracts (org_id, customer_id, name, start_date, end_date, rate_jsonb, base_rate_paise, notes)
  SELECT
    current_org_id(),
    c.customer_id,
    r.contract_name,
    r.start_dt,
    NULL,
    jsonb_build_object(
      'rate_type', r.rate_type,
      'base_rate_paise', r.base_rate,
      'fuel_surcharge_pct', r.fuel_pct,
      'gst_pct', r.gst_pct
    ),
    r.base_rate,
    r.notes
  FROM customer_rows c
  JOIN (
    VALUES
      ('WAP', 'Auto parts shuttles', 'per_km', 2050, 7, 18, 'JIT parts delivery', '2024-12-01'::date),
      ('DSL', 'Steel coils', 'per_ton_km', 1200, 8, 18, 'Heavy haul', '2024-11-15'::date),
      ('SHF', 'Food distribution', 'per_trip', 280000, 6, 12, 'Fresh food B2B', '2024-12-10'::date),
      ('CTX', 'Textile rolls', 'per_km', 1900, 9, 12, 'Chennai metro + TN', '2024-12-05'::date)
  ) AS r(cust_code, contract_name, rate_type, base_rate, fuel_pct, gst_pct, notes, start_dt)
    ON c.code = r.cust_code
  RETURNING contract_id, name, customer_id
)
SELECT 'OrgB core seeded' AS status;

-- Fleet for OrgB
WITH branch_map AS (
  SELECT code, branch_id FROM branches WHERE org_id = current_org_id()
), vehicle_rows AS (
  INSERT INTO vehicles (org_id, branch_id, reg_no, vin, make, model, year, fuel_type, capacity_kg, status, purchase_date, current_odometer_km, insurance_expiry)
  SELECT current_org_id(), b.branch_id, v.*
  FROM branch_map b
  JOIN (VALUES
    ('PUN', 'MH12BT1001', 'BTSVINPUNE01', 'Tata', 'Signa 2823', 2022, 'diesel', 28000, 'active', '2022-03-15'::date, 102300.0, '2025-11-20'::date),
    ('PUN', 'MH14BT2002', 'BTSVINPUNE02', 'BharatBenz', '1217C', 2021, 'diesel', 12000, 'maintenance', '2021-05-10'::date, 90500.0, '2025-09-15'::date),
    ('CHE', 'TN11BT3003', 'BTSVINCHEN01', 'Ashok Leyland', 'Boss 1115', 2023, 'diesel', 15000, 'active', '2023-02-18'::date, 52300.0, '2025-12-05'::date),
    ('CHE', 'TN09BT4004', 'BTSVINCHEN02', 'Eicher', 'Pro 2110', 2020, 'diesel', 9500, 'active', '2020-10-01'::date, 134500.0, '2025-07-12'::date),
    ('PUN', 'MH12BT5005', 'BTSVINPUNE03', 'Mahindra', 'Blazo X', 2019, 'diesel', 18000, 'inactive', '2019-07-20'::date, 188200.0, '2025-04-10'::date)
  ) AS v(branch_code, reg_no, vin, make, model, year, fuel_type, capacity_kg, status, purchase_date, current_odometer_km, insurance_expiry)
    ON b.code = v.branch_code
  RETURNING vehicle_id, reg_no, branch_id
), driver_rows AS (
  INSERT INTO drivers (org_id, branch_id, full_name, license_no, phone, status, joined_at)
  SELECT current_org_id(), b.branch_id, d.full_name, d.license_no, d.phone, d.status, d.joined_at
  FROM branch_map b
  JOIN (VALUES
    ('PUN', 'Rahul Deshpande', 'MH12-2019-5558881', '+919820990201', 'active', '2019-11-10'::date),
    ('PUN', 'Swapnil Shinde', 'MH14-2020-3332221', '+919820990202', 'active', '2020-07-01'::date),
    ('CHE', 'Suresh Kumar', 'TN11-2018-7776661', '+919820990203', 'active', '2018-03-18'::date),
    ('CHE', 'Arun Prakash', 'TN09-2017-1114441', '+919820990204', 'inactive', '2017-06-25'::date),
    ('PUN', 'Jayant Jadhav', 'MH12-2021-9990001', '+919820990205', 'active', '2021-09-05'::date),
    ('CHE', 'Deepa Krishnan', 'TN11-2022-5557771', '+919820990206', 'suspended', '2022-02-10'::date)
  ) AS d(branch_code, full_name, license_no, phone, status, joined_at)
    ON b.code = d.branch_code
  RETURNING driver_id, license_no
), assignment_rows AS (
  INSERT INTO assignments (org_id, vehicle_id, driver_id, start_at, end_at, notes)
  SELECT current_org_id(), v.vehicle_id, d.driver_id, a.start_at, a.end_at, a.notes
  FROM vehicle_rows v
  JOIN driver_rows d ON d.license_no = a.driver_license
  JOIN (
    VALUES
      ('MH12BT1001', 'MH12-2019-5558881', (current_date - INTERVAL '36 days')::timestamptz + INTERVAL '04:00', NULL, 'Lead driver'),
      ('MH14BT2002', 'MH14-2020-3332221', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '05:00', NULL, 'Long haul MH'),
      ('TN11BT3003', 'TN11-2018-7776661', (current_date - INTERVAL '30 days')::timestamptz + INTERVAL '06:00', NULL, 'South lanes'),
      ('TN09BT4004', 'TN09-2017-1114441', (current_date - INTERVAL '200 days')::timestamptz + INTERVAL '07:00', (current_date - INTERVAL '80 days')::timestamptz + INTERVAL '18:00', 'Historical'),
      ('TN09BT4004', 'TN11-2022-5557771', (current_date - INTERVAL '75 days')::timestamptz + INTERVAL '08:00', NULL, 'Relief driver'),
      ('MH12BT5005', 'MH12-2021-9990001', (current_date - INTERVAL '50 days')::timestamptz + INTERVAL '09:00', NULL, 'Spare vehicle'),
      ('MH12BT1001', 'MH14-2020-3332221', (current_date - INTERVAL '120 days')::timestamptz + INTERVAL '06:00', (current_date - INTERVAL '60 days')::timestamptz + INTERVAL '12:00', 'Historic swap'),
      ('TN11BT3003', 'TN09-2017-1114441', (current_date - INTERVAL '90 days')::timestamptz + INTERVAL '07:00', (current_date - INTERVAL '60 days')::timestamptz + INTERVAL '10:00', 'Historic backup')
  ) AS a(reg_no, driver_license, start_at, end_at, notes)
    ON v.reg_no = a.reg_no AND d.license_no = a.driver_license
  RETURNING assignment_id
), odo_rows AS (
  INSERT INTO odometer_logs (org_id, vehicle_id, reading_km, recorded_at, source)
  SELECT current_org_id(), v.vehicle_id, o.reading_km, o.recorded_at, 'device'
  FROM vehicle_rows v
  JOIN (
    VALUES
      ('MH12BT1001', 99500.0, (current_date - INTERVAL '30 days')::timestamptz + INTERVAL '06:00'),
      ('MH12BT1001', 102100.0, (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '06:30'),
      ('MH14BT2002', 88000.0, (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '07:00'),
      ('MH14BT2002', 90700.0, (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '07:45'),
      ('TN11BT3003', 49800.0, (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '08:00'),
      ('TN11BT3003', 52400.0, (current_date - INTERVAL '3 days')::timestamptz + INTERVAL '08:40'),
      ('TN09BT4004', 131000.0, (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '09:20'),
      ('TN09BT4004', 134700.0, (current_date - INTERVAL '2 days')::timestamptz + INTERVAL '09:50'),
      ('MH12BT5005', 186000.0, (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '10:20'),
      ('MH12BT5005', 188100.0, (current_date - INTERVAL '1 day')::timestamptz + INTERVAL '10:40')
  ) AS o(reg_no, reading_km, recorded_at)
    ON v.reg_no = o.reg_no
)
SELECT 'OrgB fleet seeded' AS status;

-- Trips for OrgB
WITH vehicle_map AS (
  SELECT reg_no, vehicle_id FROM vehicles WHERE org_id = current_org_id()
), driver_map AS (
  SELECT license_no, driver_id FROM drivers WHERE org_id = current_org_id()
), customer_map AS (
  SELECT code, customer_id FROM customers WHERE org_id = current_org_id()
), contract_map AS (
  SELECT name, contract_id FROM contracts WHERE org_id = current_org_id()
), trip_rows AS (
  INSERT INTO trips (org_id, trip_no, vehicle_id, driver_id, customer_id, contract_id, start_at, planned_end_at, end_at, origin, destination, distance_km, status, revenue_paise)
  SELECT
    current_org_id(),
    t.trip_no,
    v.vehicle_id,
    d.driver_id,
    c.customer_id,
    ct.contract_id,
    t.start_at,
    t.planned_end_at,
    t.end_at,
    t.origin,
    t.destination,
    t.distance_km,
    t.status::trip_status,
    t.revenue_paise
  FROM (VALUES
    ('BTS-TR-001', 'MH12BT1001', 'MH12-2019-5558881', 'WAP', 'Auto parts shuttles', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '05:00', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '12:00', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '11:30', 'Chakan', 'Hinjewadi', 65.0, 'completed', 210000),
    ('BTS-TR-002', 'MH14BT2002', 'MH14-2020-3332221', 'DSL', 'Steel coils', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '06:00', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '18:00', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '17:20', 'Khopoli', 'Waluj', 330.0, 'completed', 1188000),
    ('BTS-TR-003', 'TN11BT3003', 'TN11-2018-7776661', 'CTX', 'Textile rolls', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '07:00', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '13:00', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '12:40', 'Ambattur', 'Sriperumbudur', 55.0, 'completed', 150000),
    ('BTS-TR-004', 'TN09BT4004', 'TN11-2022-5557771', 'CTX', 'Textile rolls', (current_date - INTERVAL '29 days')::timestamptz + INTERVAL '08:00', (current_date - INTERVAL '29 days')::timestamptz + INTERVAL '14:00', (current_date - INTERVAL '29 days')::timestamptz + INTERVAL '13:50', 'Ambattur', 'Tiruvallur', 48.0, 'completed', 138000),
    ('BTS-TR-005', 'MH12BT5005', 'MH12-2021-9990001', 'SHF', 'Food distribution', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:30', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '09:30', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '09:20', 'Baner', 'Kothrud', 22.0, 'completed', 92000),
    ('BTS-TR-006', 'MH12BT1001', 'MH12-2019-5558881', 'DSL', 'Steel coils', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '06:00', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '18:00', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '17:50', 'Waluj', 'Chakan', 330.0, 'completed', 1195000),
    ('BTS-TR-007', 'MH14BT2002', 'MH14-2020-3332221', 'WAP', 'Auto parts shuttles', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '07:00', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '12:00', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '11:40', 'Chakan', 'Ranjangaon', 50.0, 'completed', 196000),
    ('BTS-TR-008', 'TN11BT3003', 'TN11-2018-7776661', 'CTX', 'Textile rolls', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '08:00', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '14:00', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '13:50', 'Sriperumbudur', 'Tambaram', 70.0, 'completed', 165000),
    ('BTS-TR-009', 'TN09BT4004', 'TN11-2022-5557771', 'BEL', 'Textile rolls', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '07:30', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '12:30', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '12:00', 'Tambaram', 'Oragadam', 48.0, 'completed', 140000),
    ('BTS-TR-010', 'MH12BT1001', 'MH12-2019-5558881', 'SHF', 'Food distribution', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:30', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '09:30', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '09:10', 'Baner', 'Wakad', 20.0, 'completed', 88000),
    ('BTS-TR-011', 'MH14BT2002', 'MH14-2020-3332221', 'DSL', 'Steel coils', (current_date - INTERVAL '21 days')::timestamptz + INTERVAL '06:10', (current_date - INTERVAL '21 days')::timestamptz + INTERVAL '18:10', NULL, 'Khopoli', 'Waluj', 330.0, 'in_progress', 1188000),
    ('BTS-TR-012', 'TN11BT3003', 'TN09-2017-1114441', 'CTX', 'Textile rolls', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '07:40', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '13:40', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '13:10', 'Ambattur', 'Sriperumbudur', 55.0, 'completed', 150000),
    ('BTS-TR-013', 'TN09BT4004', 'TN11-2022-5557771', 'BEL', 'Textile rolls', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '08:00', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '12:00', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '11:50', 'Tambaram', 'Guduvanchery', 35.0, 'completed', 120000),
    ('BTS-TR-014', 'MH12BT5005', 'MH12-2021-9990001', 'MRC', 'Food distribution', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '06:20', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '10:20', NULL, 'Solapur', 'Chakan', 260.0, 'in_progress', 620000),
    ('BTS-TR-015', 'MH12BT1001', 'MH14-2020-3332221', 'WAP', 'Auto parts shuttles', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '05:00', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '11:00', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '10:50', 'Chakan', 'Hinjewadi', 65.0, 'completed', 210000),
    ('BTS-TR-016', 'TN11BT3003', 'TN11-2018-7776661', 'CTX', 'Textile rolls', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '07:00', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '13:00', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '12:45', 'Ambattur', 'Pondicherry', 140.0, 'completed', 260000),
    ('BTS-TR-017', 'TN09BT4004', 'TN11-2022-5557771', 'BEL', 'Textile rolls', (current_date - INTERVAL '11 days')::timestamptz + INTERVAL '07:30', (current_date - INTERVAL '11 days')::timestamptz + INTERVAL '12:30', NULL, 'Tambaram', 'Tirupati', 150.0, 'cancelled', 0),
    ('BTS-TR-018', 'MH12BT1001', 'MH12-2019-5558881', 'SHF', 'Food distribution', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '05:30', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '09:30', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '09:10', 'Baner', 'Katraj', 25.0, 'completed', 98000),
    ('BTS-TR-019', 'MH14BT2002', 'MH14-2020-3332221', 'DSL', 'Steel coils', (current_date - INTERVAL '7 days')::timestamptz + INTERVAL '06:00', (current_date - INTERVAL '7 days')::timestamptz + INTERVAL '18:00', NULL, 'Waluj', 'Khopoli', 330.0, 'in_progress', 1188000),
    ('BTS-TR-020', 'TN11BT3003', 'TN11-2018-7776661', 'CTX', 'Textile rolls', (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '08:00', (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '14:00', NULL, 'Sriperumbudur', 'Chengalpattu', 60.0, 'planned', 160000)
  ) AS t(trip_no, reg_no, driver_license, customer_code, contract_name, start_at, planned_end_at, end_at, origin, destination, distance_km, status, revenue_paise)
  JOIN vehicle_map v ON v.reg_no = t.reg_no
  JOIN driver_map d ON d.license_no = t.driver_license
  JOIN customer_map c ON c.code = t.customer_code
  JOIN contract_map ct ON ct.name = t.contract_name
  RETURNING trip_id, trip_no
), stop_rows AS (
  INSERT INTO trip_stops (org_id, trip_id, stop_sequence, location_name, latitude, longitude, planned_at, arrival_at, departure_at)
  SELECT
    current_org_id(), tr.trip_id, s.stop_sequence, s.location_name, s.lat, s.lon, s.planned_at, s.arrival_at, s.departure_at
  FROM trip_rows tr
  JOIN (
    VALUES
      ('BTS-TR-001', 1, 'Load - Chakan', 18.7590, 73.8530, (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '04:40', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '04:45', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '05:05'),
      ('BTS-TR-001', 2, 'Drop - Hinjewadi', 18.5917, 73.7389, (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '11:20', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '11:25', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '11:40'),
      ('BTS-TR-002', 1, 'Load - Khopoli', 18.7851, 73.3458, (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '05:40', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '05:50', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '06:10'),
      ('BTS-TR-002', 2, 'Drop - Waluj', 19.8297, 75.1040, (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '17:10', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '17:15', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '17:30'),
      ('BTS-TR-003', 1, 'Load - Ambattur', 13.1085, 80.1548, (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '06:40', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '06:50', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '07:10'),
      ('BTS-TR-003', 2, 'Drop - Sriperumbudur', 12.9676, 79.9455, (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '12:30', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '12:35', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '12:50'),
      ('BTS-TR-005', 1, 'Load - Baner', 18.5590, 73.7890, (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:10', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:15', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:30'),
      ('BTS-TR-005', 2, 'Drop - Kothrud', 18.5074, 73.8077, (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '09:05', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '09:10', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '09:20'),
      ('BTS-TR-006', 1, 'Load - Waluj', 19.8297, 75.1040, (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '05:40', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '05:50', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '06:10'),
      ('BTS-TR-006', 2, 'Drop - Chakan', 18.7590, 73.8530, (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '17:20', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '17:25', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '17:45'),
      ('BTS-TR-007', 1, 'Load - Chakan', 18.7590, 73.8530, (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '06:40', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '06:45', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '07:05'),
      ('BTS-TR-007', 2, 'Drop - Ranjangaon', 18.6745, 74.3000, (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '11:20', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '11:25', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '11:40'),
      ('BTS-TR-008', 1, 'Load - Sriperumbudur', 12.9676, 79.9455, (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '07:40', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '07:45', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '08:05'),
      ('BTS-TR-008', 2, 'Drop - Tambaram', 12.9229, 80.1275, (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '13:20', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '13:25', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '13:45'),
      ('BTS-TR-009', 1, 'Load - Tambaram', 12.9229, 80.1275, (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '07:10', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '07:15', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '07:35'),
      ('BTS-TR-009', 2, 'Drop - Oragadam', 12.8452, 80.0669, (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '12:00', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '12:05', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '12:20'),
      ('BTS-TR-010', 1, 'Load - Baner', 18.5590, 73.7890, (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:10', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:15', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:30'),
      ('BTS-TR-010', 2, 'Drop - Wakad', 18.5986, 73.7632, (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '09:10', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '09:15', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '09:30'),
      ('BTS-TR-012', 1, 'Load - Ambattur', 13.1085, 80.1548, (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '07:20', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '07:25', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '07:45'),
      ('BTS-TR-012', 2, 'Drop - Sriperumbudur', 12.9676, 79.9455, (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '13:00', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '13:05', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '13:20'),
      ('BTS-TR-013', 1, 'Load - Tambaram', 12.9229, 80.1275, (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '07:20', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '07:25', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '07:40'),
      ('BTS-TR-013', 2, 'Drop - Guduvanchery', 12.8443, 80.0604, (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '11:40', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '11:45', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '12:00'),
      ('BTS-TR-015', 1, 'Load - Chakan', 18.7590, 73.8530, (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '04:40', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '04:45', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '05:05'),
      ('BTS-TR-015', 2, 'Drop - Hinjewadi', 18.5917, 73.7389, (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '10:40', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '10:45', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '11:00'),
      ('BTS-TR-016', 1, 'Load - Ambattur', 13.1085, 80.1548, (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '06:40', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '06:50', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '07:10'),
      ('BTS-TR-016', 2, 'Drop - Pondicherry', 11.9416, 79.8083, (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '12:40', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '12:45', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '13:00'),
      ('BTS-TR-018', 1, 'Load - Baner', 18.5590, 73.7890, (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '05:10', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '05:15', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '05:30'),
      ('BTS-TR-018', 2, 'Drop - Katraj', 18.4570, 73.8670, (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '09:00', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '09:05', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '09:20'),
      ('BTS-TR-020', 1, 'Load - Sriperumbudur', 12.9676, 79.9455, (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '07:40', (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '07:45', (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '08:05'),
      ('BTS-TR-020', 2, 'Drop - Chengalpattu', 12.6920, 79.9775, (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '13:00', NULL, NULL)
  ) AS s(trip_no, stop_sequence, location_name, lat, lon, planned_at, arrival_at, departure_at)
    ON tr.trip_no = s.trip_no
  RETURNING trip_stop_id
), event_rows AS (
  INSERT INTO trip_events (org_id, trip_id, event_type, event_at, payload_jsonb)
  SELECT
    current_org_id(),
    tr.trip_id,
    e.event_type,
    e.event_at,
    e.payload
  FROM trip_rows tr
  JOIN (
    VALUES
      ('BTS-TR-001', 'status_change', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '05:05', jsonb_build_object('status', 'departed')),
      ('BTS-TR-001', 'gps', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '10:00', jsonb_build_object('lat', 18.60, 'lng', 73.80)),
      ('BTS-TR-002', 'status_change', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '06:20', jsonb_build_object('status', 'departed')),
      ('BTS-TR-002', 'gps', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '15:00', jsonb_build_object('lat', 19.20, 'lng', 74.80)),
      ('BTS-TR-003', 'status_change', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '07:10', jsonb_build_object('status', 'departed')),
      ('BTS-TR-003', 'gps', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '10:30', jsonb_build_object('lat', 12.98, 'lng', 80.05)),
      ('BTS-TR-005', 'status_change', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '05:20', jsonb_build_object('status', 'departed')),
      ('BTS-TR-006', 'gps', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '12:00', jsonb_build_object('lat', 18.80, 'lng', 75.10)),
      ('BTS-TR-007', 'status_change', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '06:50', jsonb_build_object('status', 'departed')),
      ('BTS-TR-008', 'gps', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '10:20', jsonb_build_object('lat', 12.90, 'lng', 80.05)),
      ('BTS-TR-010', 'status_change', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '05:20', jsonb_build_object('status', 'departed')),
      ('BTS-TR-011', 'gps', (current_date - INTERVAL '21 days')::timestamptz + INTERVAL '12:00', jsonb_build_object('lat', 19.10, 'lng', 74.00)),
      ('BTS-TR-013', 'status_change', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '07:30', jsonb_build_object('status', 'departed')),
      ('BTS-TR-014', 'gps', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '09:30', jsonb_build_object('lat', 18.00, 'lng', 75.50)),
      ('BTS-TR-015', 'status_change', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '05:10', jsonb_build_object('status', 'departed')),
      ('BTS-TR-016', 'gps', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '11:00', jsonb_build_object('lat', 12.80, 'lng', 79.80)),
      ('BTS-TR-018', 'status_change', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '05:20', jsonb_build_object('status', 'departed')),
      ('BTS-TR-019', 'gps', (current_date - INTERVAL '7 days')::timestamptz + INTERVAL '12:00', jsonb_build_object('lat', 19.40, 'lng', 74.60))
  ) AS e(trip_no, event_type, event_at, payload)
    ON tr.trip_no = e.trip_no
)
SELECT 'OrgB trips seeded' AS status;

-- Fuel and expenses for OrgB
WITH vehicle_map AS (
  SELECT reg_no, vehicle_id FROM vehicles WHERE org_id = current_org_id()
), driver_map AS (
  SELECT license_no, driver_id FROM drivers WHERE org_id = current_org_id()
), trip_map AS (
  SELECT trip_no, trip_id FROM trips WHERE org_id = current_org_id()
), customer_map AS (
  SELECT code, customer_id FROM customers WHERE org_id = current_org_id()
), fuel_rows AS (
  INSERT INTO fuel_logs (org_id, vehicle_id, driver_id, trip_id, filled_at, odometer_km, volume_liters, price_per_liter_paise, total_amount_paise, vendor, payment_method)
  SELECT
    current_org_id(),
    v.vehicle_id,
    d.driver_id,
    t.trip_id,
    f.filled_at,
    f.odometer_km,
    f.volume_liters,
    f.price_per_liter_paise,
    ROUND(f.volume_liters * f.price_per_liter_paise)::bigint,
    f.vendor,
    f.payment_method
  FROM (VALUES
    ('MH12BT1001', 'MH12-2019-5558881', 'BTS-TR-001', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '06:00', 99600.0, 52.0, 9680, 'HPCL Talegaon', 'upi'),
    ('MH14BT2002', 'MH14-2020-3332221', 'BTS-TR-002', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '09:00', 88500.0, 60.0, 9620, 'IOCL Ahmednagar', 'card'),
    ('TN11BT3003', 'TN11-2018-7776661', 'BTS-TR-003', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '09:00', 50000.0, 38.0, 9550, 'BPCL Poonamallee', 'upi'),
    ('TN09BT4004', 'TN11-2022-5557771', 'BTS-TR-004', (current_date - INTERVAL '29 days')::timestamptz + INTERVAL '10:00', 131800.0, 40.0, 9520, 'HPCL Tambaram', 'cash'),
    ('MH12BT5005', 'MH12-2021-9990001', 'BTS-TR-005', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '06:10', 186500.0, 32.0, 9700, 'HPCL Baner', 'upi'),
    ('MH12BT1001', 'MH12-2019-5558881', 'BTS-TR-006', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '10:00', 100200.0, 58.0, 9660, 'BPCL Nashik', 'card'),
    ('MH14BT2002', 'MH14-2020-3332221', 'BTS-TR-007', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '08:10', 88900.0, 55.0, 9620, 'IOCL Ranjangaon', 'upi'),
    ('TN11BT3003', 'TN11-2018-7776661', 'BTS-TR-008', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '10:20', 50300.0, 36.0, 9500, 'HPCL Tambaram', 'upi'),
    ('TN09BT4004', 'TN11-2022-5557771', 'BTS-TR-009', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '08:00', 132500.0, 40.0, 9520, 'BPCL Guduvanchery', 'card'),
    ('MH12BT1001', 'MH12-2019-5558881', 'BTS-TR-010', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '06:20', 100900.0, 30.0, 9700, 'HPCL Wakad', 'upi'),
    ('MH14BT2002', 'MH14-2020-3332221', 'BTS-TR-011', (current_date - INTERVAL '21 days')::timestamptz + INTERVAL '09:20', 89400.0, 62.0, 9640, 'IOCL Ahmednagar', 'card'),
    ('TN11BT3003', 'TN09-2017-1114441', 'BTS-TR-012', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '09:40', 50550.0, 35.0, 9510, 'HPCL Avadi', 'upi'),
    ('TN09BT4004', 'TN11-2022-5557771', 'BTS-TR-013', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '09:00', 133200.0, 39.0, 9520, 'BPCL Chromepet', 'cash'),
    ('MH12BT5005', 'MH12-2021-9990001', 'BTS-TR-014', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '08:10', 186900.0, 55.0, 9700, 'HPCL Solapur', 'upi'),
    ('MH12BT1001', 'MH14-2020-3332221', 'BTS-TR-015', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '06:00', 101500.0, 52.0, 9680, 'HPCL Chakan', 'upi'),
    ('TN11BT3003', 'TN11-2018-7776661', 'BTS-TR-016', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '10:00', 50800.0, 42.0, 9500, 'BPCL Pondicherry', 'card'),
    ('TN09BT4004', 'TN11-2022-5557771', 'BTS-TR-017', (current_date - INTERVAL '11 days')::timestamptz + INTERVAL '08:30', 133800.0, 40.0, 9520, 'HPCL Tambaram', 'upi'),
    ('MH12BT1001', 'MH12-2019-5558881', 'BTS-TR-018', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '06:10', 101900.0, 30.0, 9700, 'HPCL Baner', 'upi'),
    ('MH14BT2002', 'MH14-2020-3332221', 'BTS-TR-019', (current_date - INTERVAL '7 days')::timestamptz + INTERVAL '08:40', 89900.0, 61.0, 9640, 'IOCL Aurangabad', 'card'),
    ('TN11BT3003', 'TN11-2018-7776661', 'BTS-TR-020', (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '09:20', 51150.0, 36.0, 9510, 'HPCL Chengalpattu', 'upi'),
    -- Unlinked fuel logs
    ('MH12BT1001', 'MH12-2019-5558881', NULL, (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '07:00', 99800.0, 40.0, 9700, 'HPCL Nashik', 'cash'),
    ('MH14BT2002', 'MH14-2020-3332221', NULL, (current_date - INTERVAL '18 days')::timestamptz + INTERVAL '07:30', 89100.0, 45.0, 9640, 'BPCL Pune', 'upi'),
    ('TN11BT3003', 'TN11-2018-7776661', NULL, (current_date - INTERVAL '14 days')::timestamptz + INTERVAL '08:00', 50650.0, 34.0, 9520, 'HPCL Chennai', 'card'),
    ('TN09BT4004', 'TN11-2022-5557771', NULL, (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '09:00', 132900.0, 38.0, 9520, 'BPCL Chengalpattu', 'upi'),
    ('MH12BT5005', 'MH12-2021-9990001', NULL, (current_date - INTERVAL '2 days')::timestamptz + INTERVAL '10:00', 187900.0, 50.0, 9700, 'HPCL Pune', 'card')
  ) AS f(reg_no, driver_license, trip_no, filled_at, odometer_km, volume_liters, price_per_liter_paise, vendor, payment_method)
  LEFT JOIN vehicle_map v ON v.reg_no = f.reg_no
  LEFT JOIN driver_map d ON d.license_no = f.driver_license
  LEFT JOIN trip_map t ON t.trip_no = f.trip_no
  RETURNING fuel_log_id
), expense_rows AS (
  INSERT INTO expense_logs (org_id, vehicle_id, driver_id, trip_id, customer_id, expense_type, description, incurred_at, amount_paise, gst_amount_paise)
  SELECT
    current_org_id(),
    v.vehicle_id,
    d.driver_id,
    t.trip_id,
    c.customer_id,
    e.expense_type,
    e.description,
    e.incurred_at,
    e.amount_paise,
    e.gst_amount_paise
  FROM (VALUES
    ('MH12BT1001', 'MH12-2019-5558881', 'BTS-TR-001', 'WAP', 'toll', 'Expressway tolls', (current_date - INTERVAL '34 days')::timestamptz + INTERVAL '07:00', 38000, 6840),
    ('MH14BT2002', 'MH14-2020-3332221', 'BTS-TR-002', 'DSL', 'repair', 'Tyre puncture (paid_by=driver)', (current_date - INTERVAL '32 days')::timestamptz + INTERVAL '12:00', 22000, 3960),
    ('TN11BT3003', 'TN11-2018-7776661', 'BTS-TR-003', 'CTX', 'parking', 'Mill gate parking', (current_date - INTERVAL '31 days')::timestamptz + INTERVAL '12:50', 7000, 1260),
    ('TN09BT4004', 'TN11-2022-5557771', 'BTS-TR-004', 'CTX', 'food', 'Driver meals', (current_date - INTERVAL '29 days')::timestamptz + INTERVAL '11:00', 9000, 1620),
    ('MH12BT5005', 'MH12-2021-9990001', 'BTS-TR-005', 'SHF', 'toll', 'City tolls', (current_date - INTERVAL '28 days')::timestamptz + INTERVAL '06:40', 6000, 1080),
    ('MH12BT1001', 'MH12-2019-5558881', 'BTS-TR-006', 'DSL', 'lodging', 'Night halt Jalna', (current_date - INTERVAL '27 days')::timestamptz + INTERVAL '22:00', 180000, 32400),
    ('MH14BT2002', 'MH14-2020-3332221', 'BTS-TR-007', 'WAP', 'toll', 'FASTag top-up', (current_date - INTERVAL '26 days')::timestamptz + INTERVAL '07:20', 95000, 17100),
    ('TN11BT3003', 'TN11-2018-7776661', 'BTS-TR-008', 'CTX', 'parking', 'Yard parking', (current_date - INTERVAL '24 days')::timestamptz + INTERVAL '09:40', 6000, 1080),
    ('TN09BT4004', 'TN11-2022-5557771', 'BTS-TR-009', 'BEL', 'food', 'Snacks', (current_date - INTERVAL '23 days')::timestamptz + INTERVAL '10:00', 6000, 1080),
    ('MH12BT1001', 'MH12-2019-5558881', 'BTS-TR-010', 'SHF', 'parking', 'Market parking', (current_date - INTERVAL '22 days')::timestamptz + INTERVAL '08:20', 5000, 900),
    ('MH14BT2002', 'MH14-2020-3332221', 'BTS-TR-011', 'DSL', 'toll', 'Expressway tolls', (current_date - INTERVAL '21 days')::timestamptz + INTERVAL '10:00', 180000, 32400),
    ('TN11BT3003', 'TN09-2017-1114441', 'BTS-TR-012', 'CTX', 'parking', 'Mill gate parking', (current_date - INTERVAL '20 days')::timestamptz + INTERVAL '10:30', 7000, 1260),
    ('TN09BT4004', 'TN11-2022-5557771', 'BTS-TR-013', 'BEL', 'toll', 'ORR toll', (current_date - INTERVAL '19 days')::timestamptz + INTERVAL '08:50', 11000, 1980),
    ('MH12BT5005', 'MH12-2021-9990001', 'BTS-TR-014', 'MRC', 'repair', 'Fuel filter change', (current_date - INTERVAL '17 days')::timestamptz + INTERVAL '12:00', 85000, 15300),
    ('MH12BT1001', 'MH14-2020-3332221', 'BTS-TR-015', 'WAP', 'food', 'Breakfast', (current_date - INTERVAL '15 days')::timestamptz + INTERVAL '06:30', 5000, 900),
    ('TN11BT3003', 'TN11-2018-7776661', 'BTS-TR-016', 'CTX', 'toll', 'ECR tolls', (current_date - INTERVAL '13 days')::timestamptz + INTERVAL '08:00', 25000, 4500),
    ('TN09BT4004', 'TN11-2022-5557771', 'BTS-TR-017', 'BEL', 'fine', 'Overweight fine', (current_date - INTERVAL '11 days')::timestamptz + INTERVAL '11:00', 32000, 0),
    ('MH12BT1001', 'MH12-2019-5558881', 'BTS-TR-018', 'SHF', 'parking', 'Market parking', (current_date - INTERVAL '9 days')::timestamptz + INTERVAL '08:20', 5000, 900),
    ('MH14BT2002', 'MH14-2020-3332221', 'BTS-TR-019', 'DSL', 'lodging', 'Night halt Aurangabad', (current_date - INTERVAL '7 days')::timestamptz + INTERVAL '22:00', 175000, 31500),
    ('TN11BT3003', 'TN11-2018-7776661', 'BTS-TR-020', 'CTX', 'parking', 'Yard parking', (current_date - INTERVAL '5 days')::timestamptz + INTERVAL '10:00', 6000, 1080),
    -- Non-trip expenses
    ('MH12BT1001', 'MH12-2019-5558881', NULL, NULL, 'repair', 'Engine oil top-up', (current_date - INTERVAL '25 days')::timestamptz + INTERVAL '12:00', 65000, 11700),
    ('MH14BT2002', 'MH14-2020-3332221', NULL, 'DSL', 'repair', 'Brake pads', (current_date - INTERVAL '18 days')::timestamptz + INTERVAL '16:00', 210000, 37800),
    ('TN11BT3003', 'TN11-2018-7776661', NULL, 'CTX', 'parking', 'Yard parking monthly', (current_date - INTERVAL '14 days')::timestamptz + INTERVAL '18:00', 15000, 2700),
    ('TN09BT4004', 'TN11-2022-5557771', NULL, 'BEL', 'food', 'Team lunch', (current_date - INTERVAL '12 days')::timestamptz + INTERVAL '13:00', 24000, 4320),
    ('MH12BT5005', 'MH12-2021-9990001', NULL, 'MRC', 'fine', 'RTO inspection fine', (current_date - INTERVAL '10 days')::timestamptz + INTERVAL '11:00', 18000, 0),
    ('MH12BT1001', 'MH12-2019-5558881', NULL, 'WAP', 'toll', 'FASTag recharge', (current_date - INTERVAL '8 days')::timestamptz + INTERVAL '08:00', 300000, 54000),
    ('MH14BT2002', 'MH14-2020-3332221', NULL, 'DSL', 'repair', 'Clutch plate', (current_date - INTERVAL '6 days')::timestamptz + INTERVAL '15:00', 340000, 61200),
    ('TN11BT3003', 'TN11-2018-7776661', NULL, 'CTX', 'lodging', 'Night halt Tindivanam', (current_date - INTERVAL '4 days')::timestamptz + INTERVAL '21:00', 110000, 19800),
    ('TN09BT4004', 'TN11-2022-5557771', NULL, 'BEL', 'repair', 'Tail lamp change', (current_date - INTERVAL '3 days')::timestamptz + INTERVAL '12:00', 28000, 5040),
    ('MH12BT5005', 'MH12-2021-9990001', NULL, 'MRC', 'parking', 'Yard parking', (current_date - INTERVAL '1 day')::timestamptz + INTERVAL '19:00', 6000, 1080)
  ) AS e(reg_no, driver_license, trip_no, customer_code, expense_type, description, incurred_at, amount_paise, gst_amount_paise)
  LEFT JOIN vehicle_map v ON v.reg_no = e.reg_no
  LEFT JOIN driver_map d ON d.license_no = e.driver_license
  LEFT JOIN trip_map t ON t.trip_no = e.trip_no
  LEFT JOIN customer_map c ON c.code = e.customer_code
  RETURNING expense_log_id
)
SELECT 'OrgB fuel & expenses seeded' AS status;

-- Maintenance for OrgB
WITH vehicle_map AS (
  SELECT reg_no, vehicle_id FROM vehicles WHERE org_id = current_org_id()
), plan_rows AS (
  INSERT INTO maintenance_plans (org_id, vehicle_id, name, interval_km, interval_days, last_service_at, last_service_odometer_km, notes)
  SELECT current_org_id(), v.vehicle_id, p.name, p.interval_km, p.interval_days, p.last_service_at, p.last_service_odometer_km, p.notes
  FROM (VALUES
    ('MH12BT1001', 'Engine service', 15000.0, 120, (current_date - INTERVAL '70 days')::timestamptz, 90000.0, 'Semi synthetic'),
    ('MH14BT2002', 'Brake check', 10000.0, NULL, (current_date - INTERVAL '60 days')::timestamptz, 82000.0, 'Shoes + drums'),
    ('TN11BT3003', 'General service', 12000.0, 150, (current_date - INTERVAL '65 days')::timestamptz, 45000.0, 'Full service'),
    ('TN09BT4004', 'PUC renewal reminder', NULL, 180, (current_date - INTERVAL '140 days')::timestamptz, 125000.0, 'PUC alignment'),
    ('MH12BT5005', 'Tyre rotation', 25000.0, NULL, (current_date - INTERVAL '90 days')::timestamptz, 180000.0, 'Rotation + balance')
  ) AS p(reg_no, name, interval_km, interval_days, last_service_at, last_service_odometer_km, notes)
  JOIN vehicle_map v ON v.reg_no = p.reg_no
  RETURNING maintenance_plan_id, vehicle_id, name
), ticket_rows AS (
  INSERT INTO maintenance_tickets (org_id, vehicle_id, maintenance_plan_id, opened_at, closed_at, status, issue_summary, issue_detail, odometer_km, cost_estimate_paise, actual_cost_paise)
  SELECT
    current_org_id(),
    v.vehicle_id,
    p.maintenance_plan_id,
    t.opened_at,
    t.closed_at,
    t.status::ticket_status,
    t.issue_summary,
    t.issue_detail,
    t.odometer_km,
    t.cost_estimate_paise,
    t.actual_cost_paise
  FROM (VALUES
    ('MH12BT1001', 'Engine service', (current_date - INTERVAL '18 days')::timestamptz, NULL, 'open', 'Oil change due', 'Service at company workshop', 101000.0, 780000, NULL),
    ('MH14BT2002', 'Brake check', (current_date - INTERVAL '25 days')::timestamptz, (current_date - INTERVAL '23 days')::timestamptz, 'completed', 'Brake shoe wear', 'Shoes replaced', 88800.0, 350000, 352000),
    ('TN11BT3003', 'General service', (current_date - INTERVAL '12 days')::timestamptz, NULL, 'in_progress', 'Scheduled service', 'Include filter change', 51000.0, 420000, NULL),
    ('TN09BT4004', 'PUC renewal reminder', (current_date - INTERVAL '5 days')::timestamptz, NULL, 'open', 'PUC expires soon', 'Book slot', 134000.0, 50000, NULL),
    ('MH12BT5005', 'Tyre rotation', (current_date - INTERVAL '40 days')::timestamptz, (current_date - INTERVAL '38 days')::timestamptz, 'completed', 'Tyre rotation', 'Rotation + alignment', 186500.0, 160000, 158000),
    ('MH12BT1001', NULL, (current_date - INTERVAL '16 days')::timestamptz, NULL, 'open', 'Fuel leak check', 'Check injectors', 101200.0, 220000, NULL),
    ('TN11BT3003', NULL, (current_date - INTERVAL '9 days')::timestamptz, NULL, 'open', 'AC blower noise', 'Inspect blower', 51400.0, 90000, NULL),
    ('MH14BT2002', NULL, (current_date - INTERVAL '3 days')::timestamptz, NULL, 'open', 'ABS warning light', 'Diagnose ABS sensors', 90500.0, 180000, NULL)
  ) AS t(reg_no, plan_name, opened_at, closed_at, status, issue_summary, issue_detail, odometer_km, cost_estimate_paise, actual_cost_paise)
  JOIN vehicle_map v ON v.reg_no = t.reg_no
  LEFT JOIN plan_rows p ON p.name = t.plan_name AND p.vehicle_id = v.vehicle_id
  RETURNING maintenance_ticket_id
), item_rows AS (
  INSERT INTO maintenance_items (org_id, maintenance_ticket_id, description, quantity, unit_cost_paise, total_cost_paise)
  SELECT
    current_org_id(),
    mt.maintenance_ticket_id,
    i.description,
    i.quantity,
    i.unit_cost_paise,
    (i.quantity * i.unit_cost_paise)::bigint
  FROM ticket_rows mt
  JOIN (
    VALUES
      ('Oil change due', 'Engine oil', 1.0, 400000),
      ('Oil change due', 'Oil filter', 1.0, 110000),
      ('Oil change due', 'Labour', 1.0, 170000),
      ('Brake shoe wear', 'Brake shoes set', 1.0, 250000),
      ('Brake shoe wear', 'Brake fluid', 1.0, 40000),
      ('Brake shoe wear', 'Labour', 1.0, 62000),
      ('Scheduled service', 'Fuel filter', 1.0, 80000),
      ('Scheduled service', 'Air filter', 1.0, 60000),
      ('Scheduled service', 'Labour', 1.0, 220000),
      ('PUC expires soon', 'PUC certificate', 1.0, 50000),
      ('Tyre rotation', 'Wheel balancing', 1.0, 60000),
      ('Tyre rotation', 'Weights', 1.0, 18000),
      ('Tyre rotation', 'Labour', 1.0, 80000),
      ('Fuel leak check', 'Injector cleaning', 1.0, 90000),
      ('Fuel leak check', 'Diagnostics', 1.0, 70000),
      ('AC blower noise', 'Blower motor', 1.0, 50000),
      ('AC blower noise', 'AC gas top-up', 1.0, 30000),
      ('ABS warning light', 'ABS sensor', 1.0, 90000),
      ('ABS warning light', 'Diagnostics', 1.0, 60000),
      ('ABS warning light', 'Labour', 1.0, 30000)
  ) AS i(issue_summary, description, quantity, unit_cost_paise)
    ON mt.issue_summary = i.issue_summary
)
SELECT 'OrgB maintenance seeded' AS status;

-- Documents for OrgB
WITH doc_type_rows AS (
  INSERT INTO doc_types (org_id, name, entity_type, validity_days)
  VALUES
    (current_org_id(), 'rc', 'vehicle', 3650),
    (current_org_id(), 'insurance', 'vehicle', 365),
    (current_org_id(), 'permit', 'vehicle', 365),
    (current_org_id(), 'fitness', 'vehicle', 365),
    (current_org_id(), 'puc', 'vehicle', 180),
    (current_org_id(), 'tax_receipt', 'vehicle', 365),
    (current_org_id(), 'driver_license', 'driver', 1825)
  RETURNING doc_type_id, name, entity_type
), vehicle_map AS (
  SELECT reg_no, vehicle_id FROM vehicles WHERE org_id = current_org_id()
), driver_map AS (
  SELECT license_no, driver_id FROM drivers WHERE org_id = current_org_id()
), doc_rows AS (
  INSERT INTO documents (org_id, doc_type_id, entity_type, entity_id, file_url, file_name, mime_type, size_bytes, issued_date, expiry_date, metadata)
  SELECT
    current_org_id(),
    dt.doc_type_id,
    d.entity_type,
    d.entity_id,
    d.file_url,
    d.file_name,
    'application/pdf',
    d.size_bytes,
    d.issued_date,
    d.expiry_date,
    d.metadata
  FROM (
    VALUES
      ('rc', 'vehicle', 'MH12BT1001', 's3://fleet-docs/orgB/vehicles/MH12BT1001/rc.pdf', 'MH12BT1001_RC.pdf', 100000, (current_date - INTERVAL '700 days')::date, (current_date + INTERVAL '1000 days')::date, jsonb_build_object('state', 'MH')),
      ('insurance', 'vehicle', 'MH12BT1001', 's3://fleet-docs/orgB/vehicles/MH12BT1001/insurance.pdf', 'MH12BT1001_INS.pdf', 95000, (current_date - INTERVAL '200 days')::date, (current_date + INTERVAL '45 days')::date, jsonb_build_object('insurer', 'ICICI Lombard')),
      ('fitness', 'vehicle', 'MH14BT2002', 's3://fleet-docs/orgB/vehicles/MH14BT2002/fitness.pdf', 'MH14BT2002_FIT.pdf', 88000, (current_date - INTERVAL '500 days')::date, (current_date + INTERVAL '25 days')::date, jsonb_build_object('center', 'Pune RTO')),
      ('permit', 'vehicle', 'TN11BT3003', 's3://fleet-docs/orgB/vehicles/TN11BT3003/permit.pdf', 'TN11BT3003_PERMIT.pdf', 87000, (current_date - INTERVAL '250 days')::date, (current_date + INTERVAL '120 days')::date, jsonb_build_object('type', 'TN State')),
      ('puc', 'vehicle', 'TN11BT3003', 's3://fleet-docs/orgB/vehicles/TN11BT3003/puc.pdf', 'TN11BT3003_PUC.pdf', 60000, (current_date - INTERVAL '140 days')::date, (current_date + INTERVAL '15 days')::date, jsonb_build_object('station', 'IOC PUC')),
      ('insurance', 'vehicle', 'TN09BT4004', 's3://fleet-docs/orgB/vehicles/TN09BT4004/insurance.pdf', 'TN09BT4004_INS.pdf', 97000, (current_date - INTERVAL '240 days')::date, (current_date + INTERVAL '200 days')::date, jsonb_build_object('insurer', 'Bajaj Allianz')),
      ('rc', 'vehicle', 'TN09BT4004', 's3://fleet-docs/orgB/vehicles/TN09BT4004/rc.pdf', 'TN09BT4004_RC.pdf', 102000, (current_date - INTERVAL '1200 days')::date, (current_date + INTERVAL '800 days')::date, jsonb_build_object('state', 'TN')),
      ('tax_receipt', 'vehicle', 'MH12BT5005', 's3://fleet-docs/orgB/vehicles/MH12BT5005/tax.pdf', 'MH12BT5005_TAX.pdf', 72000, (current_date - INTERVAL '180 days')::date, (current_date + INTERVAL '150 days')::date, jsonb_build_object('amount_paise', 3100000)),
      ('fitness', 'vehicle', 'MH12BT5005', 's3://fleet-docs/orgB/vehicles/MH12BT5005/fitness.pdf', 'MH12BT5005_FIT.pdf', 85000, (current_date - INTERVAL '600 days')::date, (current_date + INTERVAL '12 days')::date, jsonb_build_object('center', 'Pune RTO')),
      ('puc', 'vehicle', 'MH12BT5005', 's3://fleet-docs/orgB/vehicles/MH12BT5005/puc.pdf', 'MH12BT5005_PUC.pdf', 61000, (current_date - INTERVAL '120 days')::date, (current_date + INTERVAL '5 days')::date, jsonb_build_object('station', 'HPCL PUC')),
      ('driver_license', 'driver', 'MH12-2019-5558881', 's3://fleet-docs/orgB/drivers/Rahul_Deshpande/license.pdf', 'RAHUL_DESHPANDE_DL.pdf', 70000, (current_date - INTERVAL '1000 days')::date, (current_date + INTERVAL '600 days')::date, jsonb_build_object('state', 'MH')),
      ('driver_license', 'driver', 'MH14-2020-3332221', 's3://fleet-docs/orgB/drivers/Swapnil_Shinde/license.pdf', 'SWAPNIL_SHINDE_DL.pdf', 69000, (current_date - INTERVAL '700 days')::date, (current_date + INTERVAL '400 days')::date, jsonb_build_object('state', 'MH')),
      ('driver_license', 'driver', 'TN11-2018-7776661', 's3://fleet-docs/orgB/drivers/Suresh_Kumar/license.pdf', 'SURESH_KUMAR_DL.pdf', 72000, (current_date - INTERVAL '1500 days')::date, (current_date + INTERVAL '25 days')::date, jsonb_build_object('state', 'TN')),
      ('driver_license', 'driver', 'TN09-2017-1114441', 's3://fleet-docs/orgB/drivers/Arun_Prk/license.pdf', 'ARUN_PRAKASH_DL.pdf', 73000, (current_date - INTERVAL '2000 days')::date, (current_date + INTERVAL '150 days')::date, jsonb_build_object('state', 'TN')),
      ('driver_license', 'driver', 'MH12-2021-9990001', 's3://fleet-docs/orgB/drivers/Jayant_Jadhav/license.pdf', 'JAYANT_JADHAV_DL.pdf', 71000, (current_date - INTERVAL '500 days')::date, (current_date + INTERVAL '900 days')::date, jsonb_build_object('state', 'MH'))
  ) AS d(doc_type_name, entity_type, entity_key, file_url, file_name, size_bytes, issued_date, expiry_date, metadata)
  JOIN doc_type_rows dt ON dt.name = d.doc_type_name AND dt.entity_type = d.entity_type
  LEFT JOIN vehicle_map vm ON vm.reg_no = d.entity_key AND d.entity_type = 'vehicle'
  LEFT JOIN driver_map dm ON dm.license_no = d.entity_key AND d.entity_type = 'driver'
  CROSS JOIN LATERAL (
    SELECT CASE WHEN d.entity_type = 'vehicle' THEN vm.vehicle_id ELSE dm.driver_id END AS entity_id
  ) d
)
SELECT 'OrgB documents seeded' AS status;

-- Billing for OrgB
WITH customer_map AS (
  SELECT code, customer_id FROM customers WHERE org_id = current_org_id()
), contract_map AS (
  SELECT name, contract_id FROM contracts WHERE org_id = current_org_id()
), invoice_meta AS (
  SELECT * FROM (VALUES
    ('BTS-INV-001', 'WAP', 'Auto parts shuttles', 'issued', current_date - INTERVAL '26 days', current_date - INTERVAL '15 days', 'Parts shuttle billing'),
    ('BTS-INV-002', 'DSL', 'Steel coils', 'paid', current_date - INTERVAL '24 days', current_date - INTERVAL '10 days', 'Steel haulage'),
    ('BTS-INV-003', 'SHF', 'Food distribution', 'issued', current_date - INTERVAL '22 days', current_date - INTERVAL '7 days', 'Food deliveries'),
    ('BTS-INV-004', 'CTX', 'Textile rolls', 'overdue', current_date - INTERVAL '20 days', current_date - INTERVAL '3 days', 'Textile runs'),
    ('BTS-INV-005', 'BEL', 'Textile rolls', 'cancelled', current_date - INTERVAL '18 days', current_date - INTERVAL '5 days', 'Cancelled invoice'),
    ('BTS-INV-006', 'MRC', 'Food distribution', 'draft', current_date - INTERVAL '16 days', current_date - INTERVAL '2 days', 'Cement support'),
    ('BTS-INV-007', 'WAP', 'Auto parts shuttles', 'issued', current_date - INTERVAL '14 days', current_date + INTERVAL '5 days', 'Weekly shuttle'),
    ('BTS-INV-008', 'DSL', 'Steel coils', 'issued', current_date - INTERVAL '12 days', current_date + INTERVAL '6 days', 'Steel haul'),
    ('BTS-INV-009', 'SHF', 'Food distribution', 'paid', current_date - INTERVAL '10 days', current_date + INTERVAL '10 days', 'Food runs'),
    ('BTS-INV-010', 'CTX', 'Textile rolls', 'issued', current_date - INTERVAL '6 days', current_date + INTERVAL '15 days', 'Textile schedule')
  ) AS v(invoice_no, cust_code, contract_name, status, invoice_date, due_date, notes)
), invoice_line_seed AS (
  SELECT * FROM (VALUES
    ('BTS-INV-001', 'Trips BTS-TR-001 & 007', 2.0, 203000, 18.0),
    ('BTS-INV-001', 'Handling', 1.0, 18000, 18.0),
    ('BTS-INV-002', 'Trips BTS-TR-002 & 006', 2.0, 1195000, 18.0),
    ('BTS-INV-002', 'Fuel surcharge', 1.0, 120000, 18.0),
    ('BTS-INV-003', 'Trips BTS-TR-005 & 010', 2.0, 90000, 12.0),
    ('BTS-INV-003', 'Cold chain surcharge', 1.0, 35000, 12.0),
    ('BTS-INV-004', 'Trips BTS-TR-003 & 008', 2.0, 157500, 12.0),
    ('BTS-INV-004', 'Waiting charges', 1.0, 20000, 12.0),
    ('BTS-INV-005', 'Cancelled trip charge', 1.0, 20000, 18.0),
    ('BTS-INV-006', 'Trip BTS-TR-014', 1.0, 620000, 12.0),
    ('BTS-INV-006', 'Fuel surcharge', 1.0, 55000, 12.0),
    ('BTS-INV-007', 'Trip BTS-TR-015', 1.0, 210000, 18.0),
    ('BTS-INV-007', 'Toll recovery', 1.0, 45000, 18.0),
    ('BTS-INV-008', 'Trip BTS-TR-019', 1.0, 1188000, 18.0),
    ('BTS-INV-008', 'Loading detain', 1.0, 55000, 18.0),
    ('BTS-INV-009', 'Trip BTS-TR-018', 1.0, 98000, 12.0),
    ('BTS-INV-009', 'Toll recovery', 1.0, 30000, 12.0),
    ('BTS-INV-010', 'Trip BTS-TR-020', 1.0, 160000, 12.0),
    ('BTS-INV-010', 'Fuel surcharge', 1.0, 32000, 12.0),
    ('BTS-INV-003', 'Demurrage', 1.0, 18000, 12.0),
    ('BTS-INV-004', 'Night halt', 1.0, 25000, 12.0),
    ('BTS-INV-006', 'Demurrage', 1.0, 22000, 12.0),
    ('BTS-INV-007', 'Labour', 1.0, 15000, 18.0),
    ('BTS-INV-008', 'Fuel surcharge', 1.0, 85000, 18.0),
    ('BTS-INV-010', 'Handling', 1.0, 12000, 12.0)
  ) AS v(invoice_no, description, quantity, unit_price_paise, tax_rate)
), invoice_totals AS (
  SELECT
    invoice_no,
    SUM(quantity * unit_price_paise)::bigint AS subtotal_paise,
    SUM(ROUND(quantity * unit_price_paise * tax_rate / 100.0))::bigint AS tax_paise
  FROM invoice_line_seed
  GROUP BY invoice_no
), invoice_rows AS (
  INSERT INTO invoices (org_id, customer_id, contract_id, invoice_no, invoice_date, due_date, status, subtotal_paise, tax_paise, total_paise, notes)
  SELECT
    current_org_id(),
    c.customer_id,
    ct.contract_id,
    m.invoice_no,
    m.invoice_date::date,
    m.due_date::date,
    m.status::invoice_status,
    t.subtotal_paise,
    t.tax_paise,
    t.subtotal_paise + t.tax_paise,
    m.notes
  FROM invoice_meta m
  JOIN customer_map c ON c.code = m.cust_code
  JOIN contract_map ct ON ct.name = m.contract_name
  JOIN invoice_totals t ON t.invoice_no = m.invoice_no
  RETURNING invoice_id, invoice_no
), invoice_line_rows AS (
  INSERT INTO invoice_lines (org_id, invoice_id, description, quantity, unit_price_paise, tax_rate, amount_paise, tax_amount_paise)
  SELECT
    current_org_id(),
    ir.invoice_id,
    ils.description,
    ils.quantity,
    ils.unit_price_paise,
    ils.tax_rate,
    (ils.quantity * ils.unit_price_paise)::bigint,
    ROUND(ils.quantity * ils.unit_price_paise * ils.tax_rate / 100.0)::bigint
  FROM invoice_line_seed ils
  JOIN invoice_rows ir ON ir.invoice_no = ils.invoice_no
  RETURNING invoice_line_id, invoice_id
), payment_rows AS (
  INSERT INTO payments (org_id, invoice_id, payment_date, amount_paise, method, reference_no, received_by)
  SELECT
    current_org_id(),
    ir.invoice_id,
    p.payment_date,
    p.amount_paise,
    p.method,
    p.reference_no,
    p.received_by
  FROM (VALUES
    ('BTS-INV-001', current_date - INTERVAL '18 days', 240000, 'upi', 'BTS001UPI', 'Aditi Kulkarni'),
    ('BTS-INV-002', current_date - INTERVAL '16 days', 2600000, 'neft', 'UTRBTS002', 'Aditi Kulkarni'),
    ('BTS-INV-002', current_date - INTERVAL '14 days', 800000, 'neft', 'UTRBTS002B', 'Aditi Kulkarni'),
    ('BTS-INV-003', current_date - INTERVAL '10 days', 120000, 'upi', 'BTS003UPI', 'Neha Patil'),
    ('BTS-INV-004', current_date - INTERVAL '6 days', 150000, 'cash', 'CASHBTS004', 'Vignesh Ravi'),
    ('BTS-INV-006', current_date - INTERVAL '4 days', 200000, 'upi', 'BTS006UPI', 'Aditi Kulkarni'),
    ('BTS-INV-007', current_date - INTERVAL '3 days', 150000, 'upi', 'BTS007UPI', 'Neha Patil'),
    ('BTS-INV-008', current_date - INTERVAL '2 days', 400000, 'neft', 'UTRBTS008', 'Aditi Kulkarni'),
    ('BTS-INV-009', current_date - INTERVAL '1 day', 110000, 'upi', 'BTS009UPI', 'Neha Patil'),
    ('BTS-INV-001', current_date - INTERVAL '17 days', 60000, 'cash', 'CASHBTS001', 'Siddharth Joshi'),
    ('BTS-INV-004', current_date - INTERVAL '5 days', 80000, 'upi', 'BTS004UPI2', 'Vignesh Ravi'),
    ('BTS-INV-010', current_date - INTERVAL '1 day', 90000, 'upi', 'BTS010UPI', 'Neha Patil')
  ) AS p(invoice_no, payment_date, amount_paise, method, reference_no, received_by)
  JOIN invoice_rows ir ON ir.invoice_no = p.invoice_no
  RETURNING payment_id
)
SELECT 'OrgB billing seeded' AS status;

-- Notifications & audit for OrgB
WITH doc_map AS (
  SELECT file_name, document_id FROM documents WHERE org_id = current_org_id()
), invoice_map AS (
  SELECT invoice_no, invoice_id FROM invoices WHERE org_id = current_org_id()
), ticket_map AS (
  SELECT issue_summary, maintenance_ticket_id FROM maintenance_tickets WHERE org_id = current_org_id()
), notification_rows AS (
  INSERT INTO notifications (org_id, entity_type, entity_id, channel, status, send_after, sent_at, payload)
  SELECT
    current_org_id(),
    n.entity_type,
    n.entity_id,
    n.channel::notification_channel,
    n.status::notification_status,
    n.send_after,
    n.sent_at,
    n.payload
  FROM (VALUES
    ('document', (SELECT document_id FROM doc_map WHERE file_name = 'MH14BT2002_FIT.pdf'), 'email', 'scheduled', current_timestamp - INTERVAL '1 day', NULL, jsonb_build_object('type', 'DOC_EXPIRY', 'days_remaining', 25)),
    ('document', (SELECT document_id FROM doc_map WHERE file_name = 'TN11BT3003_PUC.pdf'), 'sms', 'scheduled', current_timestamp - INTERVAL '2 days', NULL, jsonb_build_object('type', 'DOC_EXPIRY', 'days_remaining', 15)),
    ('invoice', (SELECT invoice_id FROM invoice_map WHERE invoice_no = 'BTS-INV-003'), 'email', 'sent', current_timestamp - INTERVAL '9 days', current_timestamp - INTERVAL '8 days', jsonb_build_object('type', 'INVOICE_DUE')),
    ('invoice', (SELECT invoice_id FROM invoice_map WHERE invoice_no = 'BTS-INV-004'), 'push', 'scheduled', current_timestamp + INTERVAL '1 day', NULL, jsonb_build_object('type', 'INVOICE_DUE')),
    ('maintenance_ticket', (SELECT maintenance_ticket_id FROM ticket_map WHERE issue_summary = 'Oil change due'), 'email', 'pending', current_timestamp, NULL, jsonb_build_object('type', 'MAINT_DUE')),
    ('maintenance_ticket', (SELECT maintenance_ticket_id FROM ticket_map WHERE issue_summary = 'PUC expires soon'), 'sms', 'scheduled', current_timestamp + INTERVAL '3 days', NULL, jsonb_build_object('type', 'DOC_EXPIRY')),
    ('document', (SELECT document_id FROM doc_map WHERE file_name = 'MH12BT5005_PUC.pdf'), 'email', 'scheduled', current_timestamp, NULL, jsonb_build_object('type', 'DOC_EXPIRY', 'days_remaining', 5)),
    ('document', (SELECT document_id FROM doc_map WHERE file_name = 'SURESH_KUMAR_DL.pdf'), 'email', 'scheduled', current_timestamp, NULL, jsonb_build_object('type', 'DOC_EXPIRY', 'days_remaining', 20)),
    ('invoice', (SELECT invoice_id FROM invoice_map WHERE invoice_no = 'BTS-INV-007'), 'email', 'sent', current_timestamp - INTERVAL '3 days', current_timestamp - INTERVAL '3 days', jsonb_build_object('type', 'INVOICE_DUE')),
    ('invoice', (SELECT invoice_id FROM invoice_map WHERE invoice_no = 'BTS-INV-010'), 'push', 'scheduled', current_timestamp + INTERVAL '7 days', NULL, jsonb_build_object('type', 'INVOICE_DUE'))
  ) AS n(entity_type, entity_id, channel, status, send_after, sent_at, payload)
  RETURNING notification_id
), audit_rows AS (
  INSERT INTO audit_log (org_id, user_id, action, entity_type, entity_id, request_id, ip_address, created_at, payload)
  SELECT
    current_org_id(),
    (SELECT user_id FROM users WHERE email = 'neha.patil@bharattransport.in'),
    'trip_completed',
    'trip',
    (SELECT trip_id FROM trips WHERE trip_no = 'BTS-TR-015'),
    'req-bts-001',
    '198.51.100.5',
    current_timestamp,
    jsonb_build_object('status', 'completed', 'notes', 'Auto seeded')
)
SELECT 'OrgB notifications & audit seeded' AS status;

-------------------------------------------------------------------------------
-- Validation / quick checks
-------------------------------------------------------------------------------
SELECT 'Counts per org' AS label;
SELECT
  org_id,
  (SELECT COUNT(*) FROM branches b WHERE b.org_id = o.org_id) AS branches,
  (SELECT COUNT(*) FROM users u WHERE u.org_id = o.org_id) AS users,
  (SELECT COUNT(*) FROM vehicles v WHERE v.org_id = o.org_id) AS vehicles,
  (SELECT COUNT(*) FROM drivers d WHERE d.org_id = o.org_id) AS drivers,
  (SELECT COUNT(*) FROM trips t WHERE t.org_id = o.org_id) AS trips,
  (SELECT COUNT(*) FROM fuel_logs f WHERE f.org_id = o.org_id) AS fuel_logs,
  (SELECT COUNT(*) FROM expense_logs e WHERE e.org_id = o.org_id) AS expense_logs,
  (SELECT COUNT(*) FROM maintenance_tickets m WHERE m.org_id = o.org_id) AS maintenance_tickets,
  (SELECT COUNT(*) FROM invoices i WHERE i.org_id = o.org_id) AS invoices,
  (SELECT COUNT(*) FROM documents d WHERE d.org_id = o.org_id) AS documents
FROM orgs o
ORDER BY org_id;

-- RLS visibility check: OrgA should not see OrgB rows
SELECT set_tenant('11111111-1111-1111-1111-111111111111', NULL);
SELECT 'OrgA trips visible', COUNT(*) FROM trips;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM trips WHERE org_id = '22222222-2222-2222-2222-222222222222') THEN
    RAISE EXCEPTION 'OrgB data leaked into OrgA view';
  END IF;
END;
$$;

SELECT set_tenant('22222222-2222-2222-2222-222222222222', NULL);
SELECT 'OrgB trips visible', COUNT(*) FROM trips;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM trips WHERE org_id = '11111111-1111-1111-1111-111111111111') THEN
    RAISE EXCEPTION 'OrgA data leaked into OrgB view';
  END IF;
END;
$$;

SELECT clear_tenant();
