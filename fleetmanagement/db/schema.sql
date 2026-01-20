-- AutoPredator FleetManager database schema
-- PostgreSQL 16+, UUID primary keys, multi-tenant with org_id on every table.

-- Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for gen_random_uuid()

-- Enums
CREATE TYPE trip_status AS ENUM ('planned', 'in_progress', 'completed', 'cancelled');
CREATE TYPE vehicle_status AS ENUM ('active', 'inactive', 'maintenance', 'retired');
CREATE TYPE driver_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'completed', 'cancelled');
CREATE TYPE invoice_status AS ENUM ('draft', 'issued', 'paid', 'overdue', 'cancelled');
CREATE TYPE notification_status AS ENUM ('pending', 'scheduled', 'sent', 'failed', 'cancelled');
CREATE TYPE notification_channel AS ENUM ('email', 'sms', 'push', 'webhook', 'in_app');

-- Common trigger to bump updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tenants
CREATE TABLE IF NOT EXISTS orgs (
  org_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT NOT NULL UNIQUE,
  legal_name TEXT,
  gstin TEXT,
  timezone TEXT NOT NULL DEFAULT 'Asia/Kolkata',
  settings_jsonb JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS branches (
  branch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  address TEXT,
  timezone TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, branch_id)
);

-- Identity and access
CREATE TABLE IF NOT EXISTS roles (
  role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  name TEXT NOT NULL,
  description TEXT,
  is_system BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, role_id)
);

CREATE TABLE IF NOT EXISTS permissions (
  permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  code TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, permission_id)
);

CREATE TABLE IF NOT EXISTS role_permissions (
  role_permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  role_id UUID NOT NULL,
  permission_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, role_permission_id),
  UNIQUE (org_id, role_id, permission_id),
  FOREIGN KEY (org_id, role_id) REFERENCES roles(org_id, role_id),
  FOREIGN KEY (org_id, permission_id) REFERENCES permissions(org_id, permission_id)
);

CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  branch_id UUID,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  password_hash TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, user_id),
  FOREIGN KEY (org_id, branch_id) REFERENCES branches(org_id, branch_id)
);

CREATE TABLE IF NOT EXISTS user_roles (
  user_role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  user_id UUID NOT NULL,
  role_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, user_id, role_id),
  FOREIGN KEY (org_id, user_id) REFERENCES users(org_id, user_id),
  FOREIGN KEY (org_id, role_id) REFERENCES roles(org_id, role_id)
);

-- Customers and contracts
CREATE TABLE IF NOT EXISTS customers (
  customer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  name TEXT NOT NULL,
  code TEXT,
  email TEXT,
  phone TEXT,
  gstin TEXT,
  billing_address TEXT,
  shipping_address TEXT,
  credit_limit_paise BIGINT CHECK (credit_limit_paise >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, customer_id)
);

CREATE TABLE IF NOT EXISTS contracts (
  contract_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  customer_id UUID NOT NULL,
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  rate_jsonb JSONB NOT NULL DEFAULT '{}'::JSONB,
  base_rate_paise BIGINT CHECK (base_rate_paise >= 0),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, contract_id),
  FOREIGN KEY (org_id, customer_id) REFERENCES customers(org_id, customer_id)
);

-- Fleet
CREATE TABLE IF NOT EXISTS vehicles (
  vehicle_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  branch_id UUID,
  reg_no TEXT NOT NULL,
  vin TEXT,
  make TEXT,
  model TEXT,
  year INT,
  fuel_type TEXT,
  capacity_kg INT CHECK (capacity_kg IS NULL OR capacity_kg >= 0),
  status vehicle_status NOT NULL DEFAULT 'active',
  purchase_date DATE,
  current_odometer_km NUMERIC(12,2) CHECK (current_odometer_km IS NULL OR current_odometer_km >= 0),
  insurance_expiry DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, vehicle_id),
  FOREIGN KEY (org_id, branch_id) REFERENCES branches(org_id, branch_id)
);

