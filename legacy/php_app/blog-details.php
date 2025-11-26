<?php
require_once 'config.php'; // must contain $conn = new mysqli(...);

// ✅ Enable error reporting for dev (optional)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// ✅ Get blog ID from URL
$blogId = $_GET['id'] ?? null;

// ✅ Validate blog ID
if (!$blogId || !is_numeric($blogId)) {
    http_response_code(400);
    echo "<h2 style='color:red;text-align:center;'>Invalid blog ID.</h2>";
    exit;
}

// ✅ Fetch blog post from database
$stmt = $conn->prepare("SELECT title, content, image_url, created_at FROM blogs WHERE id = ? AND status = 'published'");
$stmt->bind_param("i", $blogId);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    http_response_code(404);
    echo "<h2 style='color:red;text-align:center;'>Blog post not found.</h2>";
    exit;
}

$blog = $result->fetch_assoc();
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title><?= htmlspecialchars($blog['title']) ?> | Autopredator Blog</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
  <style>
    body {
      background-color: #f8f8f8;
      font-family: 'Segoe UI', sans-serif;
    }
    .blog-container {
      max-width: 800px;
      margin: 60px auto;
      padding: 30px;
      background: #fff;
      box-shadow: 0 0 20px rgba(0,0,0,0.1);
      border-radius: 10px;
    }
    .blog-container img {
      max-width: 100%;
      height: auto;
      border-radius: 8px;
      margin-bottom: 20px;
    }
    .blog-title {
      font-size: 2rem;
      font-weight: bold;
      margin-bottom: 10px;
    }
    .blog-date {
      color: gray;
      font-size: 0.9rem;
      margin-bottom: 20px;
    }
    .blog-content {
      font-size: 1.1rem;
      line-height: 1.7;
    }
    .back-link {
      margin-top: 30px;
      display: inline-block;
      color: #007bff;
      text-decoration: none;
    }
    .back-link:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>

<div class="blog-container">
  <h1 class="blog-title"><?= htmlspecialchars($blog['title']) ?></h1>
  <p class="blog-date">Published on <?= date('F j, Y', strtotime($blog['created_at'])) ?></p>

  <?php if (!empty($blog['image_url'])): ?>
    <img src="<?= htmlspecialchars($blog['image_url']) ?>" alt="Blog Image">
  <?php endif; ?>

  <!-- ✅ Render full HTML content safely -->
  <div class="blog-content">
    <?= $blog['content'] ?> 
  </div>

  <a href="index.php#blogs" class="back-link">← Back to Blogs</a>
</div>

</body>
</html>

<?php $conn->close(); ?>
