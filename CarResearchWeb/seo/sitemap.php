<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/repository.php';

header('Content-Type: application/xml; charset=utf-8');

// Get all brands
$brands = get_all_manufacturers();

// Get all models
$allModels = [];
foreach ($brands as $brand) {
    $models = car_service()->getModelsByBrand($brand['name']);
    foreach ($models as $model) {
        $allModels[] = [
            'brand' => $brand['name'],
            'model' => $model['model'],
            'slug' => urlencode($model['model'])
        ];
    }
}

// Get all variants
$allVariants = [];
foreach ($allModels as $model) {
    $variants = car_service()->getVariantsByModel($model['model']);
    foreach ($variants as $variant) {
        $allVariants[] = [
            'brand' => $model['brand'],
            'model' => $model['model'],
            'variant' => $variant['name'],
            'id' => $variant['id'] ?? 1
        ];
    }
}

$baseUrl = 'https://autopredator.com'; // Update with your actual domain
$lastMod = date('Y-m-d');

echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <!-- Home page -->
    <url>
        <loc><?php echo $baseUrl; ?>/index.php</loc>
        <lastmod><?php echo $lastMod; ?></lastmod>
        <changefreq>daily</changefreq>
        <priority>1.0</priority>
    </url>

    <!-- Brand pages -->
    <?php foreach ($brands as $brand): ?>
    <url>
        <loc><?php echo $baseUrl; ?>/brand.php?manufacturer_name=<?php echo urlencode($brand['name']); ?></loc>
        <lastmod><?php echo $lastMod; ?></lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>
    <?php endforeach; ?>

    <!-- Model pages -->
    <?php foreach ($allModels as $model): ?>
    <url>
        <loc><?php echo $baseUrl; ?>/model.php?model_name=<?php echo $model['slug']; ?></loc>
        <lastmod><?php echo $lastMod; ?></lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.7</priority>
    </url>
    <?php endforeach; ?>

    <!-- Variant pages -->
    <?php foreach ($allVariants as $variant): ?>
    <url>
        <loc><?php echo $baseUrl; ?>/variant.php?variant_id=<?php echo (int) $variant['id']; ?>&amp;model_name=<?php echo urlencode($variant['model']); ?></loc>
        <lastmod><?php echo $lastMod; ?></lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.6</priority>
    </url>
    <?php endforeach; ?>

    <!-- Static pages -->
    <url>
        <loc><?php echo $baseUrl; ?>/search.php</loc>
        <lastmod><?php echo $lastMod; ?></lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.5</priority>
    </url>
</urlset>
<?php