CREATE TABLE IF NOT EXISTS drivers (
  driver_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  branch_id UUID,
  full_name TEXT NOT NULL,
  license_no TEXT NOT NULL,
  phone TEXT,
  status driver_status NOT NULL DEFAULT 'active',
  joined_at DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, driver_id),
  FOREIGN KEY (org_id, branch_id) REFERENCES branches(org_id, branch_id)
);

CREATE TABLE IF NOT EXISTS assignments (
  assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  vehicle_id UUID NOT NULL,
  driver_id UUID NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, assignment_id),
  FOREIGN KEY (org_id, vehicle_id) REFERENCES vehicles(org_id, vehicle_id),
  FOREIGN KEY (org_id, driver_id) REFERENCES drivers(org_id, driver_id)
);

CREATE TABLE IF NOT EXISTS odometer_logs (
  odometer_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  vehicle_id UUID NOT NULL,
  reading_km NUMERIC(12,2) NOT NULL CHECK (reading_km >= 0),
  recorded_at TIMESTAMPTZ NOT NULL,
  source TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, odometer_log_id),
  FOREIGN KEY (org_id, vehicle_id) REFERENCES vehicles(org_id, vehicle_id)
);

-- Trips
CREATE TABLE IF NOT EXISTS trips (
  trip_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  trip_no TEXT NOT NULL,
  vehicle_id UUID NOT NULL,
  driver_id UUID NOT NULL,
  customer_id UUID,
  contract_id UUID,
  start_at TIMESTAMPTZ,
  planned_end_at TIMESTAMPTZ,
  end_at TIMESTAMPTZ,
  origin TEXT,
  destination TEXT,
  distance_km NUMERIC(12,2) CHECK (distance_km IS NULL OR distance_km >= 0),
  status trip_status NOT NULL DEFAULT 'planned',
  revenue_paise BIGINT CHECK (revenue_paise IS NULL OR revenue_paise >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, trip_id),
  FOREIGN KEY (org_id, vehicle_id) REFERENCES vehicles(org_id, vehicle_id),
  FOREIGN KEY (org_id, driver_id) REFERENCES drivers(org_id, driver_id),
  FOREIGN KEY (org_id, customer_id) REFERENCES customers(org_id, customer_id),
  FOREIGN KEY (org_id, contract_id) REFERENCES contracts(org_id, contract_id)
);

CREATE TABLE IF NOT EXISTS trip_stops (
  trip_stop_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  trip_id UUID NOT NULL,
  stop_sequence INT NOT NULL,
  location_name TEXT,
  latitude NUMERIC(10,6),
  longitude NUMERIC(10,6),
  planned_at TIMESTAMPTZ,
  arrival_at TIMESTAMPTZ,
  departure_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, trip_stop_id),
  FOREIGN KEY (org_id, trip_id) REFERENCES trips(org_id, trip_id)
);

CREATE TABLE IF NOT EXISTS trip_events (
  trip_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  trip_id UUID NOT NULL,
  event_type TEXT NOT NULL,
  event_at TIMESTAMPTZ NOT NULL,
  payload_jsonb JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, trip_event_id),
  FOREIGN KEY (org_id, trip_id) REFERENCES trips(org_id, trip_id)
);
COMMENT ON TABLE trip_events IS 'Candidate for future time-based partitioning.';

-- Fuel and expenses
CREATE TABLE IF NOT EXISTS fuel_logs (
  fuel_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  vehicle_id UUID NOT NULL,
  driver_id UUID,
  trip_id UUID,
  filled_at TIMESTAMPTZ NOT NULL,
  odometer_km NUMERIC(12,2) CHECK (odometer_km IS NULL OR odometer_km >= 0),
  volume_liters NUMERIC(10,3) NOT NULL CHECK (volume_liters >= 0),
  price_per_liter_paise BIGINT NOT NULL CHECK (price_per_liter_paise >= 0),
  total_amount_paise BIGINT NOT NULL CHECK (total_amount_paise >= 0),
  vendor TEXT,
  payment_method TEXT,
  invoice_reference TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, fuel_log_id),
  FOREIGN KEY (org_id, vehicle_id) REFERENCES vehicles(org_id, vehicle_id),
  FOREIGN KEY (org_id, driver_id) REFERENCES drivers(org_id, driver_id),
  FOREIGN KEY (org_id, trip_id) REFERENCES trips(org_id, trip_id)
);

