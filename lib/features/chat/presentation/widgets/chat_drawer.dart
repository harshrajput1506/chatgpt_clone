import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/options_menu.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

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
      width:
          focusNode.hasFocus
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceDim,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(40),
            blurRadius: 8,
            offset: Offset(4, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchField(theme),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [_buildNewChatButton(theme), _buildChatsList()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onValueChange,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon:
                    focusNode.hasFocus
                        ? IconButton(
                          onPressed: () => focusNode.unfocus(),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                        : IconButton(
                          onPressed: () => focusNode.requestFocus(),

                          icon: SvgPicture.asset(
                            'assets/icons/search.svg',
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHigh,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (!hasText) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/edit.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onNewChat,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewChatButton(ThemeData theme) {
    return Column(
      children: [
        ListTile(
          leading: SvgPicture.asset(
            'assets/icons/edit.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          title: Text(
            'New Chat',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onSurface,
            ),
          ),
          onTap: onNewChat,
        ),

        ListTile(
          leading: SvgPicture.asset(
            'assets/icons/chats.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
          title: Text(
            'Chats',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatsList() {
    return BlocBuilder<ChatListBloc, ChatListState>(
      builder: (context, state) {
        if (state is ChatListLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                ShimmerLoading(
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ChatListError) {
          return Center(
            child: Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        if (state is ChatListLoaded) {
          final chats = state.displayChats;

          if (chats.isEmpty) {
            return Center(
              child: Text(
                'No chats found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final originalIndex = state.chats.indexOf(chat);
              final isSelected = selectedChatIndex == originalIndex;
              final isUpdating =
                  updatingChatIndex == originalIndex ||
                  deletetingChatIndex == originalIndex;

              return _ChatListItem(
                chat: chat,
                originalIndex: originalIndex,
                isSelected: isSelected,
                isUpdating: isUpdating,
                onChatTap: onChatTap,
                onRenameChat: onRenameChat,
                onDeleteChat: onDeleteChat,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ChatListItem extends StatefulWidget {
  final dynamic chat;
  final int originalIndex;
  final bool isSelected;
  final bool isUpdating;
  final Function(int, String) onChatTap;
  final Function(String, int, String) onRenameChat;
  final Function(String, int) onDeleteChat;

  const _ChatListItem({
    required this.chat,
    required this.originalIndex,
    required this.isSelected,
    required this.isUpdating,
    required this.onChatTap,
    required this.onRenameChat,
    required this.onDeleteChat,
  });

  @override
  State<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<_ChatListItem> {
  late final MenuController menuController;

  @override
  void initState() {
    super.initState();
    menuController = MenuController();
  }

  @override
  Widget build(BuildContext context) {
    return OptionsMenu(
      menuController: menuController,
      alignmentOffset: Offset(MediaQuery.of(context).size.width * 0.3, 0),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      menuItems: _buildChatMenuItems(
        context,
        onRenameTap:
            () => widget.onRenameChat(
              widget.chat.id,
              widget.originalIndex,
              widget.chat.title,
            ),
        onDeleteTap:
            () => widget.onDeleteChat(widget.chat.id, widget.originalIndex),
      ),
      child: Container(
        decoration: BoxDecoration(
          color:
              widget.isSelected ? Theme.of(context).colorScheme.outline : null,
        ),
        child: ListTile(
          title: Text(
            widget.chat.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color:
                  widget.isUpdating
                      ? Theme.of(context).colorScheme.outlineVariant
                      : Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onLongPress: () {
            if (!widget.isUpdating && !menuController.isOpen) {
              menuController.open();
            } else {
              menuController.close();
            }
          },
          onTap:
              !widget.isUpdating
                  ? () => widget.onChatTap(widget.originalIndex, widget.chat.id)
                  : null,
        ),
      ),
    );
  }

  List<Widget> _buildChatMenuItems(
    BuildContext context, {
    required VoidCallback onRenameTap,
    required VoidCallback onDeleteTap,
  }) {
    final theme = Theme.of(context);
    return [
      MenuItemButton(
        leadingIcon: SvgPicture.asset(
          'assets/icons/rename.svg',
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        onPressed: onRenameTap,
        child: Text(
          'Rename',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      MenuItemButton(
        leadingIcon: SvgPicture.asset(
          'assets/icons/delete.svg',
          width: 24,
          height: 24,
          fit: BoxFit.cover,
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
    ];
  }
}
