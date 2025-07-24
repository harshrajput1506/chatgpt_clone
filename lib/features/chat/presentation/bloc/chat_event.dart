import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String model;

  SendMessageEvent(this.message, this.model);

  @override
  List<Object> get props => [message];
}

class LoadChatsEvent extends ChatEvent {
  @override
  List<Object> get props => [];
}

class LoadChatEvent extends ChatEvent {
  final String chatId;

  LoadChatEvent({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class GenerateChatTitleEvent extends ChatEvent {
  @override
  List<Object> get props => [];
}

class StartNewChatEvent extends ChatEvent {
  @override
  List<Object> get props => [];
}

class SearchChatEvent extends ChatEvent {
  final String query;

  SearchChatEvent(this.query);

  @override
  List<Object> get props => [query];
}

class DeleteChatEvent extends ChatEvent {
  final String chatId;

  DeleteChatEvent({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class UpdateChatTitleEvent extends ChatEvent {
  final String chatId;
  final String title;

  UpdateChatTitleEvent({required this.chatId, required this.title});

  @override
  List<Object> get props => [chatId, title];
}

class UpdateCurrentChatTitleEvent extends ChatEvent {
  final String title;

  UpdateCurrentChatTitleEvent(this.title);

  @override
  List<Object> get props => [title];
}
