import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static String get footballApiBaseUrl =>
      dotenv.env['FOOTBALL_API_BASE_URL'] ?? '';
  static String get footballApiKey => dotenv.env['FOOTBALL_API_KEY'] ?? '';
  static String get footballApiHost => dotenv.env['FOOTBALL_API_HOST'] ?? '';

  static String get appName => dotenv.env['APP_NAME'] ?? 'Footinfo App';
  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      print('Environment configuration loaded successfully');

      if (debugMode) {
        print('API Base URL: $footballApiBaseUrl');
        print('API Host: $footballApiHost');
        print(
          'API Key: ${footballApiKey.isNotEmpty ? '***configured***' : 'NOT CONFIGURED'}',
        );
      }
    } catch (e) {
      print('Error loading .env file: $e');
      print('Make sure .env file exists in the root directory');
    }
  }

  static bool validateConfig() {
    final isValid =
        footballApiBaseUrl.isNotEmpty &&
        footballApiKey.isNotEmpty &&
        footballApiHost.isNotEmpty;

    if (!isValid && debugMode) {
      print('Warning: Some environment variables are missing!');
      if (footballApiBaseUrl.isEmpty)
        print('- FOOTBALL_API_BASE_URL is missing');
      if (footballApiKey.isEmpty) print('- FOOTBALL_API_KEY is missing');
      if (footballApiHost.isEmpty) print('- FOOTBALL_API_HOST is missing');
    }

    return isValid;
  }
}
