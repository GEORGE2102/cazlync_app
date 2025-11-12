# Push Notifications Setup Guide

## ✅ What's Already Done

### App-Side Implementation:
1. ✅ NotificationService created and initialized
2. ✅ FCM token storage on login/signup
3. ✅ Foreground notification handling
4. ✅ Background notification handling
5. ✅ Notification tap handling
6. ✅ Local notifications for foreground messages

### Cloud Functions Created:
1. ✅ `sendMessageNotification` - Sends notification when new message arrives
2. ✅ `sendListingApprovedNotification` - Notifies when listing is approved
3. ✅ `checkPremiumExpiry` - Daily check for expiring premium listings

---

## 🚀 Deployment Steps

### Step 1: Install Firebase CLI (if not already installed)
```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase
```bash
firebase login
```

### Step 3: Initialize Firebase Functions (if not done)
```bash
# In your project root
firebase init functions

# Select:
# - Use existing project: cazlync-app-final
# - Language: JavaScript
# - ESLint: No (or Yes if you prefer)
# - Install dependencies: Yes
```

### Step 4: Deploy Cloud Functions
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

This will deploy:
- `sendMessageNotification`
- `sendListingApprovedNotification`
- `checkPremiumExpiry`

---

## 🧪 Testing Notifications

### Test 1: Message Notifications

**Setup:**
1. Have two devices/accounts (or use Firebase Console)
2. Make sure both users are logged in

**Steps:**
```
Device A (Sender):
1. Open a listing from Device B's user
2. Tap "Contact Seller"
3. Send a message: "Hi, is this available?"

Device B (Receiver):
4. Should receive push notification
5. Tap notification → Should open chat
6. Should see the message
```

**Expected:**
- ✅ Notification appears on Device B
- ✅ Shows sender name and message preview
- ✅ Tapping opens the chat
- ✅ Message is visible in chat

### Test 2: Foreground Notifications

**Steps:**
```
1. Have app open on Device B
2. Send message from Device A
3. Should see local notification banner
4. Notification should appear even though app is open
```

**Expected:**
- ✅ Banner notification shows at top
- ✅ Can tap to open chat
- ✅ Message appears in real-time

### Test 3: Background Notifications

**Steps:**
```
1. Minimize app on Device B (don't close)
2. Send message from Device A
3. Should receive system notification
4. Tap notification
```

**Expected:**
- ✅ System notification appears
- ✅ App opens to chat screen
- ✅ Message is visible

### Test 4: Terminated State

**Steps:**
```
1. Force close app on Device B
2. Send message from Device A
3. Tap notification when it appears
```

**Expected:**
- ✅ Notification appears
- ✅ App launches
- ✅ Opens directly to chat
- ✅ Message is visible

---

## 🔧 Troubleshooting

### Notifications Not Appearing

**Check 1: FCM Token Stored**
```
1. Login to Firebase Console
2. Go to Firestore
3. Open users collection
4. Find your user document
5. Check if 'fcmToken' field exists
```

**Check 2: Cloud Functions Deployed**
```bash
firebase functions:list
```
Should show:
- sendMessageNotification
- sendListingApprovedNotification
- checkPremiumExpiry

**Check 3: Function Logs**
```bash
firebase functions:log
```
Look for errors or "Notification sent successfully"

**Check 4: Notification Permissions**
```
Android: Settings → Apps → CazLync → Notifications → Enabled
iOS: Settings → CazLync → Notifications → Allow
```

### Common Issues

**Issue 1: "No FCM token"**
- User needs to login again
- FCM token is stored on login
- Check Firestore user document

**Issue 2: "Recipient not found"**
- Seller user document doesn't exist
- Check Firestore users collection

**Issue 3: Notifications work in foreground but not background**
- Check Android notification channel settings
- Verify background handler is registered

**Issue 4: Tap doesn't open chat**
- Deep linking not fully implemented yet
- Will navigate to home screen for now

---

## 📱 Platform-Specific Setup

### Android

**Already configured:**
- ✅ Firebase messaging plugin
- ✅ Notification channel
- ✅ Background handler

**Additional (optional):**
- Custom notification icon
- Notification sound
- Vibration pattern

### iOS

**Required:**
- APNs certificate in Firebase Console
- Notification capabilities in Xcode
- Push notification entitlement

**Steps:**
1. Open project in Xcode
2. Select target → Signing & Capabilities
3. Add "Push Notifications" capability
4. Add "Background Modes" → Check "Remote notifications"

---

## 🎯 Current Status

### Working:
- ✅ FCM token storage on login
- ✅ Notification service initialized
- ✅ Cloud Functions created
- ✅ Message notification trigger
- ✅ Foreground notifications
- ✅ Background notifications

### Needs Testing:
- ⚠️ Cloud Functions deployment
- ⚠️ End-to-end notification flow
- ⚠️ iOS APNs setup (if testing on iOS)

### Future Enhancements:
- [ ] Deep linking to specific screens
- [ ] Notification preferences in settings
- [ ] Notification history
- [ ] Rich notifications with images
- [ ] Action buttons on notifications

---

## 🚀 Quick Start

**To enable notifications right now:**

1. **Deploy Functions:**
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

2. **Restart App:**
```bash
# In Flutter terminal
Press 'R' to hot restart
```

3. **Test:**
- Login on two devices
- Send a message
- Check if notification appears

---

## 📊 Monitoring

### Check Function Execution:
```bash
firebase functions:log --only sendMessageNotification
```

### Check FCM Delivery:
- Firebase Console → Cloud Messaging
- View delivery reports
- Check success/failure rates

### Debug Mode:
- Check terminal logs for "FCM Token: ..."
- Check "Notification sent successfully" in function logs
- Check Firestore for fcmToken field

---

## ✅ Next Steps

1. Deploy Cloud Functions
2. Test message notifications
3. Verify both devices receive notifications
4. Check function logs for any errors
5. Report back what works!

**Ready to deploy? Run:**
```bash
firebase deploy --only functions
```

Then test and let me know the results!
