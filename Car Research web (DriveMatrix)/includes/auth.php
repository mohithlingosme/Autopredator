<?php
declare(strict_types=1);

require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/repository.php';

function auth_session_start(): void
{
    if (session_status() !== PHP_SESSION_ACTIVE) {
        session_start();
    }
}

/**
 * @return array<string, mixed>|null
 */
function auth_current_user(): ?array
{
    auth_session_start();
    return $_SESSION['user'] ?? null;
}

function auth_is_logged_in(): bool
{
    return auth_current_user() !== null;
}

function auth_logout(): void
{
    auth_session_start();
    unset($_SESSION['user']);
}

/**
 * @return array<int, array<string, mixed>>
 */
function auth_user_store(): array
{
    auth_session_start();
    if (!isset($_SESSION['users'])) {
        $_SESSION['users'] = [];
    }
    /** @var array<int, array<string, mixed>> $store */
    $store = $_SESSION['users'];
    return $store;
}

function auth_save_user_store(array $store): void
{
    auth_session_start();
    $_SESSION['users'] = $store;
}

/**
 * @return string|null error message
 */
function auth_register(string $name, string $email, string $password): ?string
{
    $email = trim(strtolower($email));
    if ($email === '' || $password === '' || $name === '') {
        return 'All fields are required.';
    }

    $users = auth_user_store();
    foreach ($users as $user) {
        if (($user['email'] ?? '') === $email) {
            return 'Email already registered.';
        }
    }

    $users[] = [
        'id' => count($users) + 1,
        'name' => $name,
        'email' => $email,
        'password_hash' => password_hash($password, PASSWORD_DEFAULT),
    ];

    auth_save_user_store($users);
    $_SESSION['user'] = end($users);

    return null;
}

/**
 * @return string|null error message
 */
function auth_login(string $email, string $password): ?string
{
    $email = trim(strtolower($email));
    $users = auth_user_store();
    foreach ($users as $user) {
        if (($user['email'] ?? '') === $email && password_verify($password, $user['password_hash'] ?? '')) {
            $_SESSION['user'] = $user;
            return null;
        }
    }

    return 'Invalid credentials.';
}

function auth_require_login(string $redirectTo = '/login.php'): void
{
    if (!auth_is_logged_in()) {
        header('Location: ' . $redirectTo);
        exit;
    }
}

/**
 * Favourites (session-based)
 *
 * @return array<int, int>
 */
function fav_get_list(): array
{
    auth_session_start();
    if (!isset($_SESSION['favourites'])) {
        $_SESSION['favourites'] = [];
    }
    /** @var array<int, int> $list */
    $list = array_values(array_unique(array_map('intval', $_SESSION['favourites'])));
    $_SESSION['favourites'] = $list;
    return $list;
}

function fav_add(int $variantId): void
{
    $list = fav_get_list();
    if (!in_array($variantId, $list, true)) {
        $list[] = $variantId;
        $_SESSION['favourites'] = $list;
    }
}

function fav_remove(int $variantId): void
{
    $list = array_filter(fav_get_list(), static fn (int $id) => $id !== $variantId);
    $_SESSION['favourites'] = array_values($list);
}

function fav_clear(): void
{
    auth_session_start();
    $_SESSION['favourites'] = [];
}
