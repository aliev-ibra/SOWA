#!/bin/bash

echo "🔍 Verifying Project Structure..."
echo ""

# Check critical files
files=(
    "build.gradle"
    "settings.gradle"
    ".gitignore"
    "README.md"
    "SETUP.md"
    "TESTING_GUIDE.md"
    "gradlew.bat"
    "src/main/java/com/sowa/Application.java"
    "src/main/java/com/sowa/config/SecurityConfig.java"
    "src/main/java/com/sowa/controller/AuthController.java"
    "src/main/java/com/sowa/controller/NoteController.java"
    "src/main/resources/application.properties"
    "src/main/resources/db/migration/V1__create_users_table.sql"
    "src/main/resources/db/migration/V2__create_notes_table.sql"
)

missing_files=()

for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
        echo "❌ Missing: $file"
    else
        echo "✅ Found: $file"
    fi
done

echo ""
if [ ${#missing_files[@]} -eq 0 ]; then
    echo "✅ All critical files present!"
else
    echo "❌ Missing ${#missing_files[@]} file(s)"
    exit 1
fi

# Check .env file
echo ""
if [ -f ".env" ]; then
    echo "✅ .env file exists"
    
    # Check JWT_SECRET length
    if grep -q "JWT_SECRET=" .env; then
        jwt_secret=$(grep "JWT_SECRET=" .env | cut -d'=' -f2)
        if [ ${#jwt_secret} -ge 32 ]; then
            echo "✅ JWT_SECRET is at least 32 characters"
        else
            echo "⚠️  WARNING: JWT_SECRET should be at least 32 characters"
        fi
    fi
else
    echo "⚠️  WARNING: .env file not found. Create it from .env.example"
fi

echo ""
echo "🔍 Verification complete!"
