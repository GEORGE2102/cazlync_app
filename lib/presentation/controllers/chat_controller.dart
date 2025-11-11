import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import 'chat_state.dart';
import 'auth_providers.dart';

class ChatController extends StateNotifier<ChatState> {
  final ChatRepositoryImpl _chatRepository;
  final Ref _ref;

  ChatController({
    required ChatRepositoryImpl chatRepository,
    required Ref ref,
  })  : _chatRepository = chatRepository,
        _ref = ref,
        super(const ChatState());

  Future<void> loadChatSessions() async {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      state = state.copyWith(
        chatSessions: [],
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _chatRepository.getUserChatSessions(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (sessions) {
        state = state.copyWith(
          chatSessions: sessions,
          isLoading: false,
        );
      },
    );
  }

  Future<void> loadChatSession(String sessionId) async {
    final result = await _chatRepository.getChatSession(sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (session) {
        state = state.copyWith(currentSession: session);
      },
    );
  }

  Future<void> loadMessages(String chatSessionId) async {
    final result = await _chatRepository.getMessages(chatSessionId);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (messages) {
        state = state.copyWith(messages: messages);
      },
    );
  }

  Future<void> sendMessage({
    required String chatSessionId,
    required String text,
  }) async {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;
    final userName = authState.user?.displayName ?? 'User';

    if (userId == null) return;

    final result = await _chatRepository.sendMessage(
      chatSessionId: chatSessionId,
      senderId: userId,
      senderName: userName,
      text: text,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Message sent successfully
        // The real-time stream will update the messages
      },
    );
  }

  Future<void> markAsRead(String chatSessionId) async {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) return;

    await _chatRepository.markMessagesAsRead(
      chatSessionId: chatSessionId,
      userId: userId,
    );
  }

  Future<void> loadUnreadCount() async {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) return;

    final result = await _chatRepository.getUnreadCount(userId);

    result.fold(
      (failure) {
        // Silently fail for unread count
      },
      (count) {
        state = state.copyWith(unreadCount: count);
      },
    );
  }

  void watchChatSessions() {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;

    if (userId == null) return;

    _chatRepository.watchUserChatSessions(userId).listen((sessions) {
      state = state.copyWith(chatSessions: sessions);
    });
  }

  void watchMessages(String chatSessionId) {
    _chatRepository.watchMessages(chatSessionId).listen((messages) {
      state = state.copyWith(messages: messages);
    });
  }

  Future<String?> createChatSession({
    required String listingId,
    required String listingTitle,
    required String listingImageUrl,
    required double listingPrice,
    required String sellerId,
    required String sellerName,
    required String sellerPhotoUrl,
  }) async {
    final authState = _ref.read(authControllerProvider);
    final userId = authState.user?.id;
    final userName = authState.user?.displayName ?? 'User';
    final userPhoto = authState.user?.photoUrl ?? '';

    if (userId == null) return null;

    final result = await _chatRepository.createChatSessionWithDetails(
      listingId: listingId,
      listingTitle: listingTitle,
      listingImageUrl: listingImageUrl,
      listingPrice: listingPrice,
      buyerId: userId,
      buyerName: userName,
      buyerPhotoUrl: userPhoto,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhotoUrl: sellerPhotoUrl,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (sessionId) => sessionId,
    );
  }
}
