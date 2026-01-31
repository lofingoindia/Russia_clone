const bcrypt = require('bcryptjs');

async function generateHash() {
    try {
        const password = 'admin123';
        const hash = await bcrypt.hash(password, 10);
        console.log('\n========================================');
        console.log('Generated bcrypt hash for password: admin123');
        console.log('========================================');
        console.log(hash);
        console.log('\n\nRun this SQL command in your MySQL database:\n');
        console.log(`UPDATE admins SET password = '${hash}' WHERE email = 'admin@russiaapp.com';\n`);
        
        // Test the hash
        const isValid = await bcrypt.compare('admin123', hash);
        console.log('Verification test:', isValid ? 'PASSED ✓' : 'FAILED ✗');
        console.log('========================================\n');
    } catch (error) {
        console.error('Error:', error);
    }
}

generateHash();
