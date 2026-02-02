const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { uploadUserFiles, handleUploadError } = require('../middleware/upload');
const fs = require('fs');
const path = require('path');

const router = express.Router();

// Helper function to build file URL
const buildFileUrl = (req, filePath) => {
    if (!filePath) return null;
    return `${req.protocol}://${req.get('host')}/uploads/${filePath}`;
};

// Helper function to delete file
const deleteFile = (filePath) => {
    if (!filePath) return;
    const fullPath = path.join(__dirname, '..', 'uploads', filePath);
    if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
    }
};

// GET /api/users - Get all users
router.get('/', authenticateToken, async (req, res) => {
    try {
        const [users] = await pool.execute(
            `SELECT id, name, email, phone, address, role, 
                    profile_image, doc1, doc1_original_name, doc2, doc2_original_name,
                    doc3, doc3_original_names, doc4, doc4_original_names,
                    is_active, created_at, updated_at 
             FROM users 
             WHERE is_active = 1 
             ORDER BY created_at DESC`
        );

        // Build full URLs for files
        const usersWithUrls = users.map(user => {
            // Parse doc3 JSON arrays
            let doc3Paths = [];
            let doc3Names = [];
            try {
                if (user.doc3) doc3Paths = JSON.parse(user.doc3);
                if (user.doc3_original_names) doc3Names = JSON.parse(user.doc3_original_names);
            } catch (e) {
                console.error('Error parsing doc3 JSON:', e);
            }

            // Parse doc4 JSON arrays
            let doc4Paths = [];
            let doc4Names = [];
            try {
                if (user.doc4) doc4Paths = JSON.parse(user.doc4);
                if (user.doc4_original_names) doc4Names = JSON.parse(user.doc4_original_names);
            } catch (e) {
                console.error('Error parsing doc4 JSON:', e);
            }

            return {
                ...user,
                profileImage: buildFileUrl(req, user.profile_image),
                doc1Url: buildFileUrl(req, user.doc1),
                doc1Name: user.doc1_original_name,
                doc2Url: buildFileUrl(req, user.doc2),
                doc2Name: user.doc2_original_name,
                doc3Urls: doc3Paths.map(p => buildFileUrl(req, p)),
                doc3Names: doc3Names,
                doc4Urls: doc4Paths.map(p => buildFileUrl(req, p)),
                doc4Names: doc4Names
            };
        });

        res.json({
            success: true,
            data: usersWithUrls,
            count: users.length
        });
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// GET /api/users/stats - Get dashboard statistics
router.get('/stats', authenticateToken, async (req, res) => {
    try {
        // Total users
        const [[{ total }]] = await pool.execute(
            'SELECT COUNT(*) as total FROM users WHERE is_active = 1'
        );

        // Users by role
        const [roleStats] = await pool.execute(
            `SELECT role, COUNT(*) as count 
             FROM users 
             WHERE is_active = 1 
             GROUP BY role`
        );

        // Users with documents
        const [[{ withDocs }]] = await pool.execute(
            `SELECT COUNT(*) as withDocs 
             FROM users 
             WHERE is_active = 1 AND (doc1 IS NOT NULL OR doc2 IS NOT NULL OR doc3 IS NOT NULL OR doc4 IS NOT NULL)`
        );

        // Recent users (last 7 days)
        const [[{ recentCount }]] = await pool.execute(
            `SELECT COUNT(*) as recentCount 
             FROM users 
             WHERE is_active = 1 AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)`
        );

        res.json({
            success: true,
            data: {
                totalUsers: total,
                roleDistribution: roleStats,
                usersWithDocuments: withDocs,
                recentUsers: recentCount
            }
        });
    } catch (error) {
        console.error('Get stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// GET /api/users/:id - Get single user
router.get('/:id', authenticateToken, async (req, res) => {
    try {
        const [users] = await pool.execute(
            `SELECT id, name, email, phone, address, role, 
                    profile_image, doc1, doc1_original_name, doc2, doc2_original_name,
                    doc3, doc3_original_names, doc4, doc4_original_names,
                    is_active, created_at, updated_at 
             FROM users 
             WHERE id = ? AND is_active = 1`,
            [req.params.id]
        );

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const user = users[0];

        // Parse doc3 JSON arrays
        let doc3Paths = [];
        let doc3Names = [];
        try {
            if (user.doc3) doc3Paths = JSON.parse(user.doc3);
            if (user.doc3_original_names) doc3Names = JSON.parse(user.doc3_original_names);
        } catch (e) {
            console.error('Error parsing doc3 JSON:', e);
        }

        // Parse doc4 JSON arrays
        let doc4Paths = [];
        let doc4Names = [];
        try {
            if (user.doc4) doc4Paths = JSON.parse(user.doc4);
            if (user.doc4_original_names) doc4Names = JSON.parse(user.doc4_original_names);
        } catch (e) {
            console.error('Error parsing doc4 JSON:', e);
        }

        res.json({
            success: true,
            data: {
                ...user,
                profileImage: buildFileUrl(req, user.profile_image),
                doc1Url: buildFileUrl(req, user.doc1),
                doc1Name: user.doc1_original_name,
                doc2Url: buildFileUrl(req, user.doc2),
                doc2Name: user.doc2_original_name,
                doc3Urls: doc3Paths.map(p => buildFileUrl(req, p)),
                doc3Names: doc3Names,
                doc4Urls: doc4Paths.map(p => buildFileUrl(req, p)),
                doc4Names: doc4Names
            }
        });
    } catch (error) {
        console.error('Get user error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// POST /api/users - Create new user
router.post('/', authenticateToken, uploadUserFiles, handleUploadError, async (req, res) => {
    try {
        const { name, email, password, phone, address, role } = req.body;

        // Validate required fields
        if (!name || !email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Name, email, and password are required'
            });
        }

        // Validate password length
        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'Password must be at least 6 characters long'
            });
        }

        // Check if email already exists
        const [existing] = await pool.execute(
            'SELECT id FROM users WHERE email = ?',
            [email]
        );

        if (existing.length > 0) {
            return res.status(400).json({
                success: false,
                message: 'Email already exists'
            });
        }

        // Hash password
        const bcrypt = require('bcryptjs');
        const hashedPassword = await bcrypt.hash(password, 10);

        // Handle file uploads
        let profileImage = null;
        let doc1 = null;
        let doc1OriginalName = null;
        let doc2 = null;
        let doc2OriginalName = null;
        let doc3Paths = [];
        let doc3OriginalNames = [];
        let doc4Paths = [];
        let doc4OriginalNames = [];

        if (req.files) {
            if (req.files.profileImage) {
                profileImage = 'profiles/' + req.files.profileImage[0].filename;
            }
            if (req.files.doc1) {
                doc1 = 'documents/' + req.files.doc1[0].filename;
                doc1OriginalName = req.files.doc1[0].originalname;
            }
            if (req.files.doc2) {
                doc2 = 'documents/' + req.files.doc2[0].filename;
                doc2OriginalName = req.files.doc2[0].originalname;
            }
            if (req.files.doc3) {
                req.files.doc3.forEach(file => {
                    doc3Paths.push('documents/' + file.filename);
                    doc3OriginalNames.push(file.originalname);
                });
            }
            if (req.files.doc4) {
                req.files.doc4.forEach(file => {
                    doc4Paths.push('documents/' + file.filename);
                    doc4OriginalNames.push(file.originalname);
                });
            }
        }

        // Insert user
        const [result] = await pool.execute(
            `INSERT INTO users (name, email, password, phone, address, role, profile_image, doc1, doc1_original_name, doc2, doc2_original_name, doc3, doc3_original_names, doc4, doc4_original_names) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [name, email, hashedPassword, phone || null, address || null, role || 'User', profileImage, doc1, doc1OriginalName, doc2, doc2OriginalName, doc3Paths.length > 0 ? JSON.stringify(doc3Paths) : null, doc3OriginalNames.length > 0 ? JSON.stringify(doc3OriginalNames) : null, doc4Paths.length > 0 ? JSON.stringify(doc4Paths) : null, doc4OriginalNames.length > 0 ? JSON.stringify(doc4OriginalNames) : null]
        );

        // Get created user (without password)
        const [users] = await pool.execute(
            'SELECT id, name, email, phone, address, role, profile_image, doc1, doc1_original_name, doc2, doc2_original_name, doc3, doc3_original_names, doc4, doc4_original_names, is_active, created_at, updated_at FROM users WHERE id = ?',
            [result.insertId]
        );

        const user = users[0];

        // Parse doc3 JSON for response
        let responseDoc3Paths = [];
        let responseDoc3Names = [];
        try {
            if (user.doc3) responseDoc3Paths = JSON.parse(user.doc3);
            if (user.doc3_original_names) responseDoc3Names = JSON.parse(user.doc3_original_names);
        } catch (e) {
            console.error('Error parsing doc3 JSON:', e);
        }

        // Parse doc4 JSON for response
        let responseDoc4Paths = [];
        let responseDoc4Names = [];
        try {
            if (user.doc4) responseDoc4Paths = JSON.parse(user.doc4);
            if (user.doc4_original_names) responseDoc4Names = JSON.parse(user.doc4_original_names);
        } catch (e) {
            console.error('Error parsing doc4 JSON:', e);
        }

        res.status(201).json({
            success: true,
            message: 'User created successfully',
            data: {
                ...user,
                profileImage: buildFileUrl(req, user.profile_image),
                doc1Url: buildFileUrl(req, user.doc1),
                doc1Name: user.doc1_original_name,
                doc2Url: buildFileUrl(req, user.doc2),
                doc2Name: user.doc2_original_name,
                doc3Urls: responseDoc3Paths.map(p => buildFileUrl(req, p)),
                doc3Names: responseDoc3Names,
                doc4Urls: responseDoc4Paths.map(p => buildFileUrl(req, p)),
                doc4Names: responseDoc4Names
            }
        });
    } catch (error) {
        console.error('Create user error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// PUT /api/users/:id - Update user
router.put('/:id', authenticateToken, uploadUserFiles, handleUploadError, async (req, res) => {
    try {
        const { name, email, password, phone, address, role } = req.body;
        const userId = req.params.id;

        // Check if user exists
        const [existing] = await pool.execute(
            'SELECT * FROM users WHERE id = ? AND is_active = 1',
            [userId]
        );

        if (existing.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const currentUser = existing[0];

        // Check email uniqueness if changed
        if (email && email !== currentUser.email) {
            const [emailCheck] = await pool.execute(
                'SELECT id FROM users WHERE email = ? AND id != ?',
                [email, userId]
            );
            if (emailCheck.length > 0) {
                return res.status(400).json({
                    success: false,
                    message: 'Email already exists'
                });
            }
        }

        // Hash password if provided
        const bcrypt = require('bcryptjs');
        let hashedPassword = currentUser.password;
        if (password && password.length > 0) {
            if (password.length < 6) {
                return res.status(400).json({
                    success: false,
                    message: 'Password must be at least 6 characters long'
                });
            }
            hashedPassword = await bcrypt.hash(password, 10);
        }

        // Handle file uploads
        let profileImage = currentUser.profile_image;
        let doc1 = currentUser.doc1;
        let doc1OriginalName = currentUser.doc1_original_name;
        let doc2 = currentUser.doc2;
        let doc2OriginalName = currentUser.doc2_original_name;
        let doc3 = currentUser.doc3;
        let doc3OriginalNames = currentUser.doc3_original_names;
        let doc4 = currentUser.doc4;
        let doc4OriginalNames = currentUser.doc4_original_names;

        if (req.files) {
            if (req.files.profileImage) {
                // Delete old file
                deleteFile(currentUser.profile_image);
                profileImage = 'profiles/' + req.files.profileImage[0].filename;
            }
            if (req.files.doc1) {
                deleteFile(currentUser.doc1);
                doc1 = 'documents/' + req.files.doc1[0].filename;
                doc1OriginalName = req.files.doc1[0].originalname;
            }
            if (req.files.doc2) {
                deleteFile(currentUser.doc2);
                doc2 = 'documents/' + req.files.doc2[0].filename;
                doc2OriginalName = req.files.doc2[0].originalname;
            }
            if (req.files.doc3) {
                // Delete old doc3 files
                try {
                    if (currentUser.doc3) {
                        const oldPaths = JSON.parse(currentUser.doc3);
                        oldPaths.forEach(p => deleteFile(p));
                    }
                } catch (e) {
                    console.error('Error deleting old doc3 files:', e);
                }
                // Add new doc3 files
                const doc3Paths = [];
                const doc3Names = [];
                req.files.doc3.forEach(file => {
                    doc3Paths.push('documents/' + file.filename);
                    doc3Names.push(file.originalname);
                });
                doc3 = JSON.stringify(doc3Paths);
                doc3OriginalNames = JSON.stringify(doc3Names);
            }
            if (req.files.doc4) {
                // Delete old doc4 files
                try {
                    if (currentUser.doc4) {
                        const oldPaths = JSON.parse(currentUser.doc4);
                        oldPaths.forEach(p => deleteFile(p));
                    }
                } catch (e) {
                    console.error('Error deleting old doc4 files:', e);
                }
                // Add new doc4 files
                const doc4Paths = [];
                const doc4Names = [];
                req.files.doc4.forEach(file => {
                    doc4Paths.push('documents/' + file.filename);
                    doc4Names.push(file.originalname);
                });
                doc4 = JSON.stringify(doc4Paths);
                doc4OriginalNames = JSON.stringify(doc4Names);
            }
        }

        // Update user
        await pool.execute(
            `UPDATE users SET 
                name = ?, email = ?, password = ?, phone = ?, address = ?, role = ?,
                profile_image = ?, doc1 = ?, doc1_original_name = ?, doc2 = ?, doc2_original_name = ?,
                doc3 = ?, doc3_original_names = ?, doc4 = ?, doc4_original_names = ?,
                updated_at = NOW()
             WHERE id = ?`,
            [
                name || currentUser.name,
                email || currentUser.email,
                hashedPassword,
                phone !== undefined ? phone : currentUser.phone,
                address !== undefined ? address : currentUser.address,
                role || currentUser.role,
                profileImage, doc1, doc1OriginalName, doc2, doc2OriginalName,
                doc3, doc3OriginalNames, doc4, doc4OriginalNames,
                userId
            ]
        );

        // Get updated user (without password)
        const [users] = await pool.execute(
            'SELECT id, name, email, phone, address, role, profile_image, doc1, doc1_original_name, doc2, doc2_original_name, doc3, doc3_original_names, doc4, doc4_original_names, is_active, created_at, updated_at FROM users WHERE id = ?',
            [userId]
        );

        const user = users[0];

        // Parse doc3 JSON for response
        let responseDoc3Paths = [];
        let responseDoc3Names = [];
        try {
            if (user.doc3) responseDoc3Paths = JSON.parse(user.doc3);
            if (user.doc3_original_names) responseDoc3Names = JSON.parse(user.doc3_original_names);
        } catch (e) {
            console.error('Error parsing doc3 JSON:', e);
        }

        // Parse doc4 JSON for response
        let responseDoc4Paths = [];
        let responseDoc4Names = [];
        try {
            if (user.doc4) responseDoc4Paths = JSON.parse(user.doc4);
            if (user.doc4_original_names) responseDoc4Names = JSON.parse(user.doc4_original_names);
        } catch (e) {
            console.error('Error parsing doc4 JSON:', e);
        }

        res.json({
            success: true,
            message: 'User updated successfully',
            data: {
                ...user,
                profileImage: buildFileUrl(req, user.profile_image),
                doc1Url: buildFileUrl(req, user.doc1),
                doc1Name: user.doc1_original_name,
                doc2Url: buildFileUrl(req, user.doc2),
                doc2Name: user.doc2_original_name,
                doc3Urls: responseDoc3Paths.map(p => buildFileUrl(req, p)),
                doc3Names: responseDoc3Names,
                doc4Urls: responseDoc4Paths.map(p => buildFileUrl(req, p)),
                doc4Names: responseDoc4Names
            }
        });
    } catch (error) {
        console.error('Update user error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// DELETE /api/users/:id - Delete user (soft delete)
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const userId = req.params.id;

        // Check if user exists
        const [existing] = await pool.execute(
            'SELECT * FROM users WHERE id = ? AND is_active = 1',
            [userId]
        );

        if (existing.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Soft delete
        await pool.execute(
            'UPDATE users SET is_active = 0, updated_at = NOW() WHERE id = ?',
            [userId]
        );

        res.json({
            success: true,
            message: 'User deleted successfully'
        });
    } catch (error) {
        console.error('Delete user error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

// GET /api/users/:id/download/:docType - Download document
router.get('/:id/download/:docType', authenticateToken, async (req, res) => {
    try {
        const { id, docType } = req.params;

        // Check if docType is valid (now includes doc3-INDEX and doc4-INDEX patterns)
        const validDocTypes = ['doc1', 'doc2', 'profile'];
        const isDoc3 = docType.startsWith('doc3-');
        const isDoc4 = docType.startsWith('doc4-');

        if (!validDocTypes.includes(docType) && !isDoc3 && !isDoc4) {
            return res.status(400).json({
                success: false,
                message: 'Invalid document type'
            });
        }

        const [users] = await pool.execute(
            'SELECT * FROM users WHERE id = ? AND is_active = 1',
            [id]
        );

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const user = users[0];
        let filePath, originalName;

        if (docType === 'doc1') {
            filePath = user.doc1;
            originalName = user.doc1_original_name;
        } else if (docType === 'doc2') {
            filePath = user.doc2;
            originalName = user.doc2_original_name;
        } else if (isDoc3) {
            // Handle doc3 with index (e.g., doc3-0, doc3-1, etc.)
            const docIndex = parseInt(docType.split('-')[1], 10);
            try {
                const doc3Paths = user.doc3 ? JSON.parse(user.doc3) : [];
                const doc3Names = user.doc3_original_names ? JSON.parse(user.doc3_original_names) : [];

                if (docIndex >= 0 && docIndex < doc3Paths.length) {
                    filePath = doc3Paths[docIndex];
                    originalName = doc3Names[docIndex] || path.basename(filePath);
                }
            } catch (e) {
                console.error('Error parsing doc3 JSON for download:', e);
            }
        } else if (isDoc4) {
            // Handle doc4 with index (e.g., doc4-0, doc4-1, etc.)
            const docIndex = parseInt(docType.split('-')[1], 10);
            try {
                const doc4Paths = user.doc4 ? JSON.parse(user.doc4) : [];
                const doc4Names = user.doc4_original_names ? JSON.parse(user.doc4_original_names) : [];

                if (docIndex >= 0 && docIndex < doc4Paths.length) {
                    filePath = doc4Paths[docIndex];
                    originalName = doc4Names[docIndex] || path.basename(filePath);
                }
            } catch (e) {
                console.error('Error parsing doc4 JSON for download:', e);
            }
        } else {
            filePath = user.profile_image;
            originalName = 'profile' + path.extname(user.profile_image || '.jpg');
        }

        if (!filePath) {
            return res.status(404).json({
                success: false,
                message: 'File not found'
            });
        }

        const fullPath = path.join(__dirname, '..', 'uploads', filePath);

        if (!fs.existsSync(fullPath)) {
            return res.status(404).json({
                success: false,
                message: 'File not found on server'
            });
        }

        res.download(fullPath, originalName || path.basename(filePath));
    } catch (error) {
        console.error('Download error:', error);
        res.status(500).json({
            success: false,
            message: 'Internal server error'
        });
    }
});

module.exports = router;
