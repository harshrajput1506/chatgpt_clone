import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class CurrentChatEvent extends Equatable {}

class LoadChatEvent extends CurrentChatEvent {
  final String chatId;

  LoadChatEvent({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class SendMessageEvent extends CurrentChatEvent {
  final String message;
  final String model;
  final String? imageId;
  final String? imageUrl;

  SendMessageEvent(this.message, this.model, {this.imageId, this.imageUrl});

  @override
  List<Object?> get props => [message, model, imageId, imageUrl];
}

class RegenerateResponseEvent extends CurrentChatEvent {
  final String messageId;
  final String model;

  RegenerateResponseEvent({required this.messageId, required this.model});

  @override
  List<Object> get props => [messageId, model];
}

class StartNewChatEvent extends CurrentChatEvent {
  @override
  List<Object> get props => [];
}

class GenerateChatTitleEvent extends CurrentChatEvent {
  @override
  List<Object> get props => [];
}

class UpdateChatTitleEvent extends CurrentChatEvent {
  final String title;
  final String chatId;

  UpdateChatTitleEvent(this.title, this.chatId);

  @override
  List<Object> get props => [title, chatId];
}

// States
abstract class CurrentChatState extends Equatable {}

class CurrentChatInitial extends CurrentChatState {
  @override
  List<Object> get props => [];
}

class CurrentChatLoading extends CurrentChatState {
  @override
  List<Object> get props => [];
}

class CurrentChatLoaded extends CurrentChatState {
  final Chat? chat;
  final bool isResponding;
  final bool isRegenerating;

  CurrentChatLoaded({
    this.chat,
    this.isResponding = false,
    this.isRegenerating = false,
  });

  CurrentChatLoaded copyWith({
    Chat? chat,
    bool? isResponding,
    bool? isRegenerating,
    bool clearChat = false,
  }) {
    return CurrentChatLoaded(
      chat: clearChat ? null : (chat ?? this.chat),
      isResponding: isResponding ?? this.isResponding,
      isRegenerating: isRegenerating ?? this.isRegenerating,
    );
  }

  bool get isNewChat => chat == null || chat!.id.isEmpty;
  List<Message> get messages => chat?.messages ?? [];

  @override
  List<Object?> get props => [chat, isResponding, isRegenerating];
}

class CurrentChatError extends CurrentChatState {
  final String message;

  CurrentChatError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class CurrentChatBloc extends Bloc<CurrentChatEvent, CurrentChatState> {
  final ChatRepository chatRepository;

  CurrentChatBloc({required this.chatRepository})
    : super(CurrentChatInitial()) {
    on<LoadChatEvent>(_onLoadChat);
    on<SendMessageEvent>(_onSendMessage);
    on<RegenerateResponseEvent>(_onRegenerateResponse);
    on<StartNewChatEvent>(_onStartNewChat);
    on<GenerateChatTitleEvent>(_onGenerateChatTitle);
    on<UpdateChatTitleEvent>(_onUpdateChatTitle);
  }

  Future<void> _onLoadChat(
    LoadChatEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    emit(CurrentChatLoading());
    final result = await chatRepository.getChatHistory(chatId: event.chatId);
    result.fold(
      (failure) => emit(CurrentChatError(failure.message)),
      (chat) => emit(CurrentChatLoaded(chat: chat)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    final currentState =
        state is CurrentChatLoaded
            ? (state as CurrentChatLoaded)
            : CurrentChatLoaded();

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      type: MessageType.text,
      role: MessageRole.user,
      imageUrl: event.imageUrl,
      timestamp: DateTime.now(),
    );

    // Add user message and start responding
    final updatedChat =
        currentState.chat?.copyWith(
          messages: [...currentState.messages, userMessage],
        ) ??
        Chat(id: '', title: 'New Chat', messages: [userMessage]);

    emit(currentState.copyWith(chat: updatedChat, isResponding: true));

    final isNewChat = currentState.isNewChat;
    final result = await chatRepository.sendMessage(
      model: event.model,
      content: event.message,
      isNewChat: isNewChat,
      chatId: currentState.chat?.id ?? '',
      imageId: event.imageId,
    );

    final finalState =
        state is CurrentChatLoaded
            ? (state as CurrentChatLoaded)
            : currentState;

    result.fold((failure) => emit(CurrentChatError(failure.message)), (
      responseChat,
    ) {
      emit(
        finalState.copyWith(
          chat: finalState.chat!.copyWith(
            id: responseChat.id,
            messages: [...finalState.messages, ...responseChat.messages],
          ),
          isResponding: false,
        ),
      );

      // Generate title for new chats
      if (isNewChat) {
        add(GenerateChatTitleEvent());
      }
    });
  }

  Future<void> _onRegenerateResponse(
    RegenerateResponseEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    if (state is! CurrentChatLoaded) return;
    final currentState = state as CurrentChatLoaded;
    if (currentState.chat == null) return;

    emit(currentState.copyWith(isRegenerating: true));

    final result = await chatRepository.regenerateResponse(
      chatId: currentState.chat!.id,
      messageId: event.messageId,
      model: event.model,
    );

    result.fold(
      (failure) => emit(CurrentChatError(failure.message)),
      (regeneratedChat) => emit(
        currentState.copyWith(chat: regeneratedChat, isRegenerating: false),
      ),
    );
  }

  void _onStartNewChat(
    StartNewChatEvent event,
    Emitter<CurrentChatState> emit,
  ) {
    emit(CurrentChatLoaded());
  }

  Future<void> _onGenerateChatTitle(
    GenerateChatTitleEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    if (state is! CurrentChatLoaded) return;
    final currentState = state as CurrentChatLoaded;
    if (currentState.chat == null || currentState.chat!.id.isEmpty) return;

    final result = await chatRepository.generateChatTitle(
      chatId: currentState.chat!.id,
    );

    result.fold(
      (failure) => emit(CurrentChatError(failure.message)),
      (title) => emit(
        currentState.copyWith(chat: currentState.chat!.copyWith(title: title)),
      ),
    );
  }

  void _onUpdateChatTitle(
    UpdateChatTitleEvent event,
    Emitter<CurrentChatState> emit,
  ) {
    if (state is! CurrentChatLoaded) return;
    final currentState = state as CurrentChatLoaded;
    if (currentState.chat == null) return;

    if (event.chatId != currentState.chat!.id) return;

    emit(
      currentState.copyWith(
        chat: currentState.chat!.copyWith(title: event.title),
      ),
    );
  }
}
