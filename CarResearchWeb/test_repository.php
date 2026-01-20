<?php
require_once 'includes/repository.php';

echo "Testing repository functions...\n\n";

echo "USE_JSON constant: " . (USE_JSON ? 'true' : 'false') . "\n\n";

echo "Testing getBrands():\n";
$brands = getBrands();
var_dump($brands);

echo "\nTesting getModelsByBrand('Maruti'):\n";
$models = getModelsByBrand('Maruti');
var_dump($models);

echo "\nTesting searchCars():\n";
$cars = searchCars(['limit' => 2]);
var_dump($cars);

echo "\nTest completed.\n";
