import 'package:chatgpt_clone/core/utils/failures.dart';
import 'package:chatgpt_clone/core/utils/permission_helper.dart';
import 'package:chatgpt_clone/core/utils/error_messages.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat_image.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

// Events
abstract class ImageUploadEvent extends Equatable {}

class PickImageEvent extends ImageUploadEvent {
  final ImageSource source;

  PickImageEvent({required this.source});

  @override
  List<Object> get props => [source];
}

class ClearImageEvent extends ImageUploadEvent {
  @override
  List<Object> get props => [];
}

// States
abstract class ImageUploadState extends Equatable {}

class ImageUploadInitial extends ImageUploadState {
  @override
  List<Object> get props => [];
}

class ImageUploadInProgress extends ImageUploadState {
  final String? localPath;

  ImageUploadInProgress({this.localPath});

  @override
  List<Object?> get props => [localPath];
}

class ImageUploadSuccess extends ImageUploadState {
  final ChatImage image;
  final String localPath;

  ImageUploadSuccess({required this.image, required this.localPath});

  @override
  List<Object> get props => [image, localPath];
}

class ImageUploadError extends ImageUploadState {
  final String message;
  final String type;

  ImageUploadError(this.message, {this.type = 'general'});

  @override
  List<Object> get props => [message];
}

// BLoC
class ImageUploadBloc extends Bloc<ImageUploadEvent, ImageUploadState> {
  final ChatRepository chatRepository;
  final ImagePicker imagePicker;

  ImageUploadBloc({required this.chatRepository, required this.imagePicker})
    : super(ImageUploadInitial()) {
    on<PickImageEvent>(_onPickImage);
    on<ClearImageEvent>(_onClearImage);
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    // Check permissions
    final hasPermissions = await PermissionHelper.requestImagePermissions();
    if (!hasPermissions) {
      emit(ImageUploadError(ErrorMessages.imagePermissionError));
      return;
    }

    // Pick image
    final pickedFile = await imagePicker.pickImage(source: event.source);
    if (pickedFile == null) {
      return; // User cancelled
    }

    // Start uploading
    emit(ImageUploadInProgress(localPath: pickedFile.path));

    // Upload image
    final result = await chatRepository.uploadImage(imagePath: pickedFile.path);
    result.fold(
      (failure) => emit(
        ImageUploadError(ErrorMessages.getUserFriendlyMessage(failure.message), type: failure is ImageUploadFailure ? 'upload' : 'general'),
      ),
      (chatImage) => emit(
        ImageUploadSuccess(image: chatImage, localPath: pickedFile.path),
      ),
    );
  }

  void _onClearImage(ClearImageEvent event, Emitter<ImageUploadState> emit) {
    emit(ImageUploadInitial());
  }
}
