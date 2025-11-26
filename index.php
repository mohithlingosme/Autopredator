<?php
// Redirect all traffic to the PHP build that lives in legacy/php_app.
$target = 'legacy/php_app/';

// Use a relative redirect so it works regardless of virtual host prefix.
header("Location: {$target}");
exit;
