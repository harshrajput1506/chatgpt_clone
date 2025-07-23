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

