import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/failures.dart';

class OpenAIService {
  final Dio _dio;
  late final String _apiKey;

  OpenAIService(this._dio) {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<String> generateResponse(List<Map<String, dynamic>> messages) async {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return content as String;
      } else {
        throw ServerFailure(
          'Failed to generate response: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkFailure('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        throw ServerFailure('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        throw ServerFailure('Rate limit exceeded');
      } else {
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}
