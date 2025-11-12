# 🔔 Notification System - Quick Reference

## 🚀 Deploy Commands

```bash
# Deploy all functions
firebase deploy --only functions

# View logs
firebase functions:log

# Test locally
firebase emulators:start --only functions
```

---

## 📱 Notification Types

| Type | Trigger | Icon | Preference |
|------|---------|------|------------|
| New Message | Chat message sent | 💬 | `messages` |
| Listing Approved | Status → active | ✅ | `listings` |
| Listing Rejected | Status → rejected | ❌ | `listings` |
| Listing Removed | Status → deleted | 🚫 | `listings` |
| Premium Expiry | 3 days before | ⭐ | `premium` |
| New Favorite | Listing favorited | ❤️ | `favorites` |
| Welcome | Account created | 🎉 | Always |
| View Milestone | 50/100/500/1000 views | 🔥 | `listings` |

---

## 🎛️ User Preferences

Located in: `users/{userId}/notificationSettings`

```json
{
  "messages": true,
  "listings": true,
  "favorites": true,
  "premium": true,
  "marketing": false
}
```

---

## 📂 File Locations

```
functions/
  └── index.js              # All Cloud Functions

lib/
  ├── data/services/
  │   └── notification_service.dart
  └── presentation/screens/
      └── notification_settings_screen.dart
```

---

## 🔧 Cloud Functions

1. `sendMessageNotification` - New messages
2. `sendListingStatusNotification` - Listing updates
3. `checkPremiumExpiry` - Daily at 9 AM
4. `sendFavoriteNotification` - New favorites
5. `sendWelcomeNotification` - New users
6. `sendViewMilestoneNotification` - View milestones

---

## 🧪 Quick Test

```bash
# Test message notification
firebase firestore:write chatSessions/test/messages/msg1 \
  '{"senderId":"user1","text":"Test"}'

# Test listing approval
firebase firestore:update listings/test123 \
  '{"status":"active"}'
```

---

## 📊 Monitor

```bash
# View all logs
firebase functions:log

# Follow logs
firebase functions:log --follow

# Specific function
firebase functions:log --only sendMessageNotification
```

---

## 🎨 UI Access

**Path:** Profile → Settings → Notification Settings

**Features:**
- Toggle 5 notification categories
- Real-time updates
- Zambian colors
- Beautiful icons

---

## 🔐 Security

**Firestore Rules:**
```javascript
match /users/{userId} {
  allow update: if request.auth.uid == userId;
}
```

**Function Security:**
- ✅ Admin privileges
- ✅ Preference checking
- ✅ Error handling
- ✅ Logging

---

## 💰 Cost (Free Tier)

- 2M invocations/month
- Typical usage: ~16K/month
- Well within free tier ✅

---

## ✅ Checklist

- [ ] Deploy functions
- [ ] Enable Cloud Scheduler
- [ ] Test notifications
- [ ] Monitor logs
- [ ] Gather feedback

---

**Quick Reference Complete!** 🎉
