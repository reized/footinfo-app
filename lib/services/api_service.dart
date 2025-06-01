import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/fixture.dart';

class ApiService {
  static const String _baseUrl = 'https://v3.football.api-sports.io';
  static const String _apiKey = '86ab1cfe67a66269855aa7f7d32ce1e7';

  static Future<List<Fixture>> getTodayFixtures() async {
    try {
      // Get today's date in YYYY-MM-DD format
      String today = DateTime.now().toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse('$_baseUrl/fixtures?date=$today'),
        headers: {'x-apisports-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fixturesData = data['response'];

        // Convert to Fixture objects and limit to first 10 matches
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
  }
}
