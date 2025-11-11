import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/services/chat_service.dart';
import 'chat_controller.dart';
import 'chat_state.dart';

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final chatService = ChatService();
  final chatRepository = ChatRepositoryImpl(chatService: chatService);

  final controller = ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );

  // Watch chat sessions in real-time
  controller.watchChatSessions();

  return controller;
});

// Provider for unread count
final unreadCountProvider = Provider<int>((ref) {
  final state = ref.watch(chatControllerProvider);
  return state.unreadCount;
});
