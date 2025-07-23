import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.content,
    required super.type,
    required super.role,
    required super.timestamp,
    super.imageUrl,
    super.isLoading,
    super.hasError,
  });

  MessageModel copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageRole? role,
    DateTime? timestamp,
    String? imageUrl,
    bool? isLoading,
    bool? hasError,
  }) {
    return MessageModel(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'isLoading': isLoading,
      'hasError': hasError,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      type: json['imageId'] != null ? MessageType.image : MessageType.text,
      role: MessageRole.values.firstWhere((e) => e.name == json['sender']),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
      isLoading: json['isLoading'] ?? false,
      hasError: json['hasError'] ?? false,
    );
  }
}
