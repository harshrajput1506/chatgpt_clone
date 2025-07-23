import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_event.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ChatDrawer extends StatefulWidget {
  const ChatDrawer({super.key});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  var hasText = false; // Track if there's text in the input
  var selectedChatIndex = -1; // Track selected chat index

  @override
  void initState() {
    BlocProvider.of<ChatBloc>(context).add(LoadChatsEvent());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width:
          _focusNode.hasFocus
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
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged:
                          (value) => setState(() {
                            hasText = value.isNotEmpty;
                          }),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        filled: false,
                        fillColor: theme.colorScheme.surfaceContainer,
                        prefixIcon: IconButton(
                          onPressed: () {
                            if (_focusNode.hasFocus) {
                              _focusNode.unfocus();
                            } else {
                              _focusNode.requestFocus();
                            }
                          },
                          icon:
                              !_focusNode.hasFocus
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
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {
                                      hasText = false;
                                    });
                                  },
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
                      // New chat
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
                      onTap: () {},
                      iconAssetPath: 'assets/icons/edit.svg',
                    ),

                    _buildChatTile(
                      context: context,
                      title: 'Chats',
                      onTap: () {},
                      iconAssetPath: 'assets/icons/chats.svg',
                    ),

                    // list of chats without icons only 
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is ChatsLoaded) {
                          return Column(
                            children: state.chats.map((chat) {
                              if (chat.title.isEmpty) {
                                return _buildChatTile(
                                  context: context,
                                  title: 'New Chat',
                                  onTap: () {
                                    context.pop(); // Close the drawer
                                  },
                                  selected: true,
                                );
                              }
                              return _buildChatTile(
                                context: context,
                                title: chat.title,
                                onTap: () {
                                  // Implement chat selection functionality
                                  setState(() {
                                    selectedChatIndex = state.chats.indexOf(chat);
                                  });
                                  // Close the drawer
                                  context.pop();
                                },
                                selected: selectedChatIndex == state.chats.indexOf(chat),
                              );
                            }).toList(),
                          );
                        } else if (state is ChatsLoading) {
                          return const Center(child: CircularProgressIndicator());
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
    String? iconAssetPath,
    bool selected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
