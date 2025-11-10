# Firebase Setup Guide for CazLync

## Current Status

✅ Firebase configuration files detected:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

✅ FlutterFire CLI installed
✅ Firebase dependencies added to pubspec.yaml
✅ Firebase initialization code added to main.dart

## Next Steps

### 1. Update firebase_options.dart with Your Project Details

The file `lib/firebase_options.dart` needs to be updated with your actual Firebase project credentials. You can do this in two ways:

**Option A: Use FlutterFire CLI (Recommended)**

Run this command from the project root:
```bash
flutterfire configure
```

This will:
- Detect your Firebase projects
- Let you select which project to use
- Automatically generate the correct `firebase_options.dart` file

**Option B: Manual Configuration**

Extract the values from your configuration files:

From `android/app/google-services.json`:
- `apiKey` → client[0].api_key[0].current_key
- `appId` → client[0].client_info.mobilesdk_app_id
- `messagingSenderId` → project_info.project_number
- `projectId` → project_info.project_id
- `storageBucket` → project_info.storage_bucket

From `ios/Runner/GoogleService-Info.plist`:
- `apiKey` → API_KEY
- `appId` → GOOGLE_APP_ID
- `messagingSenderId` → GCM_SENDER_ID
- `projectId` → PROJECT_ID
- `storageBucket` → STORAGE_BUCKET

### 2. Enable Firebase Services in Console

Go to [Firebase Console](https://console.firebase.google.com) and enable:

**Authentication:**
- Email/Password
- Phone (requires setting up billing)
- Google Sign-In
- Facebook Sign-In (requires Facebook App setup)

**Firestore Database:**
- Create database in production mode
- Set up security rules (see below)

**Cloud Storage:**
- Create default bucket
- Set up security rules (see below)

**Cloud Messaging:**
- Already enabled by default
- No additional setup needed for basic functionality

**Analytics, Crashlytics, Performance:**
- Already enabled by default

### 3. Firestore Security Rules (Initial Setup)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Listings collection
    match /listings/{listingId} {
      allow read: if true; // Public read
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.sellerId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true);
    }
    
    // Chat sessions
    match /chatSessions/{sessionId} {
      allow read, write: if request.auth != null && 
        (resource.data.buyerId == request.auth.uid || 
         resource.data.sellerId == request.auth.uid);
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

### 4. Cloud Storage Security Rules (Initial Setup)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Listing images
    match /listings/{listingId}/{imageId} {
      allow read: if true; // Public read
      allow write: if request.auth != null;
    }
    
    // User profile photos
    match /users/{userId}/profile.jpg {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Verification documents (admin only)
    match /users/{userId}/verification/{document} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || 
         firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.isAdmin == true);
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5. Android Configuration

Ensure `android/app/build.gradle` has:

```gradle
dependencies {
    // ... other dependencies
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

And at the bottom of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 6. iOS Configuration

Ensure `ios/Runner/Info.plist` has:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

### 7. Test Firebase Connection

Run the app:
```bash
flutter run
```

The app should launch without Firebase errors. Check the console for:
```
[firebase_core] Successfully initialized Firebase
```

## Troubleshooting

**Error: "No Firebase App '[DEFAULT]' has been created"**
- Make sure `Firebase.initializeApp()` is called before `runApp()`
- Check that firebase_options.dart has correct values

**Error: "google-services.json not found"**
- Ensure the file is in `android/app/` directory
- Run `flutter clean` and rebuild

**Error: "GoogleService-Info.plist not found"**
- Ensure the file is in `ios/Runner/` directory
- Open Xcode and verify the file is in the project

**Authentication not working:**
- Check Firebase Console → Authentication → Sign-in methods
- Ensure the method you're testing is enabled
- For Google Sign-In, add SHA-1 fingerprint in Firebase Console

## Next Steps After Setup

Once Firebase is configured, you can proceed with:
- Task 2: Implement authentication module
- Testing authentication flows
- Setting up Firestore collections
- Implementing real-time features

## Useful Commands

```bash
# Reconfigure Firebase
flutterfire configure

# Check Flutter doctor
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# View Firebase logs
flutter logs
```
