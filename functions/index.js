const {onDocumentCreated, onDocumentUpdated} = require('firebase-functions/v2/firestore');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const {setGlobalOptions} = require('firebase-functions/v2');
const admin = require('firebase-admin');

admin.initializeApp();

// Set global options
setGlobalOptions({
  region: 'us-central1',
  maxInstances: 10,
});

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
    
    await admin.messaging().send({
      token: fcmToken,
      notification: payload.notification,
      data: payload.data,
    });
    console.log(`Notification sent to user ${userId}`);
    return true;
  } catch (error) {
    console.error(`Error sending notification to user ${userId}:`, error);
    return false;
  }
}

// Send notification when a new message is sent
exports.sendMessageNotification = onDocumentCreated(
  'chatSessions/{sessionId}/messages/{messageId}',
  async (event) => {
    try {
      const message = event.data.data();
      const sessionId = event.params.sessionId;
      
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
        },
        data: {
          type: 'new_message',
          chatSessionId: sessionId,
          senderId: senderId,
          listingId: session.listingId || '',
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
exports.sendListingStatusNotification = onDocumentUpdated(
  'listings/{listingId}',
  async (event) => {
    try {
      const before = event.data.before.data();
      const after = event.data.after.data();
      const listingId = event.params.listingId;
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
          },
          data: {
            type: 'listing_approved',
            listingId: listingId,
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
          },
          data: {
            type: 'listing_rejected',
            listingId: listingId,
          },
        };
      }
      
      // Listing sold/deleted by admin
      else if (before.status === 'active' && after.status === 'deleted') {
        payload = {
          notification: {
            title: '🚫 Listing Removed',
            body: `Your ${after.brand} ${after.model} listing has been removed.`,
          },
          data: {
            type: 'listing_removed',
            listingId: listingId,
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
exports.checkPremiumExpiry = onSchedule(
  {
    schedule: '0 9 * * *',
    timeZone: 'Africa/Lusaka',
  },
  async (event) => {
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
              },
              data: {
                type: 'premium_expiry',
                listingId: doc.id,
                daysLeft: daysLeft.toString(),
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
exports.sendFavoriteNotification = onDocumentUpdated(
  'users/{userId}',
  async (event) => {
    try {
      const before = event.data.before.data();
      const after = event.data.after.data();
      const userId = event.params.userId;
      
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
        if (sellerId === userId) continue;
        
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
          .doc(userId)
          .get();
        
        const userName = userDoc.exists 
          ? userDoc.data().displayName || 'Someone'
          : 'Someone';
        
        const payload = {
          notification: {
            title: '❤️ New Favorite!',
            body: `${userName} saved your ${listing.brand} ${listing.model} listing`,
          },
          data: {
            type: 'new_favorite',
            listingId: listingId,
            userId: userId,
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
exports.sendWelcomeNotification = onDocumentCreated(
  'users/{userId}',
  async (event) => {
    try {
      const user = event.data.data();
      const userId = event.params.userId;
      
      // Wait a bit for FCM token to be set
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      const payload = {
        notification: {
          title: '🎉 Welcome to CazLync!',
          body: `Hi ${user.displayName || 'there'}! Start browsing cars or post your first listing.`,
        },
        data: {
          type: 'welcome',
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
exports.sendViewMilestoneNotification = onDocumentUpdated(
  'listings/{listingId}',
  async (event) => {
    try {
      const before = event.data.before.data();
      const after = event.data.after.data();
      const listingId = event.params.listingId;
      
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
        },
        data: {
          type: 'view_milestone',
          listingId: listingId,
          views: reachedMilestone.toString(),
        },
      };
      
      await sendNotificationToUser(sellerId, payload);
      
      return null;
    } catch (error) {
      console.error('Error sending view milestone notification:', error);
      return null;
    }
  });

// Send notification to users when a new car is posted (latest cars)
exports.notifyNewCarPosted = onDocumentCreated(
  'listings/{listingId}',
  async (event) => {
    try {
      const listing = event.data.data();
      const listingId = event.params.listingId;
      
      // Only notify for active listings
      if (listing.status !== 'active') {
        console.log('Listing not active, skipping notification');
        return null;
      }
      
      // Get all users who have notifications enabled
      const usersSnapshot = await admin.firestore()
        .collection('users')
        .get();
      
      const notifications = [];
      
      for (const userDoc of usersSnapshot.docs) {
        const user = userDoc.data();
        const userId = userDoc.id;
        
        // Don't notify the seller
        if (userId === listing.sellerId) continue;
        
        // Check notification preferences
        const notificationSettings = user.notificationSettings || {};
        if (notificationSettings.newListings === false) continue;
        
        // Check if user has FCM token
        if (!user.fcmToken) continue;
        
        // Send notification
        const payload = {
          notification: {
            title: '🚗 New Car Posted!',
            body: `${listing.brand} ${listing.model} (${listing.year}) - ${listing.contactForPrice ? 'Contact for price' : 'K' + listing.price.toLocaleString()}`,
          },
          data: {
            type: 'new_listing',
            listingId: listingId,
            brand: listing.brand,
            model: listing.model,
          },
        };
        
        notifications.push(sendNotificationToUser(userId, payload));
      }
      
      await Promise.all(notifications);
      console.log(`Sent ${notifications.length} new car notifications`);
      
      return null;
    } catch (error) {
      console.error('Error sending new car notifications:', error);
      return null;
    }
  });

// Send notification to seller when buyer sends first message
exports.notifySellerNewBuyerMessage = onDocumentCreated(
  'chatSessions/{sessionId}/messages/{messageId}',
  async (event) => {
    try {
      const message = event.data.data();
      const sessionId = event.params.sessionId;
      
      // Get chat session
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
      
      // Only notify seller when buyer sends message
      if (senderId !== session.buyerId) {
        return null; // Seller sent message, don't notify
      }
      
      const sellerId = session.sellerId;
      
      // Check if this is the first message from buyer
      const messagesSnapshot = await admin.firestore()
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .where('senderId', '==', session.buyerId)
        .orderBy('timestamp', 'asc')
        .limit(2)
        .get();
      
      // If more than 1 message from buyer, not first message
      if (messagesSnapshot.size > 1) {
        return null;
      }
      
      // Get seller info
      const sellerDoc = await admin.firestore()
        .collection('users')
        .doc(sellerId)
        .get();
      
      if (!sellerDoc.exists) {
        console.log('Seller not found');
        return null;
      }
      
      const seller = sellerDoc.data();
      
      // Check notification preferences
      const notificationSettings = seller.notificationSettings || {};
      if (notificationSettings.messages === false) {
        console.log('Seller has disabled message notifications');
        return null;
      }
      
      // Get buyer info
      const buyerDoc = await admin.firestore()
        .collection('users')
        .doc(session.buyerId)
        .get();
      
      const buyerName = buyerDoc.exists 
        ? buyerDoc.data().displayName || 'A buyer'
        : 'A buyer';
      
      // Get listing info
      let listingInfo = '';
      if (session.listingId) {
        const listingDoc = await admin.firestore()
          .collection('listings')
          .doc(session.listingId)
          .get();
        
        if (listingDoc.exists) {
          const listing = listingDoc.data();
          listingInfo = ` about your ${listing.brand} ${listing.model}`;
        }
      }
      
      // Send notification
      const payload = {
        notification: {
          title: '💬 New Buyer Inquiry!',
          body: `${buyerName} is interested${listingInfo}: "${message.text.substring(0, 80)}${message.text.length > 80 ? '...' : ''}"`,
        },
        data: {
          type: 'buyer_message',
          chatSessionId: sessionId,
          buyerId: session.buyerId,
          listingId: session.listingId || '',
        },
      };
      
      await sendNotificationToUser(sellerId, payload);
      
      return null;
    } catch (error) {
      console.error('Error sending buyer message notification:', error);
      return null;
    }
  });

// Send daily digest of new cars to interested users
exports.sendDailyNewCarsDigest = onSchedule(
  {
    schedule: '0 18 * * *', // 6 PM daily
    timeZone: 'Africa/Lusaka',
  },
  async (event) => {
    try {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      
      // Get listings posted in last 24 hours
      const newListingsSnapshot = await admin.firestore()
        .collection('listings')
        .where('status', '==', 'active')
        .where('createdAt', '>=', yesterday)
        .get();
      
      if (newListingsSnapshot.empty) {
        console.log('No new listings in last 24 hours');
        return null;
      }
      
      const newListingsCount = newListingsSnapshot.size;
      
      // Get sample listings for the digest
      const sampleListings = newListingsSnapshot.docs
        .slice(0, 3)
        .map(doc => doc.data());
      
      // Get all users who want daily digests
      const usersSnapshot = await admin.firestore()
        .collection('users')
        .get();
      
      const notifications = [];
      
      for (const userDoc of usersSnapshot.docs) {
        const user = userDoc.data();
        const userId = userDoc.id;
        
        // Check notification preferences
        const notificationSettings = user.notificationSettings || {};
        if (notificationSettings.dailyDigest === false) continue;
        
        // Check if user has FCM token
        if (!user.fcmToken) continue;
        
        // Create digest message
        const listingsSummary = sampleListings
          .map(l => `${l.brand} ${l.model} (${l.year})`)
          .join(', ');
        
        const payload = {
          notification: {
            title: `🚗 ${newListingsCount} New Cars Today!`,
            body: `Check out: ${listingsSummary}${newListingsCount > 3 ? ` and ${newListingsCount - 3} more` : ''}`,
          },
          data: {
            type: 'daily_digest',
            count: newListingsCount.toString(),
          },
        };
        
        notifications.push(sendNotificationToUser(userId, payload));
      }
      
      await Promise.all(notifications);
      console.log(`Sent ${notifications.length} daily digest notifications`);
      
      return null;
    } catch (error) {
      console.error('Error sending daily digest:', error);
      return null;
    }
  });
