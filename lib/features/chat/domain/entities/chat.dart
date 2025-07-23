import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final String title;
  final List<Message> messages;

  const Chat({
    required this.id,
    required this.title,
    this.messages = const [],
  });

  Chat copyWith({
    String? id,
    String? title,
    List<Message>? messages,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [id, title, messages];
}