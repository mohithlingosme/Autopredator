<?php
// Blog category template
// Variables available: $posts, $pagination, $category, $page_title, $page_description
?>

<div class="blog-category-container">
    <div class="category-header">
        <div class="category-info">
            <h1><?php echo htmlspecialchars($category['name']); ?></h1>
            <?php if ($category['description']): ?>
                <p class="category-description"><?php echo htmlspecialchars($category['description']); ?></p>
            <?php endif; ?>
            <div class="category-stats">
                <span class="post-count"><?php echo $category['post_count']; ?> articles</span>
            </div>
        </div>

        <?php if ($category['parent_id']): ?>
            <nav class="breadcrumb">
                <a href="/blog.php">Blog</a>
                <span class="separator">→</span>
                <span class="current"><?php echo htmlspecialchars($category['name']); ?></span>
            </nav>
        <?php else: ?>
            <nav class="breadcrumb">
                <a href="/blog.php">Blog</a>
                <span class="separator">→</span>
                <span class="current"><?php echo htmlspecialchars($category['name']); ?></span>
            </nav>
        <?php endif; ?>
    </div>

    <div class="category-content">
        <?php if (empty($posts)): ?>
            <div class="empty-state">
                <h2>No posts in this category</h2>
                <p>There are no published posts in the "<?php echo htmlspecialchars($category['name']); ?>" category yet.</p>
                <a href="/blog.php" class="back-to-blog">← Back to Blog</a>
            </div>
        <?php else: ?>
            <div class="posts-grid">
                <?php foreach ($posts as $post): ?>
                    <article class="post-card">
                        <?php if ($post['featured_image']): ?>
                            <div class="post-image">
                                <img src="<?php echo htmlspecialchars($post['featured_image']); ?>"
                                     alt="<?php echo htmlspecialchars($post['title']); ?>"
                                     loading="lazy">
                            </div>
                        <?php endif; ?>

                        <div class="post-content">
                            <div class="post-meta">
                                <span class="post-date">
                                    <?php echo date('M j, Y', strtotime($post['published_at'])); ?>
                                </span>
                                <span class="post-author">
                                    By <?php echo htmlspecialchars($post['author_name']); ?>
                                </span>
                            </div>

                            <h2 class="post-title">
                                <a href="/blog-post.php?slug=<?php echo htmlspecialchars($post['slug']); ?>">
                                    <?php echo htmlspecialchars($post['title']); ?>
                                </a>
                            </h2>

                            <p class="post-excerpt">
                                <?php echo htmlspecialchars($post['excerpt']); ?>
                            </p>

                            <div class="post-footer">
                                <div class="post-stats">
                                    <span class="reading-time">
                                        <?php echo $post['reading_time']; ?> min read
                                    </span>
                                    <?php if (!empty($post['tags'])): ?>
                                        <div class="post-tags">
                                            <?php foreach ($post['tags'] as $tag): ?>
                                                <span class="tag"><?php echo htmlspecialchars($tag['name']); ?></span>
                                            <?php endforeach; ?>
                                        </div>
                                    <?php endif; ?>
                                </div>
                                <a href="/blog-post.php?slug=<?php echo htmlspecialchars($post['slug']); ?>" class="read-more">
                                    Read More →
                                </a>
                            </div>
                        </div>
                    </article>
                <?php endforeach; ?>
            </div>

            <!-- Pagination -->
            <?php if ($pagination['total_pages'] > 1): ?>
                <nav class="pagination" aria-label="Category pagination">
                    <?php
                    $current_page = $pagination['current_page'];
                    $total_pages = $pagination['total_pages'];
                    $base_url = '/blog-category.php?slug=' . urlencode($category['slug']) . '&page=';
                    ?>

                    <?php if ($current_page > 1): ?>
                        <a href="<?php echo $base_url . ($current_page - 1); ?>" class="pagination-prev">
                            ← Previous
                        </a>
                    <?php endif; ?>

                    <div class="pagination-numbers">
                        <?php
                        $start_page = max(1, $current_page - 2);
                        $end_page = min($total_pages, $current_page + 2);

                        if ($start_page > 1): ?>
                            <a href="<?php echo $base_url; ?>1">1</a>
                            <?php if ($start_page > 2): ?>
                                <span class="pagination-dots">...</span>
                            <?php endif; ?>
                        <?php endif; ?>

                        <?php for ($i = $start_page; $i <= $end_page; $i++): ?>
                            <?php if ($i === $current_page): ?>
                                <span class="pagination-current"><?php echo $i; ?></span>
                            <?php else: ?>
                                <a href="<?php echo $base_url . $i; ?>"><?php echo $i; ?></a>
                            <?php endif; ?>
                        <?php endfor; ?>

                        <?php if ($end_page < $total_pages): ?>
                            <?php if ($end_page < $total_pages - 1): ?>
                                <span class="pagination-dots">...</span>
                            <?php endif; ?>
                            <a href="<?php echo $base_url . $total_pages; ?>"><?php echo $total_pages; ?></a>
                        <?php endif; ?>
                    </div>

                    <?php if ($current_page < $total_pages): ?>
                        <a href="<?php echo $base_url . ($current_page + 1); ?>" class="pagination-next">
                            Next →
                        </a>
                    <?php endif; ?>
                </nav>
            <?php endif; ?>
        <?php endif; ?>
    </div>

    <!-- Related Categories -->
    <section class="related-categories">
        <h3>Other Categories</h3>
        <div class="categories-grid">
            <!-- This would be populated with sibling categories -->
            <div class="category-placeholder">
                <p>Explore other blog categories to find more content.</p>
                <a href="/blog.php" class="view-all-categories">View All Categories</a>
            </div>
        </div>
    </section>
