<?php
declare(strict_types=1);

require_once __DIR__ . '/../../includes/helpers.php';

function render_pagination(int $page, int $totalPages, array $query = []): void
{
    if ($totalPages <= 1) {
        return;
    }

    $prev = max(1, $page - 1);
    $next = min($totalPages, $page + 1);
    ?>
<nav class="pagination" aria-label="Pagination">
    <a class="btn btn-ghost <?= $page <= 1 ? 'disabled' : '' ?>" href="<?= e('/search.php?' . http_build_query(array_merge($query, ['page' => $prev]))) ?>">Prev</a>
    <span class="muted">Page <?= e((string) $page) ?> of <?= e((string) $totalPages) ?></span>
    <a class="btn btn-ghost <?= $page >= $totalPages ? 'disabled' : '' ?>" href="<?= e('/search.php?' . http_build_query(array_merge($query, ['page' => $next]))) ?>">Next</a>
<?php if ($totalPages > 4): ?>
    <label class="muted">Jump to
        <input type="number" min="1" max="<?= e((string) $totalPages) ?>" value="<?= e((string) $page) ?>"
               data-pagination-jump
               data-pagination-base="<?= e('/search.php?' . http_build_query($query)) ?>">
    </label>
<?php endif; ?>
</nav>
<?php
}
