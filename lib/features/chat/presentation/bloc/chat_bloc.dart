import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_event.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    // event handlers
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatsEvent>(_onLoadChats);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      type: MessageType.text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    // Emit the user message immediately
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(
        ChatLoaded(
          messages: [...currentState.messages, userMessage],
          isLoading: true,
        ),
      );
    } else {
      emit(ChatLoaded(messages: [userMessage], isLoading: true));
    }

    final result = await chatRepository.sendMessage(
      model: event.model,
      chatId: '123', // Replace with actual chat ID
      content: event.message,
    );

    if (state is! ChatLoaded) {
      emit(ChatError('Failed to respond.'));
      return;
    }
    final currentState = state as ChatLoaded;
    result.fold(
      (failure) {
        emit(
          ChatLoaded(
            messages: [...currentState.messages],
            errorMessage: failure.message,
          ),
        );
      },
      (message) {
        emit(ChatLoaded(messages: [...currentState.messages, message]));
      },
    );
  }

  Future<void> _onLoadChats(LoadChatsEvent event, Emitter<ChatState> emit) async {
    emit(ChatsLoading());
    final result = await chatRepository.getAllChats();
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chats) => emit(ChatsLoaded(chats)),
    );
  }
}
