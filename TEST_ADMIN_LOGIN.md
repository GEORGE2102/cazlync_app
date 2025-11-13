# 🧪 Test Admin Login - Quick Guide

## ✅ The Fix is Applied

The admin login issue has been fixed. Follow these steps to test it.

---

## 🎯 Test Scenario 1: Fresh Admin Creation

### Step 1: Create Admin Account
```
1. Run the app: flutter run
2. On login screen, click "Create Admin"
3. Fill in the form:
   - Name: Test Admin
   - Email: admin@cazlync.com
   - Password: Test123!
   - Confirm Password: Test123!
4. Click "Create Admin Account"
5. Wait for success message
```

**Expected Result:** ✅ Success dialog appears

### Step 2: Verify in Firestore
```
1. Open Firebase Console
2. Go to Firestore Database
3. Click on 'users' collection
4. Find the user with email: admin@cazlync.com
5. Check the document fields
```

**Expected Result:** ✅ `isAdmin: true` field exists

### Step 3: Login as Admin
```
1. If not already logged in, go to login screen
2. Enter:
   - Email: admin@cazlync.com
   - Password: Test123!
3. Click "Login"
4. Wait for app to load
```

**Expected Result:** ✅ Redirected to main app (Home screen)

### Step 4: Check Profile
```
1. Tap on "Profile" tab (bottom navigation)
2. Scroll down
3. Look for "Administration" section
```

**Expected Result:** ✅ "Administration" section visible with "Admin Dashboard" option

### Step 5: Access Admin Dashboard
```
1. Tap "Admin Dashboard"
2. Wait for dashboard to load
```

**Expected Result:** ✅ Admin Dashboard opens with:
- Quick Stats (Users, Listings, etc.)
- Listing Moderation button
- Analytics & Reports button

---

## 🎯 Test Scenario 2: Existing Admin Login

### If you already have an admin account:

```
1. Logout from app
2. Login with admin credentials
3. Go to Profile tab
4. Check for "Administration" section
5. Click "Admin Dashboard"
```

**Expected Result:** ✅ Admin Dashboard accessible

---

## 🎯 Test Scenario 3: Normal User (Should NOT see admin)

### Step 1: Create Normal User
```
1. Logout if logged in
2. Click "Register" on login screen
3. Fill in normal registration form
4. Complete registration
```

### Step 2: Check Profile
```
1. Go to Profile tab
2. Scroll through all sections
```

**Expected Result:** ❌ NO "Administration" section (correct!)

---

## 🐛 Troubleshooting

### Problem: Admin Dashboard Not Showing

**Solution 1: Check Firestore**
```
1. Firebase Console → Firestore
2. users → your user document
3. Verify: isAdmin = true
4. If false, change to true
5. Save
6. Restart app
```

**Solution 2: Force Refresh**
```
1. Logout completely
2. Close app
3. Reopen app
4. Login again
```

**Solution 3: Clear App Data**
```
Android:
1. Settings → Apps → CazLync
2. Storage → Clear Data
3. Reopen app
4. Login again

iOS:
1. Uninstall app
2. Reinstall app
3. Login again
```

### Problem: Can't Create Admin Account

**Solution: Check AdminRegisterScreen**
```
1. Verify the screen exists
2. Check navigation route
3. Try accessing from login screen
```

### Problem: Login Fails

**Solution: Check Credentials**
```
1. Verify email is correct
2. Verify password is correct
3. Check Firebase Console → Authentication
4. Verify user exists
```

---

## 📊 Verification Checklist

After testing, verify:

- [ ] Admin account created successfully
- [ ] isAdmin = true in Firestore
- [ ] Can login with admin credentials
- [ ] Profile shows "Administration" section
- [ ] Can access Admin Dashboard
- [ ] Dashboard shows all features
- [ ] Can moderate listings
- [ ] Can view analytics
- [ ] Normal users don't see admin features

---

## 🎯 Quick Debug Commands

### Check User in Firestore
```bash
# Using Firebase CLI
firebase firestore:get users/USER_ID
```

### Update User to Admin
```bash
# Using Firebase CLI
firebase firestore:update users/USER_ID '{"isAdmin":true}'
```

### View App Logs
```bash
# Flutter logs
flutter logs

# Filter for auth
flutter logs | grep -i "auth"
```

---

## 📱 Testing on Device

### Android
```bash
# Install and run
flutter run --release

# Or build APK
flutter build apk --release
# Install APK on device
```

### iOS
```bash
# Run on simulator
flutter run

# Or build for device
flutter build ios --release
```

---

## ✅ Expected Test Results

### Admin User Flow
```
1. Create admin account ✅
2. isAdmin = true in Firestore ✅
3. Login successful ✅
4. Profile shows admin section ✅
5. Can access dashboard ✅
6. All admin features work ✅
```

### Normal User Flow
```
1. Create normal account ✅
2. isAdmin = false in Firestore ✅
3. Login successful ✅
4. Profile shows normal sections ✅
5. No admin section visible ✅
6. Cannot access dashboard ✅
```

---

## 🎉 Success Criteria

**Test passes if:**
- ✅ Admin can login and see admin dashboard
- ✅ Admin status persists across logins
- ✅ Normal users don't see admin features
- ✅ All admin features are accessible
- ✅ No errors in console

**Test fails if:**
- ❌ Admin dashboard not showing for admin
- ❌ Admin status lost after login
- ❌ Normal users can see admin features
- ❌ Errors in console

---

## 📞 Need Help?

### Check These Files
1. `ADMIN_LOGIN_FIX.md` - Detailed fix explanation
2. `ADMIN_ACCOUNT_FIX.md` - Original fix documentation
3. `CREATE_ADMIN_NOW.md` - Admin creation guide

### Check Firebase Console
1. Authentication → Users
2. Firestore → users collection
3. Check isAdmin field

### Check App Code
1. `lib/presentation/screens/profile_screen.dart` - Line ~241
2. `lib/data/repositories/auth_repository_impl.dart` - User creation logic
3. `lib/domain/entities/user_entity.dart` - isAdmin field

---

**Status: READY TO TEST** ✅

**Run the tests and verify admin login works!** 🧪

