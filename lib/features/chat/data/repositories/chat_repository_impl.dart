import 'package:chatgpt_clone/core/services/openai_service.dart';
import 'package:chatgpt_clone/core/utils/failures.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/message.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatgpt_clone/features/chat/data/models/message_model.dart';
import 'package:dartz/dartz.dart';

class ChatRepositoryImpl implements ChatRepository {
  final OpenAIService openAIService;
  ChatRepositoryImpl({required this.openAIService});
  @override
  Future<Either<Failure, MessageModel>> regenerateResponse({
    required String chatId,
    required String messageId,
  }) async {
    // TODO: implement regenerateResponse
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage({
    required String chatId,
    required String content,
    String? imageUrl,
    required String model,
  }) async {
    try {
      // check imageUrl is not null
      var messages = <Map<String, dynamic>>[
        {
          'role': MessageRole.assistant.name,
          'content': 'You are a helpful assistant.',
        },
      ];

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // messages.add({
        //   'role': 'user',
        //   'content': content,
        //   'image_url': imageUrl,
        // });
      } else {
        messages.add({'role': MessageRole.user.name, 'content': content});
      }

      final response = await openAIService.generateResponse(messages, model);

      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        role: MessageRole.assistant,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      return Right(message);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        ServerFailure('Failed to send message due to an unexpected error: $e'),
      );
    }
  }
}
