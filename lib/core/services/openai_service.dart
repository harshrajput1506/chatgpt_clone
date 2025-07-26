import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chatgpt_clone/core/constants/app_url.dart';
import 'package:dio/dio.dart';
import 'package:logger/web.dart';
import '../utils/failures.dart';

class OpenAIService {
  final Dio _dio;
  final Logger _logger = Logger(printer: PrettyPrinter());
  final String baseUrl = AppUrl.baseUrl;

  StreamController<Map<String, dynamic>>? _responseStreamController;
  StreamSubscription? _streamSubscription;

  OpenAIService(this._dio);

  Stream<Map<String, dynamic>> get responseStream {
    _responseStreamController ??=
        StreamController<Map<String, dynamic>>.broadcast();
    return _responseStreamController!.stream;
  }

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

  Future<void> generateStreamResponse(String chatId, String model) async {
    try {
      //Ensure we have a fresh stream controller
      await _closeExistingStream();
      _responseStreamController =
          StreamController<Map<String, dynamic>>.broadcast();

      final response = await _dio.post<ResponseBody>(
        '$baseUrl/ai/chats/$chatId/stream',
        data: {'model': model},
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            // Allow all status codes so we can handle errors in the stream
            return status != null && status < 500;
          },
        ),
      );

      if (response.data == null) {
        _logger.e('No response data received from stream endpoint');
        _responseStreamController?.addError(
          ServerFailure('No response data received'),
        );
        return;
      }

      // Check if response status indicates an error
      if (response.statusCode != 200) {
        _logger.e('HTTP error ${response.statusCode} in stream');
        _responseStreamController?.addError(
          ServerFailure('HTTP ${response.statusCode}: Request failed'),
        );
        return;
      }

