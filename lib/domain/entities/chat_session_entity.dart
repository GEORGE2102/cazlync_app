import 'package:equatable/equatable.dart';

class ChatSessionEntity extends Equatable {
  final String id;
  final String listingId;
  final String listingTitle;
  final String listingImageUrl;
  final double listingPrice;
  final String buyerId;
  final String buyerName;
  final String buyerPhotoUrl;
  final String sellerId;
  final String sellerName;
  final String sellerPhotoUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final String? lastMessageSenderId;
  final DateTime createdAt;

  const ChatSessionEntity({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.listingImageUrl,
    required this.listingPrice,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhotoUrl,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhotoUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.lastMessageSenderId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        listingId,
        listingTitle,
        listingImageUrl,
        listingPrice,
        buyerId,
        buyerName,
        buyerPhotoUrl,
        sellerId,
        sellerName,
        sellerPhotoUrl,
        lastMessage,
        lastMessageTime,
        unreadCount,
        lastMessageSenderId,
        createdAt,
      ];

  ChatSessionEntity copyWith({
    String? id,
    String? listingId,
    String? listingTitle,
    String? listingImageUrl,
    double? listingPrice,
    String? buyerId,
    String? buyerName,
    String? buyerPhotoUrl,
    String? sellerId,
    String? sellerName,
    String? sellerPhotoUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    String? lastMessageSenderId,
    DateTime? createdAt,
  }) {
    return ChatSessionEntity(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingImageUrl: listingImageUrl ?? this.listingImageUrl,
      listingPrice: listingPrice ?? this.listingPrice,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerPhotoUrl: buyerPhotoUrl ?? this.buyerPhotoUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhotoUrl: sellerPhotoUrl ?? this.sellerPhotoUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
