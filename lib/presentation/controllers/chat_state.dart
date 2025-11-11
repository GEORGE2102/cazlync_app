import '../../domain/entities/chat_session_entity.dart';
import '../../domain/entities/message_entity.dart';

class ChatState {
  final List<ChatSessionEntity> chatSessions;
  final ChatSessionEntity? currentSession;
  final List<MessageEntity> messages;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  const ChatState({
    this.chatSessions = const [],
    this.currentSession,
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  ChatState copyWith({
    List<ChatSessionEntity>? chatSessions,
    ChatSessionEntity? currentSession,
    List<MessageEntity>? messages,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return ChatState(
      chatSessions: chatSessions ?? this.chatSessions,
      currentSession: currentSession ?? this.currentSession,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
