import 'package:chatgpt_clone/core/constants/app_constants.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat_image.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/current_chat_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/image_upload_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_ui_cubit.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/chat_drawer.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/options_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_list_bloc.dart'
    as chat_list;
import 'package:chatgpt_clone/features/chat/presentation/bloc/current_chat_bloc.dart'
    as current_chat;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool hasText = false;
  var selectedChatIndex = -1;
  var deletetingChatIndex = -1;
  var updatingChatIndex = -1;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load chats on initialization
    context.read<ChatListBloc>().add(LoadChatsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerScrimColor: Theme.of(context).colorScheme.scrim,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildChatArea()),
            _buildTypingIndicators(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return BlocListener<ChatListBloc, ChatListState>(
      listener: (context, state) {
        // Reset loading indicators when operations complete (success or error)
        if (state is ChatListLoaded || state is ChatListError) {
          setState(() {
            deletetingChatIndex = -1;
            updatingChatIndex = -1;
          });
        }
      },
      child: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, chatListState) {
          return ChatDrawer(
            controller: _searchController,
            focusNode: _searchFocusNode,
            hasText: hasText,
            selectedChatIndex: selectedChatIndex,
            deletetingChatIndex: deletetingChatIndex,
            updatingChatIndex: updatingChatIndex,
            onValueChange: (value) {
              setState(() {
                hasText = value.isNotEmpty;
              });
              context.read<ChatListBloc>().add(SearchChatsEvent(value));
            },
            onClear: () {
              _searchController.clear();
              context.read<ChatListBloc>().add(SearchChatsEvent(''));
              setState(() {
                hasText = false;
              });
            },
            onChatTap: (index, chatId) {
              setState(() {
                selectedChatIndex = index;
              });
              context.read<CurrentChatBloc>().add(
                LoadChatEvent(chatId: chatId),
              );
              Navigator.of(context).pop();
            },
            onNewChat: () {
              setState(() {
                selectedChatIndex = -1;
              });
              context.read<CurrentChatBloc>().add(StartNewChatEvent());
              Navigator.of(context).pop();
            },
            onRenameChat: (chatId, index, title) {
              _showRenameDialog(chatId, index, title);
            },
            onDeleteChat: (chatId, index) {
              _showDeleteDialog(chatId, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<CurrentChatBloc, CurrentChatState>(
      builder: (context, state) {
        final isNewChat = state is CurrentChatLoaded && state.isNewChat;
        final chat = state is CurrentChatLoaded ? state.chat : null;

        return _AppBarWidget(
          isNewChat: isNewChat,
          chat: chat,
          onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          onNewChatTap: () {
            setState(() {
              selectedChatIndex = -1;
            });
            context.read<CurrentChatBloc>().add(StartNewChatEvent());
          },
          onRenameTap:
              chat != null
                  ? () => _showRenameDialog(chat.id, -1, chat.title)
                  : null,
          onDeleteTap:
              chat != null ? () => _showDeleteDialog(chat.id, -1) : null,
        );
      },
    );
  }

  Widget _buildChatArea() {
    return BlocBuilder<CurrentChatBloc, CurrentChatState>(
      builder: (context, state) {
        if (state is CurrentChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CurrentChatError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }

        if (state is CurrentChatLoaded) {
          final messages = state.messages;

          if (messages.isEmpty) {
            return _buildEmptyState();
          }

          // Auto-scroll to bottom when new messages arrive
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return MessageBubble(
                message: message,
                onRegenerate:
                    message.role == MessageRole.assistant && !message.hasError
                        ? () => _regenerateResponse(message.id)
                        : null,
              );
            },
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildTypingIndicators() {
    return BlocBuilder<CurrentChatBloc, CurrentChatState>(
      buildWhen: (previous, current) {
        if (previous is CurrentChatLoaded && current is CurrentChatLoaded) {
          return previous.isResponding != current.isResponding ||
              previous.isRegenerating != current.isRegenerating;
        }
        return true;
      },
      builder: (context, state) {
        if (state is CurrentChatLoaded) {
          if (state.isResponding) {
            return _buildIndicator('Responding...');
          }
          if (state.isRegenerating) {
            return _buildIndicator('Regenerating response...');
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageInput() {
    return BlocBuilder<ChatUICubit, ChatUIState>(
      builder: (context, uiState) {
        return BlocBuilder<ImageUploadBloc, ImageUploadState>(
          builder: (context, uploadState) {
            return BlocBuilder<CurrentChatBloc, CurrentChatState>(
              buildWhen: (previous, current) {
                if (previous is CurrentChatLoaded &&
                    current is CurrentChatLoaded) {
                  return previous.isResponding != current.isResponding ||
                      previous.isRegenerating != current.isRegenerating;
                }
                return true;
              },
              builder: (context, chatState) {
                final isDisabled =
                    chatState is CurrentChatLoaded &&
                    (chatState.isResponding || chatState.isRegenerating);

                return MessageInput(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  onTextChanged: (value) {
                    setState(() {
                      // Trigger rebuild for send button
                    });
                  },
                  onSendMessage:
                      (content, model) => _sendMessage(content, model),
                  onSendImageMessage:
                      (content, model, image) =>
                          _sendImageMessage(content, model, image),
                  enabled: !isDisabled,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'What can I help you with?',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(text),
          const SizedBox(width: 8),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content, String model) {
    if (content.trim().isEmpty) return;

    context.read<CurrentChatBloc>().add(SendMessageEvent(content, model));

    // Clear image after sending
    context.read<ImageUploadBloc>().add(ClearImageEvent());
    _messageController.clear();
    _messageFocusNode.requestFocus();
    _scrollToBottom();
  }

  void _sendImageMessage(String content, String model, ChatImage image) {
    context.read<CurrentChatBloc>().add(
      SendMessageEvent(
        content,
        model,
        imageId: image.id,
        imageUrl: image.originalUrl,
      ),
    );

    // Clear image after sending
    context.read<ImageUploadBloc>().add(ClearImageEvent());
    _messageController.clear();
    _messageFocusNode.requestFocus();
    _scrollToBottom();
  }

  void _regenerateResponse(String messageId) {
    final selectedModel =
        AppConstants.availableModels[context
            .read<ChatUICubit>()
            .state
            .selectedModelIndex];

    context.read<CurrentChatBloc>().add(
      RegenerateResponseEvent(messageId: messageId, model: selectedModel),
    );
  }

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

  void _showRenameDialog(String chatId, int index, String title) {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(text: title);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final enabled = titleController.text.isNotEmpty;
            return AlertDialog(
              title: Text(
                'New Chat Title',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              content: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter new chat title',
                ),
                autofocus: true,
                onChanged: (value) {
                  setDialogState(() {});
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed:
                      enabled
                          ? () {
                            // Update in both chat list and current chat
                            context.read<ChatListBloc>().add(
                              chat_list.UpdateChatTitleEvent(
                                chatId: chatId,
                                title: titleController.text,
                              ),
                            );

                            context.read<CurrentChatBloc>().add(
                              current_chat.UpdateChatTitleEvent(
                                titleController.text,
                              ),
                            );

                            Navigator.of(context).pop();
                            setState(() {
                              updatingChatIndex = index;
                            });
                          }
                          : null,
                  child: Text(
                    'Rename',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(String chatId, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chat'),
          content: const Text('Are you sure you want to delete this chat?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<ChatListBloc>().add(
                  DeleteChatEvent(chatId: chatId),
                );

                // If deleting current chat, start new chat
                final currentChatState = context.read<CurrentChatBloc>().state;
                if (currentChatState is CurrentChatLoaded &&
                    currentChatState.chat?.id == chatId) {
                  context.read<CurrentChatBloc>().add(StartNewChatEvent());
                }

                Navigator.of(context).pop();
                setState(() {
                  deletetingChatIndex = index;
                  selectedChatIndex = -1;
                });
              },
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Separate widget for app bar to optimize rebuilds
class _AppBarWidget extends StatelessWidget {
  final bool isNewChat;
  final Chat? chat;
  final VoidCallback onMenuTap;
  final VoidCallback onNewChatTap;
  final VoidCallback? onRenameTap;
  final VoidCallback? onDeleteTap;

  const _AppBarWidget({
    required this.isNewChat,
    required this.chat,
    required this.onMenuTap,
    required this.onNewChatTap,
    this.onRenameTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = MenuController();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
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
          const Spacer(),
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
              onPressed: onNewChatTap,
            ),
            OptionsMenu(
              menuController: controller,
              menuItems: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          chat?.title ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(color: theme.colorScheme.onSurfaceVariant),
                MenuItemButton(
                  leadingIcon: SvgPicture.asset(
                    'assets/icons/rename.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: onRenameTap,
                  child: Text(
                    'Rename',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MenuItemButton(
                  leadingIcon: SvgPicture.asset(
                    'assets/icons/delete.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.error,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: onDeleteTap,
                  child: Text(
                    'Delete',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
              child: IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
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
            ),
          ],
        ],
      ),
    );
  }
}
