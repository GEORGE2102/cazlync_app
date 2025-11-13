# 🚀 Deploy Cloud Functions - Quick Start

## The Problem
Notifications aren't working because Cloud Functions haven't been deployed yet.

## The Solution (3 Commands)

```bash
# 1. Navigate to functions folder
cd functions

# 2. Install dependencies
npm install

# 3. Deploy to Firebase
firebase deploy --only functions
```

**Wait 2-3 minutes for deployment to complete.**

---

## ✅ Verify It Worked

### Check Firebase Console
1. Go to https://console.firebase.google.com
2. Select your project
3. Click **Functions** in left menu
4. You should see these 8 functions:
   - ✅ sendMessageNotification
   - ✅ sendListingStatusNotification
   - ✅ checkPremiumExpiry
   - ✅ sendFavoriteNotification
   - ✅ sendWelcomeNotification
   - ✅ sendViewMilestoneNotification

### Test Notifications
1. Login on two devices
2. Send a message from Device A
3. Device B should receive notification

---

## 🔧 If You Get Errors

### "Command not found: firebase"
```bash
npm install -g firebase-tools
```

### "Not logged in"
```bash
firebase login
```

### "No project selected"
```bash
firebase use --add
# Select your project
```

### "Billing required"
- Go to Google Cloud Console
- Enable billing (free tier is enough)
- Only needed for scheduled functions

---

## 📊 Monitor Functions

```bash
# View logs
firebase functions:log

# Real-time logs
firebase functions:log --follow

# Specific function
firebase functions:log --only sendMessageNotification
```

---

## 🎯 That's It!

After deployment:
- ✅ Message notifications will work
- ✅ Listing approval notifications will work
- ✅ Favorite notifications will work
- ✅ Welcome notifications will work
- ✅ All notifications will work!

**Deploy now and test!** 🎉
