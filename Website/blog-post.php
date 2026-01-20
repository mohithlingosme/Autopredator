<?php
declare(strict_types=1);

require_once __DIR__ . '/partials/layout.php';

$post = null;
$identifier = $_GET['id'] ?? null;
$slug = $_GET['slug'] ?? null;

try {
    $pdo = get_db_connection();
    if ($slug !== null && $slug !== '') {
        $stmt = $pdo->prepare('SELECT * FROM blog_posts WHERE slug = :slug AND is_published = 1 LIMIT 1');
        $stmt->execute(['slug' => $slug]);
        $post = $stmt->fetch();
    } elseif ($identifier !== null && ctype_digit((string)$identifier)) {
        $stmt = $pdo->prepare('SELECT * FROM blog_posts WHERE id = :id AND is_published = 1 LIMIT 1');
        $stmt->execute(['id' => (int)$identifier]);
        $post = $stmt->fetch();
    }
} catch (PDOException $e) {
    error_log('Failed to load blog post: ' . $e->getMessage());
}

$pageTitle = $post && !empty($post['title'])
    ? ($post['title'] . ' | Autopredator Blog')
    : 'Blog Post | Autopredator';
$pageDescription = $post && !empty($post['excerpt'])
    ? $post['excerpt']
    : 'Single blog post view.';

renderPage([
    'title' => $pageTitle,
    'description' => $pageDescription,
    'content' => __DIR__ . '/pages/blog-post.php',
    'platformUrl' => '../Car Research web (DriveMatrix)/index.html',
    'bodyClass' => 'page-blog-post',
    'data' => ['post' => $post],
]);
