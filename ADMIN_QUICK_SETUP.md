# ⚡ Admin Quick Setup

## 🎯 Create Admin in 3 Steps

### Step 1: Register Account
Open app → Register with email

### Step 2: Make Admin
**Firebase Console:**
1. Go to Firestore → `users`
2. Find user document
3. Add field: `isAdmin` = `true`

**Or CLI:**
```bash
firebase firestore:update users/USER_ID '{"isAdmin":true}'
```

### Step 3: Access Dashboard
1. Restart app
2. Login
3. Profile → **Admin Dashboard**

---

## 🔍 Find User ID

**Firebase Console:**
- Firestore → users → Document ID

**Or Authentication:**
- Authentication → Users → User UID

---

## ✅ Verify Admin Access

**Should see:**
- "Administration" section in Profile
- Orange "Admin Dashboard" menu item
- Can access moderation tools

**If not showing:**
- Check `isAdmin: true` in Firestore
- Restart app
- Verify logged in

---

## 🎨 What Admins See

**Profile Screen:**
```
┌─────────────────────────┐
│ Account                 │
│ ├─ Edit Profile         │
│ ├─ My Listings          │
│ └─ Favorites            │
│                         │
│ Administration  ⭐      │
│ └─ Admin Dashboard      │  ← Only for admins
│                         │
│ App Settings            │
│ └─ Settings             │
└─────────────────────────┘
```

**Admin Dashboard:**
- Quick stats
- Listing moderation
- Platform analytics
- User management

---

## 🚨 Troubleshooting

**Menu not showing?**
- Add `isAdmin: true` in Firestore
- Restart app

**Can't moderate?**
- Deploy Firestore rules
- Check admin field is boolean

---

**Done! You're now an admin!** 🔐✨

See `ADMIN_SETUP_GUIDE.md` for detailed instructions.
