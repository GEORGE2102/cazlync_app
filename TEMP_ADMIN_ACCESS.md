# Temporary Admin Access

## Quick Access Added to Login Screen

I've added TWO ways to access the admin dashboard directly from the login screen:

### Method 1: Admin Access Button (Easiest)
1. Open the app
2. On the login screen, scroll to the bottom
3. Tap the **"Admin Access"** button (gray text with shield icon)
4. You'll go directly to the Admin Dashboard

### Method 2: Hidden Easter Egg
1. Open the app
2. On the login screen, tap the **logo** 5 times quickly
3. You'll go directly to the Admin Dashboard

## What You'll See

The Admin Dashboard has:
- **Analytics** - Platform statistics
- **Listing Moderation** - Review listings
- **User Management** - Manage users
- **Reports** - Handle reports

## To Remove Later

When you're ready to remove this temporary access:

1. Open `lib/presentation/screens/login_screen.dart`
2. Find the section marked "Admin access button (temporary - remove in production)"
3. Delete that entire section (lines with the TextButton.icon for Admin Access)
4. Optionally remove the logo tap counter if you want

Or just let me know and I'll remove it for you!

## Why This Works

This bypasses the normal authentication flow and takes you directly to the admin screens. You don't need to be logged in or have the admin flag set - it's a direct route for testing purposes.

**Note:** This is for development/testing only. Remove before production launch!
