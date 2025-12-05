<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

$posts = [];
try {
    $pdo = get_db_connection();
    $stmt = $pdo->query('SELECT id, title, slug, excerpt, published_at FROM blog_posts WHERE is_published = 1 ORDER BY published_at DESC');
    $posts = $stmt->fetchAll();
} catch (PDOException $e) {
    error_log('Failed to load blog posts: ' . $e->getMessage());
}

renderPage([
    'title' => 'Blog | Autopredator',
    'description' => 'Autopredator blog articles.',
    'content' => __DIR__ . '/pages/blog-list.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-blog',
    'data' => ['posts' => $posts],
]);
