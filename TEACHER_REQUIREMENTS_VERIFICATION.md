# 🎓 Teacher Requirements Verification Guide

Complete systematic verification of all Lab 11-12 requirements.

## 📋 COMPLETE REQUIREMENTS VERIFICATION

---

## PART 1: Security Configuration Requirements ✓

### Requirement 1.1: Custom UserDetailsService

**Teacher's Requirement:** "Implement custom UserDetailsService"

#### Verification Steps:

**1. Check file exists:**
```bash
# Location: src/main/java/com/sowa/service/CustomUserDetailsService.java
ls src/main/java/com/sowa/service/CustomUserDetailsService.java
```

**2. Code Verification:**
```java
// Should have:
@Service
public class CustomUserDetailsService implements UserDetailsService {
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Implementation
    }
}
```

**3. Functional Test:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}'
```

**✅ Pass Criteria:**
- [x] File exists with `@Service` annotation
- [x] Implements `UserDetailsService` interface
- [x] Returns `UserDetails` object
- [x] Login works successfully

---

### Requirement 1.2: SecurityFilterChain Configuration

**Teacher's Requirement:** "Implement SecurityFilterChain"

#### Verification Steps:

**1. Check SecurityConfig.java exists:**
```bash
# Location: src/main/java/com/sowa/config/SecurityConfig.java
```

**2. Verify public routes work WITHOUT authentication:**
```bash
# Should return: 405 Method Not Allowed (route exists, but wrong method)
curl -X GET http://localhost:8080/auth/login -w "\nStatus: %{http_code}\n"

