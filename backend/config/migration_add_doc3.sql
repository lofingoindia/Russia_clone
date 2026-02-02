-- Migration: Add doc3 column for multiple document uploads
-- Run this SQL script to add the new document columns

-- Add doc3 column (stores JSON array of file paths for multiple files)
ALTER TABLE `users` 
ADD COLUMN `doc3` TEXT DEFAULT NULL COMMENT 'JSON array of file paths for additional documents',
ADD COLUMN `doc3_original_names` TEXT DEFAULT NULL COMMENT 'JSON array of original file names for additional documents';

-- Verify the changes
-- SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'users' AND COLUMN_NAME LIKE 'doc3%';
