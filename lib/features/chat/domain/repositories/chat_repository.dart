import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, Message>> sendMessage({
    required String model,
    required String chatId,
    required String content,
    String? imageUrl,
  });

  Future<Either<Failure, Message>> regenerateResponse({
    required String chatId,
    required String messageId,
  });
}
