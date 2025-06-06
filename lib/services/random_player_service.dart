import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/player.dart';

class RandomPlayerService {
  static const String _baseUrl = 'https://v3.football.api-sports.io';
  static const String _apiKey = '86ab1cfe67a66269855aa7f7d32ce1e7';

  // Range of player IDs - disesuaikan dengan database API
  static const int _minPlayerId = 1;
  static const int _maxPlayerId = 50000; // Increased range for more randomness

  // Maximum retry attempts to prevent infinite loops
  static const int _maxRetryAttempts = 10;

  /// Get random player from API with improved randomness
  static Future<Player?> getRandomPlayer() async {
    final random = Random();
    int attempts = 0;

    while (attempts < _maxRetryAttempts) {
      attempts++;
      late final int randomId; // Deklarasi di luar try

      try {
        // Generate random ID
        randomId = _minPlayerId + random.nextInt(_maxPlayerId - _minPlayerId);

        print('Attempting to fetch player with ID: $randomId (Attempt $attempts)');

        final response = await http.get(
          Uri.parse('$_baseUrl/players?id=$randomId&season=2023'),
          headers: {'x-apisports-key': _apiKey},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> playersData = data['response'];

          if (playersData.isNotEmpty) {
            // Get the first player from the response
            final playerData = playersData[0];

            // Validate that player has required data
            if (_isValidPlayerData(playerData)) {
              print(
                'Successfully found player: ${playerData['player']['name']}',
              );
              return Player.fromJson(playerData);
            } else {
              print('Player data incomplete, trying another ID...');
            }
          } else {
            print('No player found with ID $randomId, trying another...');
          }
        } else {
          print('API error: ${response.statusCode}, trying another ID...');
        }

        // Add small delay between attempts to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print('Error fetching player with ID $randomId: $e');
      }
    }

    print('Failed to find a valid player after $attempts attempts');
    return null;
  }

  /// Validate if player data has required fields
  static bool _isValidPlayerData(Map<String, dynamic> playerData) {
    try {
      final player = playerData['player'];

      // Check if essential fields exist and are not null/empty
      return player != null &&
          player['id'] != null &&
          player['name'] != null &&
          player['name'].toString().isNotEmpty &&
          player['photo'] != null &&
          player['photo'].toString().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get random player from a specific league (optional method)
  static Future<Player?> getRandomPlayerFromLeague(
    int leagueId, {
    int season = 2023,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/players?league=$leagueId&season=$season'),
        headers: {'x-apisports-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> playersData = data['response'];

        if (playersData.isNotEmpty) {
          // Get random player from the list
          final random = Random();
          final randomIndex = random.nextInt(playersData.length);
          return Player.fromJson(playersData[randomIndex]);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching random player from league: $e');
      return null;
    }
  }

  /// Get multiple random players (optional method)
  static Future<List<Player>> getMultipleRandomPlayers(int count) async {
    List<Player> players = [];
    Set<int> usedIds = {}; // To avoid duplicates

    for (int i = 0; i < count; i++) {
      int attempts = 0;
      while (attempts < _maxRetryAttempts) {
        final player = await getRandomPlayer();

        if (player != null && !usedIds.contains(player.id)) {
          players.add(player);
          usedIds.add(player.id);
          break;
        }

        attempts++;
      }

      // Add delay between requests
      await Future.delayed(const Duration(milliseconds: 200));
    }

    return players;
  }
}
