import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_state.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/options_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ChatDrawer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText; // Track if there's text in the input
  final int selectedChatIndex; // Track selected chat index
  final int deltetingChatIndex; // Track deleting chat index
  final int updatingChatIndex; // Track updating chat index
  final void Function(String) onValueChange;
  final VoidCallback onClear;
  final void Function(int, String) onChatTap;
  final VoidCallback onNewChat;
  final void Function(String, int, String) onRenameChat;
  final void Function(String, int) onDeleteChat;
  const ChatDrawer({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hasText = false,
    this.selectedChatIndex = -1,
    required this.onValueChange,
    required this.onClear,
    required this.onChatTap,
    required this.onNewChat,
    required this.onRenameChat,
    required this.onDeleteChat,
    this.deltetingChatIndex = -1,
    this.updatingChatIndex = -1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width:
          focusNode.hasFocus
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (value) => onValueChange(value),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        filled: false,
                        fillColor: theme.colorScheme.surfaceContainer,
                        prefixIcon: IconButton(
                          onPressed: () {
                            if (focusNode.hasFocus) {
                              focusNode.unfocus();
                            } else {
                              focusNode.requestFocus();
                            }
                          },
                          icon:
                              !focusNode.hasFocus
                                  ? SvgPicture.asset(
                                    'assets/icons/search.svg',
                                    colorFilter: ColorFilter.mode(
                                      theme.colorScheme.onSurface,
                                      BlendMode.srcIn,
                                    ),
                                  )
                                  : Icon(
                                    Icons.arrow_back_rounded,
                                    color: theme.colorScheme.onSurface,
                                  ),
                        ),
                        suffixIcon:
                            hasText
                                ? IconButton(
                                  icon: Icon(Icons.clear),
                                  color: theme.colorScheme.onSurface,
                                  onPressed: onClear,
                                )
                                : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // New chat button
                if (!hasText)
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/edit.svg',
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      onNewChat();
                      context.pop(); // Close the drawer
                    },
                  ),
                const SizedBox(width: 8),
              ],
            ),

            const SizedBox(height: 12),

            // Scroll view
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // new chat tile button
                    _buildChatTile(
                      context: context,
                      title: 'New Chat',
                      onTap: () {
                        onNewChat();
                        context.pop(); // Close the drawer
                      },
                      iconAssetPath: 'assets/icons/edit.svg',
                    ),

                    _buildChatTile(
                      context: context,
                      title: 'Chats',
                      onTap: () {}, // Placeholder for chats
                      iconAssetPath: 'assets/icons/chats.svg',
                    ),

                    // list of chats without icons only
                    BlocBuilder<ChatBloc, ChatState>(
                      buildWhen: (previous, current) {
                        return current is ChatLoaded;
                      },
                      builder: (context, state) {
                        if (state is ChatLoaded &&
                            state.isChatsLoading == false) {
                          final chats =
                              state.isSearching
                                  ? state.searchResults
                                  : state.chats;
                          return Column(
                            children:
                                chats.map((chat) {
                                  return _buildChatTile(
                                    context: context,
                                    title: chat.title,
                                    onTap: () {
                                      // Implement chat selection functionality
                                      onChatTap(
                                        state.chats.indexOf(chat),
                                        chat.id,
                                      );
                                      // Close the drawer
                                      context.pop();
                                    },
                                    onRenameChat: () {
                                      onRenameChat(
                                        chat.id,
                                        state.chats.indexOf(chat),
                                        chat.title,
                                      );
                                    },
                                    onDeleteChat: () {
                                      onDeleteChat(
                                        chat.id,
                                        state.chats.indexOf(chat),
                                      );
                                    },
                                    selected:
                                        selectedChatIndex ==
                                        state.chats.indexOf(chat),
                                    isUpdating:
                                        updatingChatIndex ==
                                            state.chats.indexOf(chat) ||
                                        deltetingChatIndex ==
                                            state.chats.indexOf(chat),
                                  );
                                }).toList(),
                          );
                        } else if (state is ChatLoaded &&
                            state.isChatsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    VoidCallback? onRenameChat,
    VoidCallback? onDeleteChat,
    String? iconAssetPath,
    bool selected = false,
    bool isUpdating = false,
  }) {
    final theme = Theme.of(context);
    final controller = MenuController();
    return OptionsMenu(
      menuController: controller,
      alignmentOffset: Offset(MediaQuery.of(context).size.width * 0.25, 0),
      menuItems: [
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
          onPressed: onRenameChat,
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
          onPressed: onDeleteChat,
          child: Text(
            'Delete',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ],
      child: Material(
        child: InkWell(
          onTap: onTap,
          onLongPress: () {
            if (controller.isOpen) {
              controller.close(); // Close if already open
            } else {
              controller.open(); // Open the menu on long press
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  selected
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Colors.transparent,
            ),
            child: Row(
              children: [
                if (iconAssetPath != null) ...[
                  SvgPicture.asset(
                    iconAssetPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          isUpdating
                              ? Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant.withAlpha(150)
                              : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
