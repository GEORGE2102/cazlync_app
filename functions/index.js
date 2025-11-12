const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Helper function to send notification to user
async function sendNotificationToUser(userId, payload) {
  try {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();
    
    if (!userDoc.exists) {
      console.log(`User ${userId} not found`);
      return false;
    }
    
    const user = userDoc.data();
    const fcmToken = user.fcmToken;
    
    if (!fcmToken) {
      console.log(`User ${userId} has no FCM token`);
      return false;
    }
    
    await admin.messaging().sendToDevice(fcmToken, payload);
    console.log(`Notification sent to user ${userId}`);
    return true;
  } catch (error) {
    console.error(`Error sending notification to user ${userId}:`, error);
    return false;
  }
}

// Send notification when a new message is sent
exports.sendMessageNotification = functions.firestore
  .document('chatSessions/{sessionId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const message = snap.data();
      const sessionId = context.params.sessionId;
      
      // Get chat session to find recipient
      const sessionDoc = await admin.firestore()
        .collection('chatSessions')
        .doc(sessionId)
        .get();
      
      if (!sessionDoc.exists) {
        console.log('Chat session not found');
        return null;
      }
      
      const session = sessionDoc.data();
      const senderId = message.senderId;
      
      // Determine recipient (the other person in the chat)
      const recipientId = senderId === session.buyerId 
        ? session.sellerId 
        : session.buyerId;
      
      // Check if recipient has notifications enabled
      const recipientDoc = await admin.firestore()
        .collection('users')
        .doc(recipientId)
        .get();
      
      if (!recipientDoc.exists) {
        console.log('Recipient not found');
        return null;
      }
      
      const recipient = recipientDoc.data();
      
      // Check notification preferences
      const notificationSettings = recipient.notificationSettings || {};
      if (notificationSettings.messages === false) {
        console.log('Recipient has disabled message notifications');
        return null;
      }
      
      // Get sender info for better notification
      const senderDoc = await admin.firestore()
        .collection('users')
        .doc(senderId)
        .get();
      
      const senderName = senderDoc.exists 
        ? senderDoc.data().displayName || 'Someone'
        : 'Someone';
      
      // Send notification
      const payload = {
        notification: {
          title: `💬 ${senderName}`,
          body: message.text.length > 100 
            ? message.text.substring(0, 100) + '...' 
            : message.text,
          sound: 'default',
        },
        data: {
          type: 'new_message',
          chatSessionId: sessionId,
          senderId: senderId,
          listingId: session.listingId || '',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
      };
      
      await sendNotificationToUser(recipientId, payload);
      
      return null;
    } catch (error) {
      console.error('Error sending message notification:', error);
      return null;
    }
  });

// Send notification when listing status changes
exports.sendListingStatusNotification = functions.firestore
  .document('listings/{listingId}')
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      const listingId = context.params.listingId;
      const sellerId = after.sellerId;
      
      // Check notification preferences
      const sellerDoc = await admin.firestore()
        .collection('users')
        .doc(sellerId)
        .get();
      
      if (!sellerDoc.exists) {
        console.log('Seller not found');
        return null;
      }
      
      const seller = sellerDoc.data();
      const notificationSettings = seller.notificationSettings || {};
      
      if (notificationSettings.listings === false) {
        console.log('Seller has disabled listing notifications');
        return null;
      }
      
      let payload = null;
      
      // Listing approved
      if (before.status !== 'active' && after.status === 'active') {
        payload = {
          notification: {
            title: '✅ Listing Approved!',
            body: `Your ${after.brand} ${after.model} (${after.year}) is now live and visible to buyers!`,
            sound: 'default',
          },
          data: {
            type: 'listing_approved',
            listingId: listingId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        };
      }
      
      // Listing rejected
      else if (before.status !== 'rejected' && after.status === 'rejected') {
        const reason = after.rejectionReason || 'Please review our listing guidelines';
        payload = {
          notification: {
            title: '❌ Listing Rejected',
            body: `Your ${after.brand} ${after.model} listing was rejected. ${reason}`,
            sound: 'default',
          },
          data: {
            type: 'listing_rejected',
            listingId: listingId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        };
      }
      
      // Listing sold/deleted by admin
      else if (before.status === 'active' && after.status === 'deleted') {
        payload = {
          notification: {
            title: '🚫 Listing Removed',
            body: `Your ${after.brand} ${after.model} listing has been removed.`,
            sound: 'default',
          },
          data: {
            type: 'listing_removed',
            listingId: listingId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        };
      }
      
      if (payload) {
        await sendNotificationToUser(sellerId, payload);
      }
      
      return null;
    } catch (error) {
      console.error('Error sending listing status notification:', error);
      return null;
    }
  });

