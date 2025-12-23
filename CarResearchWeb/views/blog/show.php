<?php
// Blog post show template
// Variables available: $post, $page_title, $page_description, $og_image
?>

<div class="blog-post-container">
    <article class="blog-post">
        <!-- Post Header -->
        <header class="post-header">
            <?php if ($post['featured_image']): ?>
                <div class="post-featured-image">
                    <img src="<?php echo htmlspecialchars($post['featured_image']); ?>"
                         alt="<?php echo htmlspecialchars($post['title']); ?>"
                         class="featured-image">
                </div>
            <?php endif; ?>

            <div class="post-meta-header">
                <div class="post-category">
                    <a href="/blog-category.php?slug=<?php echo htmlspecialchars($post['category_slug']); ?>">
                        <?php echo htmlspecialchars($post['category_name']); ?>
                    </a>
                </div>

                <h1 class="post-title"><?php echo htmlspecialchars($post['title']); ?></h1>

                <div class="post-meta">
                    <span class="post-author">
                        By <a href="#"><?php echo htmlspecialchars($post['author_name']); ?></a>
                    </span>
                    <span class="post-date">
                        <?php echo date('F j, Y', strtotime($post['published_at'])); ?>
                    </span>
                    <span class="reading-time">
                        <?php echo $post['reading_time']; ?> min read
                    </span>
                </div>

                <?php if ($post['excerpt']): ?>
                    <p class="post-excerpt"><?php echo htmlspecialchars($post['excerpt']); ?></p>
                <?php endif; ?>
            </div>
        </header>

        <!-- Post Content -->
        <div class="post-content">
            <?php echo $post['content']; ?>
        </div>

        <!-- Post Footer -->
        <footer class="post-footer">
            <?php if (!empty($post['tags'])): ?>
                <div class="post-tags">
                    <h4>Tags:</h4>
                    <div class="tags-list">
                        <?php foreach ($post['tags'] as $tag): ?>
                            <span class="tag"><?php echo htmlspecialchars($tag['name']); ?></span>
                        <?php endforeach; ?>
                    </div>
                </div>
            <?php endif; ?>

            <!-- Social Share -->
            <div class="social-share">
                <h4>Share this post:</h4>
                <div class="share-buttons">
                    <a href="https://twitter.com/intent/tweet?text=<?php echo urlencode($post['title']); ?>&url=<?php echo urlencode('https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']); ?>"
                       class="share-btn twitter" target="_blank" rel="noopener">
                        Twitter
                    </a>
                    <a href="https://www.facebook.com/sharer/sharer.php?u=<?php echo urlencode('https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']); ?>"
                       class="share-btn facebook" target="_blank" rel="noopener">
                        Facebook
                    </a>
                    <a href="https://www.linkedin.com/sharing/share-offsite/?url=<?php echo urlencode('https://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']); ?>"
                       class="share-btn linkedin" target="_blank" rel="noopener">
                        LinkedIn
                    </a>
                </div>
            </div>
        </footer>
    </article>

    <!-- Author Bio -->
    <section class="author-bio">
        <div class="author-avatar">
            <img src="<?php echo htmlspecialchars($post['author_avatar'] ?? '/assets/images/default-avatar.jpg'); ?>"
                 alt="<?php echo htmlspecialchars($post['author_name']); ?>">
        </div>
        <div class="author-info">
            <h3><?php echo htmlspecialchars($post['author_name']); ?></h3>
            <p><?php echo htmlspecialchars($post['author_bio'] ?? 'Automotive enthusiast and content creator.'); ?></p>
            <a href="#" class="author-link">View all posts by <?php echo htmlspecialchars($post['author_name']); ?></a>
        </div>
    </section>

    <!-- Related Posts -->
    <section class="related-posts">
        <h3>Related Articles</h3>
        <div class="related-grid">
            <!-- This would be populated with related posts from the same category -->
            <div class="related-placeholder">
                <p>Related posts will appear here based on categories and tags.</p>
            </div>
        </div>
    </section>

    <!-- Comments Section -->
    <section class="comments-section">
        <h3>Comments</h3>
        <div class="comments-list">
            <!-- Comments would be loaded here -->
            <div class="no-comments">
                <p>No comments yet. Be the first to share your thoughts!</p>
            </div>
        </div>

        <!-- Comment Form -->
        <div class="comment-form">
            <h4>Leave a Comment</h4>
            <form action="/api/comments" method="POST">
                <input type="hidden" name="post_id" value="<?php echo $post['id']; ?>">
                <div class="form-group">
                    <label for="comment-name">Name *</label>
                    <input type="text" id="comment-name" name="name" required>
                </div>
                <div class="form-group">
                    <label for="comment-email">Email *</label>
                    <input type="email" id="comment-email" name="email" required>
                </div>
                <div class="form-group">
                    <label for="comment-content">Comment *</label>
                    <textarea id="comment-content" name="content" rows="5" required></textarea>
                </div>
                <button type="submit" class="submit-comment">Post Comment</button>
            </form>
        </div>
    </section>
</div>

<style>
.blog-post-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
}

.blog-post {
    background: var(--bg-card);
    border-radius: 12px;
    overflow: hidden;
    box-shadow: var(--shadow-sm);
}

.post-header {
    position: relative;
}

.post-featured-image {
    width: 100%;
    height: 400px;
    overflow: hidden;
}

.featured-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.post-meta-header {
    padding: 2rem;
    padding-top: 1.5rem;
}

.post-category {
    margin-bottom: 1rem;
}

