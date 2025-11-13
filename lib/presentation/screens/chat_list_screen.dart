import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_providers.dart';
import '../controllers/auth_providers.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Use real-time stream for chat sessions
      ref.read(chatControllerProvider.notifier).watchChatSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: _buildBody(chatState, currentUserId),
    );
  }

  Widget _buildBody(chatState, String currentUserId) {
    if (chatState.isLoading && chatState.chatSessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading chats',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              chatState.error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(chatControllerProvider.notifier).loadChatSessions();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (chatState.chatSessions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(chatControllerProvider.notifier).loadChatSessions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chatState.chatSessions.length,
        itemBuilder: (context, index) {
          final session = chatState.chatSessions[index];
          final isCurrentUserBuyer = session.buyerId == currentUserId;
          final otherUserName =
              isCurrentUserBuyer ? session.sellerName : session.buyerName;
          final otherUserPhoto =
              isCurrentUserBuyer ? session.sellerPhotoUrl : session.buyerPhotoUrl;
          final hasUnread = session.lastMessageSenderId != currentUserId &&
              session.unreadCount > 0;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: hasUnread ? Colors.blue.withOpacity(0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: otherUserPhoto.isNotEmpty
                          ? CachedNetworkImageProvider(otherUserPhoto)
                          : null,
                      child: otherUserPhoto.isEmpty
                          ? Text(
                              otherUserName.isNotEmpty
                                  ? otherUserName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Online indicator (optional - can be enabled with real-time presence)
                  // Positioned(
                  //   right: 0,
                  //   bottom: 0,
                  //   child: Container(
                  //     width: 14,
                  //     height: 14,
                  //     decoration: BoxDecoration(
                  //       color: Colors.green,
                  //       shape: BoxShape.circle,
                  //       border: Border.all(color: Colors.white, width: 2),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              title: Row(
              children: [
                Expanded(
                  child: Text(
                    otherUserName,
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (session.lastMessageTime != null)
                  Text(
                    _formatTime(session.lastMessageTime!),
                    style: TextStyle(
                      fontSize: 12,
                      color: hasUnread
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[600],
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  session.listingTitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.lastMessage ?? 'No messages yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: hasUnread ? Colors.black87 : Colors.grey[700],
                          fontWeight:
                              hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasUnread)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            session.unreadCount > 99 ? '99+' : session.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                    chatSessionId: session.id,
                  ),
                ),
              );
            },
          ),
        );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Messages Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a conversation by contacting a seller on a listing.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Listings'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(time);
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
