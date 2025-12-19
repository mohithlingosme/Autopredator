<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/helpers.php';

function render_error_state(string $title, string $message): void
{
    ?>
<div class="error-state">
    <div>
        <p class="muted"><?= e($title) ?></p>
        <h3><?= e($message) ?></h3>
    </div>
</div>
<?php
}
