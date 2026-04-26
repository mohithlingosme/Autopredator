<?php
declare(strict_types=1);

/**
 * Render breadcrumbs based on current page context.
 * Expected variables: $breadcrumbs (array of ['url' => '', 'label' => ''])
 */
if (!function_exists('render_breadcrumbs')) {
    function render_breadcrumbs(array $breadcrumbs): void {
        if (empty($breadcrumbs)) return;
        ?>
        <nav aria-label="Breadcrumb" class="breadcrumbs">
            <ol class="breadcrumb-list">
                <?php foreach ($breadcrumbs as $index => $crumb): ?>
                    <li class="breadcrumb-item">
                        <?php if ($index < count($breadcrumbs) - 1): ?>
                            <a href="<?= e($crumb['url']) ?>"><?= e($crumb['label']) ?></a>
                        <?php else: ?>
                            <span aria-current="page"><?= e($crumb['label']) ?></span>
                        <?php endif; ?>
                    </li>
                <?php endforeach; ?>
            </ol>
        </nav>
        <?php
    }
}
?>
