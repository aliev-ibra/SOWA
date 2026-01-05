# 🧪 Complete Testing Guide

## ✅ Pre-Flight Checklist

### 1. Verify All Files Exist

```bash
# Project structure verification
├── build.gradle ✓
├── settings.gradle ✓
├── .gitignore ✓
├── .env (create this!)
├── .env.example ✓
├── README.md ✓
├── SETUP.md ✓
├── TESTING_GUIDE.md ✓
├── gradlew / gradlew.bat ✓
└── src/
    └── main/
        ├── java/com/sowa/
        │   ├── Application.java ✓
        │   ├── config/
        │   │   └── SecurityConfig.java ✓
        │   ├── controller/
        │   │   ├── AuthController.java ✓
        │   │   └── NoteController.java ✓
        │   ├── dto/
        │   │   ├── LoginRequest.java ✓
        │   │   ├── RegisterRequest.java ✓
        │   │   ├── AuthResponse.java ✓
        │   │   ├── NoteCreateDTO.java ✓
        │   │   └── NoteUpdateDTO.java ✓
        │   ├── exception/
        │   │   ├── GlobalExceptionHandler.java ✓
        │   │   ├── ResourceNotFoundException.java ✓
        │   │   └── UnauthorizedAccessException.java ✓
        │   ├── model/
        │   │   ├── User.java ✓
        │   │   ├── Note.java ✓
        │   │   └── enums/
        │   │       └── Role.java ✓
        │   ├── repository/
        │   │   ├── UserRepository.java ✓
        │   │   └── NoteRepository.java ✓
        │   ├── security/
        │   │   ├── JwtTokenProvider.java ✓
        │   │   └── JwtAuthenticationFilter.java ✓
        │   ├── service/
        │   │   ├── UserService.java ✓
        │   │   ├── NoteService.java ✓
        │   │   └── CustomUserDetailsService.java ✓
        │   └── validator/
        │       └── PasswordValidator.java ✓
        └── resources/
            ├── application.properties ✓
            └── db/migration/
                ├── V1__create_users_table.sql ✓
                └── V2__create_notes_table.sql ✓
```

### 2. Critical Configuration Checks

#### Create .env file (REQUIRED)

Create a `.env` file in the project root:

```properties
DB_URL=jdbc:sqlite:database.db
DB_USERNAME=
DB_PASSWORD=
JWT_SECRET=your-super-secret-jwt-key-must-be-at-least-256-bits-long-for-HS256-algorithm
JWT_EXPIRATION=86400000
```

⚠️ **IMPORTANT**: `JWT_SECRET` must be at least 32 characters for HS256!

#### Verify application.properties

The file should contain:
- `spring.config.import=optional:file:.env[.properties]`
- `spring.datasource.url=${DB_URL}`
- `spring.datasource.driver-class-name=org.sqlite.JDBC`
- `spring.jpa.database-platform=org.hibernate.community.dialect.SQLiteDialect`
- `spring.jpa.hibernate.ddl-auto=validate`
- `spring.flyway.enabled=true`
- `jwt.secret=${JWT_SECRET}`
- `jwt.expiration=${JWT_EXPIRATION:86400000}`

## 🚀 Build & Run

### 1. Clean Build

```bash
# Windows
gradlew.bat clean build

# Linux/Mac
./gradlew clean build
```

### 2. Run Application

```bash
# Windows
gradlew.bat bootRun

# Linux/Mac
./gradlew bootRun
```

### 3. Verify Startup

Look for these log messages:
```
✓ Flyway migration completed
✓ Started Application in X seconds
✓ Tomcat started on port(s): 8080
```

## 🧪 Complete Testing Suite

### Test 1: Register New User ✓

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "Test123!@#"
  }'
```

**Expected Response (201 Created):**
```json
{
  "message": "User registered successfully",
  "userId": 1
}
```

### Test 2: Registration Validation ✓

```bash
# Test weak password
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser2",
    "email": "test2@example.com",
    "password": "weak"
  }'
```

**Expected Response (400 Bad Request):**
```json
{
  "error": "Password must be at least 8 characters long"
}
```

### Test 3: Login ✓

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -c cookies.txt \
  -d '{
    "username": "testuser",
    "password": "Test123!@#"
  }'
```

