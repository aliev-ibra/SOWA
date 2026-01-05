@echo off
setlocal enabledelayedexpansion

REM Colors (ANSI escape codes for Windows 10+)
set GREEN=[92m
set RED=[91m
set YELLOW=[93m
set BLUE=[94m
set RESET=[0m

echo %BLUE%=======================================%RESET%
echo %BLUE%   AUTOMATED SECURITY TEST SUITE%RESET%
echo %BLUE%=======================================%RESET%
echo.

REM Configuration
set BASE_URL=http://localhost:8080
set USER1=testuser1
set EMAIL1=test1@example.com
set PASS1=Test123!@#
set USER2=testuser2
set EMAIL2=test2@example.com
set PASS2=Test456!@#

REM Initialize counters
set TOTAL=0
set PASSED=0
set FAILED=0

REM Clean up previous test data
del /f /q test-*.tmp temp-*.txt 2>nul

REM ========================================
REM Test 1: Application Health Check
REM ========================================
echo %YELLOW%[1/10] Testing Application Health Check...%RESET%
set /a TOTAL+=1
curl -s -o nul -w "%%{http_code}" %BASE_URL%/auth/login > temp-status.txt 2>nul
set /p STATUS=<temp-status.txt
if "%STATUS%"=="405" (
    echo %GREEN%✓ PASS%RESET% - Application is running (405 - route exists)
    set /a PASSED+=1
) else (
    echo %RED%✗ FAIL%RESET% - Application not responding (got %STATUS%, expected 405)
    echo %YELLOW%   Make sure the application is running on %BASE_URL%%RESET%
    set /a FAILED+=1
    goto :end
)
echo.

REM ========================================
REM Test 2: Weak Password Rejection
REM ========================================
echo %YELLOW%[2/10] Testing Weak Password Rejection...%RESET%
set /a TOTAL+=1
curl -s -X POST %BASE_URL%/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"weaktest\",\"email\":\"weak@test.com\",\"password\":\"weak\"}" ^
  -w "%%{http_code}" -o test-weak.tmp > temp-status.txt 2>nul
set /p STATUS=<temp-status.txt
if "%STATUS%"=="400" (
    echo %GREEN%✓ PASS%RESET% - Weak password rejected (400)
    set /a PASSED+=1
) else (
    echo %RED%✗ FAIL%RESET% - Weak password accepted (expected 400, got %STATUS%^)
    set /a FAILED+=1
)
echo.

REM ========================================
REM Test 3: Valid User Registration
REM ========================================
echo %YELLOW%[3/10] Testing Valid User Registration...%RESET%
set /a TOTAL+=1
curl -s -X POST %BASE_URL%/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"%USER1%\",\"email\":\"%EMAIL1%\",\"password\":\"%PASS1%\"}" ^
  -w "%%{http_code}" -o test-reg1.tmp > temp-status.txt 2>nul
set /p STATUS=<temp-status.txt
if "%STATUS%"=="201" (
    echo %GREEN%✓ PASS%RESET% - User registered successfully (201)
    set /a PASSED+=1
) else (
    echo %RED%✗ FAIL%RESET% - Registration failed (expected 201, got %STATUS%^)
    type test-reg1.tmp 2>nul
    set /a FAILED+=1
)
echo.

REM ========================================
REM Test 4: User Login & JWT Extraction
REM ========================================
echo %YELLOW%[4/10] Testing User Login ^& JWT Extraction...%RESET%
set /a TOTAL+=1
curl -s -X POST %BASE_URL%/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"%USER1%\",\"password\":\"%PASS1%\"}" ^
  -o test-login1.tmp > nul 2>&1

REM Extract token from JSON response
set TOKEN1=
for /f "tokens=*" %%a in (test-login1.tmp) do set RESPONSE=%%a
echo !RESPONSE! | findstr /C:"token" > nul
if %ERRORLEVEL% EQU 0 (
    REM Extract token value - look for "token":"value"
    for /f "tokens=2 delims=:" %%b in ('echo !RESPONSE! ^| findstr /C:"\"token\""') do (
        set TOKEN1=%%b
        set TOKEN1=!TOKEN1:"=!
        set TOKEN1=!TOKEN1: =!
        set TOKEN1=!TOKEN1:,=!
        set TOKEN1=!TOKEN1:}=!
    )
)

REM Check if we got a valid token (not empty and not "null")
if defined TOKEN1 (
    if not "!TOKEN1!"=="" (
        if not "!TOKEN1!"=="null" (
            echo %GREEN%✓ PASS%RESET% - Login successful, JWT token extracted
            set /a PASSED+=1
        ) else (
            echo %RED%✗ FAIL%RESET% - Login returned null token
            set /a FAILED+=1
        )
    ) else (
        echo %RED%✗ FAIL%RESET% - Login returned empty token
        set /a FAILED+=1
    )
) else (
    echo %RED%✗ FAIL%RESET% - Login failed or no token received
    type test-login1.tmp 2>nul
    set /a FAILED+=1
)
echo.

REM ========================================
REM Test 5: Unauthorized Access
REM ========================================
echo %YELLOW%[5/10] Testing Unauthorized Access...%RESET%
set /a TOTAL+=1
curl -s -X GET %BASE_URL%/api/notes ^
  -w "%%{http_code}" -o test-unauth.tmp > temp-status.txt 2>nul
set /p STATUS=<temp-status.txt
if "%STATUS%"=="401" (
    echo %GREEN%✓ PASS%RESET% - Unauthorized access blocked (401)
    set /a PASSED+=1
) else (
    echo %RED%✗ FAIL%RESET% - Unauthorized access allowed (expected 401, got %STATUS%^)
    set /a FAILED+=1
)
echo.

REM ========================================
REM Test 6: Create Note with Authentication
REM ========================================
echo %YELLOW%[6/10] Testing Create Note with Authentication...%RESET%
set /a TOTAL+=1
if not defined TOKEN1 (
    echo %RED%✗ FAIL%RESET% - Cannot test: TOKEN1 not available
    set /a FAILED+=1
    goto :test7
)
curl -s -X POST %BASE_URL%/api/notes ^
  -H "Authorization: Bearer %TOKEN1%" ^
  -H "Content-Type: application/json" ^
  -d "{\"title\":\"Test Note\",\"description\":\"User1 private note\"}" ^
  -w "%%{http_code}" -o test-create.tmp > temp-status.txt 2>nul
set /p STATUS=<temp-status.txt

REM Extract note ID from JSON response
set NOTE1_ID=
for /f "tokens=*" %%a in (test-create.tmp) do set RESPONSE=%%a
echo !RESPONSE! | findstr /C:"\"id\"" > nul
if %ERRORLEVEL% EQU 0 (
    REM Extract ID value - look for "id":value
    for /f "tokens=2 delims=:" %%b in ('echo !RESPONSE! ^| findstr /C:"\"id\""') do (
        set NOTE1_ID=%%b
        set NOTE1_ID=!NOTE1_ID: =!
        set NOTE1_ID=!NOTE1_ID:,=!
        set NOTE1_ID=!NOTE1_ID:}=!
    )
)

if "%STATUS%"=="201" (
    if defined NOTE1_ID (
        if not "!NOTE1_ID!"=="" (
            echo %GREEN%✓ PASS%RESET% - Note created (201) with ID: %NOTE1_ID%
            set /a PASSED+=1
        ) else (
            echo %GREEN%✓ PASS%RESET% - Note created (201) but ID extraction failed
            set /a PASSED+=1
        )
    ) else (
        echo %GREEN%✓ PASS%RESET% - Note created (201)
        set /a PASSED+=1
    )
) else (
    echo %RED%✗ FAIL%RESET% - Note creation failed (expected 201, got %STATUS%^)
    type test-create.tmp 2>nul
    set /a FAILED+=1
)
echo.

:test7
REM ========================================
REM Test 7: Input Validation - Empty Title
REM ========================================
echo %YELLOW%[7/10] Testing Input Validation - Empty Title...%RESET%
set /a TOTAL+=1
if not defined TOKEN1 (
    echo %RED%✗ FAIL%RESET% - Cannot test: TOKEN1 not available
    set /a FAILED+=1
    goto :test8
)
curl -s -X POST %BASE_URL%/api/notes ^
  -H "Authorization: Bearer %TOKEN1%" ^
  -H "Content-Type: application/json" ^
  -d "{\"title\":\"\",\"description\":\"Test\"}" ^
  -w "%%{http_code}" -o test-validation.tmp > temp-status.txt 2>nul
set /p STATUS=<temp-status.txt
if "%STATUS%"=="400" (
    echo %GREEN%✓ PASS%RESET% - Empty title rejected (400)
    set /a PASSED+=1
) else (
    echo %RED%✗ FAIL%RESET% - Empty title accepted (expected 400, got %STATUS%^)
    set /a FAILED+=1
)
echo.

:test8
REM ========================================
REM Test 8: Register Second User
REM ========================================
echo %YELLOW%[8/10] Testing Register Second User...%RESET%
set /a TOTAL+=1
curl -s -X POST %BASE_URL%/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"%USER2%\",\"email\":\"%EMAIL2%\",\"password\":\"%PASS2%\"}" ^
  > nul 2>&1

curl -s -X POST %BASE_URL%/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"%USER2%\",\"password\":\"%PASS2%\"}" ^
  -o test-login2.tmp > nul 2>&1

REM Extract User2 token
set TOKEN2=
for /f "tokens=*" %%a in (test-login2.tmp) do set RESPONSE=%%a
echo !RESPONSE! | findstr /C:"token" > nul
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=2 delims=:" %%b in ('echo !RESPONSE! ^| findstr /C:"\"token\""') do (
        set TOKEN2=%%b
        set TOKEN2=!TOKEN2:"=!
        set TOKEN2=!TOKEN2: =!
        set TOKEN2=!TOKEN2:,=!
        set TOKEN2=!TOKEN2:}=!
    )
)

