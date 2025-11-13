# 🔔 Fix Notifications - Quick Action Guide

## Problem
Notifications are not reaching users because Cloud Functions haven't been deployed yet.

---

## ✅ Quick Fix (5 minutes)

### Step 1: Check if Firebase CLI is installed

```bash
firebase --version
```

**If not installed:**
```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase

```bash
firebase login
```

### Step 3: Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

**Wait 2-3 minutes for deployment to complete.**

### Step 4: Verify Deployment

Go to [Firebase Console](https://console.firebase.google.com):
1. Select your project
2. Click **Functions** in left menu
3. You should see 8 functions deployed:
   - ✅ sendMessageNotification
   - ✅ sendListingStatusNotification
   - ✅ checkPremiumExpiry
   - ✅ sendFavoriteNotification
   - ✅ sendWelcomeNotification
   - ✅ sendViewMilestoneNotification

---

## 🧪 Test Notifications

### Test 1: Send a Message
1. Open app on two devices
2. Login with different accounts
3. Send a message
4. **Expected:** Recipient gets notification

### Test 2: Approve a Listing (Admin)
1. Login as admin
2. Approve a pending listing
3. **Expected:** Seller gets "Listing Approved" notification

### Test 3: Favorite a Listing
1. Login as user
2. Favorite someone else's listing
3. **Expected:** Seller gets "New Favorite" notification

---

## 🔍 Troubleshooting

### Issue: "Command not found: firebase"

**Solution:**
```bash
npm install -g firebase-tools
```

### Issue: "Not logged in"

**Solution:**
```bash
firebase login
```

### Issue: "No project selected"

**Solution:**
```bash
firebase use --add
# Select your project from the list
```

### Issue: "Billing required for scheduled functions"

**Solution:**
- Go to [Google Cloud Console](https://console.cloud.google.com)
- Select your project
- Enable billing (free tier is sufficient)
- This is only needed for the daily premium expiry check

### Issue: "Functions deployed but notifications still not working"

**Check these:**

1. **FCM Token stored?**
   - Go to Firestore
   - Open `users` collection
   - Check if user has `fcmToken` field
   - If not, logout and login again

2. **Notification permissions granted?**
   - Check device settings
   - Ensure app has notification permission

3. **Check function logs:**
   ```bash
   firebase functions:log
   ```

4. **Test manually in Firestore:**
   - Create a test message in Firestore
   - Check if function triggers

---

## 📊 Monitor Notifications

### View Function Logs

```bash
# All logs
firebase functions:log

# Specific function
firebase functions:log --only sendMessageNotification

# Real-time logs
firebase functions:log --follow
```

### Firebase Console
1. Go to Functions tab
2. Click on any function
3. View execution count and errors

---

## ⚡ Quick Commands

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:sendMessageNotification

# View logs
firebase functions:log

# List deployed functions
firebase functions:list

# Test locally (optional)
firebase emulators:start --only functions
```

---

## 🎯 What Each Function Does

| Function | Trigger | Notification |
|----------|---------|--------------|
| `sendMessageNotification` | New message sent | "💬 [Name]: Message text" |
| `sendListingStatusNotification` | Listing approved/rejected | "✅ Listing Approved!" |
| `checkPremiumExpiry` | Daily at 9 AM | "⭐ Premium expiring in X days" |
| `sendFavoriteNotification` | Listing favorited | "❤️ Someone saved your listing" |
| `sendWelcomeNotification` | New user signup | "🎉 Welcome to CazLync!" |
| `sendViewMilestoneNotification` | 50/100/500/1000 views | "🔥 Your listing reached X views!" |

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] All 8 functions show in Firebase Console
- [ ] Functions have "Active" status
- [ ] Test message notification works
- [ ] Test listing approval notification works
- [ ] Check function logs for errors
- [ ] Verify FCM tokens are stored in Firestore
- [ ] Test on both Android and iOS (if applicable)

---

## 🚀 Deploy Now!

Run these commands in order:

```bash
# 1. Navigate to functions directory
cd functions

# 2. Install dependencies
npm install

# 3. Deploy to Firebase
firebase deploy --only functions

# 4. Watch logs
firebase functions:log --follow
```

**That's it!** Notifications should now work. 🎉

---

## 💡 Pro Tips

1. **Enable Cloud Scheduler** for daily premium expiry checks:
   - Go to Google Cloud Console
   - Enable Cloud Scheduler API
   - Set up billing (free tier is enough)

2. **Monitor regularly:**
   ```bash
   firebase functions:log --only sendMessageNotification
   ```

3. **Test thoroughly:**
   - Send messages between users
   - Approve/reject listings
   - Favorite listings
   - Check all notification types

4. **User preferences:**
   - Users can disable notifications in Settings
   - Functions respect these preferences
   - Check `notificationSettings` in user document

---

## 📱 App Side (Already Done)

The Flutter app is already configured:
- ✅ FCM token stored on login
- ✅ Notifications initialized in main.dart
- ✅ Foreground/background handlers set up
- ✅ Local notifications configured
- ✅ Navigation on tap implemented

**No app changes needed!** Just deploy the functions.

---

## 🎊 Success Indicators

You'll know it's working when:
- ✅ Users receive message notifications
- ✅ Sellers get listing approval notifications
- ✅ Users get favorite notifications
- ✅ New users get welcome notification
- ✅ Function logs show successful executions
- ✅ No errors in Firebase Console

---

## Need Help?

1. Check function logs: `firebase functions:log`
2. Verify deployment: Firebase Console → Functions
3. Test FCM token: Check Firestore users collection
4. Review this guide again
5. Check Firebase Functions documentation

**Deploy now and notifications will start working immediately!** 🚀📱🔔
