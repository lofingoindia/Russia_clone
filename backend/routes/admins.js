const express = require('express');
const bcrypt = require('bcryptjs');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// GET /api/admins - Get all admins
router.get('/', authenticateToken, async (req, res) => {
    try {
        const [admins] = await pool.execute(
            'SELECT id, name, email, role, is_active, last_login, created_at, updated_at FROM admins ORDER BY created_at DESC'
        );

        res.json({
            success: true,
            data: admins
        });
    } catch (error) {
        console.error('Fetch admins error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// POST /api/admins - Create new admin
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { name, email, password, role } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, email, and password are required'
            });
        }

        // Check if admin already exists
        const [existing] = await pool.execute('SELECT id FROM admins WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Admin with this email already exists'
            });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert admin
        const [result] = await pool.execute(
            'INSERT INTO admins (name, email, password, role) VALUES (?, ?, ?, ?)',
            [name, email, hashedPassword, role || 'admin']
        );

        res.status(201).json({
            success: true,
            message: 'Admin created successfully',
            data: {
                id: result.insertId,
                name,
                email,
                role: role || 'admin'
            }
        });
    } catch (error) {
        console.error('Create admin error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// PUT /api/admins/:id - Update admin
router.put('/:id', authenticateToken, async (req, res) => {
    try {
        const { id } = req.params;
        const { name, email, role, is_active } = req.body;

        // Check if exists
        const [existing] = await pool.execute('SELECT id FROM admins WHERE id = ?', [id]);
        if (existing.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Admin not found'
            });
        }

        // Check if email is taken by another admin
        if (email) {
            const [taken] = await pool.execute('SELECT id FROM admins WHERE email = ? AND id != ?', [email, id]);
            if (taken.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: 'Email already in use'
                });
            }
        }

        // Build update query dynamically
        const updates = [];
        const values = [];

        if (name) { updates.push('name = ?'); values.push(name); }
        if (email) { updates.push('email = ?'); values.push(email); }
        if (role) { updates.push('role = ?'); values.push(role); }
        if (is_active !== undefined) { updates.push('is_active = ?'); values.push(is_active); }

        if (updates.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'No fields to update'
            });
        }

        values.push(id);
        await pool.execute(
            `UPDATE admins SET ${updates.join(', ')} WHERE id = ?`,
            values
        );

        res.json({
            success: true,
            message: 'Admin updated successfully'
        });
    } catch (error) {
        console.error('Update admin error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// DELETE /api/admins/:id - Delete admin
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const { id } = req.params;

        // Prevent self-deletion if preferred (optional)
        if (parseInt(id) === req.admin.id) {
            return res.status(400).json({
                success: false,
                message: 'You cannot delete yourself'
            });
        }

        const [result] = await pool.execute('DELETE FROM admins WHERE id = ?', [id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Admin not found'
            });
        }

        res.json({
            success: true,
            message: 'Admin deleted successfully'
        });
    } catch (error) {
        console.error('Delete admin error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
