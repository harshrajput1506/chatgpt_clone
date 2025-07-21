enum MessageType { text, image }

enum MessageRole { user, assistant }

class MessageModel {
  final String id;
  final String content;
  final MessageType type;
  final MessageRole role;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isLoading;
  final bool hasError;

  const MessageModel({
    required this.id,
    required this.content,
    required this.type,
    required this.role,
    required this.timestamp,
    this.imageUrl,
    this.isLoading = false,
    this.hasError = false,
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
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      role: MessageRole.values.firstWhere((e) => e.name == json['role']),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
      isLoading: json['isLoading'] ?? false,
      hasError: json['hasError'] ?? false,
    );
  }

  Map<String, dynamic> toOpenAIFormat() {
    if (type == MessageType.text) {
      return {'role': role.name, 'content': content};
    } else {
      return {
        'role': role.name,
        'content': [
          {'type': 'text', 'text': content},
          {
            'type': 'image_url',
            'image_url': {'url': imageUrl},
          },
        ],
      };
    }
  }
}
