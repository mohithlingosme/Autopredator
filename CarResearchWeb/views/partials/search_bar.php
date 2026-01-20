<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/helpers.php';
$queryValue = $query ?? get_query('q');
?>
<?php $searchId = $id ?? 'search-q'; ?>
<form action="search.php" method="get" class="search-form" role="search">
    <label class="sr-only" for="<?= e($searchId) ?>">Search cars</label>
    <input type="search" id="<?= e($searchId) ?>" name="q" aria-label="Search cars"
           placeholder="Search by brand, model or keyword"
           value="<?= e($queryValue) ?>"
           autocomplete="off"
           data-search-input>
    <button type="submit" class="btn btn-primary">Search</button>
    <div class="search-suggestions" data-search-suggestions hidden></div>
</form>
