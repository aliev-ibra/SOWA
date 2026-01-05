@echo off
echo 🔍 Verifying Project Structure...
echo.

set MISSING=0

REM Check critical files
if exist "build.gradle" (
    echo ✅ Found: build.gradle
) else (
    echo ❌ Missing: build.gradle
    set /a MISSING+=1
)

if exist "settings.gradle" (
    echo ✅ Found: settings.gradle
) else (
    echo ❌ Missing: settings.gradle
    set /a MISSING+=1
)

if exist ".gitignore" (
    echo ✅ Found: .gitignore
) else (
    echo ❌ Missing: .gitignore
    set /a MISSING+=1
)

if exist "README.md" (
    echo ✅ Found: README.md
) else (
    echo ❌ Missing: README.md
    set /a MISSING+=1
)

if exist "src\main\java\com\sowa\Application.java" (
    echo ✅ Found: Application.java
) else (
    echo ❌ Missing: Application.java
    set /a MISSING+=1
)

if exist "src\main\resources\application.properties" (
    echo ✅ Found: application.properties
) else (
    echo ❌ Missing: application.properties
    set /a MISSING+=1
)

echo.
if %MISSING%==0 (
    echo ✅ All critical files present!
) else (
    echo ❌ Missing %MISSING% file(s)
    exit /b 1
)

REM Check .env file
echo.
if exist ".env" (
    echo ✅ .env file exists
) else (
    echo ⚠️  WARNING: .env file not found. Create it from .env.example
)

echo.
echo 🔍 Verification complete!
pause
