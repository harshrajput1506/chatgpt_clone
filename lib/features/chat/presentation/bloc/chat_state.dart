import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
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
  final Chat? currentChat;
  final List<Chat> chats;
  final String? errorMessage;
  final bool isResponding;
  final bool isChatsLoading;
  final bool isChatLoading;
  final bool isSearching;
  final List<Chat> searchResults;

  ChatLoaded({
    this.currentChat,
    this.isChatsLoading = false,
    this.isChatLoading = false,
    this.chats = const [],
    this.errorMessage,
    this.isResponding = false,
    this.isSearching = false,
    this.searchResults = const [],
  });

  ChatLoaded copyWith({
    Chat? currentChat,
    List<Chat>? chats,
    String? errorMessage,
    bool? isResponding,
    bool? isChatsLoading,
    bool? isChatLoading,
    bool clearCurrentChat = false,
    bool clearErrorMessage = false,
    bool clearSearchResults = false,
    List<Chat>? searchResults,
    bool? isSearching,
  }) {
    return ChatLoaded(
      currentChat: clearCurrentChat ? null : (currentChat ?? this.currentChat),
      chats: chats ?? this.chats,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isResponding: isResponding ?? this.isResponding,
      isChatsLoading: isChatsLoading ?? this.isChatsLoading,
      isChatLoading: isChatLoading ?? this.isChatLoading,
      isSearching: isSearching ?? this.isSearching,
      searchResults:
          clearSearchResults ? [] : (searchResults ?? this.searchResults),
    );
  }

  @override
  List<Object?> get props => [
    currentChat,
    chats,
    errorMessage,
    isResponding,
    isChatsLoading,
    isChatLoading,
    isSearching,
    searchResults,
  ];
}
