@echo off
echo Deploying Cloud Functions...
echo.
firebase deploy --only functions 2>&1
echo.
echo Done!
pause
