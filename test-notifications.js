// Quick test script to check notification setup
// Run with: node test-notifications.js

const admin = require('firebase-admin');

// Initialize Firebase Admin (you'll need to add your service account key)
// Download from: Firebase Console → Project Settings → Service Accounts
// Save as: service-account-key.json

try {
  const serviceAccount = require('./service-account-key.json');
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  
  console.log('✅ Firebase Admin initialized');
} catch (error) {
  console.log('⚠️  Service account key not found');
  console.log('Download from: Firebase Console → Project Settings → Service Accounts');
  console.log('Save as: service-account-key.json in project root');
  process.exit(1);
}

async function checkNotificationSetup() {
  console.log('\n🔍 Checking Notification Setup...\n');
  
  try {
    // 1. Check if users have FCM tokens
    console.log('1️⃣ Checking FCM tokens in Firestore...');
    const usersSnapshot = await admin.firestore()
      .collection('users')
      .limit(10)
      .get();
    
    let usersWithTokens = 0;
    let totalUsers = usersSnapshot.size;
    
    usersSnapshot.forEach(doc => {
      const user = doc.data();
      if (user.fcmToken) {
        usersWithTokens++;
        console.log(`   ✅ User ${doc.id}: Has FCM token`);
      } else {
        console.log(`   ❌ User ${doc.id}: No FCM token`);
      }
    });
    
    console.log(`\n   Summary: ${usersWithTokens}/${totalUsers} users have FCM tokens\n`);
    
    // 2. Check deployed functions
    console.log('2️⃣ Checking deployed Cloud Functions...');
    console.log('   Go to: https://console.firebase.google.com');
    console.log('   Navigate to: Functions');
    console.log('   Expected functions:');
    console.log('   - sendMessageNotification');
    console.log('   - sendListingStatusNotification');
    console.log('   - checkPremiumExpiry');
    console.log('   - sendFavoriteNotification');
    console.log('   - sendWelcomeNotification');
    console.log('   - sendViewMilestoneNotification\n');
    
    // 3. Test sending a notification to first user with token
    const userWithToken = usersSnapshot.docs.find(doc => doc.data().fcmToken);
    
    if (userWithToken) {
      console.log('3️⃣ Testing notification send...');
      const token = userWithToken.data().fcmToken;
      
      const message = {
        notification: {
          title: '🧪 Test Notification',
          body: 'This is a test notification from CazLync. If you see this, notifications are working!',
        },
        data: {
          type: 'test',
          timestamp: new Date().toISOString(),
        },
        token: token,
      };
      
      try {
        const response = await admin.messaging().send(message);
        console.log(`   ✅ Test notification sent successfully!`);
        console.log(`   Message ID: ${response}`);
        console.log(`   Check the device for the notification.\n`);
      } catch (error) {
        console.log(`   ❌ Failed to send notification: ${error.message}\n`);
      }
    } else {
      console.log('3️⃣ No users with FCM tokens found');
      console.log('   → Users need to login to get FCM token\n');
    }
    
    // 4. Check notification settings
    console.log('4️⃣ Checking notification preferences...');
    usersSnapshot.forEach(doc => {
      const user = doc.data();
      const settings = user.notificationSettings || {};
      console.log(`   User ${doc.id}:`);
      console.log(`     Messages: ${settings.messages !== false ? '✅' : '❌'}`);
      console.log(`     Listings: ${settings.listings !== false ? '✅' : '❌'}`);
      console.log(`     Favorites: ${settings.favorites !== false ? '✅' : '❌'}`);
      console.log(`     Premium: ${settings.premium !== false ? '✅' : '❌'}`);
    });
    
    console.log('\n✅ Notification setup check complete!\n');
    
    // Summary
    console.log('📋 Summary:');
    if (usersWithTokens === 0) {
      console.log('   ⚠️  No users have FCM tokens');
      console.log('   → Users need to logout and login again');
    } else if (usersWithTokens < totalUsers) {
      console.log(`   ⚠️  Only ${usersWithTokens}/${totalUsers} users have FCM tokens`);
      console.log('   → Other users need to logout and login again');
    } else {
      console.log('   ✅ All users have FCM tokens');
    }
    
    console.log('\n📝 Next Steps:');
    console.log('   1. Deploy Cloud Functions: cd functions && firebase deploy --only functions');
    console.log('   2. Test by sending a message between users');
    console.log('   3. Check function logs: firebase functions:log');
    console.log('   4. Monitor in Firebase Console → Functions\n');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
  
  process.exit(0);
}

// Run the check
checkNotificationSetup();