</div>

<style>
.blog-category-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
}

.category-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 3rem;
    padding-bottom: 2rem;
    border-bottom: 1px solid var(--border);
}

.category-info h1 {
    font-size: 2.5rem;
    color: var(--text-primary);
    margin-bottom: 1rem;
}

.category-description {
    font-size: 1.1rem;
    color: var(--text-secondary);
    margin-bottom: 1rem;
    max-width: 600px;
}

.category-stats {
    margin-top: 1rem;
}

.post-count {
    background: var(--bg-secondary);
    padding: 0.5rem 1rem;
    border-radius: 20px;
    font-size: 0.9rem;
    color: var(--text-secondary);
}

.breadcrumb {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.9rem;
    color: var(--text-secondary);
}

.breadcrumb a {
    color: var(--primary);
    text-decoration: none;
}

.breadcrumb a:hover {
    text-decoration: underline;
}

.separator {
    color: var(--text-secondary);
}

.category-content {
    min-height: 400px;
}

.posts-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 2rem;
    margin-bottom: 3rem;
}

.post-card {
    background: var(--bg-card);
    border-radius: 12px;
    overflow: hidden;
    box-shadow: var(--shadow-sm);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.post-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
}

.post-image {
    width: 100%;
    height: 200px;
    overflow: hidden;
}

.post-image img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.3s ease;
}

.post-card:hover .post-image img {
    transform: scale(1.05);
}

.post-content {
    padding: 1.5rem;
}

.post-meta {
    display: flex;
    gap: 1rem;
    font-size: 0.9rem;
    color: var(--text-secondary);
    margin-bottom: 1rem;
}

.post-title {
    font-size: 1.5rem;
    margin-bottom: 1rem;
}

.post-title a {
    color: var(--text-primary);
    text-decoration: none;
}

.post-title a:hover {
    color: var(--primary);
}

.post-excerpt {
    color: var(--text-secondary);
    line-height: 1.6;
    margin-bottom: 1rem;
}

.post-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.post-stats {
    display: flex;
    align-items: center;
    gap: 1rem;
    font-size: 0.9rem;
    color: var(--text-secondary);
}

.post-tags {
    display: flex;
    gap: 0.5rem;
}

.tag {
    background: var(--bg-secondary);
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.8rem;
}

.read-more {
    color: var(--primary);
    font-weight: 500;
    text-decoration: none;
}

.read-more:hover {
    text-decoration: underline;
}

/* Pagination */
.pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 1rem;
    margin-top: 3rem;
    padding: 2rem 0;
}

.pagination-numbers {
    display: flex;
    gap: 0.5rem;
}

.pagination a,
.pagination-current {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 500;
}

.pagination a {
    color: var(--text-secondary);
    border: 1px solid var(--border);
}

.pagination a:hover {
    background: var(--bg-secondary);
    color: var(--text-primary);
}

.pagination-current {
    background: var(--primary);
    color: white;
}

.pagination-dots {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    color: var(--text-secondary);
}

.pagination-prev,
.pagination-next {
    padding: 0.5rem 1rem;
    border: 1px solid var(--border);
    border-radius: 6px;
    text-decoration: none;
    font-weight: 500;
    color: var(--text-primary);
}

.pagination-prev:hover,
.pagination-next:hover {
    background: var(--bg-secondary);
}

/* Empty state */
.empty-state {
    text-align: center;
    padding: 4rem 2rem;
    color: var(--text-secondary);
}

.empty-state h2 {
    color: var(--text-primary);
    margin-bottom: 1rem;
}

.back-to-blog {
    display: inline-block;
    margin-top: 2rem;
    color: var(--primary);
    text-decoration: none;
    font-weight: 500;
}

.back-to-blog:hover {
    text-decoration: underline;
}

/* Related Categories */
.related-categories {
    margin-top: 4rem;
    padding-top: 2rem;
    border-top: 1px solid var(--border);
}

.related-categories h3 {
    font-size: 1.8rem;
    margin-bottom: 1.5rem;
    color: var(--text-primary);
}

.categories-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
}

.category-placeholder {
    grid-column: 1 / -1;
    text-align: center;
    padding: 3rem;
    background: var(--bg-secondary);
    border-radius: 8px;
    color: var(--text-secondary);
}

.view-all-categories {
    display: inline-block;
    margin-top: 1rem;
    color: var(--primary);
    text-decoration: none;
    font-weight: 500;
}

.view-all-categories:hover {
    text-decoration: underline;
}

/* Responsive */
@media (max-width: 768px) {
    .blog-category-container {
        padding: 1rem;
    }

    .category-header {
        flex-direction: column;
        gap: 1.5rem;
    }

    .category-info h1 {
        font-size: 2rem;
    }

    .posts-grid {
        grid-template-columns: 1fr;
        gap: 1.5rem;
    }

    .post-card {
        margin-bottom: 1rem;
    }

    .post-footer {
        flex-direction: column;
        gap: 1rem;
        align-items: flex-start;
    }

    .pagination {
        flex-wrap: wrap;
        gap: 0.5rem;
    }

    .categories-grid {
        grid-template-columns: 1fr;
    }
}
</style>
