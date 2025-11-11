# ⚠️ Firestore Setup Required - Slow Loading Issue

## Problem

The app is taking a long time to register/login because **Firestore Database is not set up** in Firebase Console.

When you register or login, the app tries to:
1. Authenticate with Firebase Auth ✅ (works)
2. Create/read user data in Firestore ❌ (waiting/timing out)

## Solution: Enable Firestore Database

### Step 1: Go to Firebase Console

1. Open: https://console.firebase.google.com/project/cazlync-app-final/firestore
2. Or navigate: Firebase Console → Your Project → Firestore Database

### Step 2: Create Database

1. Click **"Create database"** button
2. Choose **"Start in production mode"** (we'll add rules next)
3. Select location: **"europe-west1"** (closest to Zambia with good performance)
4. Click **"Enable"**
5. Wait 1-2 minutes for provisioning

### Step 3: Set Up Security Rules

Once database is created:

1. Go to **"Rules"** tab
2. Replace the default rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone authenticated can read user profiles
      allow read: if isAuthenticated();
      // Users can only create/update their own profile
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
    }
    
    // Listings collection (for future use)
    match /listings/{listingId} {
      allow read: if true; // Public read
      allow write: if isAuthenticated();
    }
  }
}
```

3. Click **"Publish"**

### Step 4: Enable Authentication Methods

While you're in Firebase Console:

1. Go to **Authentication** → **Sign-in method**
2. Enable **"Email/Password"**
3. Click **"Save"**

## After Setup

Once Firestore is enabled:

1. **Refresh your browser** (if testing on web)
2. **Try registering again**
3. Registration should complete in **2-3 seconds**
4. Login should complete in **1-2 seconds**

## Verification

After enabling Firestore, you should see:

1. **In Firestore Console:**
   - A `users` collection appears
   - User documents are created when you register

2. **In the App:**
   - Registration completes quickly
   - Login completes quickly
   - Home screen shows your name and email

## Quick Test

```bash
# Refresh the app
flutter run -d chrome
```

Then try:
1. Register with: test@example.com / password123
2. Should complete in 2-3 seconds
3. Home screen should show "Hello, Test User!"

## Troubleshooting

### Still Slow After Enabling Firestore?

Check browser console for errors:
- Press F12 in Chrome
- Look for red errors
- Common issues:
  - Firestore rules too restrictive
  - Network connectivity
  - Firebase not initialized

### Error: "Missing or insufficient permissions"

Your Firestore rules are too restrictive. Use the rules provided above.

### Error: "Cloud Firestore API has not been used"

Wait 1-2 minutes after enabling Firestore, then try again.

## Current Status

❌ Firestore Database: **NOT ENABLED** (causing slow loading)
✅ Firebase Auth: Enabled
✅ App Code: Working correctly

## Next Steps

1. **Enable Firestore** (5 minutes)
2. **Test registration** (should be fast now)
3. **Continue development**

The app will work perfectly once Firestore is enabled!

## Alternative: Test Without Firestore

If you want to test authentication without Firestore, I can modify the code to skip Firestore user creation temporarily. Let me know!
