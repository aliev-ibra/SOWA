# 🚀 Quick Start Guide

## ⚡ 5-Minute Setup

### 1. Create .env File (30 seconds)

**Windows PowerShell:**
```powershell
@"
DB_URL=jdbc:sqlite:database.db
DB_USERNAME=
DB_PASSWORD=
JWT_SECRET=your-super-secret-jwt-key-must-be-at-least-256-bits-long-change-this-in-production
JWT_EXPIRATION=86400000
"@ | Out-File -FilePath .env -Encoding utf8
```

**Linux/Mac:**
```bash
cat > .env << EOF
DB_URL=jdbc:sqlite:database.db
DB_USERNAME=
DB_PASSWORD=
JWT_SECRET=your-super-secret-jwt-key-must-be-at-least-256-bits-long-change-this-in-production
JWT_EXPIRATION=86400000
EOF
```

### 2. Build & Run (2 minutes)

```bash
# Windows
gradlew.bat clean build
gradlew.bat bootRun

# Linux/Mac
./gradlew clean build
./gradlew bootRun
```

### 3. Test (2 minutes)

**Open new terminal and run:**
```bash
# Register
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"Test123!@#"}'

# Login (save the token)
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"Test123!@#"}'

# Create note (replace YOUR_TOKEN with token from login)
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"My Note","description":"Test"}'
```

## ✅ Success Indicators

- ✅ Application starts on `http://localhost:8080`
- ✅ Can register user (201 Created)
- ✅ Can login and get JWT token
- ✅ Can create note (201 Created)
- ✅ Can read notes (200 OK)

## 📚 Next Steps

1. Read `FINAL_STATUS.md` for complete status
2. Follow `TESTING_GUIDE.md` for all tests
3. Review `TEACHER_REQUIREMENTS_VERIFICATION.md` before submission

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "JWT secret cannot be null" | Create `.env` file |
| "Port 8080 in use" | Change port in `application.properties` |
| "Table doesn't exist" | Delete `database.db` and restart |
| "Gradle wrapper not found" | Run `gradle wrapper` |

---

**Total Setup Time: ~5 minutes** ⏱️
