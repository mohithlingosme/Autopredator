USE autopredator_site_cms;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO pages (id, page_type, title, slug, status, seo_title, seo_description, published_at)
VALUES
  (1, 'landing', 'Autopredator Home', 'home', 'published', 'Autopredator - Car Research', 'Discover specs, prices and reviews', NOW()),
  (2, 'model', 'Falcon Swiftline', 'falcon-swiftline', 'published', 'Falcon Swiftline Specs', 'All Falcon Swiftline variants and specs', NOW())
ON DUPLICATE KEY UPDATE title = VALUES(title), status = VALUES(status), seo_title = VALUES(seo_title), seo_description = VALUES(seo_description);

INSERT INTO page_entities (id, page_id, entity_type, entity_id, relationship_type)
VALUES
  (1, 2, 'model', 1, 'primary')
ON DUPLICATE KEY UPDATE entity_id = VALUES(entity_id), relationship_type = VALUES(relationship_type);

INSERT INTO faqs (id, page_id, question, answer, sort_order)
VALUES
  (1, 1, 'What is Autopredator?', 'A research and pricing platform for cars.', 1),
  (2, 1, 'How often is pricing updated?', 'Daily from dealers and market feeds.', 2)
ON DUPLICATE KEY UPDATE answer = VALUES(answer), sort_order = VALUES(sort_order);

INSERT INTO blog_posts (id, title, slug, excerpt, content, status, published_at, author_name)
VALUES
  (1, 'Welcome to Autopredator', 'welcome-autopredator', 'Kick-off post', 'We combine research, pricing and analytics.', 'published', NOW(), 'Team Autopredator')
ON DUPLICATE KEY UPDATE title = VALUES(title), status = VALUES(status), excerpt = VALUES(excerpt), content = VALUES(content);

INSERT INTO tags (id, name, slug)
VALUES
  (1, 'News', 'news'),
  (2, 'Updates', 'updates')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO post_tags (id, post_id, tag_id)
VALUES
  (1, 1, 1),
  (2, 1, 2)
ON DUPLICATE KEY UPDATE tag_id = VALUES(tag_id);

INSERT INTO redirects (id, source_path, target_path, http_status)
VALUES
  (1, '/old-home', '/home', 301)
ON DUPLICATE KEY UPDATE target_path = VALUES(target_path), http_status = VALUES(http_status);
