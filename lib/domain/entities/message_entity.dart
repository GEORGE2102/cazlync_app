import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String chatSessionId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  const MessageEntity({
    required this.id,
    required this.chatSessionId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        chatSessionId,
        senderId,
        senderName,
        text,
        timestamp,
        isRead,
        imageUrl,
      ];

  MessageEntity copyWith({
    String? id,
    String? chatSessionId,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatSessionId: chatSessionId ?? this.chatSessionId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
