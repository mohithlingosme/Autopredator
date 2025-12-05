<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/helpers.php';

/**
 * Simple layout wrapper to keep every page on the same header/footer.
 *
 * @param array $options
 */
function renderPage(array $options): void
{
    $pageTitle = $options['title'] ?? 'Autopredator | Predictive Automation';
    $pageDescription = $options['description'] ?? 'Predictive fleet automation that reduces downtime, controls costs, and keeps every vehicle compliant.';
    $bodyClass = $options['bodyClass'] ?? '';
    $contentPath = $options['content'] ?? '';
    $platformUrl = $options['platformUrl'] ?? '../Car Research web (DriveMatrix)/index.html';

    include __DIR__ . '/header.php';

    if ($contentPath && file_exists($contentPath)) {
        $data = $options['data'] ?? [];
        if (!empty($data)) {
            extract($data, EXTR_SKIP);
        }
        include $contentPath;
    } else {
        echo '<section class="section"><div class="container">Content unavailable.</div></section>';
    }

    include __DIR__ . '/footer.php';
}
