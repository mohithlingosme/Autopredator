<?php
// api/blogs.php - Blogs API endpoints

function handleBlogs($method, $segments) {
    global $conn;

    switch ($method) {
        case 'GET':
            if (!isset($segments[1])) {
                // GET /api/blogs - List all blogs
                getAllBlogs();
            } elseif (is_numeric($segments[1])) {
                // GET /api/blogs/{id} - Get specific blog
                getBlogById($segments[1]);
            } else {
                // GET /api/blogs/search - Search blogs
                searchBlogs();
            }
            break;

        case 'POST':
            // POST /api/blogs - Create new blog
            require_role('Admin'); // Only admins can create blogs
            createBlog();
            break;

        case 'PUT':
            // PUT /api/blogs/{id} - Update blog
            if (!isset($segments[1]) || !is_numeric($segments[1])) {
                http_response_code(400);
                echo json_encode(['error' => 'Blog ID required']);
                return;
            }
            require_role('Admin'); // Only admins can update blogs
            updateBlog($segments[1]);
            break;

        case 'DELETE':
            // DELETE /api/blogs/{id} - Delete blog
            if (!isset($segments[1]) || !is_numeric($segments[1])) {
                http_response_code(400);
                echo json_encode(['error' => 'Blog ID required']);
                return;
            }
            require_role('Admin'); // Only admins can delete blogs
            deleteBlog($segments[1]);
            break;

        default:
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed']);
            break;
    }
}

function getAllBlogs() {
    global $conn;

    $status = $_GET['status'] ?? 'published';
    $limit = $_GET['limit'] ?? 10;
    $offset = $_GET['offset'] ?? 0;

    $sql = "SELECT id, title, content, image_url, yt_link, status, author, excerpt, meta_title, meta_description, featured, publish_at, created_at
            FROM blogs
            WHERE status = ?
            ORDER BY publish_at DESC, created_at DESC
            LIMIT ? OFFSET ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sii", $status, $limit, $offset);
    $stmt->execute();
    $result = $stmt->get_result();

    $blogs = [];
    while ($row = $result->fetch_assoc()) {
        $blogs[] = [
            'id' => $row['id'],
            'title' => $row['title'],
            'content' => $row['content'],
            'image_url' => $row['image_url'],
            'yt_link' => $row['yt_link'],
            'status' => $row['status'],
            'author' => $row['author'],
            'excerpt' => $row['excerpt'],
            'meta_title' => $row['meta_title'],
            'meta_description' => $row['meta_description'],
            'featured' => (bool)$row['featured'],
            'publish_at' => $row['publish_at'],
            'created_at' => $row['created_at']
        ];
    }

    echo json_encode(['blogs' => $blogs, 'count' => count($blogs)]);
}

function getBlogById($id) {
    global $conn;

    $sql = "SELECT id, title, content, image_url, yt_link, status, author, excerpt, meta_title, meta_description, featured, publish_at, created_at
            FROM blogs WHERE id = ?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result && $row = $result->fetch_assoc()) {
        $blog = [
            'id' => $row['id'],
            'title' => $row['title'],
            'content' => $row['content'],
            'image_url' => $row['image_url'],
            'yt_link' => $row['yt_link'],
            'status' => $row['status'],
            'author' => $row['author'],
            'excerpt' => $row['excerpt'],
            'meta_title' => $row['meta_title'],
            'meta_description' => $row['meta_description'],
            'featured' => (bool)$row['featured'],
            'publish_at' => $row['publish_at'],
            'created_at' => $row['created_at']
        ];
        echo json_encode(['blog' => $blog]);
    } else {
        http_response_code(404);
        echo json_encode(['error' => 'Blog not found']);
    }
}

