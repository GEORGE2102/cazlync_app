# 🔔 How CazLync Notifications Work

## Complete System Overview

This document explains the entire notification system architecture, flow, and user experience.

---

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     CazLync Notification System              │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Flutter    │      │   Firebase   │      │    Cloud     │
│     App      │◄────►│   Firestore  │◄────►│  Functions   │
└──────────────┘      └──────────────┘      └──────────────┘
       │                                             │
       │                                             │
       ▼                                             ▼
┌──────────────┐                            ┌──────────────┐
│     FCM      │◄───────────────────────────│   Firebase   │
│  (Firebase   │                            │  Messaging   │
│  Messaging)  │                            │   Service    │
└──────────────┘                            └──────────────┘
       │
       ▼
┌──────────────┐
│    Device    │
│ Notification │
└──────────────┘
```

---

## 🔄 Complete Flow

### 1. Initial Setup (When User Installs App)

```
User installs app
       ↓
App starts
       ↓
NotificationService.initialize() called in main.dart
       ↓
Request notification permissions (iOS/Android)
       ↓
Get FCM token from Firebase
       ↓
Store token locally
```

### 2. User Login Flow

```
User logs in
       ↓
AuthController.login() called
       ↓
User authenticated successfully
       ↓
_storeFCMToken(userId) called
       ↓
NotificationService.storeFCMToken(userId)
       ↓
FCM token saved to Firestore: users/{userId}/fcmToken
       ↓
User can now receive notifications
```

### 3. Notification Trigger Flow

```
Event occurs (e.g., new message sent)
       ↓
Firestore document created/updated
       ↓
Cloud Function triggered automatically
       ↓
Function reads user data from Firestore
       ↓
Function checks:
  - Does user have FCM token?
  - Are notifications enabled for this type?
  - Is user the recipient?
       ↓
If all checks pass:
       ↓
Function calls Firebase Messaging API
       ↓
Firebase sends notification to device
       ↓
Device receives notification
       ↓
User sees notification
```

### 4. User Interaction Flow

```
User taps notification
       ↓
App opens (if closed) or comes to foreground
       ↓
onNotificationTapped() called
       ↓
Parse notification data
       ↓
Navigate to relevant screen:
  - Message → Chat room
  - Listing → Listing detail
  - Favorite → Listing detail
       ↓
User sees relevant content
```

---

## 📱 Notification Types & Triggers

### 1. 💬 Message Notifications

**Trigger:** When a message is sent in a chat

**Function:** `sendMessageNotification`

**Flow:**
```
User A sends message to User B
       ↓
Message saved to: chatSessions/{sessionId}/messages/{messageId}
       ↓
Cloud Function triggered (onDocumentCreated)
       ↓
Function determines recipient (User B)
       ↓
Checks User B's notification preferences
       ↓
Gets User A's name for notification
       ↓
Sends notification to User B:
  Title: "💬 John Doe"
  Body: "Hello, is this still available?"
       ↓
User B receives notification
       ↓
User B taps → Opens chat with User A
```

**Notification Payload:**
```javascript
{
  notification: {
    title: "💬 John Doe",
    body: "Hello, is this still available?"
  },
  data: {
    type: "new_message",
    chatSessionId: "abc123",
    senderId: "user_a_id",
    listingId: "listing_123"
  }
}
```

---

### 2. ✅ Listing Approval Notifications

**Trigger:** When admin approves a listing

**Function:** `sendListingStatusNotification`

**Flow:**
```
Admin approves listing
       ↓
Listing status changed: pending → active
       ↓
Cloud Function triggered (onDocumentUpdated)
       ↓
Function detects status change
       ↓
Gets seller's FCM token
       ↓
Sends notification to seller:
  Title: "✅ Listing Approved!"
  Body: "Your Toyota Corolla (2020) is now live..."
       ↓
Seller receives notification
       ↓
Seller taps → Opens listing detail
```

**Notification Payload:**
```javascript
{
  notification: {
    title: "✅ Listing Approved!",
    body: "Your Toyota Corolla (2020) is now live and visible to buyers!"
  },
  data: {
    type: "listing_approved",
    listingId: "listing_123"
  }
}
```

---

### 3. ❤️ Favorite Notifications

**Trigger:** When someone favorites a listing

**Function:** `sendFavoriteNotification`

**Flow:**
```
User B favorites User A's listing
       ↓
User B's favoriteListings array updated
       ↓
Cloud Function triggered (onDocumentUpdated)
       ↓
Function detects new favorite
       ↓
Gets listing details
       ↓
Gets User B's name
       ↓
Sends notification to User A (seller):
  Title: "❤️ New Favorite!"
  Body: "Jane saved your Toyota Corolla listing"
       ↓
User A receives notification
       ↓
User A taps → Opens listing detail
```

---

### 4. 🎉 Welcome Notifications

**Trigger:** When a new user signs up

**Function:** `sendWelcomeNotification`

**Flow:**
```
New user creates account
       ↓
User document created in Firestore
       ↓
Cloud Function triggered (onDocumentCreated)
       ↓
Function waits 5 seconds (for FCM token to be set)
       ↓