**Expected Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "userId": 1,
  "username": "testuser",
  "role": "USER"
}
```

**Save the token for next tests!**

### Test 4: Create Note (Authenticated) ✓

```bash
# Using Authorization header
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My First Note",
    "description": "This is a test note"
  }'

# OR using cookies
curl -X POST http://localhost:8080/api/notes \
  -b cookies.txt \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My First Note",
    "description": "This is a test note"
  }'
```

**Expected Response (201 Created):**
```json
{
  "id": 1,
  "userId": 1,
  "title": "My First Note",
  "description": "This is a test note",
  "status": null,
  "createdAt": "2026-01-05T...",
  "updatedAt": "2026-01-05T..."
}
```

### Test 5: Access Without Token ✓

```bash
curl -X GET http://localhost:8080/api/notes
```

**Expected Response (401 Unauthorized):**
```json
{
  "timestamp": "2026-01-05T...",
  "status": 401,
  "error": "Unauthorized",
  "message": "Full authentication is required to access this resource"
}
```

### Test 6: Get All Notes ✓

```bash
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": 1,
    "title": "My First Note",
    "description": "This is a test note",
    "status": null,
    "createdAt": "2026-01-05T...",
    "updatedAt": "2026-01-05T..."
  }
]
```

### Test 7: Get Note by ID ✓

```bash
curl -X GET http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response (200 OK):**
```json
{
  "id": 1,
  "userId": 1,
  "title": "My First Note",
  "description": "This is a test note",
  "status": null,
  "createdAt": "2026-01-05T...",
  "updatedAt": "2026-01-05T..."
}
```

### Test 8: Update Note ✓

```bash
curl -X PUT http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Title",
    "description": "Updated description"
  }'
```

**Expected Response (200 OK):**
```json
{
  "id": 1,
  "userId": 1,
  "title": "Updated Title",
  "description": "Updated description",
  "status": null,
  "createdAt": "2026-01-05T...",
  "updatedAt": "2026-01-05T..." // Updated timestamp
}
```

### Test 9: Search Notes ✓

```bash
curl -X GET "http://localhost:8080/api/notes/search?q=Updated" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": 1,
    "title": "Updated Title",
    "description": "Updated description",
    "status": null,
    "createdAt": "2026-01-05T...",
    "updatedAt": "2026-01-05T..."
  }
]
```

### Test 10: Data Isolation (CRITICAL) ✓

```bash
# Create second user
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user2",
    "email": "user2@example.com",
    "password": "Test456!@#"
  }'

# Login as second user
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user2",
    "password": "Test456!@#"
  }'

# Try to access first user's note (should fail)
curl -X GET http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer USER2_TOKEN_HERE"
```

**Expected Response (404 Not Found):**
```json
{
  "timestamp": "2026-01-05T...",
  "status": 404,
  "error": "Not Found",
  "message": "Note not found"
}
```

### Test 11: Delete Note ✓

```bash
# Login as first user
curl -X DELETE http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer USER1_TOKEN_HERE"
```

**Expected Response (204 No Content):**
```
(Empty body, status 204)
```

### Test 12: SQL Injection Prevention ✓

```bash
# Try SQL injection in search
curl -X GET "http://localhost:8080/api/notes/search?q='; DROP TABLE notes; --" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Expected**: Should return empty array or handle safely, NOT execute SQL

### Test 13: Invalid Input Validation ✓

```bash
# Create note with empty title
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "",
    "description": "Test"
  }'
```

**Expected Response (400 Bad Request):**
```json
{
  "timestamp": "2026-01-05T...",
  "status": 400,
  "error": "Validation Failed",
  "errors": {
    "title": "Title is required"
  }
}
```

### Test 14: Logout ✓

```bash
curl -X POST http://localhost:8080/auth/logout \
  -b cookies.txt \
  -c cookies.txt
```

**Expected Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

### Test 15: Duplicate Username Registration ✓

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "different@example.com",
    "password": "Test123!@#"
  }'
```

**Expected Response (400 Bad Request):**
```json
{
  "error": "Username already exists"
}
```

### Test 16: Duplicate Email Registration ✓

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "differentuser",
    "email": "test@example.com",
    "password": "Test123!@#"
  }'
