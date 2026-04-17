-- Hardening migration for autopredator_cars.
-- Makes slugs/image_url/region/as_of_date NOT NULL, enforces uniqueness, cascades, and thumbnail invariant.

CREATE DATABASE IF NOT EXISTS autopredator_cars
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE autopredator_cars;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SET @current_db := DATABASE();

-- Helper: drop index if it exists
DROP PROCEDURE IF EXISTS drop_index_if_exists;
DELIMITER //
CREATE PROCEDURE drop_index_if_exists(IN tbl VARCHAR(128), IN idx VARCHAR(128))
BEGIN
  DECLARE idx_count INT DEFAULT 0;
  SELECT COUNT(*) INTO idx_count
  FROM INFORMATION_SCHEMA.STATISTICS
  WHERE TABLE_SCHEMA = @current_db AND TABLE_NAME = tbl AND INDEX_NAME = idx;

  IF idx_count > 0 THEN
    SET @sql := CONCAT('ALTER TABLE ', tbl, ' DROP INDEX ', idx);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END//
DELIMITER ;

-- Helper: drop FK if present then add ON DELETE CASCADE
DROP PROCEDURE IF EXISTS replace_fk_with_cascade;
DELIMITER //
CREATE PROCEDURE replace_fk_with_cascade(
  IN tbl VARCHAR(128),
  IN col VARCHAR(128),
  IN ref_tbl VARCHAR(128),
  IN ref_col VARCHAR(128),
  IN fk_name VARCHAR(128)
)
BEGIN
  DECLARE existing_fk VARCHAR(128);
  SELECT CONSTRAINT_NAME INTO existing_fk
  FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
  WHERE TABLE_SCHEMA = @current_db
    AND TABLE_NAME = tbl
    AND COLUMN_NAME = col
    AND REFERENCED_TABLE_NAME IS NOT NULL
  LIMIT 1;

  IF existing_fk IS NOT NULL AND existing_fk <> '' THEN
    SET @drop_fk := CONCAT('ALTER TABLE ', tbl, ' DROP FOREIGN KEY ', existing_fk);
    PREPARE stmt_drop FROM @drop_fk;
    EXECUTE stmt_drop;
    DEALLOCATE PREPARE stmt_drop;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = @current_db
      AND CONSTRAINT_NAME = fk_name
      AND TABLE_NAME = tbl
  ) THEN
    SET @add_fk := CONCAT(
      'ALTER TABLE ', tbl, ' ADD CONSTRAINT ', fk_name,
      ' FOREIGN KEY (', col, ') REFERENCES ', ref_tbl, '(', ref_col, ') ON DELETE CASCADE'
    );
    PREPARE stmt_add FROM @add_fk;
    EXECUTE stmt_add;
    DEALLOCATE PREPARE stmt_add;
  END IF;
END//
DELIMITER ;

-- Helper: ensure unique index if missing
DROP PROCEDURE IF EXISTS ensure_unique_idx;
DELIMITER //
CREATE PROCEDURE ensure_unique_idx(
  IN tbl VARCHAR(128),
  IN idx VARCHAR(128),
  IN cols VARCHAR(256)
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = @current_db AND TABLE_NAME = tbl AND INDEX_NAME = idx
  ) THEN
    SET @sql_idx := CONCAT('ALTER TABLE ', tbl, ' ADD UNIQUE INDEX ', idx, ' (', cols, ')');
    PREPARE stmt_idx FROM @sql_idx;
    EXECUTE stmt_idx;
    DEALLOCATE PREPARE stmt_idx;
  END IF;
END//
DELIMITER ;

-- Backfill and enforce non-null slugs on brands/models/variants
UPDATE brands
SET slug = LOWER(REPLACE(TRIM(name), ' ', '-'))
WHERE (slug IS NULL OR slug = '')
  AND name IS NOT NULL
  AND TRIM(name) <> '';

WITH brand_slug_dupes AS (
  SELECT id, slug, ROW_NUMBER() OVER (PARTITION BY slug ORDER BY id) AS rn
  FROM brands
  WHERE slug IS NOT NULL AND slug <> ''
)
UPDATE brands b
JOIN brand_slug_dupes d ON b.id = d.id
SET b.slug = CONCAT(b.slug, '-', d.rn - 1)
WHERE d.rn > 1;

