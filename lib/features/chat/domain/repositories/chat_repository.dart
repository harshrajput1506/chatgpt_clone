import 'package:dartz/dartz.dart';
import '../../../shared/models/message_model.dart';
import '../../../../core/utils/failures.dart';

abstract class ChatRepository {
  Future<Either<Failure, MessageModel>> sendMessage({
    required String chatId,
    required String content,
    String? imagePath,
  });

  Future<Either<Failure, List<MessageModel>>> getChatMessages(String chatId);

  Future<Either<Failure, void>> saveChatLocally(
    String chatId,
    List<MessageModel> messages,
  );

  Future<Either<Failure, List<MessageModel>>> getLocalChatMessages(
    String chatId,
  );

  Future<Either<Failure, MessageModel>> regenerateResponse({
    required String chatId,
    required String messageId,
  });
}
