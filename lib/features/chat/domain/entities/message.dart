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

  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageRole? role,
    DateTime? timestamp,
    String? imageUrl,
    bool? isLoading,
    bool? hasError,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

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
