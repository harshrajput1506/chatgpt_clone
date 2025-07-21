// dependency injection using getit package
import 'package:chatgpt_clone/core/services/cloudinary_service.dart';
import 'package:chatgpt_clone/core/services/mongo_service.dart';
import 'package:chatgpt_clone/core/services/openai_service.dart';
import 'package:chatgpt_clone/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatgpt_clone/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final GetIt di = GetIt.instance;
Future<void> init() async {
  // Register Dio
  di.registerLazySingleton<Dio>(() => Dio());
  // Register services
  di.registerLazySingleton<CloudinaryService>(() => CloudinaryService());
  di.registerLazySingleton<MongoService>(
    () => MongoService(di.get<Dio>(), 'https://your-mongo-api-url.com'),
  );
  di.registerLazySingleton<OpenAIService>(() => OpenAIService(di.get<Dio>()));

  // Register repositories
  di.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(openAIService: di<OpenAIService>()),
  );

  // Register blocs
  di.registerFactory<ChatBloc>(
    () => ChatBloc(chatRepository: di<ChatRepository>()),
  );
}
