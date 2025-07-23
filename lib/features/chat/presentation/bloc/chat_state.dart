import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {}

class ChatInitial extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final String? errorMessage;
  final bool isLoading;

  ChatLoaded({
    required this.messages,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [messages, errorMessage];
}

class ChatLoading extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatsLoading extends ChatState {
  @override
  List<Object> get props => [];
}

class ChatsLoaded extends ChatState {
  final List<Chat> chats;

  ChatsLoaded(this.chats);

  @override
  List<Object> get props => [chats];
}