// dependency injection using getit package
import 'package:chatgpt_clone/core/services/cloudinary_service.dart';
import 'package:chatgpt_clone/core/services/mongo_service.dart';
import 'package:chatgpt_clone/core/services/openai_service.dart';
import 'package:chatgpt_clone/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/current_chat_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/image_upload_bloc.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_ui_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

final GetIt di = GetIt.instance;
Future<void> init() async {
  // Register Dio
  di.registerLazySingleton<Dio>(() => Dio());
  // Register services
  di.registerLazySingleton<CloudinaryService>(() => CloudinaryService());
  di.registerLazySingleton<MongoService>(() => MongoService(di.get<Dio>()));

  di.registerLazySingleton<OpenAIService>(() => OpenAIService(di.get<Dio>()));

  // Register repositories
  di.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      openAIService: di<OpenAIService>(),
      mongoService: di<MongoService>(),
      cloudinaryService: di<CloudinaryService>(),
    ),
  );

  // Register BLoCs
  di.registerFactory<ChatListBloc>(
    () => ChatListBloc(chatRepository: di<ChatRepository>()),
  );

  di.registerFactory<CurrentChatBloc>(
    () => CurrentChatBloc(chatRepository: di<ChatRepository>()),
  );

  di.registerFactory<ImageUploadBloc>(
    () => ImageUploadBloc(
      chatRepository: di<ChatRepository>(),
      imagePicker: di<ImagePicker>(),
    ),
  );

  di.registerFactory<ChatUICubit>(() => ChatUICubit());

  // Register ImagePicker
  di.registerLazySingleton<ImagePicker>(
    () => ImagePicker(),
  ); 
}
