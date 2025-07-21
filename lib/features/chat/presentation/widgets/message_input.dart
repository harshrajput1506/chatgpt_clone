import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String, String) onSendImage;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: widget.enabled ? _pickImage : null,
              icon: const Icon(Icons.attach_file),
              tooltip: 'Attach image',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Send a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed:
                  widget.enabled && _controller.text.trim().isNotEmpty
                      ? () => _sendMessage(_controller.text)
                      : null,
              backgroundColor:
                  widget.enabled && _controller.text.trim().isNotEmpty
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainer,
              child: Icon(
                Icons.send,
                color:
                    widget.enabled && _controller.text.trim().isNotEmpty
                        ? Colors.white
                        : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty || !widget.enabled) return;

    widget.onSendMessage(content.trim());
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
