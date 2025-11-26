<?php
include 'config.php';

$sql = "SELECT id, title, content, image_url FROM blogs ORDER BY id DESC LIMIT 5";
$result = $conn->query($sql);
?>

<div id="blogCarousel" class="carousel slide" data-bs-ride="carousel">
    <div class="carousel-inner">
        <?php
        $active = true;
        if ($result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                ?>
                <div class="carousel-item <?php echo $active ? 'active' : ''; ?>">
                    <img src="<?php echo $row['image_url']; ?>" class="d-block w-100" alt="Blog Image">
                    <div class="carousel-caption d-none d-md-block">
                        <h5><?php echo $row['title']; ?></h5>
                        <p><?php echo substr($row['content'], 0, 100) . '...'; ?></p>
                    </div>
                </div>
                <?php
                $active = false;
            }
        } else {
            echo "<p>No blog posts available.</p>";
        }
        ?>
    </div>

    <button class="carousel-control-prev" type="button" data-bs-target="#blogCarousel" data-bs-slide="prev">
        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
        <span class="visually-hidden">Previous</span>
    </button>
    <button class="carousel-control-next" type="button" data-bs-target="#blogCarousel" data-bs-slide="next">
        <span class="carousel-control-next-icon" aria-hidden="true"></span>
        <span class="visually-hidden">Next</span>
    </button>
</div>

<?php $conn->close(); ?>
