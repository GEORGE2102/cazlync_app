import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_session_entity.dart';

class ChatSessionModel extends ChatSessionEntity {
  const ChatSessionModel({
    required super.id,
    required super.listingId,
    required super.listingTitle,
    required super.listingImageUrl,
    required super.listingPrice,
    required super.buyerId,
    required super.buyerName,
    required super.buyerPhotoUrl,
    required super.sellerId,
    required super.sellerName,
    required super.sellerPhotoUrl,
    super.lastMessage,
    super.lastMessageTime,
    super.unreadCount,
    super.lastMessageSenderId,
    required super.createdAt,
  });

  factory ChatSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSessionModel(
      id: doc.id,
      listingId: data['listingId'] ?? '',
      listingTitle: data['listingTitle'] ?? '',
      listingImageUrl: data['listingImageUrl'] ?? '',
      listingPrice: (data['listingPrice'] ?? 0).toDouble(),
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      buyerPhotoUrl: data['buyerPhotoUrl'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhotoUrl: data['sellerPhotoUrl'] ?? '',
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      unreadCount: data['unreadCount'] ?? 0,
      lastMessageSenderId: data['lastMessageSenderId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImageUrl': listingImageUrl,
      'listingPrice': listingPrice,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhotoUrl': buyerPhotoUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhotoUrl': sellerPhotoUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'unreadCount': unreadCount,
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatSessionModel.fromEntity(ChatSessionEntity entity) {
    return ChatSessionModel(
      id: entity.id,
      listingId: entity.listingId,
      listingTitle: entity.listingTitle,
      listingImageUrl: entity.listingImageUrl,
      listingPrice: entity.listingPrice,
      buyerId: entity.buyerId,
      buyerName: entity.buyerName,
      buyerPhotoUrl: entity.buyerPhotoUrl,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      sellerPhotoUrl: entity.sellerPhotoUrl,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      unreadCount: entity.unreadCount,
      lastMessageSenderId: entity.lastMessageSenderId,
      createdAt: entity.createdAt,
    );
  }

  ChatSessionEntity toEntity() {
    return ChatSessionEntity(
      id: id,
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
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      lastMessageSenderId: lastMessageSenderId,
      createdAt: createdAt,
    );
  }
}
