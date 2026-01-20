USE autopredator_cars;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SELECT COUNT(*) AS brands_missing_slug
FROM brands
WHERE slug IS NULL OR TRIM(slug) = '';

SELECT COUNT(*) AS models_missing_slug
FROM models
WHERE slug IS NULL OR TRIM(slug) = '';

SELECT COUNT(*) AS variants_missing_slug
FROM variants
WHERE slug IS NULL OR TRIM(slug) = '';

SELECT COUNT(*) AS images_missing_url
FROM images
WHERE image_url IS NULL OR TRIM(image_url) = '';

SELECT COUNT(*) AS price_history_missing_region
FROM variant_price_history
WHERE region IS NULL OR TRIM(region) = '';

SELECT COUNT(*) AS price_history_missing_as_of_date
FROM variant_price_history
WHERE as_of_date IS NULL;

SELECT COUNT(*) AS variants_multiple_thumbnails
FROM (
  SELECT variant_id
  FROM images
  WHERE is_thumbnail = 1
  GROUP BY variant_id
  HAVING COUNT(*) > 1
) AS t;
