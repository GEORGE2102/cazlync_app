# 🔐 Admin Setup Guide

## How to Create Admin Accounts

There are **3 ways** to make a user an admin in CazLync:

---

## Method 1: Firebase Console (Recommended) ✅

### Step-by-Step

1. **Open Firebase Console**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your CazLync project

2. **Navigate to Firestore**
   - Click "Firestore Database" in the left menu
   - Click on the `users` collection

3. **Find the User**
   - Locate the user document by their email or ID
   - Click on the document to open it

4. **Add Admin Field**
   - Click "Add field"
   - Field name: `isAdmin`
   - Field type: `boolean`
   - Value: `true`
   - Click "Add"

5. **Verify**
   - The user document should now have `isAdmin: true`
   - User will have admin access on next app restart

### Example User Document

```json
{
  "id": "user123",
  "email": "admin@cazlync.com",
  "displayName": "Admin User",
  "isAdmin": true,  ← Add this field
  "createdAt": "2024-01-01T00:00:00Z",
  "phoneNumber": "+260971234567"
}
```

---

## Method 2: Firebase CLI 🖥️

### Prerequisites
- Firebase CLI installed
- Logged into Firebase

### Command

```bash
# Update user to admin
firebase firestore:update users/USER_ID '{"isAdmin":true}'

# Example
firebase firestore:update users/abc123xyz '{"isAdmin":true}'
```

### Find User ID

**Option A: From Firebase Console**
1. Go to Firestore → users collection
2. Copy the document ID

**Option B: From Authentication**
1. Go to Authentication → Users
2. Copy the User UID
3. Use that as USER_ID

---

## Method 3: Cloud Function (Advanced) ⚙️

### Create Admin Function

Add to `functions/index.js`:

```javascript
// Make user admin (callable function)
exports.makeUserAdmin = functions.https.onCall(async (data, context) => {
  // Only existing admins can make new admins
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated'
    );
  }

  // Check if caller is admin
  const callerDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();

  if (!callerDoc.data()?.isAdmin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can make other users admin'
    );
  }

  // Make target user admin
  const { userId } = data;
  await admin.firestore()
    .collection('users')
    .doc(userId)
    .update({ isAdmin: true });

  return { success: true };
});
```

### Deploy Function

```bash
firebase deploy --only functions:makeUserAdmin
```

### Call from App

```dart
// In your Flutter app
final callable = FirebaseFunctions.instance.httpsCallable('makeUserAdmin');
await callable.call({'userId': 'target_user_id'});
```

---

## 🎯 Creating Your First Two Admins

### Step 1: Create Regular Accounts

1. **Open the app**
2. **Register two accounts:**
   - Admin 1: `admin1@cazlync.com`
   - Admin 2: `admin2@cazlync.com`
3. **Complete registration**

### Step 2: Make Them Admins

**Using Firebase Console:**

1. Go to Firestore → `users` collection
2. Find first user by email `admin1@cazlync.com`
3. Add field: `isAdmin: true`
4. Find second user by email `admin2@cazlync.com`
5. Add field: `isAdmin: true`

**Using Firebase CLI:**

```bash
# Get user IDs from Firebase Console first
firebase firestore:update users/ADMIN1_USER_ID '{"isAdmin":true}'
firebase firestore:update users/ADMIN2_USER_ID '{"isAdmin":true}'
```

### Step 3: Verify Admin Access

1. **Restart the app**
2. **Login with admin account**
3. **Go to Profile tab**
4. **Look for "Administration" section**
5. **Tap "Admin Dashboard"**
6. **You should see the admin dashboard!** 🎉

---

## 🔍 How to Find User IDs

### Method 1: Firebase Console

1. Go to **Firestore Database**
2. Open **users** collection
3. Each document ID is the User ID
4. Look for the user by email

### Method 2: Authentication Tab

1. Go to **Authentication** → **Users**
2. Find user by email
3. Copy the **User UID**
4. That's the User ID

### Method 3: From App Logs

When user logs in, the app logs their ID:
```dart
print('User ID: ${user.uid}');
```

---

## 🎨 Admin Dashboard Access

### How It Works

**In Profile Screen:**
```dart
// Admin section only shows if user.isAdmin == true
if (user.isAdmin) {
  // Show Admin Dashboard menu item
  _buildMenuItem(
    context,
    Icons.admin_panel_settings,
    'Admin Dashboard',
    'Manage platform and moderate content',
    () => Navigator.push(...),
    color: Theme.of(context).colorScheme.tertiary, // Orange
  ),
}
```

