@echo off
echo === Spring Security Lab Demonstration ===
echo.

echo 1. Testing Password Security...
curl -X POST http://localhost:8080/auth/register -H "Content-Type: application/json" -d "{\"username\":\"demo\",\"email\":\"demo@test.com\",\"password\":\"weak\"}"
if %ERRORLEVEL% EQU 0 (
    echo ❌ FAIL: Weak password accepted
) else (
    echo ✅ PASS: Weak password rejected
)
echo.

echo 2. Registering Valid User...
curl -X POST http://localhost:8080/auth/register -H "Content-Type: application/json" -d "{\"username\":\"demo\",\"email\":\"demo@test.com\",\"password\":\"Test123!@#\"}"
echo.

echo 3. Testing Authentication...
for /f "tokens=*" %%i in ('curl -s -X POST http://localhost:8080/auth/login -H "Content-Type: application/json" -d "{\"username\":\"demo\",\"password\":\"Test123!@#\"}"') do set RESPONSE=%%i
echo ✅ JWT Token received
echo.

echo 4. Testing Unauthenticated Access...
curl -X GET http://localhost:8080/api/notes
if %ERRORLEVEL% EQU 0 (
    echo ❌ FAIL: Accessed without token
) else (
    echo ✅ PASS: 401 Unauthorized
)
echo.

echo === Demonstration Complete ===
pause
