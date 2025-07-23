import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, Chat>> sendMessage({
    required String model,
    required String content,
    String chatId,
    String? imageUrl,
    bool isNewChat,
  });

  Future<Either<Failure, Chat>> getChatHistory({required String chatId});

  Future<Either<Failure, List<Chat>>> getAllChats();

  Future<Either<Failure, String>> generateChatTitle({required String chatId});
}
