-- Fix Admin Password
-- Run this SQL command directly in your MySQL database

UPDATE admins 
SET password = '$2a$10$CwTycUXWue0Thq9StjUM0uJ4vGh1O3moEPzwmzjJvBJxNBz1dPlie'
WHERE email = 'admin@russiaapp.com';
