import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore;

  ChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create or get existing chat session
  Future<String> createChatSession({
    required String listingId,
    required String listingTitle,
    required String listingImageUrl,
    required double listingPrice,
    required String buyerId,
    required String buyerName,
    required String buyerPhotoUrl,
    required String sellerId,
    required String sellerName,
    required String sellerPhotoUrl,
  }) async {
    // Check if session already exists
    final existingSession = await findChatSession(
      listingId: listingId,
      buyerId: buyerId,
      sellerId: sellerId,
    );

    if (existingSession != null) {
      return existingSession.id;
    }

    // Create new session
    final session = ChatSessionModel(
      id: '',
      listingId: listingId,
      listingTitle: listingTitle,
      listingImageUrl: listingImageUrl,
      listingPrice: listingPrice,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerPhotoUrl: buyerPhotoUrl,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhotoUrl: sellerPhotoUrl,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection('chatSessions')
        .add(session.toFirestore());

    return docRef.id;
  }

  // Find existing chat session
  Future<ChatSessionModel?> findChatSession({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    final snapshot = await _firestore
        .collection('chatSessions')
        .where('listingId', isEqualTo: listingId)
        .where('buyerId', isEqualTo: buyerId)
        .where('sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return ChatSessionModel.fromFirestore(snapshot.docs.first);
  }

  // Get chat session by ID
  Future<ChatSessionModel> getChatSession(String sessionId) async {
    final doc =
        await _firestore.collection('chatSessions').doc(sessionId).get();

    if (!doc.exists) {
      throw Exception('Chat session not found');
    }

    return ChatSessionModel.fromFirestore(doc);
  }

  // Get user's chat sessions
  Future<List<ChatSessionModel>> getUserChatSessions(String userId) async {
    final snapshot = await _firestore
        .collection('chatSessions')
        .where('buyerId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .get();

    final sellerSnapshot = await _firestore
        .collection('chatSessions')
        .where('sellerId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .get();

    final allDocs = [...snapshot.docs, ...sellerSnapshot.docs];
    
    // Remove duplicates and sort by last message time
    final uniqueSessions = <String, ChatSessionModel>{};
    for (final doc in allDocs) {
      final session = ChatSessionModel.fromFirestore(doc);
      if (!uniqueSessions.containsKey(session.id)) {
        uniqueSessions[session.id] = session;
      }
    }

    final sessions = uniqueSessions.values.toList();
    sessions.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return sessions;
  }

  // Watch user's chat sessions
  Stream<List<ChatSessionModel>> watchUserChatSessions(String userId) {
    return _firestore
        .collection('chatSessions')
        .where('buyerId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .asyncMap((buyerSnapshot) async {
      // Also get sessions where user is seller
      final sellerSnapshot = await _firestore
          .collection('chatSessions')
          .where('sellerId', isEqualTo: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final allDocs = [...buyerSnapshot.docs, ...sellerSnapshot.docs];
      
      // Remove duplicates
      final uniqueSessions = <String, ChatSessionModel>{};
      for (final doc in allDocs) {
        final session = ChatSessionModel.fromFirestore(doc);
        if (!uniqueSessions.containsKey(session.id)) {
          uniqueSessions[session.id] = session;
        }
      }

      final sessions = uniqueSessions.values.toList();
      sessions.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      return sessions;
    });
  }

  // Send message
  Future<String> sendMessage({
    required String chatSessionId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    final message = MessageModel(
      id: '',
      chatSessionId: chatSessionId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
      imageUrl: imageUrl,
    );

    // Add message to messages subcollection
    final docRef = await _firestore
        .collection('chatSessions')
        .doc(chatSessionId)
        .collection('messages')
        .add(message.toFirestore());

    // Update chat session with last message info
    await _firestore.collection('chatSessions').doc(chatSessionId).update({
      'lastMessage': text,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
      'lastMessageSenderId': senderId,
      'unreadCount': FieldValue.increment(1),
    });

    return docRef.id;
  }

  // Get messages
  Future<List<MessageModel>> getMessages(
    String chatSessionId, {
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection('chatSessions')
        .doc(chatSessionId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => MessageModel.fromFirestore(doc))
        .toList();
  }

  // Watch messages
  Stream<List<MessageModel>> watchMessages(String chatSessionId) {
    return _firestore
        .collection('chatSessions')
        .doc(chatSessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required String chatSessionId,
    required String userId,
  }) async {
    final session = await getChatSession(chatSessionId);
    
    // Only mark as read if the user is not the last message sender
    if (session.lastMessageSenderId == userId) {
      return;
    }

    // Get unread messages
    final messagesSnapshot = await _firestore
        .collection('chatSessions')
        .doc(chatSessionId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    // Mark all as read
    final batch = _firestore.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    // Reset unread count
    await _firestore.collection('chatSessions').doc(chatSessionId).update({
      'unreadCount': 0,
    });
  }

  // Get total unread count for user
  Future<int> getUnreadCount(String userId) async {
    final buyerSessions = await _firestore
        .collection('chatSessions')
        .where('buyerId', isEqualTo: userId)
        .get();

    final sellerSessions = await _firestore
        .collection('chatSessions')
        .where('sellerId', isEqualTo: userId)
        .get();

    int totalUnread = 0;
    
    for (final doc in [...buyerSessions.docs, ...sellerSessions.docs]) {
      final data = doc.data();
      final lastSenderId = data['lastMessageSenderId'];
      
      // Only count if the last message was not sent by this user
      if (lastSenderId != userId) {
        totalUnread += (data['unreadCount'] ?? 0) as int;
      }
    }

    return totalUnread;
  }
}