CREATE TABLE IF NOT EXISTS expense_logs (
  expense_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  vehicle_id UUID,
  driver_id UUID,
  trip_id UUID,
  customer_id UUID,
  expense_type TEXT NOT NULL,
  description TEXT,
  incurred_at TIMESTAMPTZ NOT NULL,
  amount_paise BIGINT NOT NULL CHECK (amount_paise >= 0),
  gst_amount_paise BIGINT CHECK (gst_amount_paise IS NULL OR gst_amount_paise >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, expense_log_id),
  FOREIGN KEY (org_id, vehicle_id) REFERENCES vehicles(org_id, vehicle_id),
  FOREIGN KEY (org_id, driver_id) REFERENCES drivers(org_id, driver_id),
  FOREIGN KEY (org_id, trip_id) REFERENCES trips(org_id, trip_id),
  FOREIGN KEY (org_id, customer_id) REFERENCES customers(org_id, customer_id)
);

-- Maintenance
CREATE TABLE IF NOT EXISTS maintenance_plans (
  maintenance_plan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  vehicle_id UUID NOT NULL,
  name TEXT NOT NULL,
  interval_km NUMERIC(12,2) CHECK (interval_km IS NULL OR interval_km >= 0),
  interval_days INT CHECK (interval_days IS NULL OR interval_days >= 0),
  last_service_at TIMESTAMPTZ,
  last_service_odometer_km NUMERIC(12,2) CHECK (last_service_odometer_km IS NULL OR last_service_odometer_km >= 0),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, maintenance_plan_id),
  FOREIGN KEY (org_id, vehicle_id) REFERENCES vehicles(org_id, vehicle_id)
);

CREATE TABLE IF NOT EXISTS maintenance_tickets (
  maintenance_ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  vehicle_id UUID NOT NULL,
  maintenance_plan_id UUID,
  opened_at TIMESTAMPTZ NOT NULL,
  closed_at TIMESTAMPTZ,
  status ticket_status NOT NULL DEFAULT 'open',
  issue_summary TEXT NOT NULL,
  issue_detail TEXT,
  odometer_km NUMERIC(12,2) CHECK (odometer_km IS NULL OR odometer_km >= 0),
  cost_estimate_paise BIGINT CHECK (cost_estimate_paise IS NULL OR cost_estimate_paise >= 0),
  actual_cost_paise BIGINT CHECK (actual_cost_paise IS NULL OR actual_cost_paise >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, maintenance_ticket_id),
  FOREIGN KEY (org_id, vehicle_id) REFERENCES vehicles(org_id, vehicle_id),
  FOREIGN KEY (org_id, maintenance_plan_id) REFERENCES maintenance_plans(org_id, maintenance_plan_id)
);

CREATE TABLE IF NOT EXISTS maintenance_items (
  maintenance_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  maintenance_ticket_id UUID NOT NULL,
  description TEXT NOT NULL,
  quantity NUMERIC(10,2) NOT NULL CHECK (quantity >= 0),
  unit_cost_paise BIGINT NOT NULL CHECK (unit_cost_paise >= 0),
  total_cost_paise BIGINT NOT NULL CHECK (total_cost_paise >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, maintenance_item_id),
  FOREIGN KEY (org_id, maintenance_ticket_id) REFERENCES maintenance_tickets(org_id, maintenance_ticket_id)
);

-- Billing
CREATE TABLE IF NOT EXISTS invoices (
  invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  customer_id UUID NOT NULL,
  contract_id UUID,
  invoice_no TEXT NOT NULL,
  invoice_date DATE NOT NULL,
  due_date DATE NOT NULL,
  status invoice_status NOT NULL DEFAULT 'draft',
  subtotal_paise BIGINT NOT NULL CHECK (subtotal_paise >= 0),
  tax_paise BIGINT NOT NULL CHECK (tax_paise >= 0),
  total_paise BIGINT NOT NULL CHECK (total_paise >= 0),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, invoice_id),
  FOREIGN KEY (org_id, customer_id) REFERENCES customers(org_id, customer_id),
  FOREIGN KEY (org_id, contract_id) REFERENCES contracts(org_id, contract_id)
);