**Visual Indicator:**
- Admin menu item has **orange color** (Zambian flag)
- Icon: `admin_panel_settings`
- Only visible to admin users

---

## 🔐 Security

### Firestore Rules

The security rules check admin status:

```javascript
function isAdmin() {
  return request.auth != null && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}

// Only admins can update listing status
match /listings/{listingId} {
  allow update: if isAdmin();
}
```

### Important Notes

- ✅ Admin status checked server-side
- ✅ Cannot self-promote to admin
- ✅ Only admins can moderate
- ✅ Admin actions are logged
- ⚠️ Keep admin credentials secure
- ⚠️ Limit number of admins

---

## 🧪 Testing Admin Access

### Test Checklist

**As Admin User:**
- [ ] Login with admin account
- [ ] Go to Profile tab
- [ ] See "Administration" section
- [ ] Tap "Admin Dashboard"
- [ ] See dashboard with stats
- [ ] Navigate to "Listing Moderation"
- [ ] See pending listings
- [ ] Approve a listing
- [ ] Check listing is now active
- [ ] Navigate to "Analytics"
- [ ] See platform statistics

**As Regular User:**
- [ ] Login with regular account
- [ ] Go to Profile tab
- [ ] "Administration" section NOT visible
- [ ] Cannot access admin dashboard
- [ ] Cannot moderate listings

---

## 🚨 Troubleshooting

### Admin Menu Not Showing?

**Check:**
1. User has `isAdmin: true` in Firestore
2. App has been restarted
3. User is logged in
4. Check user document in Firestore

**Solution:**
```bash
# Verify in Firestore
firebase firestore:get users/USER_ID

# Should show: isAdmin: true
```

### Cannot Access Admin Dashboard?

**Check:**
1. Firestore rules deployed
2. User authenticated
3. Admin field is boolean (not string)
4. No typos in field name

**Solution:**
```bash
# Redeploy rules
firebase deploy --only firestore:rules

# Verify user is admin
firebase firestore:get users/USER_ID
```

### Admin Actions Not Working?

**Check:**
1. Firestore rules allow admin actions
2. User is authenticated
3. Network connection active
4. Check Firebase Console logs

---

## 📝 Admin Management Best Practices

### Do's ✅

1. **Limit admin accounts** - Only trusted users
2. **Use strong passwords** - For admin accounts
3. **Monitor admin actions** - Check security logs
4. **Regular audits** - Review admin activity
5. **Backup admin list** - Keep record of admins
6. **Test regularly** - Verify admin functions work
7. **Document changes** - Track who made what changes

### Don'ts ❌

1. **Don't share admin credentials**
2. **Don't make users admin without verification**
3. **Don't ignore security logs**
4. **Don't forget to remove ex-admins**
5. **Don't use weak passwords**
6. **Don't skip testing**

---

## 🎯 Quick Reference

### Make User Admin (Firebase Console)
```
1. Firestore → users → [user_document]
2. Add field: isAdmin = true
3. Save
```

### Make User Admin (CLI)
```bash
firebase firestore:update users/USER_ID '{"isAdmin":true}'
```

### Remove Admin Access
```bash
firebase firestore:update users/USER_ID '{"isAdmin":false}'
```

### Check Admin Status
```bash
firebase firestore:get users/USER_ID
```

---

## 📞 Support

### Need Help?

**Common Issues:**
- Admin menu not showing → Restart app
- Cannot moderate → Check Firestore rules
- Access denied → Verify isAdmin field

**Resources:**
- Firebase Console: https://console.firebase.google.com
- Firestore Rules: `firestore.rules`
- Admin Dashboard: `lib/presentation/screens/admin_dashboard_screen.dart`

---

## ✅ Summary

**To create admin accounts:**

1. **Register users** in the app
2. **Add `isAdmin: true`** in Firestore
3. **Restart app**
4. **Access via Profile → Admin Dashboard**

**Admin users can:**
- View admin dashboard
- Moderate listings (approve/reject)
- View platform analytics
- Manage users (backend ready)
- Monitor platform activity

**Security:**
- Admin status checked server-side
- Cannot self-promote
- All actions logged
- Firestore rules enforced

---

**Your admin accounts are ready to manage CazLync!** 🔐👨‍💼✨

