<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/helpers.php';

function render_empty_state(string $title, string $message, string $actionLabel = '', string $actionUrl = '', string $secondaryActionLabel = '', string $secondaryActionUrl = ''): void
{
    ?>
<div class="empty-state">
    <div>
        <p class="muted"><?= e($title) ?></p>
        <h3><?= e($message) ?></h3>
        <div class="empty-state-actions">
            <?php if ($actionLabel && $actionUrl): ?>
                <a class="btn btn-primary" href="<?= e($actionUrl) ?>"><?= e($actionLabel) ?></a>
            <?php endif; ?>
            <?php if ($secondaryActionLabel && $secondaryActionUrl): ?>
                <a class="btn btn-outline" href="<?= e($secondaryActionUrl) ?>"><?= e($secondaryActionLabel) ?></a>
            <?php endif; ?>
        </div>
    </div>
</div>
<?php
}
