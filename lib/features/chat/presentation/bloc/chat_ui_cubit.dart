import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class ChatUIState extends Equatable {
  final int selectedModelIndex;

  const ChatUIState({
    this.selectedModelIndex = 0,
  });

  ChatUIState copyWith({
    bool? showModelChange,
    bool? showImagePickerOptions,
    int? selectedModelIndex,
  }) {
    return ChatUIState(
      selectedModelIndex: selectedModelIndex ?? this.selectedModelIndex,
    );
  }

  @override
  List<Object> get props => [
    selectedModelIndex,
  ];
}

class ChatUICubit extends Cubit<ChatUIState> {
  ChatUICubit() : super(const ChatUIState());

  void selectModel(int index) {
    emit(
      state.copyWith(
        selectedModelIndex: index,
        showModelChange: false, // Close menu after selection
      ),
    );
  }

}
