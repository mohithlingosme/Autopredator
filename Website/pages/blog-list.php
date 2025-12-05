<?php $posts = $posts ?? []; ?>
<section class="section">
  <div class="container stack">
    <div class="section-heading">
      <div class="tagline">Blog</div>
      <h1>Insights on predictive fleet automation</h1>
      <p class="muted">Updates on data, safety, and operational best practices.</p>
    </div>

    <?php if (empty($posts)): ?>
      <div class="surface">
        <p class="muted">No posts yet. Check back soon.</p>
      </div>
    <?php else: ?>
      <div class="stack">
        <?php foreach ($posts as $post): ?>
          <?php
            $title = escape_html($post['title'] ?? '');
            $excerpt = escape_html($post['excerpt'] ?? '');
            $date = '';
            if (!empty($post['published_at'])) {
                $date = date('M j, Y', strtotime((string)$post['published_at']));
            }
            $id = (int)($post['id'] ?? 0);
            $slug = trim((string)($post['slug'] ?? ''));
            $link = $slug !== '' ? "blog-post.php?slug=" . urlencode($slug) : ($id > 0 ? "blog-post.php?id={$id}" : '#');
          ?>
          <article class="surface stack">
            <h2 class="text-emphasis"><?= $title; ?></h2>
            <?php if ($date): ?><p class="text-small muted"><?= escape_html($date); ?></p><?php endif; ?>
            <p class="muted"><?= $excerpt; ?></p>
            <a class="text-emphasis" href="<?= $link; ?>">Read more -></a>
          </article>
        <?php endforeach; ?>
      </div>
    <?php endif; ?>
  </div>
</section>
