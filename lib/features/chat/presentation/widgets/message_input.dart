import 'package:chatgpt_clone/core/constants/app_constants.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat_image.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_ui_cubit.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/image_upload_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String, String) onSendMessage;
  final Function(String, String, ChatImage) onSendImageMessage;
  final Function(String) onTextChanged;
  final VoidCallback onShowModalSheet;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    required this.onSendImageMessage,
    required this.onTextChanged,
    this.enabled = true,
    required this.onShowModalSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/gallery.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: onShowModalSheet,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _buildInputRow()),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return BlocBuilder<ImageUploadBloc, ImageUploadState>(
      builder: (context, state) {
        if (state is ImageUploadSuccess) {
          return Container(
            margin: const EdgeInsets.all(8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    File(state.localPath),
                    height: 120,
                    width: 120,
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
            margin: const EdgeInsets.all(8),
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

  Widget _buildInputRow() {
    return BlocBuilder<ChatUICubit, ChatUIState>(
      builder: (context, uiState) {
        return BlocBuilder<ImageUploadBloc, ImageUploadState>(
          builder: (context, uploadState) {
            final theme = Theme.of(context);
            final hasInput = controller.text.trim().isNotEmpty;
            final selectedModel =
                AppConstants.availableModels[uiState.selectedModelIndex];
            final isUploading = uploadState is ImageUploadInProgress;
            final isDisabled = !enabled || isUploading;

            return Container(
              constraints: BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildImagePreview(),

                  Flexible(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            enabled: enabled,
                            onChanged: (value) {
                              onTextChanged(value);
                            },
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Ask anything',
                              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.normal,
                              ),
                              filled: false,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),

                        hasInput
                            ? InkWell(
                              onTap:
                                  !isDisabled
                                      ? () {
                                        _handleSend(
                                          context,
                                          selectedModel,
                                          uploadState,
                                        );
                                        controller.clear();
                                      }
                                      : null,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/up-arrow.svg',
                                    colorFilter: ColorFilter.mode(
                                      isDisabled
                                          ? theme.colorScheme.outlineVariant
                                          : theme.colorScheme.surface,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/model-control.svg',
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.onSurfaceVariant,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: onShowModalSheet,
                            ),
                      ],
                    ),
                  ),
                ],
              ),
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
