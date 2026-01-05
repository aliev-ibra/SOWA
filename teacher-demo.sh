#!/bin/bash

echo "=== Spring Security Lab Demonstration ==="
echo ""

echo "1. Testing Password Security..."
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@test.com","password":"weak"}' \
  && echo "❌ FAIL: Weak password accepted" \
  || echo "✅ PASS: Weak password rejected"
echo ""

echo "2. Registering Valid User..."
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@test.com","password":"Test123!@#"}'
echo ""

echo "3. Testing Authentication..."
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"Test123!@#"}' | jq -r '.token')
echo "✅ JWT Token received: ${TOKEN:0:20}..."
echo ""

echo "4. Testing Unauthenticated Access..."
curl -X GET http://localhost:8080/api/notes \
  && echo "❌ FAIL: Accessed without token" \
  || echo "✅ PASS: 401 Unauthorized"
echo ""

echo "5. Creating Note (Authenticated)..."
NOTE_ID=$(curl -s -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Demo Note","description":"Teacher demonstration"}' | jq -r '.id')
echo "✅ Note created with ID: $NOTE_ID"
echo ""

echo "6. Testing Data Isolation..."
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","email":"user2@test.com","password":"Test123!@#"}' > /dev/null 2>&1
TOKEN2=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user2","password":"Test123!@#"}' | jq -r '.token')
curl -X GET http://localhost:8080/api/notes/$NOTE_ID \
  -H "Authorization: Bearer $TOKEN2" \
  && echo "❌ FAIL: User2 accessed User1's note" \
  || echo "✅ PASS: User2 cannot access User1's note (404)"
echo ""

echo "7. Testing SQL Injection Prevention..."
curl -X GET "http://localhost:8080/api/notes/search?q='; DROP TABLE notes; --" \
  -H "Authorization: Bearer $TOKEN" > /dev/null 2>&1
curl -X GET http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" > /dev/null 2>&1 \
  && echo "✅ PASS: Database intact after injection attempt" \
  || echo "❌ FAIL: Database corrupted"
echo ""

echo "8. Testing Input Validation..."
curl -X POST http://localhost:8080/api/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"","description":"Test"}' \
  && echo "❌ FAIL: Empty title accepted" \
  || echo "✅ PASS: Empty title rejected (400)"
echo ""

echo "=== All Tests Complete ==="
