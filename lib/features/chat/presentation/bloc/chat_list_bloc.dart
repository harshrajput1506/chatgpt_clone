import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ChatListEvent extends Equatable {}

class LoadChatsEvent extends ChatListEvent {
  @override
  List<Object> get props => [];
}

class SearchChatsEvent extends ChatListEvent {
  final String query;

  SearchChatsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class DeleteChatEvent extends ChatListEvent {
  final String chatId;

  DeleteChatEvent({required this.chatId});

  @override
  List<Object> get props => [chatId];
}

class UpdateChatTitleEvent extends ChatListEvent {
  final String chatId;
  final String title;

  UpdateChatTitleEvent({required this.chatId, required this.title});

  @override
  List<Object> get props => [chatId, title];
}

class AddChatEvent extends ChatListEvent {
  final Chat chat;

  AddChatEvent(this.chat);

  @override
  List<Object> get props => [chat];
}

// States
abstract class ChatListState extends Equatable {}

class ChatListInitial extends ChatListState {
  @override
  List<Object> get props => [];
}

class ChatListLoading extends ChatListState {
  @override
  List<Object> get props => [];
}

class ChatListLoaded extends ChatListState {
  final List<Chat> chats;
  final List<Chat> searchResults;
  final bool isSearching;

  ChatListLoaded({
    required this.chats,
    this.searchResults = const [],
    this.isSearching = false,
  });

  ChatListLoaded copyWith({
    List<Chat>? chats,
    List<Chat>? searchResults,
    bool? isSearching,
    bool clearSearch = false,
  }) {
    return ChatListLoaded(
      chats: chats ?? this.chats,
      searchResults: clearSearch ? [] : (searchResults ?? this.searchResults),
      isSearching: clearSearch ? false : (isSearching ?? this.isSearching),
    );
  }

  List<Chat> get displayChats => isSearching ? searchResults : chats;

  @override
  List<Object> get props => [chats, searchResults, isSearching];
}

class ChatListError extends ChatListState {
  final String message;

  ChatListError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;

  ChatListBloc({required this.chatRepository}) : super(ChatListInitial()) {
    on<LoadChatsEvent>(_onLoadChats);
    on<SearchChatsEvent>(_onSearchChats);
    on<DeleteChatEvent>(_onDeleteChat);
    on<UpdateChatTitleEvent>(_onUpdateChatTitle);
    on<AddChatEvent>(_onAddChat);
  }

  Future<void> _onLoadChats(
    LoadChatsEvent event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    final result = await chatRepository.getAllChats();
    result.fold(
      (failure) => emit(ChatListError(failure.message)),
      (chats) => emit(ChatListLoaded(chats: chats)),
    );
  }

  void _onSearchChats(SearchChatsEvent event, Emitter<ChatListState> emit) {
    if (state is! ChatListLoaded) return;
    final currentState = state as ChatListLoaded;

    if (event.query.isEmpty) {
      emit(currentState.copyWith(clearSearch: true));
      return;
    }

    final filteredChats =
        currentState.chats
            .where(
              (chat) =>
                  chat.title.toLowerCase().contains(event.query.toLowerCase()),
            )
            .toList();

    emit(
      currentState.copyWith(searchResults: filteredChats, isSearching: true),
    );
  }

  Future<void> _onDeleteChat(
    DeleteChatEvent event,
    Emitter<ChatListState> emit,
  ) async {
    if (state is! ChatListLoaded) return;
    final currentState = state as ChatListLoaded;

    final result = await chatRepository.deleteChat(chatId: event.chatId);
    result.fold((failure) => emit(ChatListError(failure.message)), (_) {
      final updatedChats =
          currentState.chats.where((chat) => chat.id != event.chatId).toList();
      emit(currentState.copyWith(chats: updatedChats));
    });
  }

  Future<void> _onUpdateChatTitle(
    UpdateChatTitleEvent event,
    Emitter<ChatListState> emit,
  ) async {
    if (state is! ChatListLoaded) return;
    final currentState = state as ChatListLoaded;

    final result = await chatRepository.updateChatTitle(
      chatId: event.chatId,
      title: event.title,
    );
    result.fold((failure) => emit(ChatListError(failure.message)), (_) {
      final updatedChats =
          currentState.chats.map((chat) {
            if (chat.id == event.chatId) {
              return chat.copyWith(title: event.title);
            }
            return chat;
          }).toList();
      emit(currentState.copyWith(chats: updatedChats));
    });
  }

  void _onAddChat(AddChatEvent event, Emitter<ChatListState> emit) {
    if (state is! ChatListLoaded) return;
    final currentState = state as ChatListLoaded;
    if (currentState.chats.any((chat) => chat.id == event.chat.id)) {
      // If the chat already exists, we don't add it again
      // but checks the chat title and updates it if necessary
      final updatedChats =
          currentState.chats.map((chat) {
            if (chat.id == event.chat.id) {
              return chat.copyWith(title: event.chat.title);
            }
            return chat;
          }).toList();
      emit(currentState.copyWith(chats: updatedChats));
    } else {
      // If it's a new chat, we add it to the top of the list
      emit(currentState.copyWith(chats: [event.chat, ...currentState.chats]));
    }
  }
}
