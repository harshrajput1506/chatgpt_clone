import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
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
    on<GenerateChatTitleEvent>(_onGenerateChatTitle);
    on<LoadChatEvent>(_onLoadChat);
    on<StartNewChatEvent>(_onStartNewChat);
    on<SearchChatEvent>(_onSearchChat);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    String? chatId;
    bool isNewChat = state is ChatInitial;
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
      chatId =
          currentState.currentChat != null &&
                  currentState.currentChat!.id.isNotEmpty
              ? currentState.currentChat!.id
              : null;
      emit(
        currentState.copyWith(
          currentChat:
              currentState.currentChat != null
                  ? currentState.currentChat!.copyWith(
                    messages: [
                      ...currentState.currentChat!.messages,
                      userMessage,
                    ],
                  )
                  : Chat(id: '', title: 'New Chat', messages: [userMessage]),
          isResponding: true,
        ),
      );
    } else {
      emit(
        ChatLoaded(
          currentChat: Chat(id: '', title: 'New Chat', messages: [userMessage]),
          isResponding: true,
        ),
      );
    }

    isNewChat = isNewChat || chatId == null || chatId.isEmpty;

    final result = await chatRepository.sendMessage(
      model: event.model,
      content: event.message,
      isNewChat: isNewChat,
      chatId: chatId ?? '',
    );

    if (state is! ChatLoaded) {
      emit(ChatError('Failed to respond.'));
      return;
    }
    final currentState = state as ChatLoaded;
    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            errorMessage: failure.message,
            isResponding: false,
          ),
        );
      },
      (chat) {
        emit(
          currentState.copyWith(
            currentChat: currentState.currentChat!.copyWith(
              id: chat.id,
              messages: [
                ...currentState.currentChat!.messages,
                ...chat.messages,
              ],
            ),
            isResponding: false,
          ),
        );
        if (isNewChat) {
          add(GenerateChatTitleEvent());
        }
      },
    );
  }

  Future<void> _onLoadChats(
    LoadChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) {
      emit(ChatLoaded(isChatsLoading: true));
    }
    final currentState = state as ChatLoaded;
    print('$currentState');
    emit(currentState.copyWith(isChatsLoading: true));
    final result = await chatRepository.getAllChats();
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chats) =>
          emit(currentState.copyWith(chats: chats, isChatsLoading: false)),
    );
  }

  Future<void> _onLoadChat(LoadChatEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) {
      emit(ChatLoaded(isChatLoading: true));
    }
    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(isChatLoading: true, clearCurrentChat: true));
    final result = await chatRepository.getChatHistory(chatId: event.chatId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chat) =>
          emit(currentState.copyWith(currentChat: chat, isChatLoading: false)),
    );
  }

  Future<void> _onGenerateChatTitle(
    GenerateChatTitleEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;
    if (currentState.currentChat == null ||
        currentState.currentChat!.id.isEmpty) {
      return;
    }

    final result = await chatRepository.generateChatTitle(
      chatId: currentState.currentChat!.id,
    );
    result.fold((failure) => emit(ChatError(failure.message)), (title) {
      final updatedChat = currentState.currentChat!.copyWith(title: title);
      emit(currentState.copyWith(currentChat: updatedChat));
    });
  }

  void _onStartNewChat(StartNewChatEvent event, Emitter<ChatState> emit) {
    // Reset the chat state to start a new chat
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(
        currentState.copyWith(
          isResponding: false,
          clearCurrentChat: true,
          isChatLoading: false,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(ChatLoaded());
    }
  }

  void _onSearchChat(SearchChatEvent event, Emitter<ChatState> emit) {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;
    if (event.query.isEmpty) {
      // If the search query is empty, reset to all chats
      emit(currentState.copyWith(isSearching: false, clearSearchResults: true));
      return;
    }
    final filteredChats =
        currentState.chats
            .where((chat) => chat.title.toLowerCase().contains(event.query))
            .toList();

    emit(
      currentState.copyWith(isSearching: true, searchResults: filteredChats),
    );
  }
}
