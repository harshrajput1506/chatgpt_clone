import 'dart:async';
import 'package:chatgpt_clone/core/utils/failures.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/web.dart';

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

// Internal events
class _RecievedChunksEvent extends CurrentChatEvent {
  final String content;

  _RecievedChunksEvent(this.content);

  @override
  List<Object> get props => [content];
}

class _CompleteResponseEvent extends CurrentChatEvent {
  final String content;
  final String messageId;
  final bool? isNewChat;

  _CompleteResponseEvent(this.content, this.messageId, this.isNewChat);

  @override
  List<Object> get props => [messageId, content];
}

class _ErrorResponseEvent extends CurrentChatEvent {
  final String error;

  _ErrorResponseEvent(this.error);

  @override
  List<Object> get props => [error];
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
  final Logger _logger = Logger(printer: PrettyPrinter());
  StreamSubscription<Map<String, dynamic>>? _streamSubscription;

  CurrentChatBloc({required this.chatRepository})
    : super(CurrentChatInitial()) {
    on<LoadChatEvent>(_onLoadChat);
    on<SendMessageEvent>(_onSendMessage);
    on<RegenerateResponseEvent>(_onRegenerateResponse);
    on<StartNewChatEvent>(_onStartNewChat);
    on<GenerateChatTitleEvent>(_onGenerateChatTitle);
    on<UpdateChatTitleEvent>(_onUpdateChatTitle);

    // Internal events
    on<_RecievedChunksEvent>(_onRecievedChunks);
    on<_CompleteResponseEvent>(_onCompleteResponse);
    on<_ErrorResponseEvent>(_onErrorResponse);

    // Start listening to the response stream immediately
    _initializeStreamListener();
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

  Future<void> _startListeningToResponseStream(bool isNewChat) async {
    await chatRepository.closeExistingStream();
    _initializeStreamListener(isNewChat: isNewChat);
  }

  void _initializeStreamListener({bool? isNewChat}) {
    // Cancel existing subscription if any
    _streamSubscription?.cancel();

    _logger.i('Initializing stream listener for CurrentChatBloc');

    _streamSubscription = chatRepository.responseStream.listen(
      (response) {
        _logger.i('Received stream response: $response');
        if (state is CurrentChatLoaded) {
          final type = response['type'] as String;
          // chunks
          if (type == 'chunk') {
            final content = response['content'] as String;
            _logger.i('Processing chunk: $content');
            add(_RecievedChunksEvent(content));
          }

          // complete
          if (type == 'complete') {
            final content = response['content'] as String;
            final messageId = response['messageId'] as String;
            _logger.i(
              'Processing complete response with messageId: $messageId',
            );
            add(_CompleteResponseEvent(content, messageId, isNewChat));
          }
        }
      },
      onError: (error) {
        _logger.e('Stream error: $error');
        if (state is CurrentChatLoaded) {
          if (error is Failure) {
            add(_ErrorResponseEvent(error.message));
          } else {
            add(_ErrorResponseEvent('An unexpected error occurred: $error'));
          }
        }
      },
      onDone: () {
        _logger.i('Stream completed');
        // Stream completed successfully - we handle this in the complete event
      },
    );
  }

  Future<void> _onCompleteResponse(
    _CompleteResponseEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    _logger.i('Handling complete response with messageId: ${event.messageId}');

    if (state is CurrentChatLoaded) {
      final currentState = state as CurrentChatLoaded;
      final messages = List<Message>.from(
        currentState.messages,
      ); // Create a new list

      _logger.i('Current messages count: ${messages.length}');

      // Add a placeholder for the completed response
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        _logger.i(
          'Last message role: ${lastMessage.role}, isLoading: ${lastMessage.isLoading}',
        );

        if (lastMessage.role == MessageRole.assistant &&
            lastMessage.isLoading) {
          _logger.i(
            'Completing assistant message with final content length: ${event.content.length}',
          );
          final completedMessage = lastMessage.copyWith(
            isLoading: false,
            id: event.messageId,
            content: event.content,
          );
          messages[messages.length - 1] = completedMessage;
        }
      }

      _logger.i('Emitting final state with isResponding: false');
      emit(
        currentState.copyWith(
          chat: currentState.chat!.copyWith(messages: messages),
          isResponding: false,
          isRegenerating: false,
        ),
      );

      // Generate title for new chats
      if (event.isNewChat != null && event.isNewChat!) {
        add(GenerateChatTitleEvent());
      }
    }
  }

