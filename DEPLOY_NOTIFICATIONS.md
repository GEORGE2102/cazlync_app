# 🚀 Deploy Notifications - Quick Guide

## Prerequisites

Before deploying, ensure you have:
- [ ] Firebase CLI installed
- [ ] Firebase project configured
- [ ] Node.js 18+ installed
- [ ] Logged into Firebase CLI

---

## 🔧 Installation

### 1. Install Firebase CLI (if not installed)

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase (if not done)

```bash
firebase init
```

Select:
- Functions
- Firestore
- Your Firebase project

---

## 📦 Deploy Cloud Functions

### Step 1: Navigate to Functions Directory

```bash
cd functions
```

### Step 2: Install Dependencies

```bash
npm install
```

### Step 3: Deploy Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:sendMessageNotification
```

### Step 4: Verify Deployment

Check Firebase Console:
1. Go to Firebase Console
2. Navigate to **Functions**
3. Verify all 8 functions are deployed:
   - `sendMessageNotification`
   - `sendListingStatusNotification`
   - `checkPremiumExpiry`
   - `sendFavoriteNotification`
   - `sendWelcomeNotification`
   - `sendViewMilestoneNotification`

---

## ⚙️ Configure Scheduled Functions

### Enable Cloud Scheduler

Scheduled functions (like `checkPremiumExpiry`) require Cloud Scheduler:

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. Enable **Cloud Scheduler API**
4. Set up billing (required for scheduled functions)

**Note:** The free tier includes enough quota for daily scheduled functions.

---

## 🧪 Test Notifications

### Test Message Notification

```bash
# In Firebase Console → Firestore
# Add a new message to: chatSessions/{sessionId}/messages/{messageId}

# Or use Firebase CLI
firebase firestore:write chatSessions/test123/messages/msg1 '{"senderId":"user1","text":"Hello!","timestamp":"2024-01-01T00:00:00Z"}'
```

### Test Listing Approval

```bash
# Update a listing status in Firestore
firebase firestore:update listings/listing123 '{"status":"active"}'
```

### Test Premium Expiry (Manual Trigger)

```bash
# In Firebase Console → Functions
# Find checkPremiumExpiry
# Click "..." → Run function
```

---

## 📊 Monitor Functions

### View Logs

```bash
# View all function logs
firebase functions:log

# View specific function logs
firebase functions:log --only sendMessageNotification

# Follow logs in real-time
firebase functions:log --follow
```

### Firebase Console

1. Go to Firebase Console
2. Navigate to **Functions**
3. Click on a function to see:
   - Execution count
   - Error rate
   - Execution time
   - Logs

---

## 🔍 Debugging

### Common Issues

#### 1. Function Not Triggering

**Check:**
```bash
# View function logs
firebase functions:log --only functionName

# Check Firestore rules
firebase firestore:rules:get
```

**Solution:**
- Verify Firestore trigger path matches your data structure
- Check function is deployed: `firebase functions:list`

#### 2. Notification Not Received

**Check:**
- User has FCM token in Firestore
- Notification preferences enabled
- Device has internet connection
- Check function logs for errors

#### 3. Scheduled Function Not Running

**Check:**
- Cloud Scheduler API enabled
- Billing enabled on project
- Function deployed successfully
- Check timezone setting

---

## 🔐 Security

### Firestore Rules

Ensure users can update their notification settings:

```javascript
// firestore.rules
match /users/{userId} {
  allow read: if request.auth != null;
  allow update: if request.auth.uid == userId;
}
```

### Function Security

Cloud Functions automatically:
- ✅ Run with admin privileges
- ✅ Validate Firestore triggers
- ✅ Handle errors gracefully
- ✅ Log all operations

---

## 💰 Cost Estimation

### Free Tier Includes:
- 2 million function invocations/month
- 400,000 GB-seconds compute time
- 200,000 CPU-seconds compute time
- 5 GB network egress

### Typical Usage (1000 users):
- Message notifications: ~10,000/month
- Listing notifications: ~1,000/month
- Scheduled checks: ~30/month
- Other notifications: ~5,000/month

**Total:** ~16,000 invocations/month (well within free tier)

---

## 📱 App Configuration

### Update Flutter App

No code changes needed! The app is already configured to:
- ✅ Store FCM tokens
- ✅ Handle incoming notifications
- ✅ Respect user preferences
- ✅ Navigate on notification tap

### Test on Device

1. Run the app: `flutter run`
2. Login with a test account
3. Trigger a notification event
4. Verify notification received

---

## ✅ Deployment Checklist

### Before Deployment
- [ ] Firebase CLI installed and logged in
- [ ] Functions code reviewed
- [ ] Dependencies installed (`npm install`)
- [ ] Firebase project selected

### Deploy
- [ ] Run `firebase deploy --only functions`
- [ ] Verify all functions deployed successfully
- [ ] Check Firebase Console for functions

### After Deployment
- [ ] Enable Cloud Scheduler API
- [ ] Test each notification type
- [ ] Monitor function logs
- [ ] Check notification delivery

### Production
- [ ] Set up error alerting
- [ ] Monitor function performance
- [ ] Track notification metrics
- [ ] Gather user feedback

---

## 🎯 Quick Commands

```bash
# Deploy everything
firebase deploy

# Deploy only functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:sendMessageNotification

# View logs
firebase functions:log

# List all functions
firebase functions:list

# Delete a function
firebase functions:delete functionName

# Test locally (emulator)
firebase emulators:start --only functions
```

---

## 📞 Support

### Issues?

1. **Check logs:** `firebase functions:log`
2. **Check status:** Firebase Console → Functions
3. **Test locally:** `firebase emulators:start`
4. **Review docs:** [Firebase Functions Docs](https://firebase.google.com/docs/functions)

### Common Solutions

**"Billing account not configured"**
- Enable billing in Google Cloud Console
- Required for scheduled functions

**"Permission denied"**
- Check Firestore security rules
- Verify user authentication

**"Function timeout"**
- Increase timeout in function config
- Optimize function code

---

## 🎊 Success!

Once deployed, your app will automatically:
- ✅ Send notifications for all events
- ✅ Respect user preferences
- ✅ Check premium expiry daily
- ✅ Welcome new users
- ✅ Notify about favorites and milestones

**Your notification system is live!** 🎉📱🔔

---

## 📝 Next Steps

1. Deploy functions to production
2. Test all notification flows
3. Monitor analytics
4. Gather user feedback
5. Iterate and improve

**Happy deploying!** 🚀
