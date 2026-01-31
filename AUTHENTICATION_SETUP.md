# Russia App - Authentication Setup Guide

## Overview
This implementation connects the Flutter mobile app with the backend authentication system. Admin users can register users from the dashboard, and those users can login to the mobile app.

## Architecture

### Database Schema
- **admins table**: Stores admin credentials for dashboard access
- **users table**: Stores user credentials for mobile app access (with password field)

### Backend APIs
- **POST /api/auth/login**: Admin login for dashboard
- **POST /api/auth/user/login**: User login for mobile app
- **POST /api/users**: Create new user (admin only, requires password)
- **PUT /api/users/:id**: Update user (admin only, can update password)

### Flutter App
- **API Service**: Handles authentication and token management
- **Login Screen**: Email/password login with backend integration
- **Profile Screen**: Displays user data and logout functionality
- **Auth Checker**: Automatically checks login status on app start

## Setup Instructions

### 1. Database Setup

If you're setting up fresh:
```sql
-- Run the complete schema file
mysql -u your_user -p your_database < backend/config/database.sql
```

If you already have the database without password field:
```sql
-- Run the migration script
mysql -u your_user -p your_database < backend/config/migration_add_password.sql
```

**Important**: The migration script sets all existing users to password `password123`. You should update passwords for production use.

### 2. Backend Configuration

Make sure your `.env` file has:
```env
JWT_SECRET=your_secret_key_here
PORT=5000
DB_HOST=localhost
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_db_name
```

Start the backend server:
```bash
cd backend
npm install
npm start
```

### 3. Dashboard Updates

The dashboard now includes a password field when creating/editing users:
- **Creating User**: Password is required (minimum 6 characters)
- **Editing User**: Password is optional (leave blank to keep current password)

### 4. Flutter App Configuration

Update the API URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-domain.com/api';
// For local testing: 'http://10.0.2.2:5000/api' (Android emulator)
// For local testing: 'http://localhost:5000/api' (iOS simulator)
```

Build and run the app:
```bash
cd russia_app
flutter pub get
flutter run
```

## Testing the Complete Flow

### 1. Create User from Dashboard
1. Login to dashboard as admin
2. Go to Users page
3. Click "Add New User"
4. Fill in:
   - Name: Test User
   - Email: test@example.com
   - Password: test123456
   - Phone, Address, Role (optional)
5. Click Save

### 2. Login to Mobile App
1. Open the Flutter app
2. Enter:
   - Email: test@example.com
   - Password: test123456
3. Click Login
4. You should be redirected to the main screen

### 3. View Profile
1. Navigate to Profile tab
2. You should see the user's name, email, and phone
3. Click "Выйти из аккаунта" (Logout) to test logout

### 4. Test Auto-Login
1. Close and reopen the app
2. You should automatically be logged in (skipping login screen)

## Default Credentials

### Dashboard Admin
- Email: admin@russiaapp.com
- Password: admin123

### Sample Users (if you ran the full database.sql)
- Email: alice@example.com
- Password: password123

- Email: bob@example.com
- Password: password123

## Security Notes

1. **Password Hashing**: All passwords are hashed using bcrypt with salt rounds of 10
2. **JWT Tokens**: 
   - Admin tokens expire in 24 hours
   - User tokens expire in 30 days (longer for mobile app convenience)
3. **Token Storage**: Tokens are stored securely in SharedPreferences on the device
4. **HTTPS**: Always use HTTPS in production to protect credentials in transit

## Troubleshooting

### "Network error" on login
- Check that backend server is running
- Verify API URL in `api_service.dart`
- Check network connectivity
- For Android emulator, use `10.0.2.2` instead of `localhost`

### "Invalid email or password"
- Verify user exists in database
- Check that password was set correctly in dashboard
- Ensure password is at least 6 characters

### Database connection errors
- Verify database credentials in `.env`
- Check that MySQL server is running
- Ensure database exists and has correct schema

### Token expired errors
- Users need to logout and login again
- Check JWT_SECRET is same across restarts
- Verify system time is correct

## API Endpoints Reference

### User Login (Mobile App)
```
POST /api/auth/user/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "jwt_token_here",
    "user": {
      "id": 1,
      "name": "User Name",
      "email": "user@example.com",
      "phone": "+1234567890",
      "address": "Address",
      "role": "User"
    }
  }
}
```

### Create User (Dashboard)
```
POST /api/users
Authorization: Bearer admin_jwt_token
Content-Type: multipart/form-data

name: User Name
email: user@example.com
password: password123
phone: +1234567890
address: Some address
role: User
profileImage: (file)
doc1: (file)
doc2: (file)
```

## Future Enhancements

1. **Password Reset**: Add forgot password functionality
2. **Email Verification**: Verify email addresses on registration
3. **Two-Factor Authentication**: Add 2FA for enhanced security
4. **Password Requirements**: Enforce stronger password policies
5. **Account Lockout**: Lock accounts after multiple failed login attempts
6. **Activity Log**: Track user login history and activities

## Support

For issues or questions, contact the development team or refer to the main project documentation.
