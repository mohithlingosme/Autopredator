<?php
session_start();
include 'config.php';
include 'includes/functions.php';

// Require admin role
require_role('Admin');

// Handle Create or Update
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $id = $_POST['id'] ?? 0;
    $title = $_POST['title'];
    $content = $_POST['content'];
    $yt_link = $_POST['yt_link'];
    $status = $_POST['status'];
    $author = $_POST['author'];
    $excerpt = $_POST['excerpt'];
    $meta_title = $_POST['meta_title'];
    $meta_description = $_POST['meta_description'];
    $featured = isset($_POST['featured']) ? 1 : 0;
    $publish_at = !empty($_POST['publish_at']) ? $_POST['publish_at'] : null;
    $image_url = "";

    // Upload image if available
    if (!empty($_FILES["image"]["name"])) {
        $target_dir = "uploads/";
        $target_file = $target_dir . time() . '_' . basename($_FILES["image"]["name"]);
        move_uploaded_file($_FILES["image"]["tmp_name"], $target_file);
        $image_url = $target_file;
    }

    if ($id) {
        // Update blog
        if ($image_url) {
            $stmt = $conn->prepare("UPDATE blogs SET title=?, content=?, image_url=?, yt_link=?, status=?, author=?, excerpt=?, meta_title=?, meta_description=?, featured=?, publish_at=? WHERE id=?");
            $stmt->bind_param("sssssssssssi", $title, $content, $image_url, $yt_link, $status, $author, $excerpt, $meta_title, $meta_description, $featured, $publish_at, $id);
        } else {
            $stmt = $conn->prepare("UPDATE blogs SET title=?, content=?, yt_link=?, status=?, author=?, excerpt=?, meta_title=?, meta_description=?, featured=?, publish_at=? WHERE id=?");
            $stmt->bind_param("ssssssssssi", $title, $content, $yt_link, $status, $author, $excerpt, $meta_title, $meta_description, $featured, $publish_at, $id);
        }
    } else {
        // Insert blog
        $stmt = $conn->prepare("INSERT INTO blogs (title, content, image_url, yt_link, status, author, excerpt, meta_title, meta_description, featured, publish_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssssssssis", $title, $content, $image_url, $yt_link, $status, $author, $excerpt, $meta_title, $meta_description, $featured, $publish_at);
    }

    $stmt->execute();
    $stmt->close();
    header("Location: admin.php");
    exit();
}

// Handle Delete
if (isset($_GET['delete'])) {
    $id = $_GET['delete'];
    $conn->query("DELETE FROM blogs WHERE id=$id");
    header("Location: admin.php");
    exit();
}

// Fetch Blogs
$result = $conn->query("SELECT * FROM blogs ORDER BY created_at DESC");

