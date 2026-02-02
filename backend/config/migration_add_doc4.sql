-- Migration: Add doc4 column for Taxpayer Identification Number document uploads
-- Run this SQL script to add the new document columns

-- Add doc4 column (stores JSON array of file paths for multiple files)
ALTER TABLE `users` 
ADD COLUMN `doc4` TEXT DEFAULT NULL COMMENT 'JSON array of file paths for taxpayer identification number documents',
ADD COLUMN `doc4_original_names` TEXT DEFAULT NULL COMMENT 'JSON array of original file names for taxpayer identification number documents';

-- Verify the changes
-- SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'users' AND COLUMN_NAME LIKE 'doc4%';
