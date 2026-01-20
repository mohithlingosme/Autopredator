-- Paste-ready tenant-aware queries. Ensure app.org_id is set.

-- Dashboard counts
WITH org AS (SELECT current_setting('app.org_id', true)::uuid AS org_id)
SELECT
  (SELECT COUNT(*) FROM trips t JOIN org o ON o.org_id = t.org_id WHERE t.status IN ('in_progress','planned')) AS active_trips,
  (SELECT COUNT(*) FROM vehicles v JOIN org o ON o.org_id = v.org_id WHERE v.status = 'active') AS active_vehicles,
  (SELECT COUNT(*) FROM maintenance_tickets mt JOIN org o ON o.org_id = mt.org_id WHERE mt.status IN ('open','in_progress')) AS open_maintenance,
  (SELECT COUNT(*) FROM documents d JOIN org o ON o.org_id = d.org_id WHERE d.expiry_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days' AND d.deleted_at IS NULL) AS expiring_documents;

-- Trip list with filters
-- Params: :start_from, :start_to, :status, :vehicle_id, :driver_id, :customer_id
SELECT
  t.trip_id, t.trip_no, t.start_at, t.end_at, t.status,
  t.vehicle_id, t.driver_id, t.customer_id,
  t.origin, t.destination, t.distance_km, t.revenue_paise
FROM trips t
WHERE t.org_id = current_org_id()
  AND (:start_from::timestamptz IS NULL OR t.start_at >= :start_from)
  AND (:start_to::timestamptz IS NULL OR t.start_at <= :start_to)
  AND (:status::trip_status IS NULL OR t.status = :status::trip_status)
  AND (:vehicle_id::uuid IS NULL OR t.vehicle_id = :vehicle_id)
  AND (:driver_id::uuid IS NULL OR t.driver_id = :driver_id)
  AND (:customer_id::uuid IS NULL OR t.customer_id = :customer_id)
ORDER BY t.start_at DESC
LIMIT :limit OFFSET :offset;

-- Profitability per vehicle per month (paise)
WITH org AS (SELECT current_org_id() AS org_id),
trip_rev AS (
  SELECT vehicle_id, date_trunc('month', start_at) AS month, SUM(COALESCE(revenue_paise,0)) AS revenue_paise
  FROM trips t JOIN org o ON o.org_id = t.org_id
  WHERE t.start_at IS NOT NULL
  GROUP BY 1,2
),
fuel AS (
  SELECT vehicle_id, date_trunc('month', filled_at) AS month, SUM(total_amount_paise) AS fuel_paise
  FROM fuel_logs f JOIN org o ON o.org_id = f.org_id
  GROUP BY 1,2
),
expenses AS (
  SELECT vehicle_id, date_trunc('month', incurred_at) AS month, SUM(amount_paise) AS expense_paise
  FROM expense_logs e JOIN org o ON o.org_id = e.org_id
  GROUP BY 1,2
),
maintenance AS (
  SELECT mt.vehicle_id, date_trunc('month', COALESCE(mt.closed_at, mt.opened_at)) AS month, SUM(COALESCE(mi.total_cost_paise,0)) AS maint_paise
  FROM maintenance_tickets mt
  JOIN org o ON o.org_id = mt.org_id
  LEFT JOIN maintenance_items mi ON mi.org_id = mt.org_id AND mi.maintenance_ticket_id = mt.maintenance_ticket_id
  GROUP BY 1,2
)
SELECT
  v.vehicle_id,
  to_char(m.month, 'YYYY-MM') AS month,
  COALESCE(trip_rev.revenue_paise,0) AS revenue_paise,
  COALESCE(fuel.fuel_paise,0) AS fuel_paise,
  COALESCE(expenses.expense_paise,0) AS expense_paise,
  COALESCE(maintenance.maint_paise,0) AS maintenance_paise,
  COALESCE(trip_rev.revenue_paise,0)
    - COALESCE(fuel.fuel_paise,0)
    - COALESCE(expenses.expense_paise,0)
    - COALESCE(maintenance.maint_paise,0) AS profit_paise
FROM (
  SELECT DISTINCT vehicle_id, month FROM (
    SELECT vehicle_id, month FROM trip_rev
    UNION
    SELECT vehicle_id, month FROM fuel
    UNION
    SELECT vehicle_id, month FROM expenses
    UNION
    SELECT vehicle_id, month FROM maintenance
  ) m
) m
LEFT JOIN trip_rev ON trip_rev.vehicle_id = m.vehicle_id AND trip_rev.month = m.month
LEFT JOIN fuel ON fuel.vehicle_id = m.vehicle_id AND fuel.month = m.month
LEFT JOIN expenses ON expenses.vehicle_id = m.vehicle_id AND expenses.month = m.month
LEFT JOIN maintenance ON maintenance.vehicle_id = m.vehicle_id AND maintenance.month = m.month
LEFT JOIN vehicles v ON v.vehicle_id = m.vehicle_id;

-- Customer outstanding invoices and aging (paise)
SELECT
  i.customer_id,
  c.name AS customer_name,
  SUM(i.total_paise - COALESCE(paid.paid_paise,0)) AS outstanding_paise,
  SUM(CASE WHEN age(CURRENT_DATE, i.invoice_date) <= INTERVAL '30 days' THEN i.total_paise - COALESCE(paid.paid_paise,0) ELSE 0 END) AS bucket_0_30,
  SUM(CASE WHEN age(CURRENT_DATE, i.invoice_date) > INTERVAL '30 days' AND age(CURRENT_DATE, i.invoice_date) <= INTERVAL '60 days' THEN i.total_paise - COALESCE(paid.paid_paise,0) ELSE 0 END) AS bucket_31_60,
  SUM(CASE WHEN age(CURRENT_DATE, i.invoice_date) > INTERVAL '60 days' AND age(CURRENT_DATE, i.invoice_date) <= INTERVAL '90 days' THEN i.total_paise - COALESCE(paid.paid_paise,0) ELSE 0 END) AS bucket_61_90,
  SUM(CASE WHEN age(CURRENT_DATE, i.invoice_date) > INTERVAL '90 days' THEN i.total_paise - COALESCE(paid.paid_paise,0) ELSE 0 END) AS bucket_90_plus
FROM invoices i
LEFT JOIN (
  SELECT invoice_id, SUM(amount_paise) AS paid_paise
  FROM payments
  WHERE org_id = current_org_id()
  GROUP BY invoice_id
) paid ON paid.invoice_id = i.invoice_id
LEFT JOIN customers c ON c.customer_id = i.customer_id
WHERE i.org_id = current_org_id()
  AND i.status IN ('issued','overdue','draft')
GROUP BY i.customer_id, c.name
ORDER BY outstanding_paise DESC;

-- Maintenance due list (km-based or date-based)
SELECT
  mp.maintenance_plan_id,
  mp.vehicle_id,
  v.reg_no,
  mp.name AS plan_name,
  mp.interval_km,
  mp.interval_days,
  mp.last_service_odometer_km,
  mp.last_service_at,
  v.current_odometer_km,
  CASE
    WHEN mp.interval_km IS NOT NULL AND v.current_odometer_km - COALESCE(mp.last_service_odometer_km,0) >= mp.interval_km THEN TRUE
    WHEN mp.interval_days IS NOT NULL AND mp.last_service_at IS NOT NULL AND mp.last_service_at <= NOW() - (mp.interval_days || ' days')::interval THEN TRUE
    WHEN mp.interval_days IS NOT NULL AND mp.last_service_at IS NULL THEN TRUE
    ELSE FALSE
  END AS is_due
FROM maintenance_plans mp
JOIN vehicles v ON v.vehicle_id = mp.vehicle_id
WHERE mp.org_id = current_org_id();
