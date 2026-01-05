# Sowa - Spring Boot Security Application

## Description
A complete Spring Boot application with secure JWT-based authentication, role-based access control, and user-specific data isolation. Users can register, login, and manage their own notes with full CRUD operations.

## Features
- ✅ User registration and login with JWT authentication
- ✅ JWT-based stateless authentication
- ✅ Role-based authorization (USER, ADMIN)
- ✅ Secure CRUD operations for Notes
- ✅ User can only access their own data (data isolation)
- ✅ Password validation and BCrypt hashing (strength 12)
- ✅ Comprehensive input validation with error handling
- ✅ SQL injection prevention using prepared statements
- ✅ HTTP-only cookies for JWT storage
- ✅ Global exception handling

## Technologies
- Java 17+
- Spring Boot 3.2.0
- Spring Security
- Spring Data JPA
- SQLite (with Hibernate Community Dialects)
- Flyway (database migrations)
- JWT (JJWT 0.12.3)
- Lombok
- Spring Validation

## Project Structure
```
src/main/java/com/sowa/
├── Application.java
├── config/
│   └── SecurityConfig.java
├── controller/
│   ├── AuthController.java
│   └── NoteController.java
├── service/
│   ├── UserService.java
│   ├── CustomUserDetailsService.java
│   └── NoteService.java
├── repository/
│   ├── UserRepository.java
│   └── NoteRepository.java
├── model/
│   ├── User.java
│   ├── Note.java
│   └── enums/
│       └── Role.java
├── dto/
│   ├── LoginRequest.java
│   ├── RegisterRequest.java
│   ├── AuthResponse.java
│   ├── NoteCreateDTO.java
│   └── NoteUpdateDTO.java
├── security/
│   ├── JwtAuthenticationFilter.java
│   └── JwtTokenProvider.java
├── exception/
│   ├── GlobalExceptionHandler.java
│   ├── ResourceNotFoundException.java
│   └── UnauthorizedAccessException.java
└── validator/
    └── PasswordValidator.java
```

## Setup Instructions

### Prerequisites
- Java 17 or higher
- Gradle (or use the included Gradle wrapper)

### Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd Sowa
   ```

2. **Generate Gradle Wrapper** (if `gradle/wrapper/gradle-wrapper.jar` doesn't exist):
   ```bash
   gradle wrapper
   ```
   Or if you don't have Gradle installed, download the wrapper jar manually or use a Gradle installation.

3. **Create environment file**
   
   Create a `.env` file in the root directory with the following content:
   ```properties
   DB_URL=jdbc:sqlite:database.db
   DB_USERNAME=
   DB_PASSWORD=
   JWT_SECRET=your-256-bit-secret-key-here-change-in-production-make-it-long-enough
   JWT_EXPIRATION=86400000
   ```
   
   **Important:** Generate a secure random secret key for `JWT_SECRET` in production. The secret should be at least 32 characters long.

3. **Build and run the application**
   
   Using Gradle wrapper (Windows):
   ```bash
   gradlew.bat bootRun
   ```
   
   Or using Gradle directly:
   ```bash
   ./gradlew bootRun
   ```
   
   Or build first then run:
   ```bash
   ./gradlew build
   java -jar build/libs/sowa-1.0.0.jar
   ```

4. **Application will start on**
   ```
   http://localhost:8080
   ```

## API Endpoints

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "Test123!@#"
}
```

**Response (201 Created):**
```json
{
  "message": "User registered successfully",
  "userId": 1
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "Test123!@#"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "userId": 1,
  "username": "testuser",
  "role": "USER"
}
```

The JWT token is also stored in an HTTP-only cookie named `jwt`.

#### Logout
```http
POST /auth/logout
```

**Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

### Notes Endpoints (Requires Authentication)

All note endpoints require authentication. Include the JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

Or the token will be automatically read from the HTTP-only cookie.

#### Get All Notes
```http
GET /api/notes
Authorization: Bearer <token>
```

#### Create Note
```http
POST /api/notes
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "My First Note",
  "description": "This is a note description",
  "status": "active"
}
```

#### Get Note by ID
```http
GET /api/notes/{id}
Authorization: Bearer <token>
```

#### Update Note
```http
PUT /api/notes/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Title",
  "description": "Updated description",
  "status": "completed"
}
```

#### Delete Note
```http
DELETE /api/notes/{id}
Authorization: Bearer <token>
```

#### Search Notes
```http
GET /api/notes/search?q=query
Authorization: Bearer <token>
```

## Testing

### 🚀 Automated Testing (Recommended)

**One-command automated testing suite** - Tests all security requirements automatically:

```bash
# Windows
cd tests
test-all.bat

# Linux/Mac
cd tests
chmod +x test-all.sh
./test-all.sh
```

