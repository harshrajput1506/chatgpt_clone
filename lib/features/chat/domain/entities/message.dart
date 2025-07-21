import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final MessageRole role;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isLoading;
  final bool hasError;

  const Message({
    required this.id,
    required this.content,
    required this.type,
    required this.role,
    required this.timestamp,
    this.imageUrl,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    type,
    role,
    timestamp,
    imageUrl,
    isLoading,
    hasError,
  ];
}

enum MessageType { text, image }

enum MessageRole { user, assistant }
