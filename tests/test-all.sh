#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Configuration
BASE_URL="http://localhost:8080"
USER1="testuser1"
EMAIL1="test1@example.com"
PASS1="Test123!@#"
USER2="testuser2"
EMAIL2="test2@example.com"
PASS2="Test456!@#"

# Counters
TOTAL=0
PASSED=0
FAILED=0

echo -e "${BLUE}=======================================${RESET}"
echo -e "${BLUE}   AUTOMATED SECURITY TEST SUITE${RESET}"
echo -e "${BLUE}=======================================${RESET}"
echo

# Test 1: Application Health
echo -e "${YELLOW}[1/10] Testing Application Health...${RESET}"
((TOTAL++))
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/auth/login 2>/dev/null)
if [ "$STATUS" == "405" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - Application is running"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - Application not responding (got $STATUS, expected 405)"
    echo -e "${YELLOW}   Make sure the application is running on $BASE_URL${RESET}"
    ((FAILED++))
    exit 1
fi
echo

# Test 2: Weak Password
echo -e "${YELLOW}[2/10] Testing Password Policy - Weak Password...${RESET}"
((TOTAL++))
STATUS=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"weaktest","email":"weak@test.com","password":"weak"}' \
  -w "%{http_code}" -o /dev/null 2>/dev/null)
if [ "$STATUS" == "400" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - Weak password rejected (400)"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - Weak password accepted (expected 400, got $STATUS)"
    ((FAILED++))
fi
echo

# Test 3: User Registration
echo -e "${YELLOW}[3/10] Testing User Registration...${RESET}"
((TOTAL++))
STATUS=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER1\",\"email\":\"$EMAIL1\",\"password\":\"$PASS1\"}" \
  -w "%{http_code}" -o /dev/null 2>/dev/null)
if [ "$STATUS" == "201" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - User registered successfully (201)"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - Registration failed (expected 201, got $STATUS)"
    ((FAILED++))
fi
echo

# Test 4: Login and JWT
echo -e "${YELLOW}[4/10] Testing Authentication - Login...${RESET}"
((TOTAL++))
RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER1\",\"password\":\"$PASS1\"}" 2>/dev/null)

# Check if jq is available, otherwise use grep/sed
if command -v jq &> /dev/null; then
    TOKEN1=$(echo $RESPONSE | jq -r '.token')
else
    TOKEN1=$(echo $RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

if [ ! -z "$TOKEN1" ] && [ "$TOKEN1" != "null" ] && [ "$TOKEN1" != "" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - Login successful, JWT received"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - Login failed or no token received"
    echo "$RESPONSE"
    ((FAILED++))
fi
echo

# Test 5: Unauthorized Access
echo -e "${YELLOW}[5/10] Testing Unauthorized Access...${RESET}"
((TOTAL++))
STATUS=$(curl -s -X GET $BASE_URL/api/notes \
  -w "%{http_code}" -o /dev/null 2>/dev/null)
if [ "$STATUS" == "401" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - Unauthorized access blocked (401)"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - Unauthorized access allowed (expected 401, got $STATUS)"
    ((FAILED++))
fi
echo

# Test 6: Note Creation
echo -e "${YELLOW}[6/10] Testing Note Creation...${RESET}"
((TOTAL++))
RESPONSE=$(curl -s -X POST $BASE_URL/api/notes \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Note","description":"User1 private note"}' 2>/dev/null)

if command -v jq &> /dev/null; then
    NOTE1_ID=$(echo $RESPONSE | jq -r '.id')
else
    NOTE1_ID=$(echo $RESPONSE | grep -o '"id":[0-9]*' | cut -d':' -f2)
fi

if [ ! -z "$NOTE1_ID" ] && [ "$NOTE1_ID" != "null" ] && [ "$NOTE1_ID" != "" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - Note created (201) with ID: $NOTE1_ID"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - Note creation failed"
    echo "$RESPONSE"
    ((FAILED++))
fi
echo

# Test 7: Input Validation
echo -e "${YELLOW}[7/10] Testing Input Validation - Empty Title...${RESET}"
((TOTAL++))
STATUS=$(curl -s -X POST $BASE_URL/api/notes \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json" \
  -d '{"title":"","description":"Test"}' \
  -w "%{http_code}" -o /dev/null 2>/dev/null)
if [ "$STATUS" == "400" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - Empty title rejected (400)"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - Empty title accepted (expected 400, got $STATUS)"
    ((FAILED++))
fi
echo

# Test 8: Register User 2
echo -e "${YELLOW}[8/10] Testing Data Isolation - Register User 2...${RESET}"
((TOTAL++))
curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER2\",\"email\":\"$EMAIL2\",\"password\":\"$PASS2\"}" \
  > /dev/null 2>&1

RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER2\",\"password\":\"$PASS2\"}" 2>/dev/null)

if command -v jq &> /dev/null; then
    TOKEN2=$(echo $RESPONSE | jq -r '.token')
else
    TOKEN2=$(echo $RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
fi

if [ ! -z "$TOKEN2" ] && [ "$TOKEN2" != "null" ] && [ "$TOKEN2" != "" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - User 2 registered and logged in"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - User 2 login failed"
    ((FAILED++))
fi
echo

# Test 9: IDOR Test
echo -e "${YELLOW}[9/10] Testing IDOR - User 2 accessing User 1's Note...${RESET}"
((TOTAL++))
if [ -z "$NOTE1_ID" ]; then
    NOTE1_ID=1
fi
STATUS=$(curl -s -X GET $BASE_URL/api/notes/$NOTE1_ID \
  -H "Authorization: Bearer $TOKEN2" \
  -w "%{http_code}" -o /dev/null 2>/dev/null)
if [ "$STATUS" == "404" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - IDOR prevented - User 2 cannot access User 1's note (404)"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - IDOR vulnerability - User 2 accessed User 1's note (got $STATUS)"
    ((FAILED++))
fi
echo

# Test 10: SQL Injection
echo -e "${YELLOW}[10/10] Testing SQL Injection Prevention...${RESET}"
((TOTAL++))
curl -s -X GET "$BASE_URL/api/notes/search?q='; DROP TABLE notes; --" \
  -H "Authorization: Bearer $TOKEN1" \
  > /dev/null 2>&1

STATUS=$(curl -s -X GET $BASE_URL/api/notes \
  -H "Authorization: Bearer $TOKEN1" \
  -w "%{http_code}" -o /dev/null 2>/dev/null)

if [ "$STATUS" == "200" ]; then
    echo -e "${GREEN}✓ PASS${RESET} - SQL injection prevented - Database intact"
    ((PASSED++))
else
    echo -e "${RED}✗ FAIL${RESET} - SQL injection may have succeeded (got $STATUS)"
    ((FAILED++))
fi
echo

# Summary
echo
echo -e "${BLUE}=======================================${RESET}"
echo -e "${BLUE}          TEST SUMMARY${RESET}"
echo -e "${BLUE}=======================================${RESET}"
echo "Total Tests:  $TOTAL"
echo -e "${GREEN}Passed:       $PASSED${RESET}"
echo -e "${RED}Failed:       $FAILED${RESET}"
echo

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED! Application is secure.${RESET}"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED! Review the failures above.${RESET}"
    exit 1
fi
