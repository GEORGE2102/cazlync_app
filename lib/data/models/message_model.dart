import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.chatSessionId,
    required super.senderId,
    required super.senderName,
    required super.text,
    required super.timestamp,
    super.isRead,
    super.imageUrl,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatSessionId: data['chatSessionId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatSessionId': chatSessionId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      chatSessionId: entity.chatSessionId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      text: entity.text,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
      imageUrl: entity.imageUrl,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      chatSessionId: chatSessionId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: timestamp,
      isRead: isRead,
      imageUrl: imageUrl,
    );
  }
}
