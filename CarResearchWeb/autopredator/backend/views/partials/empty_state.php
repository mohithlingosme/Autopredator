<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/helpers.php';

function render_empty_state(string $title, string $message, string $icon = 'search', string $actionLabel = '', string $actionUrl = '', string $secondaryActionLabel = '', string $secondaryActionUrl = ''): void
{
    $icons = [
        'search' => '<svg fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path></svg>',
        'car' => '<svg fill="currentColor" viewBox="0 0 20 20"><path d="M8 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0zM15 16.5a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z"></path><path d="M3 4a1 1 0 00-1 1v10a1 1 0 001 1h1.05a2.5 2.5 0 014.9 0H10a1 1 0 001-1V5a1 1 0 00-1-1H3zM14 7a1 1 0 00-1 1v6.05A2.5 2.5 0 0115.95 16H17a1 1 0 001-1V8a1 1 0 00-1-1h-3z"></path></svg>',
        'list' => '<svg fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path></svg>',
    ];
    $iconSvg = $icons[$icon] ?? $icons['search'];
    ?>
<div class="empty-state">
    <div class="empty-state-icon">
        <?= $iconSvg ?>
    </div>
    <div class="empty-state-content">
        <p class="muted"><?= e($title) ?></p>
        <h3><?= e($message) ?></h3>
    </div>
    <div class="empty-state-actions">
        <?php if ($actionLabel && $actionUrl): ?>
            <a class="btn btn-primary" href="<?= e($actionUrl) ?>"><?= e($actionLabel) ?></a>
        <?php endif; ?>
        <?php if ($secondaryActionLabel && $secondaryActionUrl): ?>
            <a class="btn btn-outline" href="<?= e($secondaryActionUrl) ?>"><?= e($secondaryActionLabel) ?></a>
        <?php endif; ?>
    </div>
</div>
<?php
}
