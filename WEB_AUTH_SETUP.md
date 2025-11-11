# Web Authentication Setup Guide

## Issue Fixed

**Error:** `ClientID not set` for Google Sign-In on web

**Solution:** Google Sign-In is now disabled on web by default. To enable it, you need to configure the Google Client ID.

## Current Status

✅ **Email/Password authentication** - Works on web
✅ **Facebook authentication** - Works on web (if configured)
⚠️ **Google Sign-In** - Disabled on web (requires configuration)
✅ **Phone authentication** - Works on web

## To Enable Google Sign-In on Web

### Step 1: Get Google Client ID

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services** → **Credentials**
4. Find your **OAuth 2.0 Client ID** for Web
5. Copy the **Client ID** (looks like: `123456789-abc123.apps.googleusercontent.com`)

### Step 2: Add Client ID to web/index.html

Add this meta tag in the `<head>` section of `web/index.html`:

```html
<head>
  <!-- ... other meta tags ... -->
  
  <!-- Google Sign-In Client ID -->
  <meta name="google-signin-client_id" content="YOUR_CLIENT_ID_HERE.apps.googleusercontent.com">
  
  <!-- ... rest of head ... -->
</head>
```

### Step 3: Update AuthService

In `lib/data/services/auth_service.dart`, change the initialization:

```dart
AuthService({
  FirebaseAuth? firebaseAuth,
  GoogleSignIn? googleSignIn,
  FacebookAuth? facebookAuth,
})  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      // Initialize GoogleSignIn with client ID for web
      _googleSignIn = googleSignIn ?? GoogleSignIn(
        clientId: kIsWeb ? 'YOUR_CLIENT_ID_HERE.apps.googleusercontent.com' : null,
      ),
      _facebookAuth = facebookAuth ?? FacebookAuth.instance;
```

## Alternative: Use Firebase UI Auth for Web

For a simpler web authentication experience, you can use Firebase UI Auth which handles all OAuth flows automatically.

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_ui_auth: ^1.10.0
```

## Current Workaround

The app currently works on web with:
- ✅ Email/Password sign in
- ✅ Email/Password sign up
- ✅ Facebook sign in (if configured)
- ✅ Phone authentication

Google Sign-In button will show an error message if clicked on web.

## Testing on Web

```bash
flutter run -d chrome
```

### What Works:
1. **Register with Email/Password** ✅
   - Enter name, email, password
   - Click "Create Account"
   - Automatically logs in

2. **Login with Email/Password** ✅
   - Enter email and password
   - Click "Login"
   - Shows home screen

3. **Sign Out** ✅
   - Click logout button
   - Returns to login screen

### What Doesn't Work (Without Configuration):
- ❌ Google Sign-In (requires client ID)
- ⚠️ Facebook Sign-In (requires Facebook App configuration)

## Recommended Approach for Web

For production web deployment, consider:

1. **Configure Google Sign-In** (as described above)
2. **Or use Firebase UI Auth** for automatic OAuth handling
3. **Or disable social login buttons on web** and only show email/password

## Quick Fix: Hide Google Button on Web

Update `lib/presentation/screens/login_screen.dart`:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

// In the build method, wrap Google button:
if (!kIsWeb) ...[
  OutlinedButton.icon(
    onPressed: authState.isLoading ? null : _handleGoogleLogin,
    icon: const Icon(Icons.g_mobiledata, size: 24),
    label: const Text('Continue with Google'),
  ),
  const SizedBox(height: 12),
],
```

## For Mobile (Android/iOS)

Google Sign-In works out of the box on mobile platforms. No additional configuration needed beyond Firebase setup.

### Android Requirements:
- SHA-1 fingerprint added to Firebase Console
- Google Sign-In enabled in Firebase Authentication

### iOS Requirements:
- URL scheme configured in Info.plist (done by FlutterFire CLI)
- Google Sign-In enabled in Firebase Authentication

## Status

✅ Web authentication working with email/password
✅ Error fixed (Google Sign-In disabled on web)
✅ App runs successfully on web
⚠️ Google Sign-In requires additional configuration for web

## Next Steps

Choose one:
1. **Add Google Client ID** to enable Google Sign-In on web
2. **Hide Google button on web** (quick fix)
3. **Use Firebase UI Auth** for automatic OAuth handling
4. **Keep as is** - email/password works fine for testing

The app is fully functional on web with email/password authentication!
