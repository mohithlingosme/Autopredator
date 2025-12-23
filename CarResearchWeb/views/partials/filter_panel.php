<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/helpers.php';

/**
 * @param array<string, mixed> $filters
 * @param array<string, array<int, string>> $options
 */
function render_filter_panel(array $filters, array $options = []): void
{
    $fuels = $options['fuel_types'] ?? [];
    $bodyTypes = $options['body_types'] ?? [];
    ?>
<aside class="filter-panel" data-filter-panel>
    <div class="filter-panel__header">
        <h3>Filters</h3>
        <button class="btn btn-ghost" type="button" data-filter-close aria-label="Close filters">Close</button>
    </div>
    <div class="filter-group">
        <?php if (!empty($options['manufacturers'] ?? [])): ?>
            <label for="filter-make">Manufacturer</label>
            <select id="filter-make" name="manufacturer_id">
                <option value="">Any</option>
                <?php foreach ($options['manufacturers'] as $man): ?>
                    <option value="<?= (int) ($man['id'] ?? 0) ?>" <?= (isset($filters['manufacturer_id']) && (int) $filters['manufacturer_id'] === (int) ($man['id'] ?? 0)) ? 'selected' : '' ?>><?= e($man['name'] ?? '') ?></option>
                <?php endforeach; ?>
            </select>
        <?php endif; ?>
    </div>
    <div class="filter-group">
        <label for="filter-search">Keyword</label>
        <input id="filter-search" type="text" name="q" value="<?= e($filters['search_text'] ?? '') ?>" placeholder="Brand or model">
    </div>
    <div class="filter-group">
        <label for="filter-body">Body Type</label>
        <select id="filter-body" name="body_type">
            <option value="">Any</option>
            <?php foreach ($bodyTypes as $body): ?>
                <?php
                $selected = false;
                if (isset($filters['body_type'])) {
                    $filterBodyTypes = is_array($filters['body_type']) ? $filters['body_type'] : [$filters['body_type']];
                    $selected = in_array(strtolower($body), array_map('strtolower', $filterBodyTypes), true);
                }
                ?>
                <option value="<?= e($body) ?>" <?= $selected ? 'selected' : '' ?>><?= e($body) ?></option>
            <?php endforeach; ?>
        </select>
    </div>
    <div class="filter-group">
        <p class="filter-label">Fuel Type</p>
        <div class="chip-row">
            <?php foreach ($fuels as $fuel): ?>
                <?php
                $active = false;
                if (isset($filters['fuel_type'])) {
                    $active = in_array(strtolower($fuel), array_map('strtolower', (array) $filters['fuel_type']), true);
                }
                ?>
                <label class="chip">
                    <input type="checkbox" name="fuel_type[]" value="<?= e($fuel) ?>" <?= $active ? 'checked' : '' ?>>
                    <span><?= e($fuel) ?></span>
                </label>
            <?php endforeach; ?>
        </div>
    </div>
    <div class="filter-group dual">
        <label>
            Min Budget (Rs)
            <input type="number" name="min_budget" value="<?= e((string) ($filters['min_budget'] ?? '')) ?>" min="0" step="50000" placeholder="0">
        </label>
        <label>
            Max Budget (Rs)
            <input type="number" name="max_budget" value="<?= e((string) ($filters['max_budget'] ?? '')) ?>" min="0" step="50000" placeholder="5000000">
        </label>
    </div>
    <div class="filter-actions">
        <button class="btn btn-primary" type="submit">Apply</button>
        <a class="btn btn-ghost" href="search.php">Reset</a>
    </div>
<?php
}
