const DB_HOST = 'localhost';
const DB_NAME = 'autopredator_unified';
const DB_USER = 'root';
const DB_PASS = '';
const DB_CHARSET = 'utf8mb4';
=======
// Database credentials (with .env support)
const DB_HOST = getenv('DB_HOST') ?: 'localhost';
const DB_PORT = getenv('DB_PORT') ?: 3306;
const DB_NAME = getenv('DB_NAME') ?: 'autopredator_cars';
const DB_USER = getenv('DB_USER') ?: 'root';
const DB_PASS = getenv('DB_PASS') ?: '';
const DB_CHARSET = 'utf8mb4';
