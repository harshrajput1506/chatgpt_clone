import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class ChatUIState extends Equatable {
  final bool showModelChange;
  final bool showImagePickerOptions;
  final int selectedModelIndex;

  const ChatUIState({
    this.showModelChange = false,
    this.showImagePickerOptions = false,
    this.selectedModelIndex = 0,
  });

  ChatUIState copyWith({
    bool? showModelChange,
    bool? showImagePickerOptions,
    int? selectedModelIndex,
  }) {
    return ChatUIState(
      showModelChange: showModelChange ?? this.showModelChange,
      showImagePickerOptions:
          showImagePickerOptions ?? this.showImagePickerOptions,
      selectedModelIndex: selectedModelIndex ?? this.selectedModelIndex,
    );
  }

  @override
  List<Object> get props => [
    showModelChange,
    showImagePickerOptions,
    selectedModelIndex,
  ];
}

class ChatUICubit extends Cubit<ChatUIState> {
  ChatUICubit() : super(const ChatUIState());

  void toggleModelChange() {
    emit(
      state.copyWith(
        showModelChange: !state.showModelChange,
        showImagePickerOptions: false, // Close other menus
      ),
    );
  }

  void toggleImagePickerOptions() {
    emit(
      state.copyWith(
        showImagePickerOptions: !state.showImagePickerOptions,
        showModelChange: false, // Close other menus
      ),
    );
  }

  void selectModel(int index) {
    emit(
      state.copyWith(
        selectedModelIndex: index,
        showModelChange: false, // Close menu after selection
      ),
    );
  }

  void hideAllMenus() {
    emit(state.copyWith(showModelChange: false, showImagePickerOptions: false));
  }
}
