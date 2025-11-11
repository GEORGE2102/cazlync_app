# Deploy Firestore Indexes

The app requires composite indexes for chat functionality to work properly. Follow these steps to deploy them:

## Option 1: Deploy via Firebase CLI (Recommended)

1. Make sure you have Firebase CLI installed:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Initialize Firebase in your project (if not already done):
```bash
firebase init firestore
```

4. Deploy the indexes:
```bash
firebase deploy --only firestore:indexes
```

This will deploy the indexes defined in `firestore.indexes.json`.

## Option 2: Create Indexes Manually

If you prefer to create indexes manually or the CLI deployment fails, follow these steps:

### 1. Chat Sessions - Buyer Query Index
- Collection: `chatSessions`
- Fields:
  - `buyerId` (Ascending)
  - `lastMessageTime` (Descending)

### 2. Chat Sessions - Seller Query Index
- Collection: `chatSessions`
- Fields:
  - `sellerId` (Ascending)
  - `lastMessageTime` (Descending)

### 3. Messages - Timestamp Query Index
- Collection Group: `messages`
- Fields:
  - `chatSessionId` (Ascending)
  - `timestamp` (Ascending)

### 4. Messages - Read Status Query Index
- Collection Group: `messages`
- Fields:
  - `isRead` (Ascending)
  - `senderId` (Ascending)

### 5. Listings - Premium Query Index (Already exists)
- Collection: `listings`
- Fields:
  - `status` (Ascending)
  - `isPremium` (Descending)
  - `createdAt` (Descending)

## How to Create Indexes Manually

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Indexes**
4. Click **Create Index**
5. Enter the collection name and fields as specified above
6. Click **Create**

## Verify Indexes

After deployment, verify that all indexes are created:

1. Go to Firebase Console → Firestore Database → Indexes
2. Check that all indexes show status: **Enabled**
3. If any index shows **Building**, wait for it to complete

## Troubleshooting

### Index Creation Failed
- Check that you're logged into the correct Firebase project
- Verify that you have sufficient permissions
- Try creating the index manually through the console

### Messages Not Showing
1. Verify all indexes are **Enabled** in Firebase Console
2. Check Firestore Rules allow read/write access
3. Restart the app after indexes are created
4. Check the app logs for any Firestore errors

### Chat Sessions Not Loading
1. Ensure the `buyerId` and `sellerId` indexes are created
2. Verify that `lastMessageTime` field exists in your chat sessions
3. Check that the user is authenticated

## Testing

After deploying indexes, test the following:

1. **Send a message** - Should appear immediately in chat room
2. **View chat list** - Should show all conversations sorted by last message time
3. **Unread count** - Should update when new messages arrive
4. **Real-time updates** - Messages should appear without refreshing

## Index Build Time

- Small datasets (< 1000 documents): Usually instant
- Medium datasets (1000-10000 documents): 1-5 minutes
- Large datasets (> 10000 documents): 5-30 minutes

The app will show errors until indexes are fully built.
