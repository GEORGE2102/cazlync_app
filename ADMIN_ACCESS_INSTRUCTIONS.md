# Admin Access Instructions

## Current Status
✅ User `hzCCiiFOCbSTTiFOU1bvQq9CCL33` has been set as admin in Firestore
✅ Profile screen now has a refresh button

## Problem
When you log in, the app caches your user data. The admin flag was added AFTER you logged in, so the app still has the old cached data without the admin flag.

## Solution - Choose ONE:

### Option 1: Force Refresh (Easiest)
1. Stay logged in
2. Go to the **Profile** tab
3. Tap the **refresh icon** (🔄) in the top right corner
4. The "Administration" section should now appear
5. Tap "Admin Dashboard" to access admin features

### Option 2: Restart App
1. **Force close** the app completely (don't just minimize it)
2. Reopen the app
3. You should still be logged in
4. Go to Profile tab
5. Look for "Administration" section

### Option 3: Log Out and Back In
1. Go to Profile → Settings
2. Tap "Logout"
3. Log back in with the same account
4. Go to Profile tab
5. Look for "Administration" section

## How to Verify It Worked

Once you see the "Administration" section in your Profile:
- It will have an orange/tertiary color icon
- Shows "Admin Dashboard" option
- Description: "Manage platform and moderate content"

## Admin Dashboard Features

Once you access it, you'll see:
- **Analytics** - View platform statistics
- **Listing Moderation** - Review and moderate listings
- **User Management** - Manage users (coming soon)
- **Reports** - Handle user reports (coming soon)

## Troubleshooting

If you still don't see admin features after trying all options:

1. Check your user ID is correct:
   - Go to Profile → Settings
   - Your user ID should be: `hzCCiiFOCbSTTiFOU1bvQq9CCL33`

2. Verify admin flag in Firestore:
   - Go to Firebase Console
   - Navigate to Firestore Database
   - Find collection: `users`
   - Find document: `hzCCiiFOCbSTTiFOU1bvQq9CCL33`
   - Check field: `isAdmin` should be `true`

3. If the field is missing or false:
   ```bash
   node make-admin.js hzCCiiFOCbSTTiFOU1bvQq9CCL33
   ```

## Making Other Users Admin

To make another user admin:
```bash
node make-admin.js USER_ID_HERE
```

To list all users:
```bash
node make-admin.js --list
```
