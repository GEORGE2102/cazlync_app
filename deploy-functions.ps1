# Deploy Cloud Functions to Firebase
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploying Cloud Functions to Firebase" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Firebase CLI
Write-Host "Step 1: Checking Firebase CLI..." -ForegroundColor Yellow
$version = firebase --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Firebase CLI not found!" -ForegroundColor Red
    Write-Host "Install with: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}
Write-Host "Firebase CLI version: $version" -ForegroundColor Green
Write-Host ""

# Step 2: Check current project
Write-Host "Step 2: Checking current project..." -ForegroundColor Yellow
firebase use
Write-Host ""

# Step 3: Install dependencies
Write-Host "Step 3: Installing dependencies..." -ForegroundColor Yellow
Push-Location functions
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location
Write-Host "Dependencies installed successfully!" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy functions
Write-Host "Step 4: Deploying functions..." -ForegroundColor Yellow
Write-Host "This may take 2-3 minutes..." -ForegroundColor Cyan
firebase deploy --only functions
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Deployment failed!" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Check Firebase Console:" -ForegroundColor White
Write-Host "   https://console.firebase.google.com/project/cazlync-app-final/functions" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Test notifications:" -ForegroundColor White
Write-Host "   - Send a message between users" -ForegroundColor Yellow
Write-Host "   - Approve a listing as admin" -ForegroundColor Yellow
Write-Host "   - Favorite a listing" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Monitor function logs:" -ForegroundColor White
Write-Host "   firebase functions:log" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"
