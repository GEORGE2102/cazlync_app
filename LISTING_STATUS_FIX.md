# Listing Status Fix - Auto-Approval

## Problem
- Listings were created with `status = 'pending'`
- Home screen only shows listings with `status = 'active'`
- Result: New listings didn't appear in the app

## Solution Applied
Changed default listing status from `pending` to `active` for auto-approval.

## What Changed
- `lib/domain/entities/listing_entity.dart`: Default status is now `active`
- New listings will automatically appear on the home screen
- No admin approval needed (can add later)

## Steps to See Your Listings

### 1. Hot Restart the App
```bash
# In your terminal, press:
R
```

### 2. Update Existing Listings in Firebase
Go to Firebase Console and update your existing listings:

1. Open https://console.firebase.google.com
2. Select your project: `cazlync-app-final`
3. Go to **Firestore Database**
4. Click on **listings** collection
5. For each listing document:
   - Click on the document
   - Find the `status` field
   - Change value from `pending` to `active`
   - Click **Update**

### 3. Test
- Go to home screen - you should see your listings
- Create a new listing - it will appear immediately

## Future Enhancement
You can add an admin panel later to:
- Review pending listings
- Approve/reject listings
- Manage reported content

For now, all listings are auto-approved for faster development and testing.
