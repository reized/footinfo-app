import 'package:footinfo_app/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/player.dart';

class RandomPlayerService {
  static String get _baseUrl => ApiConfig.footballApiBaseUrl;
  static String get _apiKey => ApiConfig.footballApiKey;

  static const int _minPlayerId = 1;
  static const int _maxPlayerId = 50000;

  static const int _maxRetryAttempts = 10;

  static Future<Player?> getRandomPlayer() async {
    if (!ApiConfig.validateConfig()) {
      print(
        'Error: API configuration is incomplete. Please check your .env file.',
      );
      return null;
    }

    final random = Random();
    int attempts = 0;

    while (attempts < _maxRetryAttempts) {
      attempts++;
      late final int randomId;

      try {
        randomId = _minPlayerId + random.nextInt(_maxPlayerId - _minPlayerId);

        print(
          'Attempting to fetch player with ID: $randomId (Attempt $attempts)',
        );

        final response = await http.get(
          Uri.parse('$_baseUrl/players?id=$randomId&season=2023'),
          headers: {'x-apisports-key': _apiKey},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> playersData = data['response'];

          if (playersData.isNotEmpty) {
            final playerData = playersData[0];

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

        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print('Error fetching player with ID $randomId: $e');
      }
    }

    print('Failed to find a valid player after $attempts attempts');
    return null;
  }

  static bool _isValidPlayerData(Map<String, dynamic> playerData) {
    try {
      final player = playerData['player'];

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

  static Future<Player?> getRandomPlayerFromLeague(
    int leagueId, {
    int season = 2023,
  }) async {
    try {
      if (!ApiConfig.validateConfig()) {
        print(
          'Error: API configuration is incomplete. Please check your .env file.',
        );
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/players?league=$leagueId&season=$season'),
        headers: {'x-apisports-key': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> playersData = data['response'];

        if (playersData.isNotEmpty) {
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

  static Future<List<Player>> getMultipleRandomPlayers(int count) async {
    List<Player> players = [];
    Set<int> usedIds = {};

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

      await Future.delayed(const Duration(milliseconds: 200));
    }

    return players;
  }
}
