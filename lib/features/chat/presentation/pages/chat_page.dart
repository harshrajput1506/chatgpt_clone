import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            final messages =
                state is ChatLoaded
                    ? List<Message>.from(state.messages)
                    : <Message>[];
            final isLoading = state is ChatLoaded && state.isLoading == true;
            if (messages.isNotEmpty) {
              // Ensure the scroll position is at the bottom when loading
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
            return Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child:
                      messages.isEmpty
                          ? _buildEmptyState()
                          : _buildMessageList(messages),
                ),
                if (isLoading) _buildTypingIndicator(),
                MessageInput(
                  onSendMessage:
                      (content, model) => _sendMessage(context, content, model),
                  onSendImage:
                      (imagePath, caption, model) =>
                          _sendImageMessage(context, imagePath, caption),
                  enabled: !isLoading,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'assets/icons/menu.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          'ChatGPT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Spacer(),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/edit.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {},
        ),
        IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'assets/icons/three-dots.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Send a message to begin chatting',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          message: message,
          onRetry:
              message.hasError
                  ? () => _retryMessage(context, message.id)
                  : null,
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        children: [
          Text('Responding...'),
          SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context, String content, String model) {
    if (content.trim().isEmpty) return;
    // You may want to pass the selected model from UI
    BlocProvider.of<ChatBloc>(context).add(SendMessageEvent(content, model));
    _scrollToBottom();
  }

  void _sendImageMessage(
    BuildContext context,
    String imagePath,
    String caption,
  ) {
    // Implement image message event if needed in ChatBloc
    // BlocProvider.of<ChatBloc>(context).add(SendImageMessageEvent(...));
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image message sending not implemented in Bloc.'),
      ),
    );
  }

  // _generateResponse removed: now handled by Bloc

  void _retryMessage(BuildContext context, String messageId) {
    // Implement retry event if needed in ChatBloc
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retry not implemented in Bloc.')),
    );
  }

  // void _regenerateLastResponse(BuildContext context) {
  //   // Implement regenerate event if needed in ChatBloc
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Regenerate not implemented in Bloc.')),
  //   );
  // }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
