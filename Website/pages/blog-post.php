<?php $post = $post ?? null; ?>
<section class="section">
  <div class="container stack">
    <?php if (!$post): ?>
      <div class="surface">
        <p class="muted">Post not found.</p>
        <a class="text-emphasis" href="blog-list.php">Back to blog</a>
      </div>
    <?php else: ?>
      <?php
        $title = escape_html($post['title'] ?? '');
        $excerpt = escape_html($post['excerpt'] ?? '');
        $featured = escape_html($post['featured_image'] ?? '');
        $content = $post['content'] ?? '';
        $date = '';
        if (!empty($post['published_at'])) {
            $date = date('M j, Y', strtotime((string)$post['published_at']));
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
          <img src="<?= $featured; ?>" alt="<?= $title; ?>" class="featured-image">
        <?php endif; ?>
        <div class="stack">
          <?= $content !== '' ? $content : '<p class="muted">No content available.</p>'; ?>
        </div>
      </article>
      <div>
        <a class="text-emphasis" href="blog-list.php">Back to blog</a>
      </div>
    <?php endif; ?>
  </div>
</section>
