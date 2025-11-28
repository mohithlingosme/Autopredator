<?php
declare(strict_types=1);
?>
</main>
<footer class="site-footer">
    <div class="container footer-content">
        <div class="footer-brand">Autopredator</div>
        <div class="footer-links">
            <a href="about.php">About</a>
            <a href="contact.php">Contact</a>
            <a href="terms.php">Terms</a>
            <a href="privacy.php">Privacy</a>
        </div>
        <div class="footer-copy">&copy; <?= date('Y') ?> Autopredator. All rights reserved.</div>
    </div>
</footer>
<div class="compare-bar" data-compare-bar hidden>
    <div class="compare-bar-summary">Compare (<span data-compare-count>0</span>)</div>
    <div class="compare-bar-actions">
        <button type="button" class="btn btn-outline" data-compare-clear>Clear</button>
        <a class="btn btn-primary" href="/compare.php" data-compare-link>Compare Now</a>
    </div>
</div>
<script src="assets/js/main.js"></script>
</body>
</html>