Sends welcome notification:
  Title: "🎉 Welcome to CazLync!"
  Body: "Hi John! Start browsing cars..."
       ↓
User receives notification
       ↓
User taps → Opens home screen
```

---

### 5. ⭐ Premium Expiry Notifications

**Trigger:** Daily at 9 AM (scheduled)

**Function:** `checkPremiumExpiry`

**Flow:**
```
9 AM every day (Zambian time)
       ↓
Cloud Function runs automatically
       ↓
Queries listings expiring in 3 days
       ↓
For each expiring listing:
  - Get seller info
  - Check notification preferences
  - Calculate days left
  - Send notification
       ↓
Sellers receive notifications:
  Title: "⭐ Premium Listing Expiring Soon"
  Body: "Your Toyota Corolla expires in 2 days..."
       ↓
Seller taps → Opens listing detail
```

---

### 6. 🔥 View Milestone Notifications

**Trigger:** When listing reaches view milestones (50, 100, 500, 1000)

**Function:** `sendViewMilestoneNotification`

**Flow:**
```
Listing view count updated
       ↓
Cloud Function triggered (onDocumentUpdated)
       ↓
Function checks if milestone reached
       ↓
If milestone (e.g., 100 views):
  - Get seller info
  - Send notification
       ↓
Seller receives notification:
  Title: "🔥 Your Listing is Popular!"
  Body: "Your Toyota Corolla has reached 100 views!"
       ↓
Seller taps → Opens listing detail
```

---

### 7. 🚗 New Car Posted Notifications

**Trigger:** When a new car is posted and approved

**Function:** `notifyNewCarPosted`

**Flow:**
```
New listing created and approved
       ↓
Cloud Function triggered (onDocumentCreated)
       ↓
Function gets all users (except seller)
       ↓
For each user:
  - Check notification preferences
  - Check FCM token exists
  - Send notification
       ↓
Users receive notification:
  Title: "🚗 New Car Posted!"
  Body: "Toyota Corolla (2020) - K85,000"
       ↓
User taps → Opens listing detail
```

---

### 8. 💬 Buyer Inquiry Notifications

**Trigger:** When buyer sends first message to seller

**Function:** `notifySellerNewBuyerMessage`

**Flow:**
```
Buyer sends first message to seller
       ↓
Cloud Function triggered (onDocumentCreated)
       ↓
Function checks if first message from buyer
       ↓
Gets buyer name and listing info
       ↓
Sends notification to seller:
  Title: "💬 New Buyer Inquiry!"
  Body: "John is interested about your Toyota Corolla..."
       ↓
Seller receives notification
       ↓
Seller taps → Opens chat with buyer
```

---

### 9. 📊 Daily Digest Notifications

**Trigger:** Every day at 6 PM (scheduled)

**Function:** `sendDailyNewCarsDigest`

**Flow:**
```
6 PM every day (Zambian time)
       ↓
Cloud Function runs automatically
       ↓
Queries listings posted in last 24 hours
       ↓
Creates digest with top 3 cars
       ↓
For each user with dailyDigest enabled:
  - Send notification
       ↓
Users receive notification:
  Title: "🚗 15 New Cars Today!"
  Body: "Check out: Toyota Corolla, Honda Civic..."
       ↓
User taps → Opens home screen
```

---

## 🎯 Notification States

### Foreground (App is Open)

```
Notification received
       ↓
FirebaseMessaging.onMessage triggered
       ↓
_handleForegroundMessage() called
       ↓
Local notification shown via flutter_local_notifications
       ↓
User sees notification banner
       ↓
User taps → Navigate to relevant screen
```

**User Experience:**
- Notification appears as banner at top
- Sound plays
- Can dismiss or tap
- Tapping navigates within app

---

### Background (App is Closed/Minimized)

```
Notification received
       ↓
System handles notification
       ↓
Notification appears in system tray
       ↓
User taps notification
       ↓
App opens
       ↓
FirebaseMessaging.onMessageOpenedApp triggered
       ↓
_handleMessageOpenedApp() called
       ↓
Navigate to relevant screen
```

**User Experience:**
- Notification appears in notification tray
- Sound/vibration based on device settings
- Badge count updates (iOS)
- Tapping opens app and navigates

---

### Terminated (App Not Running)

```
Notification received
       ↓
System stores notification
       ↓
User taps notification
       ↓
App launches
       ↓
FirebaseMessaging.getInitialMessage() called
       ↓
_checkInitialMessage() called
       ↓
Navigate to relevant screen
```

**User Experience:**
- Notification appears in notification tray
- Tapping launches app
- App opens directly to relevant screen

---

## ⚙️ Notification Preferences

Users can control notifications in Settings:

```dart
notificationSettings: {
  messages: true,        // Chat messages
  listings: true,        // Listing status changes
  favorites: true,       // Someone favorited
  premium: true,         // Premium expiry
  newListings: true,     // New cars posted
  dailyDigest: true,     // Daily digest at 6 PM
}
```

**How Preferences Work:**

```
Notification triggered
       ↓
Cloud Function checks user's notificationSettings
       ↓
