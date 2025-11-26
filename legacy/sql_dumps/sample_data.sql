-- Sample data for autopredator database
-- Insert sample users
INSERT INTO `users` (`name`, `email`, `password_hash`, `phone_number`, `address`, `user_type`) VALUES
('John Doe', 'john@example.com', '$2y$10$examplehash1', '1234567890', '123 Main St, City', 'Buyer'),
('Jane Smith', 'jane@example.com', '$2y$10$examplehash2', '0987654321', '456 Elm St, City', 'Seller'),
('Auto Dealer', 'dealer@example.com', '$2y$10$examplehash3', '1122334455', '789 Oak St, City', 'Dealer')
ON DUPLICATE KEY UPDATE name=VALUES(name), password_hash=VALUES(password_hash), phone_number=VALUES(phone_number), address=VALUES(address), user_type=VALUES(user_type);