.post-category a {
    color: var(--primary);
    font-weight: 500;
    text-decoration: none;
    padding: 0.5rem 1rem;
    background: var(--bg-secondary);
    border-radius: 20px;
    font-size: 0.9rem;
}

.post-category a:hover {
    background: var(--primary);
    color: white;
}

.post-title {
    font-size: 2.5rem;
    color: var(--text-primary);
    margin: 1rem 0;
    line-height: 1.2;
}

.post-meta {
    display: flex;
    gap: 2rem;
    font-size: 0.9rem;
    color: var(--text-secondary);
    margin-bottom: 1.5rem;
}

.post-author a,
.post-date,
.reading-time {
    color: var(--text-secondary);
}

.post-author a:hover {
    color: var(--primary);
}

.post-excerpt {
    font-size: 1.2rem;
    color: var(--text-secondary);
    line-height: 1.6;
    font-style: italic;
}

.post-content {
    padding: 0 2rem;
    line-height: 1.8;
    color: var(--text-primary);
}

.post-content h2,
.post-content h3,
.post-content h4 {
    margin-top: 2rem;
    margin-bottom: 1rem;
    color: var(--text-primary);
}

.post-content h2 {
    font-size: 1.8rem;
}

.post-content h3 {
    font-size: 1.5rem;
}

.post-content p {
    margin-bottom: 1.5rem;
}

.post-content ul,
.post-content ol {
    margin-bottom: 1.5rem;
    padding-left: 2rem;
}

.post-content li {
    margin-bottom: 0.5rem;
}

.post-content blockquote {
    border-left: 4px solid var(--primary);
    padding-left: 1.5rem;
    margin: 2rem 0;
    font-style: italic;
    color: var(--text-secondary);
}

.post-content img {
    max-width: 100%;
    height: auto;
    border-radius: 8px;
    margin: 1.5rem 0;
}

.post-footer {
    padding: 2rem;
    border-top: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 2rem;
}

.post-tags h4,
.social-share h4 {
    margin-bottom: 1rem;
    color: var(--text-primary);
    font-size: 1.1rem;
}

.tags-list {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
}

.tag {
    background: var(--bg-secondary);
    padding: 0.5rem 1rem;
    border-radius: 20px;
    font-size: 0.9rem;
    color: var(--text-secondary);
}

.share-buttons {
    display: flex;
    gap: 1rem;
}

.share-btn {
    padding: 0.5rem 1rem;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 500;
    font-size: 0.9rem;
    transition: all 0.2s ease;
}

.share-btn.twitter {
    background: #1da1f2;
    color: white;
}

.share-btn.facebook {
    background: #1877f2;
    color: white;
}

.share-btn.linkedin {
    background: #0077b5;
    color: white;
}

.share-btn:hover {
    transform: translateY(-1px);
    box-shadow: var(--shadow-sm);
}

/* Author Bio */
.author-bio {
    display: flex;
    gap: 1.5rem;
    background: var(--bg-card);
    padding: 2rem;
    border-radius: 12px;
    margin-top: 2rem;
    box-shadow: var(--shadow-sm);
}

.author-avatar {
    flex-shrink: 0;
}

.author-avatar img {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    object-fit: cover;
}

.author-info h3 {
    margin-bottom: 0.5rem;
    color: var(--text-primary);
}

.author-info p {
    color: var(--text-secondary);
    margin-bottom: 1rem;
    line-height: 1.6;
}

.author-link {
    color: var(--primary);
    text-decoration: none;
    font-weight: 500;
}

.author-link:hover {
    text-decoration: underline;
}

/* Related Posts */
.related-posts {
    margin-top: 3rem;
}

.related-posts h3 {
    font-size: 1.8rem;
    margin-bottom: 1.5rem;
    color: var(--text-primary);
}

.related-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
}

.related-placeholder {
    grid-column: 1 / -1;
    text-align: center;
    padding: 3rem;
    background: var(--bg-secondary);
    border-radius: 8px;
    color: var(--text-secondary);
}

/* Comments Section */
.comments-section {
    margin-top: 3rem;
}

.comments-section h3 {
    font-size: 1.8rem;
    margin-bottom: 1.5rem;
    color: var(--text-primary);
}

.no-comments {
    text-align: center;
    padding: 2rem;
    background: var(--bg-secondary);
    border-radius: 8px;
    color: var(--text-secondary);
}

.comment-form {
    margin-top: 2rem;
    background: var(--bg-card);
    padding: 2rem;
    border-radius: 12px;
    box-shadow: var(--shadow-sm);
}

.comment-form h4 {
    margin-bottom: 1.5rem;
    color: var(--text-primary);
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    color: var(--text-primary);
    font-weight: 500;
}

.form-group input,
.form-group textarea {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid var(--border);
    border-radius: 6px;
    font-size: 1rem;
    font-family: inherit;
}

.form-group textarea {
    resize: vertical;
    min-height: 120px;
}

.submit-comment {
    background: var(--primary);
    color: white;
    border: none;
    padding: 0.75rem 2rem;
    border-radius: 6px;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s ease;
}

.submit-comment:hover {
    background: var(--primary-dark);
}

/* Responsive */
@media (max-width: 768px) {
    .blog-post-container {
        padding: 1rem;
    }

    .post-title {
        font-size: 2rem;
    }

    .post-meta {
        flex-direction: column;
        gap: 0.5rem;
    }

    .post-footer {
        flex-direction: column;
        gap: 1.5rem;
    }

    .author-bio {
        flex-direction: column;
        text-align: center;
    }

    .related-grid {
        grid-template-columns: 1fr;
    }

    .share-buttons {
        flex-direction: column;
    }

    .tags-list {
        justify-content: center;
    }
}
</style>
