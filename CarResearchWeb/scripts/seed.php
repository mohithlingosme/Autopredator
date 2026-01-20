<?php

echo "Starting seed process...\n";

$normalizedDir = __DIR__ . '/../data/normalized';
$files = ['brands.json', 'models.json', 'variants.json'];

foreach ($files as $file) {
    if (!file_exists($normalizedDir . '/' . $file)) {
        echo "❌ Error: Normalized file '{$file}' not found.\n";
        echo "Please run 'php scripts/normalize.php' first.\n";
        exit(1);
    }
}

echo "✅ Seed check complete. Normalized data files are present.\n";
echo "Application can now read from /data/normalized/*.json\n";
exit(0);