If setting is false for this type:
  - Skip notification
  - Log "User has disabled X notifications"
       ↓
If setting is true:
  - Send notification
```

---

## 🔐 Security & Privacy

### FCM Token Security

- Tokens are stored securely in Firestore
- Only accessible by authenticated users
- Tokens refresh automatically
- Old tokens are deleted on logout

### Notification Content

- No sensitive data in notification body
- Personal info only shown to relevant users
- Seller info only shown to buyers in chat
- Buyer info only shown to sellers

### Firestore Rules

```javascript
match /users/{userId} {
  allow read: if request.auth != null;
  allow update: if request.auth.uid == userId;
}
```

---

## 📊 Notification Analytics

### Metrics to Track

1. **Delivery Rate**
   - Notifications sent vs delivered
   - Failed deliveries

2. **Open Rate**
   - Notifications delivered vs opened
   - Time to open

3. **Engagement**
   - Actions taken after opening
   - Conversion rate

4. **Preferences**
   - Most disabled notification types
   - Most enabled notification types

---

## 🔧 Technical Implementation

### App Side (Flutter)

**Files:**
- `lib/main.dart` - Initialize notifications
- `lib/data/services/notification_service.dart` - Handle FCM
- `lib/presentation/controllers/auth_controller.dart` - Store token on login

**Key Functions:**
```dart
// Initialize on app start
NotificationService.initialize()

// Store token on login
NotificationService.storeFCMToken(userId)

// Handle foreground messages
FirebaseMessaging.onMessage.listen()

// Handle background messages
FirebaseMessaging.onMessageOpenedApp.listen()

// Handle terminated state
FirebaseMessaging.getInitialMessage()
```

---

### Backend Side (Cloud Functions)

**File:** `functions/index.js`

**Key Functions:**
```javascript
// Helper to send notification
sendNotificationToUser(userId, payload)

// Firestore triggers
onDocumentCreated('path', handler)
onDocumentUpdated('path', handler)

// Scheduled triggers
onSchedule({schedule, timeZone}, handler)
```

---

## 🧪 Testing Notifications

### Manual Test

1. **Get FCM Token:**
   - Check Firestore: `users/{userId}/fcmToken`

2. **Send Test from Console:**
   - Firebase Console → Cloud Messaging
   - Click "Send test message"
   - Paste FCM token
   - Send

3. **Verify Receipt:**
   - Check device receives notification
   - Tap notification
   - Verify navigation works

### Automated Test

1. **Message Test:**
   ```
   User A sends message to User B
   → User B should receive notification
   ```

2. **Listing Test:**
   ```
   Admin approves listing
   → Seller should receive notification
   ```

3. **Favorite Test:**
   ```
   User favorites listing
   → Seller should receive notification
   ```

---

## 🐛 Common Issues & Solutions

### Issue 1: No Notification Received

**Possible Causes:**
- No FCM token in Firestore
- Notification permissions not granted
- Internet connection issues
- Function not triggered

**Solution:**
1. Check FCM token exists
2. Check device permissions
3. Check function logs
4. Logout and login again

---

### Issue 2: Notification Received but No Navigation

**Possible Causes:**
- Navigation handler not implemented
- Invalid data in notification payload
- App state issues

**Solution:**
1. Check `_handleNotificationNavigation()` implementation
2. Verify notification data structure
3. Check app navigation setup

---

### Issue 3: Duplicate Notifications

**Possible Causes:**
- Multiple function triggers
- Token stored multiple times
- Background and foreground handlers both firing

**Solution:**
1. Check function logs for duplicates
2. Ensure token stored only once
3. Implement deduplication logic

---

## 📈 Performance Considerations

### Optimization Tips

1. **Batch Notifications:**
   - Group similar notifications
   - Send digest instead of individual

2. **Rate Limiting:**
   - Don't spam users
   - Implement cooldown periods

3. **Selective Sending:**
   - Only send to relevant users
   - Check preferences before sending

4. **Efficient Queries:**
   - Use indexes for Firestore queries
   - Limit query results

---

## 🎯 Best Practices

### For Developers

1. **Always check FCM token exists**
2. **Respect user preferences**
3. **Include relevant data in payload**
4. **Handle all notification states**
5. **Log errors for debugging**
6. **Test on real devices**

### For Users

1. **Grant notification permissions**
2. **Keep app updated**
3. **Check notification settings**
4. **Ensure internet connection**
5. **Report issues promptly**

---

## 📚 Summary

**Notification Flow:**
```
Event → Cloud Function → Firebase Messaging → Device → User
```

**Key Components:**
- Flutter app (receives notifications)
- Cloud Functions (sends notifications)
- Firebase Messaging (delivers notifications)
- Firestore (stores tokens and preferences)

**9 Notification Types:**
1. Messages
2. Listing approvals
3. Favorites
4. Welcome
5. Premium expiry
6. View milestones
7. New cars posted
8. Buyer inquiries
9. Daily digest

**User Control:**
- Can enable/disable each type
- Can manage in Settings
- Respects device permissions

---

**The notification system is fully automated and works seamlessly once set up!** 🎉
