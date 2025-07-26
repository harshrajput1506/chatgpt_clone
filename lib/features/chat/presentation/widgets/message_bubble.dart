import 'package:chatgpt_clone/config/routes.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/current_chat_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/options_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onRegenerate;

  const MessageBubble({super.key, required this.message, this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    if (isUser) {
      return _buildUserMessageBubble(context);
    }

    return BlocBuilder<CurrentChatBloc, CurrentChatState>(
      buildWhen: (previous, current) {
        return current is CurrentChatLoaded &&
            current.messages.isNotEmpty &&
            message.id == current.messages[current.messages.length - 1].id;
      },
      builder: (context, state) {
        return _buildAiMessageBubble(context);
      },
    );
  }

  Widget _buildUserMessageBubble(BuildContext context) {
    final controller = MenuController();
    final theme = Theme.of(context);
    if (message.content.isNotEmpty) {
      return OptionsMenu(
        menuController: controller,
        alignmentOffset: Offset(MediaQuery.of(context).size.width * 0.4, 0),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        menuItems: [
          MenuItemButton(
            leadingIcon: SvgPicture.asset(
              'assets/icons/copy.svg',
              width: 20,
              height: 20,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              // Copy message content to clipboard
              Clipboard.setData(ClipboardData(text: message.content));
            },
            child: Text(
              'Copy',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          MenuItemButton(
            leadingIcon: SvgPicture.asset(
              'assets/icons/file.svg',
              width: 20,
              height: 20,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              // Navigate to selectable page with message content
              context.push(
                AppRoutes.selectablePage,
                extra: {'content': message.content, 'role': message.role.name},
              );
            },
            child: Text(
              'Select Text',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
        child: InkWell(
          onTap: () => controller.close(),
          onLongPress: () {
            // Show options menu for user messages
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // display image if available
                    if (message.imageUrl != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: Image.network(
                            message.imageUrl!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Text(
                        message.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(220),
                        ),
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

    return const SizedBox.shrink();
  }

  Widget _buildAiMessageBubble(BuildContext context) {
    final controller = MenuController();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
      child: OptionsMenu(
        menuController: controller,
        alignmentOffset: Offset(
          MediaQuery.of(context).size.width * 0.2,
          -MediaQuery.of(context).size.height * 0.4,
        ),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        menuItems: _buildAiMenuItemsList(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.content.isNotEmpty &&
                message.role == MessageRole.assistant)
              //  MarkdownBody here
              Material(
                child: InkWell(
                  onTap: () => controller.close(),
                  onLongPress: () {
                    // Show options menu for assistant messages
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: GptMarkdown(
                    message.content,
                    codeBuilder: (context, name, code, closed) {
                      return _codeBuilder(context, name, code, closed);
                    },
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
    
            _buildAiMessageError(context),
    
            // showing ai response options lile copy, regenerate
            _buildAiResponseOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAiMessageError(BuildContext context) {
    final theme = Theme.of(context);
    if (message.hasError) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
            const SizedBox(width: 4),
            Text(
              'Failed to send',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAiResponseOptions(BuildContext context) {
    final theme = Theme.of(context);
    if (!message.isLoading && !message.hasError) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (message.content.isNotEmpty)
              InkWell(
                onTap: () {
                  // Copy message content to clipboard
                  Clipboard.setData(ClipboardData(text: message.content));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/icons/copy.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            InkWell(
              onTap: onRegenerate,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/icons/retry.svg',
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _codeBuilder(
    BuildContext context,
    String name,
    String code,
    bool closed,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // copy button
              TextButton.icon(
                onPressed: () {
                  // Copy code to clipboard
                  Clipboard.setData(ClipboardData(text: code));
                },
                label: Text(
                  'Copy Code',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: SvgPicture.asset(
                  'assets/icons/clipboard.svg',
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  code,
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAiMenuItemsList(BuildContext context) {
    final theme = Theme.of(context);
    return [
      MenuItemButton(
        leadingIcon: SvgPicture.asset(
          'assets/icons/copy.svg',
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {
          // Copy message content to clipboard
          Clipboard.setData(ClipboardData(text: message.content));
        },
        child: Text(
          'Copy',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),

      MenuItemButton(
        leadingIcon: SvgPicture.asset(
          'assets/icons/file.svg',
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {
          // Navigate to selectable page with message content

          context.push(
            AppRoutes.selectablePage,
            extra: {'content': message.content, 'role': message.role.name},
          );
        },
        child: Text(
          'Select Text',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),

      MenuItemButton(
        leadingIcon: SvgPicture.asset(
          'assets/icons/retry.svg',
          width: 16,
          height: 16,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        onPressed: onRegenerate,
        child: Text(
          'Regenerate Response',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    ];
  }
}
