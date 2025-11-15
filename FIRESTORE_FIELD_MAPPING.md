# 🔄 Firestore Field Mapping - Data Structure Mismatch

## Problem Identified

Your provided functions use different field names than our current implementation.

---

## Field Name Differences

### Users Collection

| Your Functions | Our Functions | Fix Needed |
|----------------|---------------|------------|
| `fullName` | `displayName` | ✅ Update |
| `favoriteListings` | `favoriteListings` | ✅ Match |
| `fcmToken` | `fcmToken` | ✅ Match |
| `notificationSettings` | `notificationSettings` | ✅ Match |

### Listings Collection

| Your Functions | Our Functions | Fix Needed |
|----------------|---------------|------------|
| `ownerId` | `sellerId` | ✅ Update |
| `title` | `brand + model` | ✅ Update |
| `price` | `price` | ✅ Match |
| `status` | `status` | ✅ Match |
| `views` | `viewCount` | ✅ Update |
| `premiumExpiry` | `premiumExpiresAt` | ✅ Update |
| `createdAt` | `createdAt` | ✅ Match |

### Messages Collection

| Your Functions | Our Functions | Fix Needed |
|----------------|---------------|------------|
| `recipientId` | Calculated from session | ✅ Update |
| `senderName` | Fetched from users | ✅ Update |
| `message` | `text` | ✅ Update |
| `sellerId` | From session | ✅ Update |
| `isFirstMessage` | Calculated | ✅ Update |

---

## Recommendation

**Option 1: Update Cloud Functions to Match Your Data** (Recommended)
- Faster to implement
- No app changes needed
- Just update field names in functions

**Option 2: Update Firestore Data to Match Functions**
- Requires data migration
- More work
- Better long-term consistency

---

## Quick Fix: Update Functions

I'll update the functions to use your field names:
- `ownerId` instead of `sellerId`
- `title` instead of `brand + model`
- `fullName` instead of `displayName`
- `views` instead of `viewCount`
- `premiumExpiry` instead of `premiumExpiresAt`
- `message` instead of `text`

This way notifications will work immediately with your existing data structure.

---

**Shall I update the functions to match your data structure?**