function searchBlogs() {
    global $conn;

    $query = $_GET['q'] ?? '';
    $author = $_GET['author'] ?? '';
    $status = $_GET['status'] ?? 'published';
    $featured = $_GET['featured'] ?? null;

    $sql = "SELECT id, title, content, image_url, yt_link, status, author, excerpt, meta_title, meta_description, featured, publish_at, created_at
            FROM blogs WHERE status = ?";

    $params = [$status];
    $types = "s";

    if (!empty($query)) {
        $sql .= " AND (title LIKE ? OR content LIKE ? OR excerpt LIKE ?)";
        $searchTerm = "%$query%";
        $params[] = $searchTerm;
        $params[] = $searchTerm;
        $params[] = $searchTerm;
        $types .= "sss";
    }

    if (!empty($author)) {
        $sql .= " AND author LIKE ?";
        $params[] = "%$author%";
        $types .= "s";
    }

    if ($featured !== null) {
        $sql .= " AND featured = ?";
        $params[] = (int)$featured;
        $types .= "i";
    }

    $sql .= " ORDER BY publish_at DESC, created_at DESC";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    $result = $stmt->get_result();

    $blogs = [];
    while ($row = $result->fetch_assoc()) {
        $blogs[] = [
            'id' => $row['id'],
            'title' => $row['title'],
            'content' => $row['content'],
            'image_url' => $row['image_url'],
            'yt_link' => $row['yt_link'],
            'status' => $row['status'],
            'author' => $row['author'],
            'excerpt' => $row['excerpt'],
            'meta_title' => $row['meta_title'],
            'meta_description' => $row['meta_description'],
            'featured' => (bool)$row['featured'],
            'publish_at' => $row['publish_at'],
            'created_at' => $row['created_at']
        ];
    }

    echo json_encode(['blogs' => $blogs, 'count' => count($blogs)]);
}

function createBlog() {
    global $conn;

    $data = json_decode(file_get_contents('php://input'), true);

    if (!$data) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid JSON data']);
        return;
    }

    // Validate required fields
    if (!isset($data['title']) || !isset($data['content'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Title and content are required']);
        return;
    }

    $sql = "INSERT INTO blogs (title, content, image_url, yt_link, status, author, excerpt, meta_title, meta_description, featured, publish_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssssssis",
        $data['title'],
        $data['content'],
        $data['image_url'] ?? null,
        $data['yt_link'] ?? null,
        $data['status'] ?? 'draft',
        $data['author'] ?? 'Admin',
        $data['excerpt'] ?? null,
        $data['meta_title'] ?? null,
        $data['meta_description'] ?? null,
        $data['featured'] ?? 0,
        $data['publish_at'] ?? null
    );

    if ($stmt->execute()) {
        $newId = $conn->insert_id;
        http_response_code(201);
        echo json_encode(['message' => 'Blog created successfully', 'id' => $newId]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to create blog']);
    }
}

function updateBlog($id) {
    global $conn;

    $data = json_decode(file_get_contents('php://input'), true);

    if (!$data) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid JSON data']);
        return;
    }

    $sql = "UPDATE blogs SET title=?, content=?, image_url=?, yt_link=?, status=?, author=?, excerpt=?, meta_title=?, meta_description=?, featured=?, publish_at=? WHERE id=?";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssssssisi",
        $data['title'] ?? '',
        $data['content'] ?? '',
        $data['image_url'] ?? null,
        $data['yt_link'] ?? null,
        $data['status'] ?? 'draft',
        $data['author'] ?? 'Admin',
        $data['excerpt'] ?? null,
        $data['meta_title'] ?? null,
        $data['meta_description'] ?? null,
        $data['featured'] ?? 0,
        $data['publish_at'] ?? null,
        $id
    );

    if ($stmt->execute()) {
        echo json_encode(['message' => 'Blog updated successfully']);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to update blog']);
    }
}

function deleteBlog($id) {
    global $conn;

    $sql = "DELETE FROM blogs WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['message' => 'Blog deleted successfully']);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Blog not found']);
        }
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to delete blog']);
    }
}
?>
