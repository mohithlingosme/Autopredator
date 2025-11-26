-- Sample data for blogs database
INSERT INTO `blogs` (`title`, `content`, `image_url`, `yt_link`, `status`, `author`, `excerpt`, `meta_title`, `meta_description`, `featured`, `publish_at`) VALUES
('Sample Blog 1', 'This is a sample blog post about cars.', 'uploads/sample1.jpg', 'https://youtube.com/sample1', 'published', 'Admin', 'Sample excerpt', 'Sample Title', 'Sample description', 1, NOW()),
('Sample Blog 2', 'Another sample blog post.', 'uploads/sample2.jpg', 'https://youtube.com/sample2', 'published', 'Admin', 'Another excerpt', 'Another Title', 'Another description', 0, NOW())
ON DUPLICATE KEY UPDATE content=VALUES(content), image_url=VALUES(image_url), yt_link=VALUES(yt_link), status=VALUES(status), author=VALUES(author), excerpt=VALUES(excerpt), meta_title=VALUES(meta_title), meta_description=VALUES(meta_description), featured=VALUES(featured), publish_at=VALUES(publish_at);
