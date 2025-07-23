import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/chat_drawer.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool hasText = false; // Track if there's text in the search input
  var selectedChatIndex = -1; // Track selected chat index
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // Initialize the chat drawer and load chats
    BlocProvider.of<ChatBloc>(context).add(LoadChatsEvent());
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerScrimColor: Theme.of(context).colorScheme.scrim,
      drawer: ChatDrawer(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hasText: hasText,
        selectedChatIndex: selectedChatIndex,
        onValueChange: (value) {
          setState(() {
            hasText = value.isNotEmpty;
          });
          // Trigger search event
          BlocProvider.of<ChatBloc>(context).add(SearchChatEvent(value));
        },
        onClear: () {
          _searchController.clear();
          // Clear search results
          BlocProvider.of<ChatBloc>(context).add(SearchChatEvent(''));
          setState(() {
            hasText = false;
          });
        },
        onChatTap: (index, chatId) {
          setState(() {
            selectedChatIndex = index;
          });
          // Load the selected chat
          BlocProvider.of<ChatBloc>(context).add(LoadChatEvent(chatId: chatId));
        },
        onNewChat: () {
          // Start a new chat
          setState(() {
            selectedChatIndex = -1; // Reset selected chat index
          });
          BlocProvider.of<ChatBloc>(context).add(StartNewChatEvent());
        },
      ),
      body: SafeArea(
        child: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is ChatLoaded && state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          buildWhen: (previous, current) => current is ChatLoaded,
          builder: (context, state) {
            final messages =
                state is ChatLoaded
                    ? state.currentChat?.messages ?? []
                    : <Message>[];
            print('NewChatState: ${messages.isEmpty}');
            final isResponding =
                state is ChatLoaded && state.isResponding == true;
            final isChatLoading =
                state is ChatLoaded && state.isChatLoading == true;
            if (messages.isNotEmpty) {
              // Ensure the scroll position is at the bottom when loading
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
            return Column(
              children: [
                _buildAppBar(messages.isEmpty),
                Expanded(
                  child:
                      messages.isEmpty && !isChatLoading
                          ? _buildEmptyState()
                          : _buildMessageList(messages, isChatLoading),
                ),
                if (isResponding) _buildTypingIndicator(),
                MessageInput(
                  onSendMessage:
                      (content, model) => _sendMessage(context, content, model),
                  onSendImage:
                      (imagePath, caption, model) =>
                          _sendImageMessage(context, imagePath, caption),
                  enabled: !isResponding,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isNewChat) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // Open the chat drawer
            _scaffoldKey.currentState?.openDrawer();
          },
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
        const SizedBox(width: 4),
        Text(
          'ChatGPT',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        Spacer(),
        if (!isNewChat) ...[
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
            onPressed: () {
              // Start a new chat
              setState(() {
                selectedChatIndex = -1; // Reset selected chat index
              });
              BlocProvider.of<ChatBloc>(context).add(StartNewChatEvent());
            },
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
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Send a message to begin chatting',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
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
