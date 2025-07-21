class ChatModel {
  final String id;
  final String title;
  final DateTime lastMessageTime;
  final List<String> messageIds;

  const ChatModel({
    required this.id,
    required this.title,
    required this.lastMessageTime,
    required this.messageIds,
  });

  ChatModel copyWith({
    String? id,
    String? title,
    DateTime? lastMessageTime,
    List<String>? messageIds,
  }) {
    return ChatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      messageIds: messageIds ?? this.messageIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'messageIds': messageIds,
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      title: json['title'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      messageIds: List<String>.from(json['messageIds']),
    );
  }
}