# Should return: 405 Method Not Allowed (route exists, but wrong method)
curl -X GET http://localhost:8080/auth/register -w "\nStatus: %{http_code}\n"
```

**3. Verify protected routes REQUIRE authentication:**
```bash
# Should return: 401 Unauthorized (no token provided)
curl -X GET http://localhost:8080/api/notes -w "\nStatus: %{http_code}\n"
```

**✅ Pass Criteria:**
- [x] `SecurityConfig.java` has `@Bean SecurityFilterChain`
- [x] Public routes (`/auth/**`) accessible without token
- [x] Protected routes (`/api/**`) require authentication
- [x] Returns 401 for unauthenticated requests

---

### Requirement 1.3: Password Hashing with BCrypt

**Teacher's Requirement:** "Use bcrypt with strength parameter"

#### Verification Steps:

**1. Register a user:**
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"bcrypttest","email":"bcrypt@test.com","password":"Test123!@#"}'
```

**2. Check database directly:**
```sql
-- Open database.db with SQLite viewer
SELECT password FROM users WHERE username='bcrypttest';
-- Password should start with $2a$ or $2b$ (BCrypt format)
-- Example: $2a$12$... (where 12 is the strength parameter)
```

**3. Code Verification:**
```java
// In SecurityConfig.java, verify this exists:
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(12); // ← Strength parameter = 12
}
```

**4. Verify login works:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"bcrypttest","password":"Test123!@#"}'
```

**✅ Pass Criteria:**
- [x] Password in database starts with `$2a$` or `$2b$`
- [x] Contains `$12$` (strength parameter)
- [x] Original password NOT visible in database
- [x] Can login with original password

---

## PART 2: JWT Authentication Requirements ✓

### Requirement 2.1: /auth/login Returns JWT

**Teacher's Requirement:** "Implement /auth/login returning JWT"

#### Test:
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -v \
  -d '{"username":"testuser","password":"Test123!@#"}'
```

**✅ Pass Criteria:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",  // ← JWT token
  "type": "Bearer",
  "userId": 1,
  "username": "testuser",
  "role": "USER"
}
```

**Additional Check:** Token should have 3 parts separated by dots (header.payload.signature)

---

### Requirement 2.2: JWT Stored in HTTP-only Cookie OR Authorization Header

**Teacher's Requirement:** "Store JWT in HTTP-only cookie or Authorization: Bearer"

#### Test Option A - HTTP-only Cookie:
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -v \
  -d '{"username":"testuser","password":"Test123!@#"}' 2>&1 | grep -i "Set-Cookie"
```

**✅ Pass Criteria:** Response headers include:
```
Set-Cookie: jwt=eyJhbGc...; Path=/; HttpOnly
```

#### Test Option B - Authorization Header:
```bash
# Get token from login
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' \
  | jq -r '.token')

# Use it in Authorization header
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN"
```

**✅ Pass Criteria:** Both methods work for authentication

---

### Requirement 2.3: Custom JWT Filter

**Teacher's Requirement:** "Build JwtAuthFilter"

#### Verification:

**1. Check file exists:**
```bash
# Location: src/main/java/com/sowa/security/JwtAuthenticationFilter.java
```

**2. Code Verification:**
```java
// Should have:
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(...) {
        // Implementation
    }
}
```

**3. Test it intercepts requests:**
```bash
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer INVALID_TOKEN" \
  -w "\nStatus: %{http_code}\n"
```

**✅ Pass Criteria:**
- [x] File exists and extends `OncePerRequestFilter`
- [x] Invalid token returns 401 or 403
- [x] Valid token allows access
- [x] Filter registered in `SecurityFilterChain`

---

### Requirement 2.4: Tokens Validated on Every Request

**Teacher's Requirement:** "Tokens validated on every request"

#### Test:
```bash
# 1. Login and get token
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' \
  | jq -r '.token')

# 2. Make multiple requests with same token
for i in {1..5}; do
  echo "Request $i:"
  curl -X GET http://localhost:8080/api/notes \
    -H "Authorization: Bearer $TOKEN" \
    -w "\nStatus: %{http_code}\n\n"
done

# 3. Use expired/invalid token
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer invalid.token.here" \
  -w "\nStatus: %{http_code}\n"
```

**✅ Pass Criteria:**
- [x] Valid token: All requests return 200
- [x] Invalid token: All requests return 401
- [x] Each request validates the token (not cached)

---

### Requirement 2.5: SecurityContextHolder Identifies Authenticated User

**Teacher's Requirement:** "Use SecurityContextHolder to identify the authenticated user"

#### Code Verification:
```java
// In NoteService.java, verify this pattern exists:
private Long getCurrentUserId() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    // ... extracts user ID from authentication
}
```

#### Functional Test:
```bash
# 1. Create two users
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","email":"user1@test.com","password":"Test123!@#"}'

curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","email":"user2@test.com","password":"Test123!@#"}'

# 2. Login as user1, create note
TOKEN1=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"Test123!@#"}' | jq -r '.token')

NOTE_ID=$(curl -s -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json" \
  -d '{"title":"User1 Note","description":"Test"}' | jq -r '.id')

# 3. Login as user2, try to get user1's notes
TOKEN2=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"Test123!@#"}' | jq -r '.token')

curl -X GET http://localhost:8080/api/notes/$NOTE_ID \
  -H "Authorization: Bearer $TOKEN2" \
  -w "\nStatus: %{http_code}\n"
# Should return 404 (not found), proving user isolation works
```

**✅ Pass Criteria:**
- [x] User2 cannot access User1's notes (404 response)
- [x] Each user only sees their own data
- [x] SecurityContextHolder correctly identifies current user

---

## PART 3: Authorization Requirements ✓

### Requirement 3.1: Roles Defined (USER, ADMIN)

**Teacher's Requirement:** "Defined roles (e.g., USER, ADMIN)"

#### Verification:

**1. Check Role.java enum exists:**
```bash
# Location: src/main/java/com/sowa/model/enums/Role.java
```

**2. Code Verification:**
```java
public enum Role {
    USER, ADMIN
}
```

**3. Verify in database:**
```sql
SELECT role FROM users;
-- Should show: USER or ADMIN
```

**✅ Pass Criteria:**
- [x] `Role.java` enum exists with USER and ADMIN
- [x] Users are assigned roles
- [x] Default role is USER for registration

---

### Requirement 3.2: Protected Endpoints Using @PreAuthorize

**Teacher's Requirement:** "Protected endpoints using: @PreAuthorize or route-based config"

#### Code Verification:
```java
// In NoteController.java, verify annotations exist:
@PreAuthorize("hasRole('USER')")
@GetMapping
public ResponseEntity<List<Note>> getAllNotes() { ... }
```

#### Functional Test:
```bash
# Test with USER role (should work)
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# Should return: 200 OK
```

**✅ Pass Criteria:**
- [x] All controller methods have `@PreAuthorize` annotations
- [x] Correct roles can access endpoints
- [x] Wrong roles receive 403 Forbidden

---

### Requirement 3.3: Denied Access Returns 401/403

**Teacher's Requirement:** "Denied access returns correct status (401/403)"

#### Test Cases:
```bash
# Test 1: No token (should return 401 Unauthorized)
curl -X GET http://localhost:8080/api/notes -w "\nStatus: %{http_code}\n"

# Test 2: Invalid token (should return 401 Unauthorized)
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer invalid.token.here" \
  -w "\nStatus: %{http_code}\n"

# Test 3: Access other user's resource (should return 404 Not Found)
curl -X GET http://localhost:8080/api/notes/999 \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
```

**✅ Pass Criteria:**
- [x] No authentication → 401 Unauthorized
- [x] Invalid token → 401 Unauthorized
- [x] Wrong role → 403 Forbidden
- [x] Other user's data → 404 Not Found (not 403!)

---

## PART 4: Database Layer Requirements ✓

### Requirement 4.1: Flyway Migrations

**Teacher's Requirement:** "Created Flyway migration V<number>_create<entity>.sql"

#### Verification:

**1. Check migrations exist:**
```bash
ls src/main/resources/db/migration/
# Should show:
# V1__create_users_table.sql
# V2__create_notes_table.sql
```

**2. Verify migrations ran:**
Check application startup logs:
```
Flyway migration completed successfully
```

**3. Check database:**
```sql
-- Open database.db
-- Tables should exist: users, notes, flyway_schema_history
SELECT * FROM flyway_schema_history;
```

**✅ Pass Criteria:**
- [x] Migration files exist with correct naming
- [x] Migrations execute on startup
- [x] Tables created in database
- [x] `flyway_schema_history` table shows applied migrations

---

### Requirement 4.2: Entity Table Includes user_id Foreign Key

**Teacher's Requirement:** "Entity table includes user_id foreign key"

#### SQL Verification:
```sql
-- Check V2__create_notes_table.sql contains:
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,  -- ← Must exist
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE  -- ← Foreign key
);

CREATE INDEX idx_notes_user_id ON notes(user_id);  -- ← Index for performance
```

#### Database Verification:
```sql
-- Open database.db and run:
PRAGMA foreign_key_list(notes);
-- Should show: user_id references users(id)
```

**✅ Pass Criteria:**
- [x] `user_id` column exists in notes table
- [x] Foreign key constraint defined
- [x] Index on `user_id` for performance
- [x] Cascade delete configured

---

### Requirement 4.3: Spring Data JPA Repository

**Teacher's Requirement:** "Implemented JPA repository or JDBC Template"

#### Code Check:
```java
@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    // Should have custom query methods
    List<Note> findByUserId(Long userId);
    Optional<Note> findByIdAndUserId(Long id, Long userId);
}
```

**✅ Pass Criteria:**
- [x] Repository interface exists
- [x] Extends `JpaRepository<Note, Long>`
- [x] Has custom query methods
- [x] Methods follow Spring Data JPA naming conventions

---

### Requirement 4.4: At Least One Prepared Statement Raw SQL

**Teacher's Requirement:** "At least one prepared-statement raw SQL (if JDBC template)"

#### Code Verification - Find in NoteRepository.java:
```java
@Query(value = "SELECT * FROM notes WHERE user_id = ?1 AND title LIKE ?2 ORDER BY created_at DESC", 
       nativeQuery = true)
List<Note> searchByUserAndTitle(Long userId, String titlePattern);

@Modifying
@Query(value = "DELETE FROM notes WHERE user_id = ?1 AND id = ?2", nativeQuery = true)
int deleteByIdAndUserId(Long userId, Long id);
```

#### Functional Test:
```bash
# Test the raw SQL query
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

curl -X GET "http://localhost:8080/api/notes/search?q=test" \
  -H "Authorization: Bearer $TOKEN"
```

**✅ Pass Criteria:**
- [x] At least one `@Query` with `nativeQuery = true`
- [x] Uses `?` placeholders (prepared statements)
- [x] Query works functionally
- [x] SQL injection attempts fail

---

## PART 5: Entity and Validation Requirements ✓

### Requirement 5.1: Entity Class with Constraints

**Teacher's Requirement:** "Created entity class with fields + constraints"

#### Code Check - Note.java:
```java
@Entity
@Table(name = "notes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Note {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "user_id", nullable = false)  // ← Constraint
    private Long userId;
    
    @NotBlank  // ← Validation
    @Size(max = 255)  // ← Constraint
    private String title;
    
    @Size(max = 5000)
    private String description;
    
    // ... timestamps
}
```

**✅ Pass Criteria:**
- [x] Entity has `@Entity` annotation
- [x] Fields have validation constraints
- [x] Database constraints match entity constraints

---

### Requirement 5.2: DTO for Input with Validation

**Teacher's Requirement:** "DTO for input with validation annotations"

#### Code Check - NoteCreateDTO.java:
```java
@Data
public class NoteCreateDTO {
    @NotBlank(message = "Title is required")
    @Size(max = 255, message = "Title cannot exceed 255 characters")
    private String title;
    
    @Size(max = 5000, message = "Description cannot exceed 5000 characters")
    private String description;
}
```

#### Functional Test:
```bash
# Test validation - empty title
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"","description":"Test"}'

# Expected response (400 Bad Request):
# {
#   "status": 400,
#   "error": "Validation Failed",
#   "errors": {
#     "title": "Title is required"
#   }
# }
```

**✅ Pass Criteria:**
- [x] DTOs exist for create and update operations
- [x] Have validation annotations (`@NotBlank`, `@Size`, `@Email`, etc.)
- [x] Validation messages are clear
- [x] Invalid input returns 400 with detailed errors

---

### Requirement 5.3: Prevent Mass Assignment

**Teacher's Requirement:** "Prevented mass assignment (no direct mapping from DTO → entity without whitelisting)"

#### Code Verification - NoteService.java:
```java
public Note createNote(NoteCreateDTO dto) {
    Long userId = getCurrentUserId();
    
    Note note = new Note();
    note.setUserId(userId);  // ← Set from SecurityContext, NOT from DTO
    note.setTitle(dto.getTitle());  // ← Only whitelisted fields
    note.setDescription(dto.getDescription());  // ← Only whitelisted fields
    // id, createdAt, updatedAt NOT settable from DTO
    
    return noteRepository.save(note);
}
```

#### Attack Test:
```bash
# Try to set userId via DTO (should be ignored)
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title":"Test",
    "description":"Test",
    "userId":999
  }'

# Verify the note has correct userId (from token, not from request)
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN"
# userId should match authenticated user, NOT 999
```

**✅ Pass Criteria:**
- [x] DTOs don't include sensitive fields (id, userId, timestamps)
- [x] Service layer explicitly sets fields
- [x] No ModelMapper/BeanUtils direct copying
- [x] userId always comes from SecurityContext

---

## PART 6: Service Layer Security Requirements ✓

### Requirement 6.1: CRUD Operations with Access Control

**Teacher's Requirement:** "CRUD operations must enforce access rules: Users can only access/update/delete their own data"

#### Complete Test Suite:
```bash
# Setup: Create two users and notes
# User 1
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","email":"user1@test.com","password":"Test123!@#"}'

TOKEN1=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"Test123!@#"}' | jq -r '.token')

NOTE1=$(curl -s -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json" \
  -d '{"title":"User1 Note","description":"Private"}' | jq -r '.id')

# User 2
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","email":"user2@test.com","password":"Test123!@#"}'

TOKEN2=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"Test123!@#"}' | jq -r '.token')

# Test 1: User2 tries to READ User1's note
echo "Test 1: User2 reads User1's note"
curl -X GET http://localhost:8080/api/notes/$NOTE1 \
  -H "Authorization: Bearer $TOKEN2" \
  -w "\nStatus: %{http_code}\n"
# ✅ Must return: 404 Not Found

# Test 2: User2 tries to UPDATE User1's note
echo "Test 2: User2 updates User1's note"
curl -X PUT http://localhost:8080/api/notes/$NOTE1 \
  -H "Authorization: Bearer $TOKEN2" \
  -H "Content-Type: application/json" \
  -d '{"title":"Hacked!"}' \
  -w "\nStatus: %{http_code}\n"
# ✅ Must return: 404 Not Found

# Test 3: User2 tries to DELETE User1's note
echo "Test 3: User2 deletes User1's note"
curl -X DELETE http://localhost:8080/api/notes/$NOTE1 \
  -H "Authorization: Bearer $TOKEN2" \
  -w "\nStatus: %{http_code}\n"
# ✅ Must return: 404 Not Found

# Test 4: Verify User1's note still exists
echo "Test 4: User1 reads own note"
curl -X GET http://localhost:8080/api/notes/$NOTE1 \
  -H "Authorization: Bearer $TOKEN1" \
  -w "\nStatus: %{http_code}\n"
# ✅ Must return: 200 OK with note data

# Test 5: User1 can update own note
echo "Test 5: User1 updates own note"
curl -X PUT http://localhost:8080/api/notes/$NOTE1 \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated by owner"}' \
  -w "\nStatus: %{http_code}\n"
# ✅ Must return: 200 OK

# Test 6: User1 can delete own note
echo "Test 6: User1 deletes own note"
curl -X DELETE http://localhost:8080/api/notes/$NOTE1 \
  -H "Authorization: Bearer $TOKEN1" \
  -w "\nStatus: %{http_code}\n"
# ✅ Must return: 204 No Content
```

**✅ Pass Criteria:**
- [x] User cannot read other user's data (404)
- [x] User cannot update other user's data (404)
- [x] User cannot delete other user's data (404)
- [x] User CAN perform all CRUD on own data (200/201/204)
- [x] Returns 404 (not 403) for other user's data

---

### Requirement 6.2: Proper 404 for Other User's Resources

**Teacher's Requirement:** "proper '404' returned if accessing someone else's resource"

**Why 404 and not 403?**
- 403 Forbidden reveals the resource exists
- 404 Not Found hides existence from unauthorized users
- Better security practice

#### Test:
```bash
# User2 tries to access User1's note ID
curl -X GET http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer $TOKEN2" \
  -v

# Expected Response:
# HTTP/1.1 404 Not Found
# {
#   "timestamp": "2026-01-05T...",
#   "status": 404,
#   "error": "Not Found",
#   "message": "Note not found"
# }
```

#### Code Verification:
```java
// Service method should use findByIdAndUserId:
public Note getNoteById(Long id) {
    Long userId = getCurrentUserId();
    return noteRepository.findByIdAndUserId(id, userId)
        .orElseThrow(() -> new ResourceNotFoundException("Note not found"));
    // ← Throws 404, not 403
}
```

**✅ Pass Criteria:**
- [x] Returns 404 (not 403) for other user's data
- [x] Error message doesn't reveal resource existence
- [x] Same behavior for non-existent IDs

---

## PART 7: Security and Error Handling ✓

### Requirement 7.1: No SQL Injection Possible

**Teacher's Requirement:** "No SQL injection is possible"

#### SQL Injection Tests:
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

# Test 1: Search with SQL injection attempt
curl -X GET "http://localhost:8080/api/notes/search?q='; DROP TABLE notes; --" \
  -H "Authorization: Bearer $TOKEN"
# ✅ Should return empty array, NOT execute DROP

# Test 2: Title with SQL injection
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"'\'' OR 1=1; --","description":"Test"}'
# ✅ Should create note with literal title, NOT execute SQL

# Verify: Check tables still exist
# Open database.db
# SELECT COUNT(*) FROM users;  -- Should return count, not error
# SELECT COUNT(*) FROM notes;  -- Should return count, not error
```

#### Code Verification:
```java
// All queries must use prepared statements:
@Query(value = "SELECT * FROM notes WHERE user_id = ?1 AND title LIKE ?2", 
       nativeQuery = true)
List<Note> searchByUserAndTitle(Long userId, String titlePattern);
// ← Uses ? placeholders = prepared statements = SQL injection safe
```

**✅ Pass Criteria:**
- [x] All SQL injection attempts fail safely
- [x] Database tables intact after injection attempts
- [x] Uses parameterized queries (`?` placeholders)
- [x] JPA/Hibernate also prevents injection by default

---

### Requirement 7.2: Global Exception Handler

**Teacher's Requirement:** "Global exception handler returns safe, non-sensitive messages"

#### Test Cases:
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

# Test 1: Resource not found
curl -X GET http://localhost:8080/api/notes/999999 \
  -H "Authorization: Bearer $TOKEN"

# Expected:
# {
#   "timestamp": "2026-01-05T...",
#   "status": 404,
#   "error": "Not Found",
#   "message": "Note not found"  ← Safe message
# }
# ✅ NO stack trace visible

# Test 2: Validation error
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"","description":"Test"}'

# Expected:
# {
#   "timestamp": "2026-01-05T...",
#   "status": 400,
#   "error": "Validation Failed",
#   "errors": {
#     "title": "Title is required"  ← Specific field errors
#   }
# }

# Test 3: Invalid login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user1","password":"wrongpassword"}'

# Expected:
# {
#   "error": "Invalid username or password"  ← Generic message
# }
# ✅ Doesn't reveal if username exists

# Test 4: Unauthorized access
curl -X GET http://localhost:8080/api/notes

# Expected:
# HTTP 401 Unauthorized
# NO sensitive information exposed
```

#### Code Verification:
```java
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleResourceNotFound(...) {
        // Returns safe error message without sensitive data
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleGeneralException(...) {
        // Returns "Internal Server Error" WITHOUT stack trace
    }
}
```

**✅ Pass Criteria:**
- [x] No stack traces in JSON responses
- [x] Error messages are generic and safe
- [x] No file paths or internal details exposed
- [x] Returns appropriate HTTP status codes
- [x] GlobalExceptionHandler catches all exceptions

---

### Requirement 7.3: Handled Non-Existent Resources

**Teacher's Requirement:** "Handled non-existent resources"

#### Test:
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

# Test non-existent note ID
curl -X GET http://localhost:8080/api/notes/999999 \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Must return 404

# Test invalid route
curl -X GET http://localhost:8080/api/invalid-route \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Should return 404

# Test DELETE non-existent
curl -X DELETE http://localhost:8080/api/notes/999999 \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Must return 404
```

**✅ Pass Criteria:**
- [x] Non-existent resources return 404
- [x] Consistent error format
- [x] No database errors exposed

---

## PART 8: Password Security Requirements ✓

### Requirement 8.1: Password Policy Implementation

**Teacher's Requirement:** "Create password policy: length, charset, no common passwords"

#### Code Verification - PasswordValidator.java:
```java
@Component
public class PasswordValidator {
    private static final int MIN_LENGTH = 8;
    private static final Set<String> COMMON_PASSWORDS = Set.of(
        "password", "12345678", "qwerty", "abc123", "password123"
    );
    
    public void validate(String password) {
        // Length check
        if (password.length() < MIN_LENGTH) { ... }
        
        // Common password check
        if (COMMON_PASSWORDS.contains(password.toLowerCase())) { ... }
        
        // Character set requirements
        boolean hasUpper = ...;
        boolean hasLower = ...;
        boolean hasDigit = ...;
        boolean hasSpecial = ...;
    }
}
```

#### Functional Tests:
```bash
# Test 1: Too short
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test1","email":"test1@test.com","password":"Test1!"}'
# ✅ Should fail: Password must be at least 8 characters

# Test 2: No uppercase
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test2","email":"test2@test.com","password":"test123!@#"}'
# ✅ Should fail: Password must contain uppercase

# Test 3: No lowercase
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test3","email":"test3@test.com","password":"TEST123!@#"}'
# ✅ Should fail: Password must contain lowercase

# Test 4: No digit
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test4","email":"test4@test.com","password":"TestTest!@#"}'
# ✅ Should fail: Password must contain digit

# Test 5: No special character
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test5","email":"test5@test.com","password":"TestTest123"}'
# ✅ Should fail: Password must contain special character

# Test 6: Common password
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test6","email":"test6@test.com","password":"password"}'
# ✅ Should fail: Password is too common

# Test 7: Valid password
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test7","email":"test7@test.com","password":"Test123!@#"}'
# ✅ Should succeed: 201 Created
```

**✅ Pass Criteria:**
- [x] Minimum 8 characters
- [x] Requires uppercase letter
- [x] Requires lowercase letter
- [x] Requires digit
- [x] Requires special character
- [x] Blocks common passwords
- [x] Clear error messages for each rule

---

## PART 9: Controller Requirements ✓

### Requirement 9.1: CRUD Routes Implemented

**Teacher's Requirement:** "CRUD routes implemented"

#### Test All Endpoints:
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

# CREATE
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Test"}' \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 201 Created

# READ (all)
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 200 OK

# READ (by ID)
curl -X GET http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 200 OK

# UPDATE
curl -X PUT http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated"}' \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 200 OK

# DELETE
curl -X DELETE http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 204 No Content
```

**✅ Pass Criteria:**
- [x] All 5 CRUD operations work
- [x] Correct HTTP methods used
- [x] Returns appropriate data/status

---

### Requirement 9.2: Proper HTTP Status Codes

**Teacher's Requirement:** "Proper HTTP status codes used"

#### Status Code Checklist:
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

# 200 OK - Successful GET, PUT
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 200

# 201 Created - Successful POST
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Test"}' \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 201

# 204 No Content - Successful DELETE
curl -X DELETE http://localhost:8080/api/notes/1 \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 204

# 400 Bad Request - Validation error
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":""}' \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 400

# 401 Unauthorized - No/invalid token
curl -X GET http://localhost:8080/api/notes \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 401

# 404 Not Found - Non-existent resource
curl -X GET http://localhost:8080/api/notes/999999 \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n"
# ✅ Expected: 404
```

**✅ Pass Criteria:**
- [x] Uses RESTful status codes
- [x] Consistent across all endpoints
- [x] Matches HTTP semantics

---

### Requirement 9.3: JSON Controllers for CRUD (REST)

**Teacher's Requirement:** "REST: JSON controllers for CRUD"

#### Verification:
```bash
# All responses should be JSON
# Check Content-Type header:
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"Test123!@#"}' | jq -r '.token')

curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -v 2>&1 | grep "Content-Type"
# ✅ Should show: Content-Type: application/json
```

#### Code Verification:
```java
@RestController  // ← Not @Controller
@RequestMapping("/api/notes")
public class NoteController {
    // All methods return objects, not view names
    // Spring auto-converts to JSON
}
```

**✅ Pass Criteria:**
- [x] Controllers use `@RestController`
- [x] All responses are JSON
- [x] Content-Type header is `application/json`
- [x] No HTML/Thymeleaf templates

---

## 🎯 FINAL COMPREHENSIVE CHECKLIST

Print this checklist and mark each item as you verify:

### Security Configuration
- [ ] CustomUserDetailsService exists and implements UserDetailsService
- [ ] SecurityFilterChain configured with correct public/private routes
- [ ] BCrypt password encoding with strength parameter (12)
- [ ] Password policy enforces: length, uppercase, lowercase, digit, special char
- [ ] Common passwords are blocked

### Authentication (JWT)
- [ ] /auth/login endpoint returns JWT token
- [ ] JWT stored in HTTP-only cookie
- [ ] JWT also works in Authorization: Bearer header
- [ ] JwtAuthenticationFilter exists and extends OncePerRequestFilter
- [ ] Tokens validated on every request
- [ ] Invalid/expired tokens return 401

### Authorization
- [ ] Role enum defined (USER, ADMIN)
- [ ] Users assigned roles on registration
- [ ] @PreAuthorize annotations on controller methods
- [ ] Correct roles can access endpoints
- [ ] Wrong roles receive 403

### Database Layer
- [ ] V1__create_users_table.sql exists
- [ ] V2__create_notes_table.sql exists
- [ ] Migrations run successfully on startup
- [ ] Notes table has user_id foreign key
- [ ] Foreign key constraint works
- [ ] JPA Repository implemented
- [ ] At least one @Query with nativeQuery=true and ? placeholders

### Entity & Validation
- [ ] Note entity exists with @Entity annotation
- [ ] Entity has validation annotations
- [ ] NoteCreateDTO exists with validation
- [ ] NoteUpdateDTO exists
- [ ] Validation errors return 400 with field details
- [ ] Mass assignment prevented (userId not settable via DTO)

### Service Layer Security
- [ ] getCurrentUserId() uses SecurityContextHolder
- [ ] All CRUD methods check userId
- [ ] User can create own notes
- [ ] User can read own notes
- [ ] User CANNOT read other user's notes (404)
- [ ] User can update own notes
- [ ] User CANNOT update other user's notes (404)
- [ ] User can delete own notes
- [ ] User CANNOT delete other user's notes (404)

### Security & Error Handling
- [ ] SQL injection attempts fail safely
- [ ] All queries use prepared statements
- [ ] GlobalExceptionHandler exists with @ControllerAdvice
- [ ] No stack traces in responses
- [ ] Error messages are safe and generic
- [ ] 404 for non-existent resources
- [ ] 401 for unauthenticated requests
- [ ] 403 for unauthorized requests (wrong role)

### Controllers
- [ ] All CRUD endpoints implemented (POST, GET, PUT, DELETE)
- [ ] Proper HTTP status codes (200, 201, 204, 400, 401, 404)
- [ ] All endpoints return JSON
- [ ] Content-Type: application/json in responses
- [ ] @RestController annotation used

### Additional Requirements
- [ ] .env file created with strong JWT secret
- [ ] .gitignore includes .env and *.db
- [ ] README.md documents API endpoints
- [ ] Application starts without errors
- [ ] Can register, login, and perform all CRUD operations
- [ ] Two users cannot access each other's data

---

## 📊 Teacher Demonstration Script

Use this script when demonstrating to your teacher:

```bash
#!/bin/bash

echo "=== Spring Security Lab Demonstration ==="
echo ""

echo "1. Starting application..."
echo "   Command: gradlew.bat bootRun"
echo "   Waiting for startup..."
echo ""

echo "2. Testing Password Security..."
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@test.com","password":"weak"}' \
  && echo "❌ FAIL: Weak password accepted" \
  || echo "✅ PASS: Weak password rejected"
echo ""

echo "3. Registering Valid User..."
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@test.com","password":"Test123!@#"}'
echo ""

echo "4. Testing Authentication..."
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"Test123!@#"}' | jq -r '.token')
echo "✅ JWT Token received: ${TOKEN:0:20}..."
echo ""

echo "5. Testing Unauthenticated Access..."
curl -X GET http://localhost:8080/api/notes \
  && echo "❌ FAIL: Accessed without token" \
  || echo "✅ PASS: 401 Unauthorized"
echo ""

echo "6. Creating Note (Authenticated)..."
NOTE_ID=$(curl -s -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Demo Note","description":"Teacher demonstration"}' | jq -r '.id')
echo "✅ Note created with ID: $NOTE_ID"
echo ""

echo "7. Testing Data Isolation..."
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","email":"user2@test.com","password":"Test123!@#"}' > /dev/null
TOKEN2=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"Test123!@#"}' | jq -r '.token')
curl -X GET http://localhost:8080/api/notes/$NOTE_ID \
  -H "Authorization: Bearer $TOKEN2" \
  && echo "❌ FAIL: User2 accessed User1's note" \
  || echo "✅ PASS: User2 cannot access User1's note (404)"
echo ""

echo "8. Testing SQL Injection Prevention..."
curl -X GET "http://localhost:8080/api/notes/search?q='; DROP TABLE notes; --" \
  -H "Authorization: Bearer $TOKEN" > /dev/null
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" > /dev/null \
  && echo "✅ PASS: Database intact after injection attempt" \
  || echo "❌ FAIL: Database corrupted"
echo ""

echo "9. Testing Input Validation..."
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"","description":"Test"}' \
  && echo "❌ FAIL: Empty title accepted" \
  || echo "✅ PASS: Empty title rejected (400)"
echo ""

echo "=== All Tests Complete ==="
```

---

## 🎓 Final Submission Checklist

Before submitting to your teacher:

- [ ] All tests in this document pass
- [ ] No errors in application startup
- [ ] README.md is complete
- [ ] Code is committed to Git
- [ ] .env is NOT committed
- [ ] database.db is NOT committed
- [ ] Can clone fresh and run with setup instructions
- [ ] TESTING_GUIDE.md included
- [ ] postman_collection.json works
- [ ] TEACHER_REQUIREMENTS_VERIFICATION.md (this file) included

---

**Good luck with your submission! 🚀**
