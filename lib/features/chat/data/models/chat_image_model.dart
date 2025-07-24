import 'package:chatgpt_clone/features/chat/domain/entities/chat_image.dart';

class ChatImageModel extends ChatImage {
  const ChatImageModel({
    required super.id,
    required super.publicId,
    required super.originalName,
    required super.originalUrl,
    required super.urls,
  });

  factory ChatImageModel.fromJson(Map<String, dynamic> json) {
    return ChatImageModel(
      id: json['id'] as String,
      publicId: json['publicId'] as String,
      originalName: json['originalName'] as String,
      originalUrl: json['originalUrl'] as String,
      urls: json['urls'] as Map<String, String>,
    );
  }
}
