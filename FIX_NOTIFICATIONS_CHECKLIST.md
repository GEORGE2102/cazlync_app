# 🔔 Fix Notifications - Complete Checklist

## Problem: Notifications Not Received

Functions are deployed but notifications aren't reaching devices.

---

## ✅ Quick Fix Steps

### Step 1: Check FCM Token in Firestore

1. Go to Firebase Console → Firestore
2. Open `users` collection
3. Click on your user document
4. **Look for `fcmToken` field**

**If missing:**
- Logout from app
- Login again
- Token should be stored automatically

### Step 2: Check Device Permissions

**Android:**
- Settings → Apps → CazLync → Notifications
- Ensure "Allow notifications" is ON

**iOS:**
- Settings → Notifications → CazLync  
- Ensure "Allow Notifications" is ON

### Step 3: Check Function Logs

```bash
firebase functions:log
```

Look for:
- ✅ "Notification sent to user..."
- ❌ "User has no FCM token"

### Step 4: Test Notification Manually

1. Get your FCM token from Firestore
2. Go to Firebase Console → Cloud Messaging
3. Click "Send test message"
4. Paste your FCM token
5. Click "Test"

---

## 🔍 Common Issues

### Issue 1: No FCM Token

**Symptom:** Function logs show "User has no FCM token"

**Solution:**
1. Logout from app
2. Login again
3. Check Firestore - `fcmToken` should appear

### Issue 2: Permissions Not Granted

**Symptom:** Token exists but no notifications

**Solution:**
- Check device notification settings
- Ensure app has permission

### Issue 3: App Not Running

**Symptom:** Notifications only work when app is open

**Solution:**
- This is normal for foreground notifications
- Background notifications need proper setup
- Check `AndroidManifest.xml` configuration

---

## 📱 Android Manifest Check

Ensure `android/app/src/main/AndroidManifest.xml` has:

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- FCM default notification channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="cazlync_channel" />
    </application>
</manifest>
```

---

## 🧪 Test Scenarios

### Test 1: Message Notification
1. Login on Device A as User 1
2. Login on Device B as User 2
3. User 2 sends message to User 1
4. User 1 should receive notification

### Test 2: Listing Approval
1. Create listing as regular user
2. Login as admin
3. Approve the listing
4. User should receive "Listing Approved" notification

### Test 3: New Car Posted
1. Admin approves a new listing
2. All other users should receive "New Car Posted" notification

---

## 🔧 Debug Commands

```bash
# View all function logs
firebase functions:log

# View specific function
firebase functions:log --only sendMessageNotification

# Follow logs in real-time
firebase functions:log --follow

# Check deployed functions
firebase functions:list
```

---

## ✅ Verification Checklist

- [ ] Functions deployed successfully
- [ ] FCM token exists in Firestore for test user
- [ ] Device notification permissions granted
- [ ] Function logs show "Notification sent"
- [ ] No errors in function logs
- [ ] Test notification from Firebase Console works
- [ ] Message notification works
- [ ] Listing approval notification works

---

## 💡 Quick Fixes

**If notifications still don't work:**

1. **Restart the app** - Sometimes needed after permission changes
2. **Clear app data** - Settings → Apps → CazLync → Clear Data
3. **Reinstall app** - Uninstall and reinstall
4. **Check internet** - Device needs internet connection
5. **Wait a few minutes** - FCM can take time to propagate

---

## 📊 Expected Behavior

**Foreground (App Open):**
- Local notification appears
- Sound plays
- Can tap to navigate

**Background (App Closed):**
- System notification appears
- Tapping opens app
- Navigates to relevant screen

---

## 🎯 Most Common Solution

**90% of the time, the issue is:**
1. FCM token not stored in Firestore
2. Device permissions not granted

**Fix:**
1. Logout and login again
2. Grant notification permissions
3. Test again

---

**Need more help? Check function logs for specific errors!**
