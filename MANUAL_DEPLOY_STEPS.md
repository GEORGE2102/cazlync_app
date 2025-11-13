# 🚀 Manual Deployment Steps for Cloud Functions

Since automated deployment is having issues, please follow these manual steps:

## Step 1: Open Command Prompt or PowerShell

Press `Win + R`, type `cmd` or `powershell`, and press Enter.

## Step 2: Navigate to Project Directory

```bash
cd C:\Users\georg\flutter-projets\cazlync_app
```

## Step 3: Check Firebase CLI

```bash
firebase --version
```

If you see a version number, you're good to go!

## Step 4: Check Current Project

```bash
firebase use
```

Should show: `cazlync-app-final`

## Step 5: Install Function Dependencies

```bash
cd functions
npm install
cd ..
```

## Step 6: Deploy Functions

```bash
firebase deploy --only functions
```

**Wait 2-3 minutes for deployment to complete.**

You should see output like:
```
✔ functions: Finished running predeploy script.
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
i  functions: ensuring required API cloudbuild.googleapis.com is enabled...
✔ functions: required API cloudfunctions.googleapis.com is enabled
✔ functions: required API cloudbuild.googleapis.com is enabled
i  functions: preparing functions directory for uploading...
i  functions: packaged functions (XX.XX KB) for uploading
✔ functions: functions folder uploaded successfully
i  functions: creating Node.js 18 function sendMessageNotification...
i  functions: creating Node.js 18 function sendListingStatusNotification...
i  functions: creating Node.js 18 function checkPremiumExpiry...
i  functions: creating Node.js 18 function sendFavoriteNotification...
i  functions: creating Node.js 18 function sendWelcomeNotification...
i  functions: creating Node.js 18 function sendViewMilestoneNotification...
✔ functions[sendMessageNotification] Successful create operation.
✔ functions[sendListingStatusNotification] Successful create operation.
✔ functions[checkPremiumExpiry] Successful create operation.
✔ functions[sendFavoriteNotification] Successful create operation.
✔ functions[sendWelcomeNotification] Successful create operation.
✔ functions[sendViewMilestoneNotification] Successful create operation.

✔ Deploy complete!
```

## Step 7: Verify Deployment

### Option A: Firebase Console
1. Go to https://console.firebase.google.com
2. Select project: `cazlync-app-final`
3. Click **Functions** in left menu
4. You should see 8 functions listed

### Option B: Command Line
```bash
firebase functions:list
```

Should show all 8 functions.

## Step 8: Test Notifications

### Test Message Notification:
1. Login on two devices with different accounts
2. Send a message from Device A
3. Device B should receive notification

### Test Listing Approval:
1. Login as admin
2. Approve a pending listing
3. Seller should receive notification

## Troubleshooting

### Error: "Billing account not configured"
- Go to Google Cloud Console
- Enable billing (free tier is sufficient)
- Required for scheduled functions

### Error: "Permission denied"
- Run: `firebase login`
- Login with your Google account

### Error: "No project selected"
- Run: `firebase use cazlync-app-final`

### Functions deployed but not working:
1. Check function logs:
   ```bash
   firebase functions:log
   ```

2. Check if FCM tokens are stored:
   - Go to Firestore in Firebase Console
   - Open `users` collection
   - Check if users have `fcmToken` field
   - If not, users need to logout and login again

## Monitor Functions

### View Logs:
```bash
# All logs
firebase functions:log

# Specific function
firebase functions:log --only sendMessageNotification

# Real-time logs
firebase functions:log --follow
```

### Firebase Console:
1. Go to Functions tab
2. Click on any function
3. View execution count, errors, and logs

## Success Indicators

You'll know it worked when:
- ✅ All 8 functions show in Firebase Console
- ✅ Functions have "Active" status
- ✅ Test message notification works
- ✅ No errors in function logs

## Need Help?

If deployment fails:
1. Copy the error message
2. Check the error message for specific issues
3. Common issues:
   - Billing not enabled
   - Wrong Node.js version
   - Missing dependencies
   - Network issues

---

**Once deployed, notifications will work immediately!** 🎉
