# Install Firebase CLI - Windows Guide

## Method 1: Using npm (Recommended)

### Step 1: Install Node.js
1. Download Node.js from: https://nodejs.org/
2. Install the LTS version (includes npm)
3. Restart your terminal after installation

### Step 2: Install Firebase CLI
```powershell
npm install -g firebase-tools
```

### Step 3: Verify Installation
```powershell
firebase --version
```

### Step 4: Login to Firebase
```powershell
firebase login
```

### Step 5: Deploy Indexes
```powershell
firebase deploy --only firestore:indexes
```

## Method 2: Using Standalone Binary

### Step 1: Download Firebase CLI
1. Go to: https://firebase.tools/bin/win/instant/latest
2. Download the executable
3. Run the installer

### Step 2: Verify Installation
```powershell
firebase --version
```

### Step 3: Login and Deploy
```powershell
firebase login
firebase deploy --only firestore:indexes
```

## Method 3: Manual Index Creation (No CLI Required)

If you can't install Firebase CLI, create indexes manually through Firebase Console:

### Step 1: Go to Firebase Console
1. Open: https://console.firebase.google.com/
2. Select your project: **cazlync-app**

### Step 2: Navigate to Firestore Indexes
1. Click **Firestore Database** in left menu
2. Click **Indexes** tab at the top

### Step 3: Create Each Index

#### Index 1: Chat Sessions - Buyer Query
- Click **Create Index**
- Collection ID: `chatSessions`
- Fields to index:
  - Field: `buyerId`, Order: `Ascending`
  - Field: `lastMessageTime`, Order: `Descending`
- Query scope: `Collection`
- Click **Create**

#### Index 2: Chat Sessions - Seller Query
- Click **Create Index**
- Collection ID: `chatSessions`
- Fields to index:
  - Field: `sellerId`, Order: `Ascending`
  - Field: `lastMessageTime`, Order: `Descending`
- Query scope: `Collection`
- Click **Create**

#### Index 3: Messages - Timestamp Query
- Click **Create Index**
- Collection ID: `messages`
- Fields to index:
  - Field: `chatSessionId`, Order: `Ascending`
  - Field: `timestamp`, Order: `Ascending`
- Query scope: `Collection group`
- Click **Create**

#### Index 4: Messages - Read Status Query
- Click **Create Index**
- Collection ID: `messages`
- Fields to index:
  - Field: `isRead`, Order: `Ascending`
  - Field: `senderId`, Order: `Ascending`
- Query scope: `Collection group`
- Click **Create**

#### Index 5: Listings - Premium Query (May already exist)
- Click **Create Index**
- Collection ID: `listings`
- Fields to index:
  - Field: `status`, Order: `Ascending`
  - Field: `isPremium`, Order: `Descending`
  - Field: `createdAt`, Order: `Descending`
- Query scope: `Collection`
- Click **Create**

### Step 4: Wait for Indexes to Build
- Each index will show "Building" status
- Wait until all show "Enabled" status
- This can take 5-30 minutes depending on data size

### Step 5: Verify Indexes
Check that you have these indexes enabled:
- ✅ chatSessions (buyerId, lastMessageTime)
- ✅ chatSessions (sellerId, lastMessageTime)
- ✅ messages (chatSessionId, timestamp) - Collection group
- ✅ messages (isRead, senderId) - Collection group
- ✅ listings (status, isPremium, createdAt)

## Troubleshooting

### "npm is not recognized"
- Node.js is not installed or not in PATH
- Download and install from: https://nodejs.org/
- Restart terminal after installation

### "Permission denied" when installing
Run PowerShell as Administrator:
```powershell
npm install -g firebase-tools
```

### Firebase login opens browser but doesn't work
Try:
```powershell
firebase login --no-localhost
```

### Can't install anything
Use **Method 3: Manual Index Creation** - no installation required!

## Quick Check

After installation, verify:
```powershell
# Check Node.js
node --version

# Check npm
npm --version

# Check Firebase CLI
firebase --version
```

All should show version numbers.

## Next Steps

Once Firebase CLI is installed OR indexes are created manually:

1. Restart your app:
   ```powershell
   flutter run
   ```

2. Test chat messages - they should now appear in real-time!

## Need Help?

If you're having trouble:
1. Use **Method 3: Manual Index Creation** - it's the easiest
2. Just go to Firebase Console and create indexes through the UI
3. No command line tools needed!
