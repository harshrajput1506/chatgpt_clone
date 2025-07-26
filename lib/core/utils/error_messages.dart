class ErrorMessages {
  static const String networkError =
      'Please check your internet connection and try again.';
  static const String serverError =
      'Something went wrong. Please try again later.';
  static const String imageUploadError =
      'Failed to upload image. Please try again.';
  static const String imagePermissionError =
      'Permission needed to access photos.';
  static const String imageSizeError =
      'Image is too large. Please select a smaller image.';
  static const String invalidImageError = 'Please select a valid image file.';
  static const String messageError =
      'Failed to send message. Please try again.';
  static const String chatLoadError = 'Failed to load chat. Please try again.';
  static const String chatDeleteError =
      'Failed to delete chat. Please try again.';
  static const String chatUpdateError =
      'Failed to update chat. Please try again.';
  static const String generalError = 'Something went wrong. Please try again.';

  /// Converts technical error messages to user-friendly ones
  static String getUserFriendlyMessage(String technicalMessage) {
    final message = technicalMessage.toLowerCase();

    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('internet')) {
      return networkError;
    }

    if (message.contains('permission')) {
      return imagePermissionError;
    }

    if (message.contains('image') &&
        (message.contains('size') || message.contains('large'))) {
      return imageSizeError;
    }

    if (message.contains('image') &&
        (message.contains('type') ||
            message.contains('format') ||
            message.contains('invalid'))) {
      return invalidImageError;
    }

    if (message.contains('upload') && message.contains('image')) {
      return imageUploadError;
    }

    if (message.contains('message') || message.contains('send')) {
      return messageError;
    }

    if (message.contains('chat') && message.contains('load')) {
      return chatLoadError;
    }

    if (message.contains('chat') && message.contains('delete')) {
      return chatDeleteError;
    }

    if (message.contains('chat') && message.contains('update')) {
      return chatUpdateError;
    }

    if (message.contains('server') ||
        message.contains('500') ||
        message.contains('internal')) {
      return serverError;
    }

    return generalError;
  }
}