ALTER TABLE brands
  MODIFY COLUMN slug VARCHAR(191) NOT NULL;
CALL ensure_unique_idx('brands', 'uq_brands_slug', 'slug');

UPDATE models
SET slug = LOWER(REPLACE(TRIM(name), ' ', '-'))
WHERE (slug IS NULL OR slug = '')
  AND name IS NOT NULL
  AND TRIM(name) <> '';

WITH model_slug_dupes AS (
  SELECT id, slug, ROW_NUMBER() OVER (PARTITION BY slug ORDER BY id) AS rn
  FROM models
  WHERE slug IS NOT NULL AND slug <> ''
)
UPDATE models m
JOIN model_slug_dupes d ON m.id = d.id
SET m.slug = CONCAT(m.slug, '-', d.rn - 1)
WHERE d.rn > 1;

ALTER TABLE models
  MODIFY COLUMN slug VARCHAR(191) NOT NULL;
CALL ensure_unique_idx('models', 'uq_models_slug', 'slug');

UPDATE variants
SET slug = LOWER(REPLACE(TRIM(name), ' ', '-'))
WHERE (slug IS NULL OR slug = '')
  AND name IS NOT NULL
  AND TRIM(name) <> '';

WITH variant_slug_dupes AS (
  SELECT id, slug, ROW_NUMBER() OVER (PARTITION BY slug ORDER BY id) AS rn
  FROM variants
  WHERE slug IS NOT NULL AND slug <> ''
)
UPDATE variants v
JOIN variant_slug_dupes d ON v.id = d.id
SET v.slug = CONCAT(v.slug, '-', d.rn - 1)
WHERE d.rn > 1;

ALTER TABLE variants
  MODIFY COLUMN slug VARCHAR(191) NOT NULL;
CALL ensure_unique_idx('variants', 'uq_variants_slug', 'slug');

-- Clean up and enforce images.image_url NOT NULL and uniqueness per variant
DELETE FROM images WHERE image_url IS NULL OR TRIM(image_url) = '';
ALTER TABLE images
  MODIFY COLUMN image_url VARCHAR(1024) NOT NULL;
CALL ensure_unique_idx('images', 'uq_images_variant_url', 'variant_id, image_url');

-- Region/as_of_date backfill and non-null enforcement for price history
UPDATE variant_price_history
SET region = 'IN'
WHERE region IS NULL OR TRIM(region) = '';

UPDATE variant_price_history
SET as_of_date = COALESCE(as_of_date, DATE(created_at))
WHERE as_of_date IS NULL;

ALTER TABLE variant_price_history
  MODIFY COLUMN region VARCHAR(10) NOT NULL,
  MODIFY COLUMN as_of_date DATE NOT NULL;

CALL ensure_unique_idx(
  'variant_price_history',
  'uq_variant_price_history_latest',
  'variant_id, price_type, region, as_of_date'
);

-- Ensure cascades for brand -> models and model -> variants
CALL replace_fk_with_cascade('models', 'brand_id', 'brands', 'id', 'fk_models_brand_cascade');
CALL replace_fk_with_cascade('variants', 'model_id', 'models', 'id', 'fk_variants_model_cascade');

-- Enforce only one thumbnail per variant via generated column + unique key
ALTER TABLE images
  ADD COLUMN IF NOT EXISTS thumbnail_variant_id BIGINT GENERATED ALWAYS AS (
    CASE WHEN is_thumbnail = 1 THEN variant_id ELSE NULL END
  ) STORED;
CALL ensure_unique_idx('images', 'uq_images_single_thumbnail', 'thumbnail_variant_id');

-- Drop redundant indexes
CALL drop_index_if_exists('variants', 'idx_variants_model');
CALL drop_index_if_exists('variant_feature_values', 'uq_variant_feature');

-- Cleanup helper routines
DROP PROCEDURE IF EXISTS drop_index_if_exists;
DROP PROCEDURE IF EXISTS replace_fk_with_cascade;
DROP PROCEDURE IF EXISTS ensure_unique_idx;
