import 'dart:io';

import 'package:chatgpt_clone/core/services/cloudinary_service.dart';
import 'package:chatgpt_clone/core/services/mongo_service.dart';
import 'package:chatgpt_clone/core/services/openai_service.dart';
import 'package:chatgpt_clone/core/utils/failures.dart';
import 'package:chatgpt_clone/core/utils/uid_helper.dart';
import 'package:chatgpt_clone/features/chat/data/models/chat_image_model.dart';
import 'package:chatgpt_clone/features/chat/data/models/chat_model.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat.dart';
import 'package:chatgpt_clone/features/chat/domain/entities/chat_image.dart';
import 'package:chatgpt_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';

class ChatRepositoryImpl implements ChatRepository {
  final OpenAIService openAIService;
  final MongoService mongoService;
  final CloudinaryService cloudinaryService;
  final Logger _logger = Logger(printer: PrettyPrinter());
  ChatRepositoryImpl({
    required this.openAIService,
    required this.mongoService,
    required this.cloudinaryService,
  });

  @override
  Future<Either<Failure, Chat>> sendMessage({
    required String model,
    required String content,
    String? imageId,
    String chatId = '',
    bool isNewChat = false,
  }) async {
    try {
      final uid = await UidHelper.getUid();
      // check isNewChat to determine if we need to create a new chat or use an existing one
      if (isNewChat) {
        // Create a new chat
        final data = await mongoService.saveChat(uid);
        chatId =
            ChatModel.fromJson(
              data,
            ).id; // Update chatId with the newly created chat's ID
      }
      // If not a new chat, ensure chatId is provided
      if (!isNewChat && chatId.isEmpty) {
        return Left(ServerFailure('Chat ID is required for existing chats'));
      }

      // Save the user message
      await mongoService.saveMessage(
        chatId,
        content,
        sender: 'user',
        imageId: imageId,
      );

      // generate response from OpenAI
      await openAIService.generateStreamResponse(chatId, model);

      final ChatModel chat = ChatModel(
        id: chatId,
        title: 'title',
        messages: [],
      );

      return Right(chat);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Failed to send message'));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getAllChats() async {
    try {
      final uid = await UidHelper.getUid(); // Get the user ID
      // Fetch all chats from the MongoDB service
      final chatsData = await mongoService.getAllChats(uid);
      _logger.i('Fetched chats data: $chatsData');
      final chats =
          (chatsData).map((chat) => ChatModel.fromJson(chat)).toList();
      _logger.i('Fetched ${chats.length} chats - $chats');
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
      _logger.i('Fetched chat history: $chat');
      return Right(chat);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch chat history'));
    }
  }

  @override
  Future<Either<Failure, String>> generateChatTitle({
    required String chatId,
  }) async {
    try {
      final uid = await UidHelper.getUid(); // Get the user ID
      // Generate a chat title
      final title = await mongoService.generateChatTitle(chatId, uid);
      return Right(title);
    } catch (e) {
      return Left(ServerFailure('Failed to generate chat title'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChat({required String chatId}) async {
    try {
      final uid = await UidHelper.getUid(); // Get the user ID
      // Delete the chat from MongoDB service
      await mongoService.deleteChat(chatId, uid);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete chat'));
    }
  }

  @override
  Future<Either<Failure, void>> updateChatTitle({
    required String chatId,
    required String title,
  }) async {
    try {
      final uid = await UidHelper.getUid(); // Get the user ID
      // Update the chat title in MongoDB service
      await mongoService.updateChatTitle(chatId, title, uid);

      return Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update chat title'));
    }
  }

  @override
  Future<Either<Failure, void>> regenerateResponse({
    required String chatId,
    required String messageId,
    required String model,
  }) async {
    try {
      // Call the OpenAI service to regenerate the response
      await openAIService.regenerateStreamResponse(chatId, model, messageId);

      return Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Failed to regenerate response'));
    }
  }

  @override
  Future<Either<Failure, ChatImage>> uploadImage({
    required String imagePath,
  }) async {
    try {
      // validate the file size and type if needed
      if (imagePath.isEmpty) {
        return Left(ServerFailure('Image path cannot be empty'));
      }

      final file = File(imagePath);

      _logger.i('Uploading image from path: $imagePath');

      _logger.i(
        'Image file size: ${file.lengthSync() / 1024 / 1024} MB - extension - ${file.path.split('.').last}',
      );

      // check file type is image
      if (![
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'bmp',
      ].contains(imagePath.split('.').last.toLowerCase())) {
        return Left(ServerFailure('Invalid image type'));
      }

      // check file size not more than 5MB
      if (file.lengthSync() > 5 * 1024 * 1024) {
        return Left(ServerFailure('Image size should not exceed 5MB'));
      }

      // Upload the image on the cloudinary
      final response = await cloudinaryService.uploadImage(imagePath);

      // save the image in mongoDB
      final imageData = await mongoService.saveImage(
        response['publicId'],
        response['originalName'],
        response['originalUrl'],
      );
      final image = ChatImageModel.fromJson(imageData);

      return Right(image);
    } catch (e) {
      _logger.e('Failed to upload image: $e');
      return Left(ServerFailure('Failed to upload image'));
    }
  }

  @override
  Stream<Map<String, dynamic>> get responseStream =>
      openAIService.responseStream;

  @override
  void dispose() {
    openAIService.dispose();
  }
}
