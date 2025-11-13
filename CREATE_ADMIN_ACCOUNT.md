# Create Admin Account - Quick Guide

## ✅ Admin Registration Form Added!

I've created a special registration form that automatically creates admin accounts with the `isAdmin` flag set to `true`.

## How to Create Your Admin Account

### Step 1: Open the App
1. Launch the CazLync app
2. You'll see the login screen

### Step 2: Access Admin Registration
1. Scroll to the bottom of the login screen
2. Tap the **"Create Admin Account"** button (gray text with shield icon)

### Step 3: Fill Out the Form
1. Enter your **Full Name**
2. Enter your **Email**
3. Create a **Password** (minimum 6 characters)
4. **Confirm Password**
5. Tap **"Create Admin Account"** button

### Step 4: Success!
- You'll see a green success message
- You'll be automatically logged in
- The account is created with `isAdmin: true` in Firestore

### Step 5: Access Admin Features
1. Go to the **Profile** tab
2. Scroll down to see the **"Administration"** section
3. Tap **"Admin Dashboard"**
4. You now have full admin access!

## What Makes This Different?

**Normal Registration:**
- Creates user with `isAdmin: false`
- No admin privileges
- Can't access Admin Dashboard

**Admin Registration (this form):**
- Creates user with `isAdmin: true` ✅
- Full admin privileges
- Can access Admin Dashboard immediately

## Admin Features You'll Have

Once logged in as admin, you can:
- View **Analytics** - Platform statistics
- **Moderate Listings** - Approve/reject listings
- **Manage Users** - View and manage users
- **Handle Reports** - Review user reports

## Remove This Form Later

Once you've created your admin account, you should remove this registration form:

### Option 1: Let Me Remove It
Just tell me "remove the admin registration form" and I'll delete it.

### Option 2: Manual Removal
1. Delete file: `lib/presentation/screens/admin_register_screen.dart`
2. In `lib/presentation/screens/login_screen.dart`:
   - Remove the import: `import 'admin_register_screen.dart';`
   - Remove the "Create Admin Account" button section

## Security Note

⚠️ **Important:** This form should only be used during initial setup. Remove it before launching to production to prevent unauthorized admin account creation.

## Troubleshooting

**"Email already in use"**
- This email is already registered
- Try a different email or login with existing account

**"Password too weak"**
- Use at least 6 characters
- Include letters and numbers

**Can't see Admin Dashboard after registration**
- Make sure you're on the Profile tab
- Scroll down to find "Administration" section
- If not visible, try logging out and back in

## Making Additional Admins Later

After removing this form, you can make existing users admin using:
```bash
node make-admin.js USER_ID
```

Get the USER_ID from Firebase Console → Firestore → users collection.