See [tests/README.md](tests/README.md) for details.

### 📋 Manual Testing

For comprehensive manual testing instructions, see [TESTING_GUIDE.md](TESTING_GUIDE.md).

**For teacher requirements verification**, see [TEACHER_REQUIREMENTS_VERIFICATION.md](TEACHER_REQUIREMENTS_VERIFICATION.md) - a complete checklist of all lab requirements.

### Quick Testing with cURL

### 1. Register a new user
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"Test123!@#\"}"
```

### 2. Login
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"password\":\"Test123!@#\"}" \
  -c cookies.txt
```

Save the token from the response.

### 3. Create a note
```bash
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"My Note\",\"description\":\"Note content\"}"
```

### 4. Get all notes
```bash
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 5. Search notes
```bash
curl -X GET "http://localhost:8080/api/notes/search?q=My" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Password Requirements

Passwords must meet the following criteria:
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special character (!@#$%^&*())
- Cannot be a common password (password, 12345678, qwerty, etc.)

## Security Features

### Authentication & Authorization
- **JWT-based stateless authentication** - Tokens are signed with HMAC SHA-256
- **BCrypt password hashing** - Strength parameter 12
- **Role-based access control** - USER and ADMIN roles
- **HTTP-only cookies** - JWT stored in secure HTTP-only cookies
- **Token expiration** - Configurable token expiration (default 24 hours)

### Data Protection
- **User data isolation** - Users can only access their own notes
- **Prepared statements** - All SQL queries use prepared statements to prevent SQL injection
- **Input validation** - Comprehensive validation using Jakarta Validation
- **Error handling** - Secure error messages that don't expose system details

### Additional Security
- **CSRF disabled** - For stateless JWT authentication (not needed)
- **Session stateless** - No server-side session storage
- **Password policy** - Enforced password complexity requirements

## Database

The application uses SQLite by default. The database file (`database.db`) will be created automatically in the project root directory.

### Database Schema

**Users Table:**
- id (PRIMARY KEY)
- username (UNIQUE)
- email (UNIQUE)
- password (BCrypt hashed)
- role (USER/ADMIN)
- enabled (boolean)
- created_at, updated_at

**Notes Table:**
- id (PRIMARY KEY)
- user_id (FOREIGN KEY to users.id)
- title
- description
- status
- created_at, updated_at

## Error Responses

All errors follow a consistent format:

```json
{
  "timestamp": "2024-01-01T12:00:00",
  "status": 404,
  "error": "Not Found",
  "message": "Note not found"
}
```

### Common HTTP Status Codes
- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success with no content
- `400 Bad Request` - Validation error or bad input
- `401 Unauthorized` - Authentication required or failed
- `403 Forbidden` - Access denied
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

## Testing Checklist

### Authentication Tests
- ✅ Register new user (success)
- ✅ Register with existing username (fail with 400)
- ✅ Register with weak password (fail with 400)
- ✅ Login with valid credentials (success)
- ✅ Login with invalid credentials (fail with 401)
- ✅ Access protected route without token (fail 401)
- ✅ Access protected route with valid token (success)
- ✅ Logout and verify token invalidation

### Authorization Tests
- ✅ User can create their own note
- ✅ User can read their own notes
- ✅ User cannot read other user's notes (404)
- ✅ User can update their own note
- ✅ User cannot update other user's note (404)
- ✅ User can delete their own note
- ✅ User cannot delete other user's note (404)
- ✅ Admin can access /admin/** routes (if implemented)
- ✅ User cannot access /admin/** routes (403)

### Validation Tests
- ✅ Create note with invalid data (400)
- ✅ Create note with missing required fields (400)
- ✅ Update note with invalid data (400)

### SQL Injection Prevention
- ✅ Try SQL injection in search queries
- ✅ Verify prepared statements prevent injection

## Development

### Building the Project
```bash
./gradlew build
```

### Running Tests
```bash
./gradlew test
```

### Database Migrations
Flyway automatically runs migrations on startup. Migration files are located in:
```
src/main/resources/db/migration/
```

## Production Considerations

1. **Change JWT Secret**: Use a strong, randomly generated secret key (at least 32 characters)
2. **Enable HTTPS**: Set `cookie.setSecure(true)` in `AuthController.java`
3. **Environment Variables**: Use proper environment variable management (not .env files)
4. **Database**: Consider using PostgreSQL or MySQL for production
5. **Logging**: Configure proper logging levels
6. **Monitoring**: Add application monitoring and health checks
7. **Rate Limiting**: Consider adding rate limiting for authentication endpoints
8. **Token Refresh**: Implement token refresh mechanism for better UX

## License

This project is provided as-is for educational purposes.

## Support

For issues or questions, please refer to the Spring Boot and Spring Security documentation.
