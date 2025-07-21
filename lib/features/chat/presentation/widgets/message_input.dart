import 'package:chatgpt_clone/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:file_picker/file_picker.dart';

class MessageInput extends StatefulWidget {
  final Function(String, String) onSendMessage;
  final Function(String, String, String) onSendImage;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onSendImage,
    this.enabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Move these to be fields so their state persists and can be updated
  bool showModelChange = false; // Show model change when input is empty
  int selectedModelIndex = 0; // Default to first model

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var canSend = _controller.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: widget.enabled ? _pickImage : null,
                  icon: SvgPicture.asset(
                    'assets/icons/gallery.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  tooltip: 'Attach image',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        canSend
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8.0,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 150,
                            ), // add expand button later
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              enabled: widget.enabled,
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: 'Ask anything',
                                filled: false,
                                fillColor: colorScheme.surfaceContainer,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              cursorColor: colorScheme.onSurface,
                              onSubmitted: _sendMessage,
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  // show model change button
                                  setState(() {
                                    canSend = false;
                                  });
                                } else {
                                  // show send message button
                                  setState(() {
                                    canSend = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),

                      if (!canSend) ...[
                        GestureDetector(
                          onTap: () {
                            // Show model change options
                            setState(() {
                              showModelChange = !showModelChange;
                            });
                          },
                          child: Text(
                            AppConstants.availableModels[selectedModelIndex],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Show model change options
                            setState(() {
                              showModelChange = !showModelChange;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/model-control.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                colorScheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: () => _sendMessage(_controller.text),
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.inverseSurface,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/up-arrow.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                colorScheme.onInverseSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Show model chips
          if (showModelChange) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                AppConstants.availableModels.length,
                (index) => ChoiceChip(
                  label: Text(AppConstants.availableModels[index]),
                  selected: selectedModelIndex == index,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      selectedModelIndex = index;
                      showModelChange = false; // Hide after selection
                    });
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty || !widget.enabled) return;

    widget.onSendMessage(
      content.trim(),
      AppConstants.availableModels[selectedModelIndex] // Use selected model,
    );
    _controller.clear();
    _focusNode.requestFocus();
  }

  void _pickImage() async {
    // In a real app, you would use file_picker here
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.image,
    //   allowMultiple: false,
    // );

    // if (result != null && result.files.single.path != null) {
    //   widget.onSendImage(result.files.single.path!, 'Describe this image');
    // }

    // For demo purposes, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker would open here in a real implementation'),
      ),
    );
  }
}
