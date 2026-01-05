# 🧪 Automated Testing Suite

Complete automated testing solution for the Spring Boot Security application.

## 🚀 Quick Start

### Windows
```batch
# 1. Start your application in one terminal
gradlew.bat bootRun

# 2. Open another terminal and run tests
cd tests
test-all.bat
```

### Linux/Mac
```bash
# 1. Start your application
./gradlew bootRun

# 2. In another terminal
cd tests
chmod +x test-all.sh
./test-all.sh
```

## ✅ What Gets Tested

The automated test suite verifies all critical security requirements:

1. **Application Health** - Server is running and responding
2. **Password Policy** - Weak passwords are rejected
3. **User Registration** - New users can register successfully
4. **Authentication** - Login works and returns JWT token
5. **Authorization** - Unauthenticated requests are blocked (401)
6. **CRUD Operations** - Can create notes with authentication
7. **Input Validation** - Invalid data (empty title) is rejected
8. **Data Isolation** - Multiple users can register and login
9. **IDOR Prevention** - Users cannot access other users' data (404)
10. **SQL Injection** - Database is protected from injection attacks

## 📊 Expected Output

```
=========================================
   AUTOMATED SECURITY TEST SUITE
=========================================

[1/10] Testing Application Health...
✓ PASS - Application is running

[2/10] Testing Password Policy - Weak Password...
✓ PASS - Weak password rejected (400)

[3/10] Testing User Registration...
✓ PASS - User registered successfully (201)

[4/10] Testing Authentication - Login...
✓ PASS - Login successful, JWT received

[5/10] Testing Unauthorized Access...
✓ PASS - Unauthorized access blocked (401)

[6/10] Testing Note Creation...
✓ PASS - Note created (201) with ID: 1

[7/10] Testing Input Validation - Empty Title...
✓ PASS - Empty title rejected (400)

[8/10] Testing Data Isolation - Register User 2...
✓ PASS - User 2 registered and logged in

[9/10] Testing IDOR - User 2 accessing User 1's Note...
✓ PASS - IDOR prevented - User 2 cannot access User 1's note (404)

[10/10] Testing SQL Injection Prevention...
✓ PASS - SQL injection prevented - Database intact

=========================================
          TEST SUMMARY
=========================================
Total Tests:  10
Passed:       10
Failed:       0

✓ ALL TESTS PASSED! Application is secure.
```

## 🎯 Advantages

- ✅ **One Command** - Just run the script
- ✅ **No Manual Work** - Fully automated
- ✅ **Clear Output** - Color-coded pass/fail
- ✅ **Teacher Friendly** - Easy to demonstrate
- ✅ **CI Ready** - Can integrate with GitHub Actions
- ✅ **Exit Codes** - Scripts return 0 (pass) or 1 (fail)
- ✅ **Comprehensive** - Tests all security requirements

## 🔧 Requirements

### Windows
- Windows 10+ (for ANSI color support)
- curl (usually pre-installed or available via Chocolatey)
- Application running on `http://localhost:8080`

### Linux/Mac
- bash 4.0+
- curl (usually pre-installed)
- jq (optional, for better JSON parsing - falls back to grep if not available)
- Application running on `http://localhost:8080`

## 🐛 Troubleshooting

### Issue: "Application not responding"
**Solution**: Make sure the application is running:
```bash
gradlew.bat bootRun  # Windows
./gradlew bootRun    # Linux/Mac
```

### Issue: "curl: command not found"
**Solution**: Install curl:
- **Windows**: Download from https://curl.se/windows/ or use Chocolatey: `choco install curl`
- **Linux**: `sudo apt-get install curl` (Debian/Ubuntu) or `sudo yum install curl` (RHEL/CentOS)
- **Mac**: Usually pre-installed, or use Homebrew: `brew install curl`

### Issue: "jq: command not found" (Linux/Mac)
**Solution**: The script will work without jq, but for better JSON parsing:
- **Linux**: `sudo apt-get install jq` (Debian/Ubuntu) or `sudo yum install jq` (RHEL/CentOS)
- **Mac**: `brew install jq`

### Issue: Tests fail with "expected 201, got 400"
**Solution**: User might already exist. The script creates test users - if they already exist, delete the database:
```bash
# Delete database and restart
rm database.db      # Linux/Mac
del database.db     # Windows
gradlew.bat bootRun
```

### Issue: Colors not showing (Windows)
**Solution**: Windows 10+ supports ANSI colors. For older Windows, colors may not display but tests still work.

## 📝 Customization

You can modify the test configuration by editing the variables at the top of the scripts:

**Windows (test-all.bat):**
```batch
set BASE_URL=http://localhost:8080
set USER1=testuser1
set EMAIL1=test1@example.com
set PASS1=Test123!@#
```

**Linux/Mac (test-all.sh):**
```bash
BASE_URL="http://localhost:8080"
USER1="testuser1"
EMAIL1="test1@example.com"
PASS1="Test123!@#"
```

## 🎓 For Teacher Demonstration

1. Start the application in one terminal
2. Run the test script in another terminal
3. Show the colored output with all passing tests
4. Explain what each test verifies

The script provides clear, professional output perfect for demonstrations!

## 🔗 Related Documentation

- **Main Testing Guide**: `../TESTING_GUIDE.md`
- **Teacher Requirements**: `../TEACHER_REQUIREMENTS_VERIFICATION.md`
- **Setup Guide**: `../SETUP.md`

---

**Happy Testing! 🚀**