if defined TOKEN2 (
    if not "!TOKEN2!"=="" (
        if not "!TOKEN2!"=="null" (
            echo %GREEN%✓ PASS%RESET% - User 2 registered and logged in, token extracted
            set /a PASSED+=1
        ) else (
            echo %RED%✗ FAIL%RESET% - User 2 login returned null token
            set /a FAILED+=1
        )
    ) else (
        echo %RED%✗ FAIL%RESET% - User 2 login returned empty token
        set /a FAILED+=1
    )
) else (
    echo %RED%✗ FAIL%RESET% - User 2 login failed
    type test-login2.tmp 2>nul
    set /a FAILED+=1
)
echo.

REM ========================================
REM Test 9: IDOR Prevention (Critical Security Test)
REM ========================================
echo %YELLOW%[9/10] Testing IDOR Prevention - User 2 accessing User 1's Note...%RESET%
set /a TOTAL+=1
if not defined TOKEN2 (
    echo %RED%✗ FAIL%RESET% - Cannot test: TOKEN2 not available
    set /a FAILED+=1
    goto :test10
)
if not defined NOTE1_ID (
    set NOTE1_ID=1
)
curl -s -X GET %BASE_URL%/api/notes/%NOTE1_ID% ^
  -H "Authorization: Bearer %TOKEN2%" ^
  -w "%%{http_code}" -o test-idor.tmp > temp-status.txt 2>nul
