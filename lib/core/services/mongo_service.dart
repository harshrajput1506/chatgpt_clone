import 'package:chatgpt_clone/core/constants/app_url.dart';
import 'package:dio/dio.dart';
import 'package:logger/web.dart';
import '../utils/failures.dart';

class MongoService {
  final Dio _dio;
  final String baseUrl = AppUrl.baseUrl;
  final Logger _logger = Logger(printer: PrettyPrinter());

  MongoService(this._dio);

  Future<Map<String, dynamic>> saveMessage(
    String chatId,
    String content, {
    String sender = 'user',
    String? imageId,
  }) async {
    try {
      var body = {'content': content, 'sender': sender};
      if (imageId != null) {
        body['imageId'] = imageId;
      }

      final response = await _dio.post(
        '$baseUrl/chats/$chatId/messages',
        data: body,
      );
      _logger.i(
        'Message saved successfully: ${response.data}, status: ${response.statusCode}',
      );
      if (response.statusCode != 201) {
        throw ServerFailure('Failed to save message');
      }
      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw ServerFailure('No data returned from server');
      }
      if (data['success'] != true) {
        throw ServerFailure('Failed to save message');
      }
      if (data['message'] == null) {
        throw ServerFailure('Message data is null');
      }
      return Map<String, dynamic>.from(data['message'] as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Failed to save message: $e');
      throw ServerFailure('Failed to save message: $e');
    }
  }

  Future<Map<String, dynamic>> saveChat(
    String uid, {
    String title = 'New Chat',
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/chats',
        data: {'uid': uid, 'title': title},
      );
      _logger.i(
        'Chat saved successfully: ${response.data}, status: ${response.statusCode}',
      );
      if (response.statusCode != 201) {
        throw ServerFailure('Failed to save chat');
      }
      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw ServerFailure('No data returned from server');
      }
      if (data['success'] != true) {
        throw ServerFailure('Failed to save chat');
      }
      if (data['chat'] == null) {
        throw ServerFailure('Chat data is null');
      }

      return Map<String, dynamic>.from(data['chat'] as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Failed to save chat: $e');
      throw ServerFailure('Failed to save chat: $e');
    }
  }

  Future<Map<String, dynamic>> getChatHistory(String chatId, String uid) async {
    try {
      final response = await _dio.get(
        '$baseUrl/chats/$chatId',
        queryParameters: {'uid': uid},
      );
      _logger.i(
        'Chat history fetched successfully: ${response.data}, status: ${response.statusCode}',
      );
      if (response.statusCode != 200) {
        throw ServerFailure('Failed to fetch chat history');
      }
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw ServerFailure('Invalid chat history data');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      _logger.e('Failed to fetch chat history: $e');
      throw ServerFailure('Failed to fetch chat history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllChats(String uid) async {
    try {
      final response = await _dio.get(
        '$baseUrl/chats',
        queryParameters: {'uid': uid},
      );
      _logger.i(
        'Chats fetched successfully: ${response.data}, status: ${response.statusCode}',
      );
      if (response.statusCode != 200) {
        throw ServerFailure('Failed to fetch chats');
      }
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw ServerFailure('Invalid chats data');
      }
      final chats = response.data['chats'];
      if (chats == null || chats is! List) {
        throw ServerFailure('Chats data is not a list');
      }
      if (chats.isEmpty) {
        _logger.w('No chats found for user $uid');
        return [];
      }
      _logger.i('Fetched ${chats.length} chats for user $uid');
      return List<Map<String, dynamic>>.from(chats);
    } catch (e) {
      _logger.e('Failed to fetch chats: $e');
      throw ServerFailure('Failed to fetch chats: $e');
    }
  }

  Future<void> deleteChat(String chatId, String uid) async {
    try {
      await _dio.delete(
        '$baseUrl/chats/$chatId',
        queryParameters: {'uid': uid},
      );
    } catch (e) {
      _logger.e('Failed to delete chat: $e');
      throw ServerFailure('Failed to delete chat: $e');
    }
  }

  Future<String> generateChatTitle(String chatId, String uid) async {
    try {
      final response = await _dio.post(
        '$baseUrl/chats/$chatId/generate-title',
        queryParameters: {'uid': uid},
      );
      _logger.i(
        'Chat title generated successfully: ${response.data}, status: ${response.statusCode}',
      );
      if (response.statusCode != 200) {
        throw ServerFailure('Failed to generate chat title');
      }
      if (response.data == null || response.data['success'] != true) {
        throw ServerFailure('Invalid chat title data');
      }
      final title = response.data['chat']['title'];
      return title as String? ?? 'New Chat';
    } catch (e) {
      _logger.e('Failed to generate chat title: $e');
      throw ServerFailure('Failed to generate chat title');
    }
  }

  Future<void> updateChatTitle(String chatId, String title, String uid) async {
    try {
      final response = await _dio.put(
        '$baseUrl/chats/$chatId',
        data: {'title': title, uid: uid},
      );
      _logger.i(
        'Chat title updated successfully: ${response.data}, status: ${response.statusCode}',
      );
      if (response.statusCode != 200) {
        throw ServerFailure('Failed to update chat title');
      }
      if (response.data == null || response.data['success'] != true) {
        throw ServerFailure('Invalid chat title update data');
      }
    } catch (e) {
      _logger.e('Failed to update chat title: $e');
      throw ServerFailure('Failed to update chat title: $e');
    }
  }

  Future<Map<String, dynamic>> saveImage(
    String publicId,
    String originalName,
    String url,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/images',
        data: {'publicId': publicId, 'originalName': originalName, 'url': url},
      );
      _logger.i(
        'Image saved successfully: ${response.data}, status: ${response.statusCode}',
      );
      if (response.statusCode != 201) {
        throw ServerFailure('Failed to save image');
      }
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw ServerFailure('Invalid image data');
      }
      if (response.data['success'] != true) {
        throw ServerFailure('Failed to save image');
      }
      return Map<String, dynamic>.from(
        response.data['image'] as Map<String, dynamic>,
      );
    } catch (e) {
      _logger.e('Failed to save image: $e');
      throw ServerFailure('Failed to save image: $e');
    }
  }
}