```

**Expected Response (400 Bad Request):**
```json
{
  "error": "Email already exists"
}
```

## 🔍 Common Issues & Solutions

### Issue 1: "JWT secret cannot be null"
**Solution**: Ensure `.env` file exists and `JWT_SECRET` is at least 32 characters

### Issue 2: "Table 'users' doesn't exist"
**Solution**: Delete `database.db` and restart application to run Flyway migrations

### Issue 3: "Port 8080 already in use"
**Solution**: Add to `application.properties`:
```properties
server.port=8081
```

### Issue 4: "Unable to load UserDetailsService"
**Solution**: Check `CustomUserDetailsService` is annotated with `@Service`

### Issue 5: 401 even with valid token
**Solution**: Verify:
- Token format: `Bearer YOUR_TOKEN` (space after Bearer)
- Token not expired
- Cookie httpOnly and secure settings match your environment

### Issue 6: "Gradle wrapper not found"
**Solution**: Run `gradle wrapper` to generate wrapper files

### Issue 7: "Database locked"
**Solution**: Close any other connections to `database.db` or restart the application

## 📊 Security Verification Matrix

| Security Feature | Status | Test Method |
|-----------------|--------|-------------|
| Password Hashing (BCrypt) | ✅ | Check database - password should be hashed |
| Password Validation | ✅ | Test 2: Try weak password |
| JWT Generation | ✅ | Test 3: Login returns token |
| JWT Validation | ✅ | Test 5: Access without token fails |
| HTTP-Only Cookies | ✅ | Check Set-Cookie header |
| Data Isolation | ✅ | Test 10: User2 can't access User1 data |
| SQL Injection Prevention | ✅ | Test 12: Injection attempts fail safely |
| Input Validation | ✅ | Test 13: Invalid input rejected |
| CSRF Protection | ✅ | Disabled for stateless JWT (correct) |
| Role-Based Access | ✅ | `@PreAuthorize` annotations present |
| Prepared Statements | ✅ | Repository uses `@Query` with `?` placeholders |
| Error Handling | ✅ | No stack traces in responses |

## 🎯 Final Checklist

- [ ] `.env` file created with strong JWT secret (at least 32 chars)
- [ ] Application starts without errors
- [ ] Database migrations run successfully
- [ ] Can register new user
- [ ] Password validation works
- [ ] Can login and receive JWT
- [ ] Can create note with authentication
- [ ] Cannot access notes without authentication
- [ ] Users cannot access other users' notes
- [ ] Can update own notes
- [ ] Can delete own notes
- [ ] Search functionality works
- [ ] SQL injection attempts fail safely
- [ ] Validation errors return proper messages
- [ ] Logout clears JWT cookie
- [ ] No sensitive data in error responses
- [ ] All tests pass

## 🚀 Ready for Submission

Once all tests pass:

- ✅ Commit all code (except `.env` and `database.db`)
- ✅ Push to GitHub/GitLab
- ✅ Verify README.md is complete
- ✅ Test fresh clone works with setup instructions
- ✅ Document any additional features or deviations

## 📝 Automated Test Script

Save this as `test-api.sh` (Linux/Mac) or `test-api.bat` (Windows):

### Linux/Mac Script

```bash
#!/bin/bash

BASE_URL="http://localhost:8080"
TOKEN=""

echo "🧪 Starting API Tests..."

# Test 1: Register
echo "Test 1: Register user"
RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"Test123!@#"}')
echo "$RESPONSE"
echo ""

# Test 2: Login
echo "Test 2: Login"
RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}')
TOKEN=$(echo $RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Token: ${TOKEN:0:50}..."
echo ""

# Test 3: Create Note
echo "Test 3: Create note"
RESPONSE=$(curl -s -X POST "$BASE_URL/api/notes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Note","description":"Test description"}')
echo "$RESPONSE"
echo ""

# Test 4: Get Notes
echo "Test 4: Get all notes"
RESPONSE=$(curl -s -X GET "$BASE_URL/api/notes" \
  -H "Authorization: Bearer $TOKEN")
echo "$RESPONSE"
echo ""

echo "✅ Tests completed!"
```

### Windows Batch Script

```batch
@echo off
set BASE_URL=http://localhost:8080
set TOKEN=

echo 🧪 Starting API Tests...

echo Test 1: Register user
curl -X POST "%BASE_URL%/auth/register" -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"Test123!@#\"}"
echo.

echo Test 2: Login
for /f "tokens=*" %%i in ('curl -s -X POST "%BASE_URL%/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"password\":\"Test123!@#\"}"') do set RESPONSE=%%i
echo %RESPONSE%
echo.

echo ✅ Tests completed!
pause
```
