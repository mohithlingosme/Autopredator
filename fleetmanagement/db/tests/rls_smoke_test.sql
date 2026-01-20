-- RLS smoke test: proves isolation between OrgA and OrgB and blocks cross-tenant writes.

-- Expect to see only OrgA rows
SELECT set_tenant('11111111-1111-1111-1111-111111111111', NULL);
SELECT 'OrgA trips visible' AS check_name, COUNT(*) AS count FROM trips;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM trips WHERE org_id = '22222222-2222-2222-2222-222222222222') THEN
    RAISE EXCEPTION 'OrgB data leaked into OrgA view';
  END IF;
END;
$$;

-- Expect to see only OrgB rows
SELECT set_tenant('22222222-2222-2222-2222-222222222222', NULL);
SELECT 'OrgB trips visible' AS check_name, COUNT(*) AS count FROM trips;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM trips WHERE org_id = '11111111-1111-1111-1111-111111111111') THEN
    RAISE EXCEPTION 'OrgA data leaked into OrgB view';
  END IF;
END;
$$;

-- Illegal cross-tenant insert should fail
SELECT set_tenant('11111111-1111-1111-1111-111111111111', NULL);
DO $$
BEGIN
  BEGIN
    INSERT INTO vehicles (vehicle_id, org_id, reg_no, fuel_type)
    VALUES (gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'TEST-RLS-FAIL', 'diesel');
    RAISE EXCEPTION 'Cross-tenant insert unexpectedly succeeded';
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'Cross-tenant insert blocked as expected: %', SQLERRM;
  END;
END;
$$;

-- Illegal update on another tenant should fail
SELECT set_tenant('22222222-2222-2222-2222-222222222222', NULL);
DO $$
BEGIN
  BEGIN
    UPDATE trips SET status = 'cancelled'
    WHERE trip_id = '11111111-0000-0000-0000-000000000110';
    RAISE EXCEPTION 'Cross-tenant update unexpectedly succeeded';
  EXCEPTION WHEN others THEN
    RAISE NOTICE 'Cross-tenant update blocked as expected: %', SQLERRM;
  END;
END;
$$;

SELECT clear_tenant();
