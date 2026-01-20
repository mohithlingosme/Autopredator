-- Additional indexes and unique constraints for performance and integrity.

-- Trip queries
CREATE INDEX IF NOT EXISTS idx_trips_org_start_at ON trips (org_id, start_at);
CREATE INDEX IF NOT EXISTS idx_trips_org_vehicle_start_at ON trips (org_id, vehicle_id, start_at);
CREATE INDEX IF NOT EXISTS idx_trips_org_driver_start_at ON trips (org_id, driver_id, start_at);
CREATE INDEX IF NOT EXISTS idx_trips_org_status ON trips (org_id, status);

-- Documents
CREATE INDEX IF NOT EXISTS idx_documents_org_expiry ON documents (org_id, expiry_date);
CREATE INDEX IF NOT EXISTS idx_documents_org_entity ON documents (org_id, entity_type, entity_id);

-- Fuel logs
CREATE INDEX IF NOT EXISTS idx_fuel_logs_org_vehicle_filled ON fuel_logs (org_id, vehicle_id, filled_at);

-- Maintenance
CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_org_vehicle_opened ON maintenance_tickets (org_id, vehicle_id, opened_at);
CREATE INDEX IF NOT EXISTS idx_maintenance_tickets_org_status ON maintenance_tickets (org_id, status);

-- Billing
CREATE INDEX IF NOT EXISTS idx_invoices_org_invoice_date ON invoices (org_id, invoice_date);
CREATE INDEX IF NOT EXISTS idx_invoices_org_status ON invoices (org_id, status);

-- Audit
CREATE INDEX IF NOT EXISTS idx_audit_log_org_created_at ON audit_log (org_id, created_at);

-- Integrity uniques
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'vehicles_org_reg_no_key'
  ) THEN
    ALTER TABLE vehicles ADD CONSTRAINT vehicles_org_reg_no_key UNIQUE (org_id, reg_no);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'trips_org_trip_no_key'
  ) THEN
    ALTER TABLE trips ADD CONSTRAINT trips_org_trip_no_key UNIQUE (org_id, trip_no);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'invoices_org_invoice_no_key'
  ) THEN
    ALTER TABLE invoices ADD CONSTRAINT invoices_org_invoice_no_key UNIQUE (org_id, invoice_no);
  END IF;
END;
$$;
