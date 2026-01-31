-- Migration script to add password field to existing users table
-- Run this if you already have the users table without password field

-- Add password column
ALTER TABLE `users` 
ADD COLUMN `password` VARCHAR(255) NOT NULL AFTER `email`;

-- Update existing users with a default hashed password (password123)
-- Note: Change this for production - you should set unique passwords for each user
UPDATE `users` 
SET `password` = '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'
WHERE `password` = '' OR `password` IS NULL;
