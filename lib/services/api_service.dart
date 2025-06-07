import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/fixture.dart';
import '../config/api_config.dart';

class ApiService {
  static String get _baseUrl => ApiConfig.footballApiBaseUrl;
  static String get _apiKey => ApiConfig.footballApiKey;

  static Future<List<Fixture>> getTodayFixtures() async {
    try {
      if (!ApiConfig.validateConfig()) {
        throw Exception(
          'API configuration is incomplete. Please check your .env file.',
        );
      }

      String today = DateTime.now().toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?date=$today'),
        headers: {'x-apisports-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fixturesData = data['response'];

        List<Fixture> fixtures = fixturesData
            .take(10)
            .map((json) => Fixture.fromJson(json))
            .toList();

        return fixtures;
      } else {
        throw Exception('Failed to load fixtures: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching today fixtures: $e');
      return [];
    }
  }

  static Future<void> fetchTeams(String query) async {
    try {
      if (!ApiConfig.validateConfig()) {
        throw Exception(
          'API configuration is incomplete. Please check your .env file.',
        );
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/teams?search=$query'),
        headers: {'x-apisports-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
      } else {
        throw Exception('Gagal memuat data tim');
      }
    } catch (e) {
      print('Error fetching teams: $e');
      rethrow;
    }
  }
}
