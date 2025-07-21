import 'package:dio/dio.dart';
import 'package:logger/web.dart';
import '../utils/failures.dart';

class OpenAIService {
  final Dio _dio;
  late final String _apiKey;
  final Logger _logger = Logger(printer: PrettyPrinter());

  OpenAIService(this._dio) {
    _apiKey = 'api-key-here';
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<String> generateResponse(
    List<Map<String, dynamic>> messages,
    String model,
  ) async {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: {'model': model, 'messages': messages, 'max_tokens': 1000},
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        _logger.i('Response generated successfully: $content');
        if (content == null || content.isEmpty) {
          _logger.e('Response content is empty');
          throw ServerFailure('Response content is empty');
        }
        return content as String;
      } else {
        _logger.e('Failed to generate response: ${response.statusMessage}');
        throw ServerFailure('Failed to generate response');
      }
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
    } catch (e) {
      _logger.e('Unexpected error: $e');
      throw ServerFailure('Unexpected error');
    }
  }
}
