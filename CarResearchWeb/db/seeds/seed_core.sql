USE autopredator_core;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

INSERT INTO roles (id, name, code, description)
VALUES
  (1, 'Administrator', 'admin', 'Platform superuser'),
  (2, 'Dealer Admin', 'dealer_admin', 'Manage dealership staff and inventory'),
  (3, 'Dealer User', 'dealer_user', 'Regular dealership operator')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO permissions (id, name, code, description)
VALUES
  (1, 'Manage Users', 'manage_users', 'Create, disable and update users'),
  (2, 'Manage Inventory', 'manage_inventory', 'Manage vehicles, specs and pricing'),
  (3, 'View Reports', 'view_reports', 'Access analytics and exports')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO role_permissions (id, role_id, permission_id)
VALUES
  (1, 1, 1),
  (2, 1, 2),
  (3, 1, 3),
  (4, 2, 2),
  (5, 2, 3)
ON DUPLICATE KEY UPDATE role_id = VALUES(role_id), permission_id = VALUES(permission_id);