CREATE TABLE IF NOT EXISTS invoice_lines (
  invoice_line_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  invoice_id UUID NOT NULL,
  description TEXT NOT NULL,
  quantity NUMERIC(12,2) NOT NULL CHECK (quantity >= 0),
  unit_price_paise BIGINT NOT NULL CHECK (unit_price_paise >= 0),
  tax_rate NUMERIC(5,2) CHECK (tax_rate IS NULL OR tax_rate >= 0),
  amount_paise BIGINT NOT NULL CHECK (amount_paise >= 0),
  tax_amount_paise BIGINT CHECK (tax_amount_paise IS NULL OR tax_amount_paise >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, invoice_line_id),
  FOREIGN KEY (org_id, invoice_id) REFERENCES invoices(org_id, invoice_id)
);

CREATE TABLE IF NOT EXISTS payments (
  payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  invoice_id UUID NOT NULL,
  payment_date DATE NOT NULL,
  amount_paise BIGINT NOT NULL CHECK (amount_paise >= 0),
  method TEXT,
  reference_no TEXT,
  received_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, payment_id),
  FOREIGN KEY (org_id, invoice_id) REFERENCES invoices(org_id, invoice_id)
);

-- Compliance and documents
CREATE TABLE IF NOT EXISTS doc_types (
  doc_type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  name TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  validity_days INT CHECK (validity_days IS NULL OR validity_days >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, doc_type_id)
);

CREATE TABLE IF NOT EXISTS documents (
  document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  doc_type_id UUID NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  file_url TEXT NOT NULL,
  file_name TEXT,
  mime_type TEXT,
  size_bytes BIGINT CHECK (size_bytes IS NULL OR size_bytes >= 0),
  issued_date DATE,
  expiry_date DATE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, document_id),
  FOREIGN KEY (org_id, doc_type_id) REFERENCES doc_types(org_id, doc_type_id)
);

CREATE TABLE IF NOT EXISTS notifications (
  notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  entity_type TEXT,
  entity_id UUID,
  channel notification_channel NOT NULL,
  status notification_status NOT NULL DEFAULT 'pending',
  send_after TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  error_message TEXT,
  payload JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, notification_id)
);

-- Audit
CREATE TABLE IF NOT EXISTS audit_log (
  audit_log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES orgs(org_id),
  user_id UUID,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  request_id TEXT,
  ip_address INET,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  payload JSONB NOT NULL DEFAULT '{}'::JSONB,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (org_id, audit_log_id),
  FOREIGN KEY (org_id, user_id) REFERENCES users(org_id, user_id)
);
COMMENT ON TABLE audit_log IS 'High-volume; consider partitioning by month if volume grows.';

-- Update triggers
DO $$
DECLARE
  tbl RECORD;
BEGIN
  FOR tbl IN
    SELECT tablename FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename IN (
        'orgs','branches','roles','permissions','role_permissions','users','user_roles',
        'customers','contracts','vehicles','drivers','assignments','odometer_logs',
        'trips','trip_stops','trip_events','fuel_logs','expense_logs',
        'maintenance_plans','maintenance_tickets','maintenance_items',
        'invoices','invoice_lines','payments','doc_types','documents',
        'notifications','audit_log'
      )
  LOOP
    EXECUTE format($f$
      DO $do$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_trigger
          WHERE tgname = '%I_set_updated_at'
        ) THEN
          CREATE TRIGGER %I_set_updated_at
          BEFORE UPDATE ON %I
          FOR EACH ROW EXECUTE PROCEDURE set_updated_at();
        END IF;
      END;
      $do$;
    $f$, tbl.tablename, tbl.tablename, tbl.tablename);
  END LOOP;
END;
$$;