// Check for premium listing expiry (runs daily)
exports.checkPremiumExpiry = functions.pubsub
  .schedule('0 9 * * *') // Run at 9 AM every day (Zambian time)
  .timeZone('Africa/Lusaka')
  .onRun(async (context) => {
    try {
      const threeDaysFromNow = new Date();
      threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);
      
      // Find premium listings expiring in 3 days
      const expiringListings = await admin.firestore()
        .collection('listings')
        .where('isPremium', '==', true)
        .where('premiumExpiresAt', '<=', threeDaysFromNow)
        .where('premiumExpiresAt', '>', new Date())
        .get();
      
      const notifications = [];
      
      for (const doc of expiringListings.docs) {
        const listing = doc.data();
        const sellerId = listing.sellerId;
        
        // Check notification preferences
        const sellerDoc = await admin.firestore()
          .collection('users')
          .doc(sellerId)
          .get();
        
        if (sellerDoc.exists) {
          const seller = sellerDoc.data();
          const notificationSettings = seller.notificationSettings || {};
          
          if (notificationSettings.premium !== false) {
            const daysLeft = Math.ceil(
              (listing.premiumExpiresAt.toDate() - new Date()) / (1000 * 60 * 60 * 24)
            );
            
            const payload = {
              notification: {
                title: '⭐ Premium Listing Expiring Soon',
                body: `Your ${listing.brand} ${listing.model} premium listing expires in ${daysLeft} day${daysLeft > 1 ? 's' : ''}. Renew now to stay featured!`,
                sound: 'default',
              },
              data: {
                type: 'premium_expiry',
                listingId: doc.id,
                daysLeft: daysLeft.toString(),
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
              },
            };
            
            notifications.push(sendNotificationToUser(sellerId, payload));
          }
        }
      }
      
      await Promise.all(notifications);
      console.log(`Sent ${notifications.length} premium expiry notifications`);
      
      return null;
    } catch (error) {
      console.error('Error checking premium expiry:', error);
      return null;
    }
  });

// Send notification when someone favorites your listing
exports.sendFavoriteNotification = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      
      const beforeFavorites = before.favoriteListings || [];
      const afterFavorites = after.favoriteListings || [];
      
      // Check if a new favorite was added
      const newFavorites = afterFavorites.filter(id => !beforeFavorites.includes(id));
      
      if (newFavorites.length === 0) {
        return null;
      }
      
      // Get the listing details
      for (const listingId of newFavorites) {
        const listingDoc = await admin.firestore()
          .collection('listings')
          .doc(listingId)
          .get();
        
        if (!listingDoc.exists) continue;
        
        const listing = listingDoc.data();
        const sellerId = listing.sellerId;
        
        // Don't notify if user favorited their own listing
        if (sellerId === context.params.userId) continue;
        
        // Check notification preferences
        const sellerDoc = await admin.firestore()
          .collection('users')
          .doc(sellerId)
          .get();
        
        if (!sellerDoc.exists) continue;
        
        const seller = sellerDoc.data();
        const notificationSettings = seller.notificationSettings || {};
        
        if (notificationSettings.favorites === false) continue;
        
        // Get user who favorited
        const userDoc = await admin.firestore()
          .collection('users')
          .doc(context.params.userId)
          .get();
        
        const userName = userDoc.exists 
          ? userDoc.data().displayName || 'Someone'
          : 'Someone';
        
        const payload = {
          notification: {
            title: '❤️ New Favorite!',
            body: `${userName} saved your ${listing.brand} ${listing.model} listing`,
            sound: 'default',
          },
          data: {
            type: 'new_favorite',
            listingId: listingId,
            userId: context.params.userId,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
        };
        
        await sendNotificationToUser(sellerId, payload);
      }
      
      return null;
    } catch (error) {
      console.error('Error sending favorite notification:', error);
      return null;
    }
  });

// Send welcome notification to new users
exports.sendWelcomeNotification = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    try {
      const user = snap.data();
      const userId = context.params.userId;
      
      // Wait a bit for FCM token to be set
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      const payload = {
        notification: {
          title: '🎉 Welcome to CazLync!',
          body: `Hi ${user.displayName || 'there'}! Start browsing cars or post your first listing.`,
          sound: 'default',
        },
        data: {
          type: 'welcome',
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
      };
      
      await sendNotificationToUser(userId, payload);
      
      return null;
    } catch (error) {
      console.error('Error sending welcome notification:', error);
      return null;
    }
  });

// Send notification when listing gets a certain number of views
exports.sendViewMilestoneNotification = functions.firestore
  .document('listings/{listingId}')
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      
      const beforeViews = before.viewCount || 0;
      const afterViews = after.viewCount || 0;
      
      // Check for milestone views (50, 100, 500, 1000)
      const milestones = [50, 100, 500, 1000];
      const reachedMilestone = milestones.find(
        milestone => beforeViews < milestone && afterViews >= milestone
      );
      
      if (!reachedMilestone) {
        return null;
      }
      
      const sellerId = after.sellerId;
      
      // Check notification preferences
      const sellerDoc = await admin.firestore()
        .collection('users')
        .doc(sellerId)
        .get();
      
      if (!sellerDoc.exists) {
        return null;
      }
      
      const seller = sellerDoc.data();
      const notificationSettings = seller.notificationSettings || {};
      
      if (notificationSettings.listings === false) {
        return null;
      }
      
      const payload = {
        notification: {
          title: '🔥 Your Listing is Popular!',
          body: `Your ${after.brand} ${after.model} has reached ${reachedMilestone} views!`,
          sound: 'default',
        },
        data: {
          type: 'view_milestone',
          listingId: context.params.listingId,
          views: reachedMilestone.toString(),
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
      };
      
      await sendNotificationToUser(sellerId, payload);
      
      return null;
    } catch (error) {
      console.error('Error sending view milestone notification:', error);
      return null;
    }
  });
