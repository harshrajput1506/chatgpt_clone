import 'package:chatgpt_clone/core/constants/app_url.dart';
import 'package:dio/dio.dart';
import 'package:logger/web.dart';
import '../utils/failures.dart';

class OpenAIService {
  final Dio _dio;
  final Logger _logger = Logger(printer: PrettyPrinter());
  final String baseUrl = AppUrl.baseUrl;
  OpenAIService(this._dio);

  Future<Map<String, dynamic>> generateResponse(
    String chatId,
    String model,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/ai/chats/$chatId/generate',
        data: {'model': model},
      );

      _logger.i(
        'Response generated successfully: ${response.data}, status: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        _logger.e('Failed to generate response: ${response.data}');
        throw ServerFailure('Failed to generate response');
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        _logger.e('No response data returned from server');
        throw ServerFailure('No response data returned from server');
      }

      if (data['success'] != true) {
        _logger.e('Failed to generate response: ${data['message']}');
        throw ServerFailure(data['message'] ?? 'Failed to generate response');
      }

      if (data['message']['sender'] != 'assistant') {
        _logger.e(
          'Unexpected sender in response: ${data['message']['sender']}',
        );
        throw ServerFailure('Unexpected sender in response');
      }

      return Map<String, dynamic>.from(data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _logger.e('Connection timeout: ${e.message}');
        throw NetworkFailure('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        _logger.e('Invalid API key: ${e.message}');
        throw ServerFailure('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        _logger.e('Rate limit exceeded: ${e.message}');
        throw ServerFailure('Rate limit exceeded');
      } else {
        _logger.e('Network error: ${e.message}');
        throw ServerFailure('Network error');
      }
    } on ServerFailure catch (e) {
      _logger.e('Serverfaiure error: $e');
      throw ServerFailure(e.message);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      throw ServerFailure('Unexpected error');
    }
  }
}
