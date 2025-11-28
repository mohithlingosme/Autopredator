Niceee, progress 😌🔥

Since you’re “done with website”, let’s line up **what comes next** so Autopredator stops being just pretty pages and starts behaving like a real product.

I’ll keep it super focused.

---

## 1️⃣ Connect the Website to the Database

**Goal:** Make the site *do* something – store leads, show blog posts, etc.

### TODO

* [ ] Create/finish `Website/includes/config.php` with PDO:

  ```php
  <?php
  $db_host = 'localhost';
  $db_name = 'autopredator_site';
  $db_user = 'root';
  $db_pass = '';

  function get_db_connection(): PDO {
      static $pdo = null;
      if ($pdo === null) {
          $dsn = "mysql:host=localhost;dbname=autopredator_site;charset=utf8mb4";
          $pdo = new PDO($dsn, 'root', '', [
              PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
              PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
          ]);
      }
      return $pdo;
  }
  ```

* [ ] In `contact-submit.php`:

  * Use `get_db_connection()`
  * Insert into `leads` table with prepared statement
  * Redirect to `thank-you.php`

* [ ] In `blog-list.php`:

  * Query `blog_posts`
  * Loop and render cards

* [ ] In `blog-post.php`:

  * Get `id` (or `slug`) from `$_GET`
  * Fetch a single blog row and render full content

---

## 2️⃣ PHASE 5 – Auth & Dashboard Placeholder

**Goal:** Basic login system for future portal.

### TODO

* [ ] Make sure **sessions** start in a common place:

  ```php
  // At the very top of Website/includes/header.php (or a new init.php)
  <?php
  if (session_status() === PHP_SESSION_NONE) {
      session_start();
  }
  ?>
  ```

* [ ] `Website/login.php`

  * Email + password fields
  * POST to `auth-process.php` (or handle inside same file)
  * Show error message if login fails (red text)

* [ ] `Website/auth-process.php` (if separate)

  * `require_once 'includes/config.php';`
  * Use PDO to find user by email in `users` table
  * Verify with `password_verify()`
  * On success:

    * `$_SESSION['user_id'] = $user['id'];`
    * Redirect to `dashboard-placeholder.php`
  * On failure:

    * Redirect back to `login.php?error=1` or show inline error

* [ ] `Website/dashboard-placeholder.php`

  * At top:

    ```php
    <?php
    require_once 'includes/config.php'; // if needed
    if (session_status() === PHP_SESSION_NONE) session_start();
    if (empty($_SESSION['user_id'])) {
        header('Location: login.php');
        exit;
    }
    ?>
    ```

  * Body: “Autopredator Portal coming soon” + links:

    * Back to Home
    * Logout

* [ ] `Website/logout.php`

  ```php
  <?php
  session_start();
  session_unset();
  session_destroy();
  header('Location: index.php');
  exit;
  ?>
  ```

---

## 3️⃣ PHASE 6 – JavaScript Enhancements

**Goal:** Make UX feel smooth and “premium” without changing your red/black/white vibe.

### TODO

* [ ] `Website/assets/js/main.js`

  * Smooth scroll for nav links (`href="#section-id"`)
  * Mobile nav toggle (burger → open/close menu with a class like `.nav-open`)
  * Optional: active link highlight based on scroll position

* [ ] `Website/assets/js/form-validation.js`

  * Contact form validation:

    * Required: name, email
    * Check valid email format
  * Login form validation:

    * Required: email, password length ≥ 6
  * Show errors in **red/white only** via CSS classes (no inline color codes in JS)

---

## 4️⃣ Final polish & deploy prep

Once the above is done:

* [ ] Check all pages work without PHP notices/warnings
* [ ] Test on mobile (Chrome dev tools)
* [ ] Add simple `.htaccess` if you want cleaner URLs later
* [ ] Backup DB + code → then you’re ready for shared hosting / VPS

---

If you tell me **what you want to do next** (“auth”, “contact-submit PHP”, “JS files”), I can spit out **ready-to-paste code** for that part.
