// dependency injection using getit package
import 'package:chatgpt_clone/core/services/cloudinary_service.dart';
import 'package:chatgpt_clone/core/services/mongo_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final GetIt di = GetIt.instance;
Future<void> init()  async{
  // Register services
  di.registerLazySingleton<CloudinaryService>(() => CloudinaryService());
  di.registerLazySingleton<MongoService>(() => MongoService(di<Dio>(), 'https://your-mongo-api-url.com'));

  // Register repositories
  

  // Register other dependencies as needed
}
