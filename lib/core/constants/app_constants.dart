class AppConstants {
  // API Constants
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String chatCompletionsEndpoint = '/chat/completions';

  // Local Storage Keys
  static const String themeKey = 'theme_mode';
  static const String apiKeyKey = 'api_key';
  static const String userIdKey = 'user_id';

  // App Constants
  static const String appName = 'ChatGPT Clone';
  static const int maxRetries = 3;
  static const Duration timeoutDuration = Duration(seconds: 30);

  // UI Constants
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double messageSpacing = 8.0;

  // Chat Constants
  static const String defaultModel = 'gpt-3.5-turbo';
  static const int maxTokens = 1000;
  static const double temperature = 0.7;
}
