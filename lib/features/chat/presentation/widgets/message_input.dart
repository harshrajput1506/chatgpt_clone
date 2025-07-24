import 'dart:io';

import 'package:chatgpt_clone/core/constants/app_constants.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:file_picker/file_picker.dart';

class MessageInput extends StatelessWidget {
  final Function(String, String) onSendMessage;
  final Function(String, String, ChatImage) onSendImageMessage;
  final bool enabled;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ChatImage? pickedImage;
  final String? pickedImagePath;
  final bool isImageUploading;
  final bool showModelChange;
  final int selectedModelIndex;
  final bool showImagePickerOptions;
  final VoidCallback onToggleModelChange;
  final Function(ImageSource) onPickImage;
  final VoidCallback onToggleImagePickerOptions;
  final Function(int) onModelSelected;
  final Function(String) onTextChanged;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.onSendImageMessage,
    required this.controller,
    required this.focusNode,
    required this.showModelChange,
    required this.selectedModelIndex,
    required this.onToggleModelChange,
    required this.onModelSelected,
    required this.onTextChanged,
    required this.onToggleImagePickerOptions,
    required this.showImagePickerOptions,
    required this.onPickImage,
    this.pickedImage,
    this.pickedImagePath,
    this.isImageUploading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    var canSend = controller.text.isNotEmpty;

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
                  onPressed: onToggleImagePickerOptions,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pickedImagePath != null) ...[
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  isImageUploading
                                      ? Center(
                                        child: CircularProgressIndicator(
                                          color: colorScheme.onSurface,
                                        ),
                                      )
                                      : Image.file(
                                        File(pickedImagePath!),
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                        ),
                      ],
                      Row(
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
                                  controller: controller,
                                  focusNode: focusNode,
                                  enabled: enabled,
                                  maxLines: null,
                                  textCapitalization:
                                      TextCapitalization.sentences,
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
                                  onChanged: onTextChanged,
                                ),
                              ),
                            ),
                          ),

                          if (!canSend) ...[
                            InkWell(
                              onTap: onToggleModelChange,
                              borderRadius: BorderRadius.circular(4),
                              child: Text(
                                AppConstants
                                    .availableModels[selectedModelIndex],
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: colorScheme.secondary),
                              ),
                            ),
                            InkWell(
                              onTap: onToggleModelChange,
                              borderRadius: BorderRadius.circular(24),
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
                            InkWell(
                              onTap: () {
                                if (isImageUploading) return;
                                if (pickedImage != null) {
                                  _onSendImageMessageMessage(
                                    pickedImage!,
                                    controller.text,
                                  );
                                } else {
                                  _sendMessage(controller.text);
                                }
                              },
                              borderRadius: BorderRadius.circular(24),
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
                    if (selected) {
                      onModelSelected(index);
                    }
                  },
                ),
              ),
            ),
          ],

          // Show image picker option
          if (showImagePickerOptions) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () => onPickImage(ImageSource.camera),
                  label: Text(
                    'Camera',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/camera.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                OutlinedButton.icon(
                  onPressed: () => onPickImage(ImageSource.gallery),
                  label: Text(
                    'Gallery',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/image.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _onSendImageMessageMessage(ChatImage image, String content) {
    if (content.trim().isEmpty || !enabled) return;

    onSendImageMessage(
      content.trim(),
      AppConstants.availableModels[selectedModelIndex], // Use selected model
      image,
    );
    controller.clear();
    focusNode.requestFocus();
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty || !enabled) return;

    onSendMessage(
      content.trim(),
      AppConstants.availableModels[selectedModelIndex], // Use selected model,
    );
    controller.clear();
    focusNode.requestFocus();
  }
}
