import 'package:dio/dio.dart';
import '../utils/failures.dart';

class MongoService {
  final Dio _dio;
  final String baseUrl;

  MongoService(this._dio, this.baseUrl);

  Future<void> saveMessage(Map<String, dynamic> messageData) async {
    try {
      await _dio.post('$baseUrl/messages', data: messageData);
    } catch (e) {
      throw ServerFailure('Failed to save message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChatHistory(String chatId) async {
    try {
      final response = await _dio.get('$baseUrl/chats/$chatId/messages');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw ServerFailure('Failed to fetch chat history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllChats() async {
    try {
      final response = await _dio.get('$baseUrl/chats');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw ServerFailure('Failed to fetch chats: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _dio.delete('$baseUrl/chats/$chatId');
    } catch (e) {
      throw ServerFailure('Failed to delete chat: $e');
    }
  }
}
