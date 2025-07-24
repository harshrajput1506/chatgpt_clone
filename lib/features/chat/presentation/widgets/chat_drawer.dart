import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ChatDrawer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final int selectedChatIndex;
  final int deletetingChatIndex;
  final int updatingChatIndex;
  final Function(String) onValueChange;
  final VoidCallback onClear;
  final Function(int, String) onChatTap;
  final VoidCallback onNewChat;
  final Function(String, int, String) onRenameChat;
  final Function(String, int) onDeleteChat;

  const ChatDrawer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.selectedChatIndex,
    required this.deletetingChatIndex,
    required this.updatingChatIndex,
    required this.onValueChange,
    required this.onClear,
    required this.onChatTap,
    required this.onNewChat,
    required this.onRenameChat,
    required this.onDeleteChat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme),
            _buildSearchField(theme),
            _buildNewChatButton(theme),
            _buildChatsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Text(
            'Conversations',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onValueChange,
        decoration: InputDecoration(
          hintText: 'Search conversations',
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon:
              hasText
                  ? IconButton(
                    onPressed: onClear,
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNewChatButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onNewChat,
          icon: SvgPicture.asset(
            'assets/icons/edit.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          label: Text(
            'New Chat',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    return Expanded(
      child: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading chats',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatListBloc>().add(LoadChatsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatListLoaded) {
            final chats = state.displayChats;

            if (chats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.isSearching
                          ? 'No chats found'
                          : 'No conversations yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.isSearching
                          ? 'Try searching with different keywords'
                          : 'Start a new conversation to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final originalIndex = state.chats.indexOf(chat);
                final isSelected = selectedChatIndex == originalIndex;
                final isUpdating =
                    updatingChatIndex == originalIndex ||
                    deletetingChatIndex == originalIndex;

                return _ChatTile(
                  title: chat.title,
                  isSelected: isSelected,
                  isUpdating: isUpdating,
                  onTap: () => onChatTap(originalIndex, chat.id),
                  onRename:
                      () => onRenameChat(chat.id, originalIndex, chat.title),
                  onDelete: () => onDeleteChat(chat.id, originalIndex),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isUpdating;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ChatTile({
    required this.title,
    required this.isSelected,
    required this.isUpdating,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: isSelected ? theme.colorScheme.primary.withOpacity(0.3) : null,
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: isUpdating ? null : onTap,
        trailing:
            isUpdating
                ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                )
                : PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'rename':
                        onRename();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/rename.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.onSurface,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Rename', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/delete.svg',
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.error,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
      ),
    );
  }
}
