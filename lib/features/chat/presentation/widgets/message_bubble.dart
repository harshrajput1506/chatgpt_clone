import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/presentation/widgets/options_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onRetry;

  const MessageBubble({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final controller = MenuController();
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);

    if (isUser &&
        message.type == MessageType.text &&
        message.content.isNotEmpty) {
      return OptionsMenu(
        menuController: controller,
        alignmentOffset: Offset(MediaQuery.of(context).size.width * 0.4, 0),
        menuItems: [
          MenuItemButton(
            leadingIcon: SvgPicture.asset(
              'assets/icons/copy.svg',
              width: 20,
              height: 20,
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
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
              ),
            ),
          ),

          MenuItemButton(
            leadingIcon: SvgPicture.asset(
              'assets/icons/file.svg',
              width: 20,
              height: 20,
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {},
            child: Text(
              'Select Text',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        child: InkWell(
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
                child: Container(
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
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: OptionsMenu(
          menuController: controller,
          alignmentOffset: Offset(
            MediaQuery.of(context).size.width * 0.2,
            -MediaQuery.of(context).size.height * 0.4,
          ),
          menuItems: [
            MenuItemButton(
              leadingIcon: SvgPicture.asset(
                'assets/icons/copy.svg',
                width: 20,
                height: 20,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface,
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
                ),
              ),
            ),

            MenuItemButton(
              leadingIcon: SvgPicture.asset(
                'assets/icons/file.svg',
                width: 20,
                height: 20,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {},
              child: Text(
                'Select Text',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            MenuItemButton(
              leadingIcon: SvgPicture.asset(
                'assets/icons/retry.svg',
                width: 16,
                height: 16,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {},
              child: Text(
                'Regenerate Response',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.content.isNotEmpty &&
                  message.role == MessageRole.assistant)
                //  MarkdownBody here
                Material(
                  child: InkWell(
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
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      name,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                  // copy button
                                  TextButton.icon(
                                    onPressed: () {
                                      // Copy code to clipboard
                                      Clipboard.setData(
                                        ClipboardData(text: code),
                                      );
                                    },
                                    label: Text(
                                      'Copy Code',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    icon: SvgPicture.asset(
                                      'assets/icons/clipboard.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width * 0.8,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      code,
                                      textAlign: TextAlign.left,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              if (message.hasError && onRetry != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Failed to send',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const Spacer(),
                    TextButton(onPressed: onRetry, child: const Text('Retry')),
                  ],
                ),
              ],

              // showing ai response options lile copy, regenerate
              if (message.role == MessageRole.assistant &&
                  !message.isLoading &&
                  !message.hasError) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (message.content.isNotEmpty)
                      InkWell(
                        onTap: () {
                          // Copy message content to clipboard
                          Clipboard.setData(
                            ClipboardData(text: message.content),
                          );
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
                      onTap: onRetry,
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
