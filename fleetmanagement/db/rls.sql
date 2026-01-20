-- Row Level Security configuration for AutoPredator FleetManager

-- Helper to set tenant context per transaction/session.
CREATE OR REPLACE FUNCTION set_tenant(p_org_id UUID, p_user_id UUID DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
  IF p_org_id IS NULL THEN
    RAISE EXCEPTION 'org_id is required for tenant context';
  END IF;
  PERFORM set_config('app.org_id', p_org_id::TEXT, TRUE);
  IF p_user_id IS NULL THEN
    PERFORM set_config('app.user_id', '', TRUE);
  ELSE
    PERFORM set_config('app.user_id', p_user_id::TEXT, TRUE);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

CREATE OR REPLACE FUNCTION clear_tenant()
RETURNS VOID AS $$
BEGIN
  PERFORM set_config('app.org_id', '', TRUE);
  PERFORM set_config('app.user_id', '', TRUE);
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

CREATE OR REPLACE FUNCTION current_org_id()
RETURNS UUID AS $$
DECLARE
  v_org_id TEXT;
BEGIN
  v_org_id := NULLIF(current_setting('app.org_id', TRUE), '');
  IF v_org_id IS NULL THEN
    RAISE EXCEPTION 'app.org_id is not set';
  END IF;
  RETURN v_org_id::UUID;
END;
$$ LANGUAGE plpgsql STABLE;

-- Service role for internal jobs; policies explicitly allow it.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role NOLOGIN;
  END IF;
END;
$$;

GRANT USAGE ON SCHEMA public TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO service_role;

-- Enable and enforce RLS on all tenant tables.
DO $$
DECLARE
  t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'orgs','branches','roles','permissions','role_permissions','users','user_roles',
    'customers','contracts','vehicles','drivers','assignments','odometer_logs',
    'trips','trip_stops','trip_events','fuel_logs','expense_logs',
    'maintenance_plans','maintenance_tickets','maintenance_items',
    'invoices','invoice_lines','payments','doc_types','documents',
    'notifications','audit_log'
  ]) LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY;', t);
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY;', t);

    IF NOT EXISTS (
      SELECT 1 FROM pg_policies
      WHERE schemaname = 'public' AND tablename = t AND policyname = t || '_tenant_policy'
    ) THEN
      EXECUTE format($fmt$
        CREATE POLICY %I ON %I
        FOR ALL
        USING (
          current_role = 'service_role'
          OR (
            current_setting('app.org_id', true) IS NOT NULL
            AND current_setting('app.org_id', true) <> ''
            AND org_id = current_setting('app.org_id', true)::uuid
          )
        )
        WITH CHECK (
          current_role = 'service_role'
          OR (
            current_setting('app.org_id', true) IS NOT NULL
            AND current_setting('app.org_id', true) <> ''
            AND org_id = current_setting('app.org_id', true)::uuid
          )
        );
      $fmt$, t || '_tenant_policy', t);
    END IF;
  END LOOP;
END;
$$;
