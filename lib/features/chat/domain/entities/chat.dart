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
  @override
  List<Object?> get props => [id, title, messages];
}