  Future<void> _onRecievedChunks(
    _RecievedChunksEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    _logger.i('Handling received chunks: "${event.content}"');

    if (state is CurrentChatLoaded) {
      final currentState = state as CurrentChatLoaded;
      final messages = List<Message>.from(
        currentState.messages,
      ); // Create a new list

      _logger.i('Current messages count: ${messages.length}');

      // Add the new chunk to the last message
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        _logger.i(
          'Last message role: ${lastMessage.role}, content length: ${lastMessage.content.length}',
        );

        if (lastMessage.role != MessageRole.assistant) {
          // If the last message is not from the assistant, create a new message
          _logger.i('Creating new assistant message');
          final newMessage = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: event.content,
            type: MessageType.text,
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
            isLoading: true,
          );
          messages.add(newMessage);
        } else {
          _logger.i(
            'Updating existing assistant message, new content length: ${lastMessage.content.length + event.content.length}',
          );
          final updatedMessage = lastMessage.copyWith(
            content: lastMessage.content + event.content,
            isLoading: true, // Keep loading state for the last message
          );
          messages[messages.length - 1] = updatedMessage;
        }
      }

      _logger.i('Emitting new state with ${messages.length} messages');
      emit(
        currentState.copyWith(
          chat: currentState.chat!.copyWith(messages: messages),
          isResponding: false, // Keep responding state while receiving chunks
          isRegenerating: false,
        ),
      );
    }
  }

  Future<void> _onErrorResponse(
    _ErrorResponseEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    emit(CurrentChatError(event.error));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    _logger.i('Sending message: "${event.message}"');

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

    _logger.i(
      'Emitting state with user message, total messages: ${updatedChat.messages.length}',
    );
    emit(currentState.copyWith(chat: updatedChat, isResponding: true));

    final isNewChat = currentState.isNewChat;

    _logger.i('Starting response stream listener');
    await _startListeningToResponseStream(isNewChat);

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
    final emptyMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '',
      type: MessageType.text,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    result.fold((failure) => emit(CurrentChatError(failure.message)), (
      responseChat,
    ) {
      _logger.i('Message sent successfully, chat ID: ${responseChat.id}');
      emit(
        finalState.copyWith(
          chat: finalState.chat!.copyWith(
            id: responseChat.id,
            messages: [
              ...finalState.messages,
              emptyMessage, // Placeholder for response
            ],
          ),
          isResponding: true,
        ),
      );
    });
  }

  Future<void> _onRegenerateResponse(
    RegenerateResponseEvent event,
    Emitter<CurrentChatState> emit,
  ) async {
    if (state is! CurrentChatLoaded) return;
    final currentState = state as CurrentChatLoaded;
    if (currentState.chat == null) return;

    // first delete the message till which we are regenerating
    final messages = List<Message>.from(currentState.messages);
    final messageIndex = messages.indexWhere((m) => m.id == event.messageId);
    if (messageIndex == -1) {
      emit(CurrentChatError('Message not found for regeneration'));
      return;
    }
    // Remove the message to regenerate
    messages.removeRange(messageIndex, messages.length);

    emit(
      currentState.copyWith(
        isRegenerating: true,
        chat: currentState.chat!.copyWith(messages: messages),
      ),
    );

    _logger.i('Regeneration started for message ID: ${event.messageId}');
    // Start listening to the response stream for regeneration
    await _startListeningToResponseStream(false);

    final result = await chatRepository.regenerateResponse(
      chatId: currentState.chat!.id,
      messageId: event.messageId,
      model: event.model,
    );

    result.fold((failure) => emit(CurrentChatError(failure.message)), (_) {});
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

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    chatRepository.dispose();
    return super.close();
  }
}
