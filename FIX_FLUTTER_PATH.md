# Fix Flutter PATH Issue

## Problem
Flutter command not recognized because the PATH is incorrect.

## Flutter Location
Your Flutter is installed at: `C:\flutter\src\flutter\bin`

## Temporary Fix (Current Session Only)
Run this in PowerShell:
```powershell
$env:Path = "C:\flutter\src\flutter\bin;" + $env:Path
```

## Permanent Fix (Recommended)

### Option 1: Using System Settings (GUI)
1. Press `Windows Key + R`
2. Type `sysdm.cpl` and press Enter
3. Click "Advanced" tab
4. Click "Environment Variables"
5. In "User variables" section, find and select "Path"
6. Click "Edit"
7. Click "New"
8. Add: `C:\flutter\src\flutter\bin`
9. Click "OK" on all windows
10. **Close and reopen PowerShell**

### Option 2: Using PowerShell (Quick)
Run this command in PowerShell **as Administrator**:

```powershell
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\flutter\src\flutter\bin",
    "User"
)
```

Then **close and reopen PowerShell**.

## Verification

After adding to PATH permanently, open a **new** PowerShell window and run:

```powershell
flutter --version
```

You should see:
```
Flutter 3.35.3 • channel stable
```

## Quick Commands for Current Session

If you don't want to permanently fix it right now, run this at the start of each PowerShell session:

```powershell
$env:Path = "C:\flutter\src\flutter\bin;" + $env:Path
```

Or create a PowerShell profile to do it automatically:

```powershell
# Create profile if it doesn't exist
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -Type File -Force
}

# Add Flutter to PATH in profile
Add-Content $PROFILE '$env:Path = "C:\flutter\src\flutter\bin;" + $env:Path'
```

## Current Status

✅ Flutter is working in this session
⚠️ You need to add it to PATH permanently or run the temporary fix each time

## Next Steps

1. Add Flutter to PATH permanently (recommended)
2. Close and reopen PowerShell
3. Run `flutter doctor` to verify
4. Continue with `flutter run` to test the app