      _streamSubscription = response.data!.stream
          .transform(
            StreamTransformer<Uint8List, String>.fromHandlers(
              handleData: (data, sink) {
                sink.add(utf8.decode(data));
              },
            ),
          )
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith("data: ")) {
                final raw = line.replaceFirst("data: ", "").trim();
                if (raw == "[DONE]") {
                  _logger.i("Stream completed.");
                  return;
                }

                try {
                  final jsonData = json.decode(raw);

                  // Check for error in the stream data
                  if (jsonData['error'] != null) {
                    _logger.e('Server error in stream: ${jsonData['error']}');
                    _responseStreamController?.addError(
                      ServerFailure(jsonData['error']),
                    );
                    return;
                  }

                  final type = jsonData['type'];

                  if (type == 'chunk') {
                    final content = jsonData['content'];
                    _responseStreamController?.add({
                      'type': 'chunk',
                      'content': content,
                    });
                    _logger.d('Chunk received: $content');
                  } else if (type == 'complete') {
                    final fullContent = jsonData['fullContent'];
                    _responseStreamController?.add({
                      'type': 'complete',
                      'content': fullContent,
                      'messageId': jsonData['messageId'],
                    });
                    _logger.i('Stream completed with content: $fullContent');
                  }
                } catch (e) {
                  _logger.e('Error parsing JSON: $e');
                  _responseStreamController?.addError(
                    ServerFailure('Error parsing streaming response'),
                  );
                }
              }
            },
            onDone: () {
              _logger.i("Stream done.");
              _closeExistingStream();
            },
            onError: (e) {
              _logger.e('Stream error: $e');
              _responseStreamController?.addError(
                ServerFailure('Stream error: $e'),
              );
              _closeExistingStream();
            },
            cancelOnError: false,
          );
    } on DioException catch (e) {
      _logger.e('Network error in stream: ${e.message}');
      _logger.e('Response status: ${e.response?.statusCode}');
      _logger.e('Response data: ${e.response?.data}');

      String errorMessage = 'Network error';

      if (e.response?.statusCode == 400) {
        // Try to extract error message from response
        try {
          final errorData = e.response?.data;
          if (errorData is Map) {
            errorMessage =
                errorData['error'] ?? errorData['details'] ?? 'Bad request';
          } else if (errorData is String) {
            errorMessage = errorData;
          } else {
            errorMessage = 'Bad request - please check your input';
          }
        } catch (_) {
          errorMessage = 'Bad request - please check your input';
        }
        _responseStreamController?.addError(ServerFailure(errorMessage));
        throw ServerFailure(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _responseStreamController?.addError(
          NetworkFailure('Connection timeout'),
        );
        throw NetworkFailure('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        _responseStreamController?.addError(ServerFailure('Invalid API key'));
        throw ServerFailure('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        _responseStreamController?.addError(
          ServerFailure('Rate limit exceeded'),
        );
        throw ServerFailure('Rate limit exceeded');
      } else {
        _responseStreamController?.addError(ServerFailure('Network error'));
        throw ServerFailure('Network error');
      }
    } on ServerFailure catch (e) {
      _logger.e('Server failure error: $e');
      _responseStreamController?.addError(e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error: $e');
      _responseStreamController?.addError(ServerFailure('Unexpected error'));
      throw ServerFailure('Unexpected error');
    }
  }

  Future<void> regenerateStreamResponse(
    String chatId,
    String model,
    String messageId,
  ) async {
    try {
      //Ensure we have a fresh stream controller
      await _closeExistingStream();
      _responseStreamController =
          StreamController<Map<String, dynamic>>.broadcast();

      final response = await _dio.post<ResponseBody>(
        '$baseUrl/ai/chats/$chatId/messages/$messageId/regenerate-stream',
        data: {'model': model},
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            // Allow all status codes so we can handle errors in the stream
            return status != null && status < 500;
          },
        ),
      );

      if (response.data == null) {
        _logger.e('No response data received from stream endpoint');
        _responseStreamController?.addError(
          ServerFailure('No response data received'),
        );
        return;
      }

      // Check if response status indicates an error
      if (response.statusCode != 200) {
        _logger.e(
          'HTTP error ${response.statusCode} in regenerate stream - ${response.data}',
        );
        _responseStreamController?.addError(
          ServerFailure('HTTP ${response.statusCode}: Request failed'),
        );
        return;
      }

      _streamSubscription = response.data!.stream
          .transform(
            StreamTransformer<Uint8List, String>.fromHandlers(
              handleData: (data, sink) {
                sink.add(utf8.decode(data));
              },
            ),
          )
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith("data: ")) {
                final raw = line.replaceFirst("data: ", "").trim();
                if (raw == "[DONE]") {
                  _logger.i("Stream completed.");
                  return;
                }

                try {
                  final jsonData = json.decode(raw);

                  // Check for error in the stream data
                  if (jsonData['error'] != null) {
                    _logger.e('Server error in stream: ${jsonData['error']}');
                    _responseStreamController?.addError(
                      ServerFailure(jsonData['error']),
                    );
                    return;
                  }

                  final type = jsonData['type'];

                  if (type == 'chunk') {
                    final content = jsonData['content'];
                    _responseStreamController?.add({
                      'type': 'chunk',
                      'content': content,
                      'regenerated': jsonData['regenerated'] ?? true,
                    });
                    _logger.d('Regenerate chunk received: $content');
                  } else if (type == 'complete') {
                    final fullContent = jsonData['fullContent'];
                    _responseStreamController?.add({
                      'type': 'complete',
                      'content': fullContent,
                      'messageId': jsonData['messageId'],
                      'regenerated': jsonData['regenerated'] ?? true,
                    });
                    _logger.i(
                      'Regenerate stream completed with content: $fullContent',
                    );
                  }
                } catch (e) {
                  _logger.e('Error parsing JSON: $e');
                  _responseStreamController?.addError(
                    ServerFailure('Error parsing streaming response'),
                  );
                }
              }
            },
            onDone: () {
              _logger.i("Regenerate stream done.");
              _closeExistingStream();
            },
            onError: (e) {
              _logger.e('Regenerate stream error: $e');
              _responseStreamController?.addError(
                ServerFailure('Stream error'),
              );
              _closeExistingStream();
            },
            cancelOnError: false,
          );
    } on DioException catch (e) {
      _logger.e('Network error in regenerate stream: ${e.message}');
      _logger.e('Response status: ${e.response?.statusCode}');
      _logger.e('Response data: ${e.response?.data}');

      String errorMessage = 'Network error';

      if (e.response?.statusCode == 400) {
        // Try to extract error message from response
        try {
          final errorData = e.response?.data;
          if (errorData is Map) {
            errorMessage =
                errorData['error'] ?? errorData['details'] ?? 'Bad request';
          } else if (errorData is String) {
            errorMessage = errorData;
          } else {
            errorMessage = 'Bad request - please check your input';
          }
        } catch (_) {
          errorMessage = 'Bad request - please check your input';
        }
        _responseStreamController?.addError(ServerFailure(errorMessage));
        throw ServerFailure(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _responseStreamController?.addError(
          NetworkFailure('Connection timeout'),
        );
        throw NetworkFailure('Connection timeout');
      } else if (e.response?.statusCode == 401) {
        _responseStreamController?.addError(ServerFailure('Invalid API key'));
        throw ServerFailure('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        _responseStreamController?.addError(
          ServerFailure('Rate limit exceeded'),
        );
        throw ServerFailure('Rate limit exceeded');
      } else {
        _responseStreamController?.addError(ServerFailure('Network error'));
        throw ServerFailure('Network error');
      }
    } on ServerFailure catch (e) {
      _logger.e('Server failure error: $e');
      _responseStreamController?.addError(e);
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error: $e');
      _responseStreamController?.addError(ServerFailure('Unexpected error'));
      throw ServerFailure('Unexpected error');
    }
  }

  Future<void> _closeExistingStream() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    if (_responseStreamController != null &&
        !_responseStreamController!.isClosed) {
      await _responseStreamController!.close();
    }
    _responseStreamController = null;
  }

  Future<Map<String, dynamic>> regenerateResponse(
    String chatId,
    String messageId,
    String model,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/ai/chats/$chatId/messages/$messageId/regenerate',
        data: {'model': model},
      );

      _logger.i(
        'Response regenerated successfully: ${response.data}, status: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        _logger.e('Failed to regenerate response: ${response.data}');
        throw ServerFailure('Failed to regenerate response');
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        _logger.e('No response data returned from server');
        throw ServerFailure('No response data returned from server');
      }

      if (data['success'] != true) {
        _logger.e('Failed to regenerate response: ${data['message']}');
        throw ServerFailure(data['message'] ?? 'Failed to regenerate response');
      }

      if (data['regenerated'] != true) {
        _logger.e('Response was not regenerated properly');
        throw ServerFailure('Response was not regenerated properly');
      }

      return data;
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
      _logger.e('Server failure error: $e');
      throw ServerFailure(e.message);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      throw ServerFailure('Unexpected error');
    }
  }

  void dispose() {
    _closeExistingStream();
  }
}
