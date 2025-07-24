import 'package:chatgpt_clone/core/constants/app_constants.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat_image.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_ui_cubit.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/image_upload_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String, String) onSendMessage;
  final Function(String, String, ChatImage) onSendImageMessage;
  final Function(String) onTextChanged;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    required this.onSendImageMessage,
    required this.onTextChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          _buildImagePreview(),
          _buildModelSelector(),
          _buildImagePickerOptions(),
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return BlocBuilder<ImageUploadBloc, ImageUploadState>(
      builder: (context, state) {
        if (state is ImageUploadSuccess) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(state.localPath),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      context.read<ImageUploadBloc>().add(ClearImageEvent());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ImageUploadInProgress && state.localPath != null) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(state.localPath!),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildModelSelector() {
    return BlocBuilder<ChatUICubit, ChatUIState>(
      builder: (context, state) {
        if (!state.showModelChange) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            children:
                AppConstants.availableModels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final model = entry.value;
                  final isSelected = index == state.selectedModelIndex;

                  return ListTile(
                    title: Text(model),
                    leading: Radio<int>(
                      value: index,
                      groupValue: state.selectedModelIndex,
                      onChanged: (value) {
                        context.read<ChatUICubit>().selectModel(value!);
                      },
                    ),
                    onTap: () {
                      context.read<ChatUICubit>().selectModel(index);
                    },
                    selected: isSelected,
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOptions() {
    return BlocBuilder<ChatUICubit, ChatUIState>(
      builder: (context, state) {
        if (!state.showImagePickerOptions) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImagePickerButton(
                context,
                'Camera',
                'assets/icons/camera.svg',
                ImageSource.camera,
              ),
              _buildImagePickerButton(
                context,
                'Gallery',
                'assets/icons/gallery.svg',
                ImageSource.gallery,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerButton(
    BuildContext context,
    String label,
    String iconPath,
    ImageSource source,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        context.read<ImageUploadBloc>().add(PickImageEvent(source: source));
        context.read<ChatUICubit>().hideAllMenus();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow() {
    return BlocBuilder<ChatUICubit, ChatUIState>(
      builder: (context, uiState) {
        return BlocBuilder<ImageUploadBloc, ImageUploadState>(
          builder: (context, uploadState) {
            final theme = Theme.of(context);
            final hasText = controller.text.trim().isNotEmpty;
            final selectedModel =
                AppConstants.availableModels[uiState.selectedModelIndex];
            final isUploading = uploadState is ImageUploadInProgress;

            return Row(
              children: [
                // Model change button
                IconButton(
                  onPressed:
                      enabled && !isUploading
                          ? () =>
                              context.read<ChatUICubit>().toggleModelChange()
                          : null,
                  icon: SvgPicture.asset(
                    'assets/icons/model-control.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      uiState.showModelChange
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                // Image picker button
                IconButton(
                  onPressed:
                      enabled && !isUploading
                          ? () =>
                              context
                                  .read<ChatUICubit>()
                                  .toggleImagePickerOptions()
                          : null,
                  icon: SvgPicture.asset(
                    'assets/icons/image.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      uiState.showImagePickerOptions
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                // Text field
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 240, // Limit max height to ~5-6 lines
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: enabled && !isUploading,
                      onChanged: (value) {
                        onTextChanged(value);
                        // Hide menus when typing
                        if (value.isNotEmpty) {
                          context.read<ChatUICubit>().hideAllMenus();
                        }
                      },
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
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
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                IconButton(
                  onPressed:
                      (enabled && !isUploading && hasText) ||
                              (uploadState is ImageUploadSuccess)
                          ? () =>
                              _handleSend(context, selectedModel, uploadState)
                          : null,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          ((enabled && !isUploading && hasText) ||
                                  (uploadState is ImageUploadSuccess))
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/up-arrow.svg',
                      width: 16,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        ((enabled && !isUploading && hasText) ||
                                (uploadState is ImageUploadSuccess))
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
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

  void _handleSend(
    BuildContext context,
    String model,
    ImageUploadState uploadState,
  ) {
    final content = controller.text.trim();

    if (uploadState is ImageUploadSuccess) {
      // Send image message
      onSendImageMessage(content, model, uploadState.image);
    } else if (content.isNotEmpty) {
      // Send text message
      onSendMessage(content, model);
    }
  }
}
