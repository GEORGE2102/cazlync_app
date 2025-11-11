import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chat_session_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  // Chat Session methods
  Future<Either<Failure, String>> createChatSession({
    required String listingId,
    required String buyerId,
    required String sellerId,
  });

  Future<Either<Failure, ChatSessionEntity>> getChatSession(String sessionId);

  Future<Either<Failure, ChatSessionEntity?>> findChatSession({
    required String listingId,
    required String buyerId,
    required String sellerId,
  });

  Future<Either<Failure, List<ChatSessionEntity>>> getUserChatSessions(
    String userId,
  );

  Stream<List<ChatSessionEntity>> watchUserChatSessions(String userId);

  // Message methods
  Future<Either<Failure, String>> sendMessage({
    required String chatSessionId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  });

  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String chatSessionId, {
    int limit = 50,
  });

  Stream<List<MessageEntity>> watchMessages(String chatSessionId);

  Future<Either<Failure, void>> markMessagesAsRead({
    required String chatSessionId,
    required String userId,
  });

  Future<Either<Failure, int>> getUnreadCount(String userId);
}
