# Enable Firestore Database - Quick Guide

## Step-by-Step Instructions

### 1. Open Firebase Console
Go to: https://console.firebase.google.com/project/cazlync-app-final/firestore

### 2. Create Firestore Database

1. Click **"Create database"** button
2. Choose **"Start in production mode"** (we'll add rules next)
3. Select location: **"europe-west1"** (closest to Zambia with good performance)
4. Click **"Enable"**

Wait 1-2 minutes for Firestore to be provisioned.

### 3. Set Up Security Rules

Once Firestore is created:

1. Go to **"Rules"** tab
2. Replace the default rules with these initial rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && request.auth.uid == userId;
      allow update: if isAuthenticated() && request.auth.uid == userId;
      allow delete: if isAdmin();
    }
    
    // Listings collection
    match /listings/{listingId} {
      allow read: if true; // Public read for browsing
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
                      (resource.data.sellerId == request.auth.uid || isAdmin());
      allow delete: if isAuthenticated() && 
                      (resource.data.sellerId == request.auth.uid || isAdmin());
    }
    
    // Chat sessions
    match /chatSessions/{sessionId} {
      allow read: if isAuthenticated() && 
                    (resource.data.buyerId == request.auth.uid || 
                     resource.data.sellerId == request.auth.uid);
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && 
                      (resource.data.buyerId == request.auth.uid || 
                       resource.data.sellerId == request.auth.uid);
      
      // Messages subcollection
      match /messages/{messageId} {
        allow read: if isAuthenticated();
        allow create: if isAuthenticated();
      }
    }
    
    // Reports collection (admin only)
    match /reports/{reportId} {
      allow read: if isAdmin();
      allow create: if isAuthenticated();
      allow update: if isAdmin();
    }
    
    // Analytics collection (admin only)
    match /analytics/{document=**} {
      allow read: if isAdmin();
      allow write: if false; // Only Cloud Functions can write
    }
  }
}
```

3. Click **"Publish"**

### 4. Enable Authentication Methods

Go to: https://console.firebase.google.com/project/cazlync-app-final/authentication/providers

Enable these sign-in methods:

#### Email/Password
1. Click **"Email/Password"**
2. Toggle **"Enable"**
3. Click **"Save"**

#### Phone
1. Click **"Phone"**
2. Toggle **"Enable"**
3. Add test phone numbers if needed (for development)
4. Click **"Save"**
5. **Note:** Phone auth requires billing to be enabled

#### Google
1. Click **"Google"**
2. Toggle **"Enable"**
3. Enter project support email
4. Click **"Save"**

#### Facebook (Optional - requires Facebook App)
1. Create a Facebook App at https://developers.facebook.com
2. Get App ID and App Secret
3. In Firebase Console, click **"Facebook"**
4. Toggle **"Enable"**
5. Enter App ID and App Secret
6. Copy the OAuth redirect URI
7. Add it to Facebook App settings
8. Click **"Save"**

### 5. Enable Cloud Storage

Go to: https://console.firebase.google.com/project/cazlync-app-final/storage

1. Click **"Get started"**
2. Choose **"Start in production mode"**
3. Select same location as Firestore: **"europe-west1"**
4. Click **"Done"**

### 6. Set Storage Security Rules

1. Go to **"Rules"** tab
2. Replace with these rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Helper function
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Listing images - public read, authenticated write
    match /listings/{listingId}/{imageId} {
      allow read: if true;
      allow write: if isAuthenticated();
    }
    
    // User profile photos
    match /users/{userId}/profile.jpg {
      allow read: if true;
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }
    
    // Verification documents (private)
    match /users/{userId}/verification/{document} {
      allow read: if isAuthenticated() && request.auth.uid == userId;
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }
  }
}
```

3. Click **"Publish"**

### 7. Verify Setup

Run this command to test Firebase connection:

```bash
cd cazlync_app
flutter run
```

The app should:
- ✅ Launch without Firebase errors
- ✅ Show the splash screen
- ✅ Console shows: `[firebase_core] Successfully initialized Firebase`

## Verification Checklist

- [ ] Firestore Database created
- [ ] Firestore security rules published
- [ ] Email/Password authentication enabled
- [ ] Phone authentication enabled (optional, requires billing)
- [ ] Google Sign-In enabled
- [ ] Facebook Sign-In enabled (optional)
- [ ] Cloud Storage created
- [ ] Storage security rules published
- [ ] App runs without Firebase errors

## Troubleshooting

**Error: "Cloud Firestore API has not been used"**
- Wait 1-2 minutes after enabling Firestore
- Try running the app again

**Error: "PERMISSION_DENIED"**
- Check that security rules are published
- Verify user is authenticated before accessing data

**Phone auth not working:**
- Ensure billing is enabled in Google Cloud Console
- Add test phone numbers in Authentication settings

## Next Steps

Once all services are enabled:
✅ Task 1 is fully complete
🚀 Ready to start **Task 2: Implement authentication module**
