import 'package:chatgpt_clone/features/chat/data/models/message_model.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required super.id,
    required super.title,
    super.messages = const [],
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      title: json['title'] as String,
      messages:
          json['messages'] == null
              ? []
              : (json['messages'] as List<dynamic>)
                  .map(
                    (message) =>
                        MessageModel.fromJson(message as Map<String, dynamic>),
                  )
                  .toList(),
    );
  }
}