// Fetch blog for editing
$editBlog = null;
if (isset($_GET['edit'])) {
    $id = $_GET['edit'];
    $editBlog = $conn->query("SELECT * FROM blogs WHERE id=$id")->fetch_assoc();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Panel - Blog Manager</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  
  <!-- ✅ TinyMCE with your API Key -->
  <script src="https://cdn.tiny.cloud/1/04agretrbqogfswjk93jabzbls9hsp6g9jes36b3bxpmh6sg/tinymce/6/tinymce.min.js" referrerpolicy="origin"></script>
  <script>
    tinymce.init({
      selector: '#content',
      plugins: 'link image media code fullscreen preview',
      toolbar: 'undo redo | formatselect | bold italic underline | alignleft aligncenter alignright | link image media | code fullscreen preview',
      height: 400
    });
  </script>
</head>
<body class="container py-5">

  <h2 class="mb-4">🛠️ Blog Admin Panel</h2>

  <!-- Blog Form -->
  <form method="POST" enctype="multipart/form-data" class="mb-5">
    <input type="hidden" name="id" value="<?= $editBlog['id'] ?? '' ?>">

    <div class="mb-3">
      <label>Title</label>
      <input type="text" name="title" class="form-control" required value="<?= $editBlog['title'] ?? '' ?>">
    </div>

    <div class="mb-3">
      <label>Excerpt</label>
      <textarea name="excerpt" class="form-control"><?= $editBlog['excerpt'] ?? '' ?></textarea>
    </div>

    <div class="mb-3">
      <label>Content</label>
      <textarea name="content" id="content"><?= $editBlog['content'] ?? '' ?></textarea>
    </div>

    <div class="mb-3">
      <label>Upload Image</label>
      <input type="file" name="image" class="form-control">
      <?php if (!empty($editBlog['image_url'])): ?>
        <img src="<?= $editBlog['image_url'] ?>" class="mt-2" width="150">
      <?php endif; ?>
    </div>

    <div class="mb-3">
      <label>YouTube Video Link</label>
      <input type="text" name="yt_link" class="form-control" value="<?= $editBlog['yt_link'] ?? '' ?>">
    </div>

    <div class="mb-3">
      <label>Status</label>
      <select name="status" class="form-select">
        <option value="draft" <?= ($editBlog['status'] ?? '') == 'draft' ? 'selected' : '' ?>>Draft</option>
        <option value="published" <?= ($editBlog['status'] ?? '') == 'published' ? 'selected' : '' ?>>Published</option>
      </select>
    </div>

    <div class="mb-3">
      <label>Author</label>
      <input type="text" name="author" class="form-control" value="<?= $editBlog['author'] ?? 'Admin' ?>">
    </div>

    <div class="mb-3">
      <label>Meta Title (SEO)</label>
      <input type="text" name="meta_title" class="form-control" value="<?= $editBlog['meta_title'] ?? '' ?>">
    </div>

    <div class="mb-3">
      <label>Meta Description (SEO)</label>
      <textarea name="meta_description" class="form-control"><?= $editBlog['meta_description'] ?? '' ?></textarea>
    </div>

    <div class="mb-3">
      <label>Scheduled Publish Date</label>
      <input type="datetime-local" name="publish_at" class="form-control"
             value="<?= isset($editBlog['publish_at']) ? date('Y-m-d\TH:i', strtotime($editBlog['publish_at'])) : '' ?>">
    </div>

    <div class="form-check mb-4">
      <input type="checkbox" class="form-check-input" name="featured" <?= isset($editBlog['featured']) && $editBlog['featured'] ? 'checked' : '' ?>>
      <label class="form-check-label">Featured Post</label>
    </div>

    <button type="submit" class="btn btn-success"><?= isset($editBlog) ? 'Update Blog' : 'Create Blog' ?></button>
    <?php if (isset($editBlog)): ?>
      <a href="admin.php" class="btn btn-secondary">Cancel</a>
    <?php endif; ?>
  </form>

  <!-- Blog List -->
  <hr>
  <h3>📄 Existing Blogs</h3>
  <table class="table table-bordered mt-3">
    <thead class="table-light">
      <tr>
        <th>Title</th>
        <th>Status</th>
        <th>Author</th>
        <th>Featured</th>
        <th>Publish At</th>
        <th>Image</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php while ($row = $result->fetch_assoc()): ?>
        <tr>
          <td><?= htmlspecialchars($row['title']); ?></td>
          <td><?= ucfirst($row['status']); ?></td>
          <td><?= htmlspecialchars($row['author']); ?></td>
          <td><?= $row['featured'] ? 'Yes' : 'No'; ?></td>
          <td><?= $row['publish_at'] ? date('Y-m-d H:i', strtotime($row['publish_at'])) : '—'; ?></td>
          <td>
            <?php if ($row['image_url']): ?>
              <img src="<?= $row['image_url'] ?>" width="60">
            <?php endif; ?>
          </td>
          <td>
            <a href="admin.php?edit=<?= $row['id']; ?>" class="btn btn-sm btn-warning">Edit</a>
            <a href="admin.php?delete=<?= $row['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this blog?')">Delete</a>
          </td>
        </tr>
      <?php endwhile; ?>
    </tbody>
  </table>

</body>
</html>

<?php $conn->close(); ?>
