@echo off
echo ========================================
echo Deploying Cloud Functions to Firebase
echo ========================================
echo.

echo Step 1: Checking Firebase CLI...
firebase --version
if %errorlevel% neq 0 (
    echo ERROR: Firebase CLI not found!
    exit /b 1
)
echo.

echo Step 2: Checking current project...
firebase use
echo.

echo Step 3: Installing dependencies...
cd functions
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies!
    cd ..
    exit /b 1
)
cd ..
echo.

echo Step 4: Deploying functions...
firebase deploy --only functions
if %errorlevel% neq 0 (
    echo ERROR: Deployment failed!
    exit /b 1
)
echo.

echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo Check Firebase Console to verify:
echo https://console.firebase.google.com/project/cazlync-app-final/functions
echo.
pause