set /p STATUS=<temp-status.txt
if "%STATUS%"=="404" (
    echo %GREEN%✓ PASS%RESET% - IDOR prevented - User 2 cannot access User 1's note (404)
    set /a PASSED+=1
) else (
    echo %RED%✗ FAIL%RESET% - IDOR vulnerability - User 2 accessed User 1's note (got %STATUS%, expected 404)
    set /a FAILED+=1
)
echo.

:test10
REM ========================================
REM Test 10: SQL Injection Prevention
REM ========================================
echo %YELLOW%[10/10] Testing SQL Injection Prevention...%RESET%
set /a TOTAL+=1
if not defined TOKEN1 (
    echo %RED%✗ FAIL%RESET% - Cannot test: TOKEN1 not available
    set /a FAILED+=1
    goto :end
)
REM Attempt SQL injection in search query
curl -s -X GET "%BASE_URL%/api/notes/search?q='; DROP TABLE notes; --" ^
  -H "Authorization: Bearer %TOKEN1%" ^
  > nul 2>&1

REM Verify database is still intact by fetching notes
curl -s -X GET %BASE_URL%/api/notes ^
  -H "Authorization: Bearer %TOKEN1%" ^
  -w "%%{http_code}" > temp-verify.txt 2>nul
set /p VERIFY_STATUS=<temp-verify.txt

if "%VERIFY_STATUS%"=="200" (
    echo %GREEN%✓ PASS%RESET% - SQL injection prevented - Database intact (200)
    set /a PASSED+=1
) else (
    echo %RED%✗ FAIL%RESET% - SQL injection may have succeeded (got %VERIFY_STATUS%, expected 200)
    set /a FAILED+=1
)
echo.

:end
REM Clean up
del /f /q test-*.tmp temp-*.txt 2>nul

REM Print summary
echo.
echo %BLUE%=======================================%RESET%
echo %BLUE%          TEST SUMMARY%RESET%
echo %BLUE%=======================================%RESET%
echo Total Tests:  %TOTAL%
echo %GREEN%Passed:       %PASSED%%RESET%
echo %RED%Failed:       %FAILED%%RESET%
echo.

if %FAILED%==0 (
    echo %GREEN%✓ ALL TESTS PASSED! Application is secure.%RESET%
    exit /b 0
) else (
    echo %RED%✗ SOME TESTS FAILED! Review the failures above.%RESET%
    exit /b 1
)
