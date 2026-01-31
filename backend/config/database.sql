-- Russia App Dashboard Database Schema
-- Database: mosr_app_clone
-- Run this SQL script to create all required tables

-- Drop tables if they exist (for fresh setup)
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `admins`;

-- ===========================================
-- ADMINS TABLE - For dashboard authentication
-- ===========================================
CREATE TABLE `admins` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('super_admin', 'admin', 'moderator') DEFAULT 'admin',
    `is_active` TINYINT(1) DEFAULT 1,
    `last_login` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_email` (`email`),
    INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- USERS TABLE - Main users managed by dashboard
-- ===========================================
CREATE TABLE `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(50) DEFAULT NULL,
    `address` TEXT DEFAULT NULL,
    `role` ENUM('Admin', 'Manager', 'User') DEFAULT 'User',
    `profile_image` VARCHAR(500) DEFAULT NULL,
    `doc1` VARCHAR(500) DEFAULT NULL,
    `doc1_original_name` VARCHAR(255) DEFAULT NULL,
    `doc2` VARCHAR(500) DEFAULT NULL,
    `doc2_original_name` VARCHAR(255) DEFAULT NULL,
    `is_active` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_email` (`email`),
    INDEX `idx_role` (`role`),
    INDEX `idx_is_active` (`is_active`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================
-- INSERT DEFAULT ADMIN
-- Password: admin123 (bcrypt hashed)
-- ===========================================
INSERT INTO `admins` (`name`, `email`, `password`, `role`) VALUES
('John Doe', 'admin@russiaapp.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin');

-- ===========================================
-- INSERT SAMPLE USERS (Optional - for testing)
-- Password for all: password123 (bcrypt hashed)
-- ===========================================
INSERT INTO `users` (`name`, `email`, `password`, `phone`, `address`, `role`, `doc1_original_name`, `doc2_original_name`) VALUES
('Alice Johnson', 'alice@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1 (555) 123-4567', '123 Maple St, Springfield, IL', 'Admin', 'passport.pdf', 'id_card.png'),
('Bob Smith', 'bob@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+1 (555) 987-6543', '456 Oak Ave, Metropolis, NY', 'Manager', 'contract.pdf', NULL);
