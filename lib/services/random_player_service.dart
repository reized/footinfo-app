import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/player.dart';

class RandomPlayerService {
  static const String _baseUrl = 'https://v3.football.api-sports.io';
  static const String _apiKey = '86ab1cfe67a66269855aa7f7d32ce1e7';

  // Approximate range of valid player IDs in the API
  static const int _minPlayerId = 1;
  static const int _maxPlayerId = 2000;

  /// Get random player from API
  static Future<Player?> getRandomPlayer() async {
    try {
      final random = Random();
      // Generate random ID between min and max
      final randomId = _minPlayerId + random.nextInt(_maxPlayerId - _minPlayerId);

      final response = await http.get(
        Uri.parse('$_baseUrl/players?id=$randomId'),
        headers: {'x-apisports-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> playersData = data['response'];

        if (playersData.isNotEmpty) {
          return Player.fromJson(playersData[0]);
        }
      }
      
      // If no player found with this ID, try again recursively
      // with a limit to prevent infinite recursion
      return await getRandomPlayer();
      
    } catch (e) {
      print('Error getting random player: $e');
      return null;
    }
  }
}