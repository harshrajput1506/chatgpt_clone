import 'package:chatgpt_clone/core/services/mongo_service.dart';
import 'package:chatgpt_clone/core/services/openai_service.dart';
import 'package:chatgpt_clone/core/utils/failures.dart';
import 'package:chatgpt_clone/core/utils/uid_helper.dart';
import 'package:chatgpt_clone/features/chat/data/models/chat_model.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:chatgpt_clone/features/chat/data/models/message_model.dart';
import 'package:dartz/dartz.dart';

class ChatRepositoryImpl implements ChatRepository {
  final OpenAIService openAIService;
  final MongoService mongoService;
  ChatRepositoryImpl({required this.openAIService, required this.mongoService});
  

  @override
  Future<Either<Failure, MessageModel>> sendMessage({
    required String model,
    required String content,
    String? imageUrl,
    String chatId = '',
    bool isNewChat = false,
  }) async {
    try {
      final uid = await UidHelper.getUid();
      ChatModel chat;
      // check isNewChat to determine if we need to create a new chat or use an existing one
      if (isNewChat) {
        // Create a new chat
        final data = await mongoService.saveChat(uid);
        chat = ChatModel.fromJson(data);
        chatId = chat.id; // Update chatId with the newly created chat's ID
      }
      // If not a new chat, ensure chatId is provided
      if (!isNewChat && chatId.isEmpty) {
        return Left(ServerFailure('Chat ID is required for existing chats'));
      }

      // Save the user message
      await mongoService.saveMessage(chatId, content, sender: 'user');

      // generate response from OpenAI
      final response = await openAIService.generateResponse(chatId, model);
      final responseMessage = MessageModel.fromJson(response);

      return Right(responseMessage);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        ServerFailure('Failed to send message'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getAllChats() async {
    try {
      final uid = await UidHelper.getUid(); // Get the user ID
      // Fetch all chats from the MongoDB service
      final chatsData = await mongoService.getAllChats(uid);
      final chats = (chatsData as List)
          .map((chat) => ChatModel.fromJson(chat as Map<String, dynamic>))
          .toList();
      return Right(chats);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch all chats'));
    }
  }

  @override
  Future<Either<Failure, Chat>> getChatHistory({required String chatId}) async {
    try {
      final uid = await UidHelper.getUid(); // Get the user ID
      // Fetch chat history from MongoDB service
      final chatData = await mongoService.getChatHistory(chatId, uid);
      final chat = ChatModel.fromJson(chatData);
      return Right(chat);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch chat history'));
    }
  }
  
  @override
  Future<Either<Failure, String>> generateChatTitle({required String chatId}) async {
    try {
      final uid = await UidHelper.getUid(); // Get the user ID
      // Generate a chat title
      final title = await mongoService.generateChatTitle(chatId, uid);
      return Right(title);
    } catch (e) {
      return Left(ServerFailure('Failed to generate chat title'));
    } 
  }
}
