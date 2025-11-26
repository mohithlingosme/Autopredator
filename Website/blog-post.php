<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/helpers.php';

$identifier = $_GET['id'] ?? '';
$post = null;
$pdo = get_db_connection();

if ($pdo && $identifier !== '') {
    try {
        if (ctype_digit((string)$identifier)) {
            $stmt = $pdo->prepare('SELECT * FROM blog_posts WHERE id = :id LIMIT 1');
            $stmt->execute(['id' => (int)$identifier]);
            $post = $stmt->fetch();
        } else {
            $stmt = $pdo->prepare('SELECT * FROM blog_posts WHERE slug = :slug LIMIT 1');
            $stmt->execute(['slug' => $identifier]);
            $post = $stmt->fetch();
        }
    } catch (PDOException $e) {
        error_log('Failed to load blog post: ' . $e->getMessage());
    }
}

$pageTitle = $post && !empty($post['title'])
    ? ($post['title'] . " | Autopredator Blog")
    : "Blog Post | Autopredator";
$pageDescription = $post && !empty($post['excerpt'])
    ? $post['excerpt']
    : "Single blog post view.";

include 'includes/header.php';
?>
<section class="section">
  <div class="container stack">
    <?php if (!$post): ?>
      <div class="surface">
        <p class="muted">Post not found.</p>
        <a class="text-emphasis" href="blog-list.php">← Back to blog</a>
      </div>
    <?php else: ?>
      <?php
        $title = escape_html($post['title'] ?? '');
        $excerpt = escape_html($post['excerpt'] ?? '');
        $content = nl2br(escape_html($post['content'] ?? ''));
        $featured = escape_html($post['featured_image'] ?? '');
        $date = '';
        if (!empty($post['created_at'])) {
            $date = date('M j, Y', strtotime($post['created_at']));
        }
      ?>
      <div class="surface stack">
        <div class="tagline">Autopredator Blog</div>
        <h1 class="text-emphasis"><?= $title; ?></h1>
        <?php if ($date): ?><p class="text-small muted"><?= escape_html($date); ?></p><?php endif; ?>
        <?php if ($excerpt): ?><p class="muted"><?= $excerpt; ?></p><?php endif; ?>
      </div>
      <article class="card stack">
        <?php if ($featured): ?>
          <img src="<?= $featured; ?>" alt="<?= $title; ?>" style="width:100%;border-radius:10px;border:1px solid var(--ap-border);">
        <?php endif; ?>
        <div><?= $content; ?></div>
      </article>
      <div>
        <a class="text-emphasis" href="blog-list.php">← Back to blog</a>
      </div>
    <?php endif; ?>
  </div>
</section>
<?php include 'includes/footer.php'; ?>
