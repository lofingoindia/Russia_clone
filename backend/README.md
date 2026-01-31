# Russia App Dashboard - Backend API

Node.js + Express + MySQL backend for the Russia App Dashboard.

## Prerequisites

- Node.js 18+ 
- MySQL 8.0+
- npm or yarn

## Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Database

1. Create a MySQL database (or use existing):
   - Database Name: `mosr_app_clone`
   - User: `mosr_app_clone32`
   - Password: `CwiN7l%6wm7GmD*+`

2. Run the SQL schema to create tables:
   ```bash
   mysql -u mosr_app_clone32 -p mosr_app_clone < config/database.sql
   ```

   Or run the SQL manually in MySQL Workbench / phpMyAdmin.

### 3. Environment Variables

The `.env` file is already configured. Update if needed:

```env
DB_HOST=localhost
DB_USER=mosr_app_clone32
DB_PASSWORD=CwiN7l%6wm7GmD*+
DB_NAME=mosr_app_clone
DB_PORT=3306
JWT_SECRET=russia_app_super_secret_jwt_key_2024_secure
PORT=5000
FRONTEND_URL=http://localhost:3000
```

### 4. Start the Server

Development mode:
```bash
npm run dev
```

Production mode:
```bash
npm start
```

Server will run on `http://localhost:5000`

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Admin login |
| GET | `/api/auth/me` | Get current admin |
| POST | `/api/auth/logout` | Logout |
| POST | `/api/auth/change-password` | Change password |

### Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users |
| GET | `/api/users/stats` | Get dashboard statistics |
| GET | `/api/users/:id` | Get single user |
| POST | `/api/users` | Create new user |
| PUT | `/api/users/:id` | Update user |
| DELETE | `/api/users/:id` | Delete user (soft delete) |
| GET | `/api/users/:id/download/:docType` | Download user document |

## Default Admin Credentials

- **Email:** admin@russiaapp.com
- **Password:** admin123

## File Uploads

Files are stored in the `uploads/` directory:
- `uploads/profiles/` - Profile images
- `uploads/documents/` - User documents (ID, migration card)

## Database Schema

### admins table
- `id` - Primary key
- `name` - Admin name
- `email` - Unique email
- `password` - Bcrypt hashed password
- `role` - super_admin, admin, moderator
- `is_active` - Account status
- `last_login` - Last login timestamp

### users table
- `id` - Primary key
- `name` - User full name
- `email` - Unique email
- `phone` - Phone number
- `address` - Physical address
- `role` - Admin, Manager, User
- `profile_image` - Profile image path
- `doc1` - Document 1 path
- `doc1_original_name` - Original filename
- `doc2` - Document 2 path
- `doc2_original_name` - Original filename
- `is_active` - Account status
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp
