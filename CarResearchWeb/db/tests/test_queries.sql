-- Run after loading migrations and seeds. These queries should return zero rows unless otherwise noted.

-- 1) Orphan variants (variants without a model/manufacturer chain) should be zero rows.
SELECT v.id AS variant_id
FROM autopredator_cars_research.variants v
LEFT JOIN autopredator_cars_research.models m ON v.model_id = m.id
LEFT JOIN autopredator_cars_research.manufacturers mf ON m.manufacturer_id = mf.id
WHERE m.id IS NULL OR mf.id IS NULL;

-- 2) Orphan price history (variant must exist in research DB) should be zero rows.
SELECT ph.id AS price_history_id
FROM autopredator_pricing.price_history ph
LEFT JOIN autopredator_cars_research.variants v ON ph.variant_id = v.id
WHERE v.id IS NULL;

-- 3) Page entities should only point at existing research entities; expect zero rows.
SELECT pe.id AS page_entity_id, pe.entity_type, pe.entity_id
FROM autopredator_site_cms.page_entities pe
LEFT JOIN autopredator_cars_research.manufacturers mf ON pe.entity_type = 'manufacturer' AND pe.entity_id = mf.id
LEFT JOIN autopredator_cars_research.models m ON pe.entity_type = 'model' AND pe.entity_id = m.id
LEFT JOIN autopredator_cars_research.variants v ON pe.entity_type = 'variant' AND pe.entity_id = v.id
WHERE (pe.entity_type = 'manufacturer' AND mf.id IS NULL)
   OR (pe.entity_type = 'model' AND m.id IS NULL)
   OR (pe.entity_type = 'variant' AND v.id IS NULL);

-- 4) Unique page slugs check; expect zero rows.
SELECT slug, COUNT(*) AS cnt
FROM autopredator_site_cms.pages
GROUP BY slug
HAVING COUNT(*) > 1;

-- 5) Variant comparison: spec differences between variant 1 and 2 (values should differ for power, torque, mileage).
SELECT
  sd.name AS spec_name,
  MAX(CASE WHEN vs.variant_id = 1 THEN COALESCE(CAST(vs.value_number AS CHAR), vs.value_text) END) AS variant_1_value,
  MAX(CASE WHEN vs.variant_id = 2 THEN COALESCE(CAST(vs.value_number AS CHAR), vs.value_text) END) AS variant_2_value
FROM autopredator_cars_research.spec_definitions sd
JOIN autopredator_cars_research.variant_specs vs
  ON sd.id = vs.spec_definition_id AND vs.variant_id IN (1, 2)
WHERE sd.spec_key IN ('engine_displacement_cc','max_power_bhp','max_torque_nm','mileage_kmpl')
GROUP BY sd.id, sd.name;

-- 6) Price trend ordering for variant 1 (should be newest first by captured_on then id).
SELECT ph.id, ph.price_type, ph.price_amount, ph.captured_on, c.name AS city_name
FROM autopredator_pricing.price_history ph
JOIN autopredator_pricing.cities c ON ph.city_id = c.id
WHERE ph.variant_id = 1
ORDER BY ph.captured_on DESC, ph.id DESC;
