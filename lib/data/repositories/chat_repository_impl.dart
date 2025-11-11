import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../services/chat_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _chatService;

  ChatRepositoryImpl({required ChatService chatService})
      : _chatService = chatService;

  @override
  Future<Either<Failure, String>> createChatSession({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    try {
      // Note: This method needs listing details which should be passed from the UI
      // For now, we'll throw an error if called directly
      throw UnimplementedError(
        'Use createChatSessionWithDetails instead',
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> createChatSessionWithDetails({
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
    try {
      final sessionId = await _chatService.createChatSession(
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
      );
      return Right(sessionId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatSessionEntity>> getChatSession(
    String sessionId,
  ) async {
    try {
      final session = await _chatService.getChatSession(sessionId);
      return Right(session.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatSessionEntity?>> findChatSession({
    required String listingId,
    required String buyerId,
    required String sellerId,
  }) async {
    try {
      final session = await _chatService.findChatSession(
        listingId: listingId,
        buyerId: buyerId,
        sellerId: sellerId,
      );
      return Right(session?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatSessionEntity>>> getUserChatSessions(
    String userId,
  ) async {
    try {
      final sessions = await _chatService.getUserChatSessions(userId);
      return Right(sessions.map((s) => s.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ChatSessionEntity>> watchUserChatSessions(String userId) {
    return _chatService.watchUserChatSessions(userId).map(
          (sessions) => sessions.map((s) => s.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, String>> sendMessage({
    required String chatSessionId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final messageId = await _chatService.sendMessage(
        chatSessionId: chatSessionId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        imageUrl: imageUrl,
      );
      return Right(messageId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String chatSessionId, {
    int limit = 50,
  }) async {
    try {
      final messages = await _chatService.getMessages(
        chatSessionId,
        limit: limit,
      );
      return Right(messages.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String chatSessionId) {
    return _chatService.watchMessages(chatSessionId).map(
          (messages) => messages.map((m) => m.toEntity()).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String chatSessionId,
    required String userId,
  }) async {
    try {
      await _chatService.markMessagesAsRead(
        chatSessionId: chatSessionId,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final count = await _chatService.getUnreadCount(userId);
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
