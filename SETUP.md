# Quick Setup Guide

## Prerequisites
- Java 17 or higher installed
- Gradle (optional - wrapper will be used if available)

## Initial Setup

1. **Create `.env` file** in the project root:
   ```properties
   DB_URL=jdbc:sqlite:database.db
   DB_USERNAME=
   DB_PASSWORD=
   JWT_SECRET=your-256-bit-secret-key-here-change-in-production-make-it-long-enough
   JWT_EXPIRATION=86400000
   ```

2. **Generate Gradle Wrapper** (if not already present):
   ```bash
   gradle wrapper
   ```
   This will create the `gradle-wrapper.jar` file needed to run the project.

3. **Build the project**:
   ```bash
   # Windows
   gradlew.bat build
   
   # Linux/Mac
   ./gradlew build
   ```

4. **Run the application**:
   ```bash
   # Windows
   gradlew.bat bootRun
   
   # Linux/Mac
   ./gradlew bootRun
   ```

## First Run

1. The application will start on `http://localhost:8080`
2. Flyway will automatically create the database tables on first run
3. The SQLite database file (`database.db`) will be created in the project root

## Testing the API

### 1. Register a user:
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"Test123!@#\"}"
```

### 2. Login:
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"password\":\"Test123!@#\"}"
```

Copy the `token` from the response.

### 3. Create a note:
```bash
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"My Note\",\"description\":\"Note content\"}"
```

## Troubleshooting

### Gradle Wrapper Issues
If `gradlew` doesn't work, install Gradle and run:
```bash
gradle wrapper
```

### Database Issues
- Ensure the `.env` file exists with correct `DB_URL`
- Delete `database.db` if you need to reset the database
- Check Flyway migration logs in the console

### Port Already in Use
Change the port in `application.properties`:
```properties
server.port=8081
```

## Next Steps

- Read the full [README.md](README.md) for complete documentation
- Review the API endpoints and security features
- Test all CRUD operations for notes
- Verify user data isolation (users can only access their own notes)
