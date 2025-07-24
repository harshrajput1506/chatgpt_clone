import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat_image.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, Chat>> sendMessage({
    required String model,
    required String content,
    String chatId,
    String? imageId,
    bool isNewChat,
  });
  Future<Either<Failure, Chat>> getChatHistory({required String chatId});
  Future<Either<Failure, List<Chat>>> getAllChats();
  Future<Either<Failure, String>> generateChatTitle({required String chatId});
  Future<Either<Failure, void>> deleteChat({required String chatId});
  Future<Either<Failure, void>> updateChatTitle({
    required String chatId,
    required String title,
  });
  Future<Either<Failure, Chat>> regenerateResponse({
    required String chatId,
    required String messageId,
    required String model,
  });

  Future<Either<Failure, ChatImage>> uploadImage({
    required String imagePath
  });
}