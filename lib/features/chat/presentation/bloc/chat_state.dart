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
  final bool hasUpdatedTitle;
  final bool hasDeletedChat;
  final bool isRegenerating;
  final bool isImageLoading;
  final String? selectedImagePath;
  final String? selectedImageId;
  final List<Chat> searchResults;
  final String? error;
  ChatLoaded({
    this.currentChat,
    this.isChatsLoading = false,
    this.isChatLoading = false,
    this.chats = const [],
    this.errorMessage,
    this.isResponding = false,
    this.isSearching = false,
    this.hasUpdatedTitle = false,
    this.hasDeletedChat = false,
    this.isRegenerating = false,
    this.isImageLoading = false,
    this.selectedImagePath,
    this.selectedImageId,
    this.searchResults = const [],
    this.error,
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
    bool? hasUpdatedTitle,
    bool? hasDeletedChat,
    bool? isRegenerating,
    bool? isImageLoading,
    String? selectedImagePath,
    String? selectedImageId,
    bool clearSelectedImage = false,
    String? error,
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
      hasUpdatedTitle: hasUpdatedTitle ?? this.hasUpdatedTitle,
      hasDeletedChat: hasDeletedChat ?? this.hasDeletedChat,
      isRegenerating: isRegenerating ?? this.isRegenerating,
      isImageLoading: isImageLoading ?? this.isImageLoading,
      error: error ?? this.error,
      selectedImagePath:
          clearSelectedImage
              ? null
              : (selectedImagePath ?? this.selectedImagePath),
      selectedImageId:
          clearSelectedImage ? null : (selectedImageId ?? this.selectedImageId),
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
    hasUpdatedTitle,
    hasDeletedChat,
    isRegenerating,
    error,
    isImageLoading,
  ];
}
