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
