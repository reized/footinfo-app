import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoriteService {
  static const String _playersKey = 'favorite_players';
  static const String _teamsKey = 'favorite_teams';

  // Player favorites
  static Future<List<int>> getFavoritePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? playersJson = prefs.getString(_playersKey);
    if (playersJson == null) return [];

    final List<dynamic> playersList = json.decode(playersJson);
    return playersList.cast<int>();
  }

  static Future<bool> addPlayerToFavorites(int playerId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> favorites = await getFavoritePlayers();

    if (!favorites.contains(playerId)) {
      favorites.add(playerId);
      final String playersJson = json.encode(favorites);
      return await prefs.setString(_playersKey, playersJson);
    }
    return true;
  }

  static Future<bool> removePlayerFromFavorites(int playerId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> favorites = await getFavoritePlayers();

    favorites.remove(playerId);
    final String playersJson = json.encode(favorites);
    return await prefs.setString(_playersKey, playersJson);
  }

  static Future<bool> isPlayerFavorite(int playerId) async {
    final List<int> favorites = await getFavoritePlayers();
    return favorites.contains(playerId);
  }

  // Team favorites
  static Future<List<int>> getFavoriteTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final String? teamsJson = prefs.getString(_teamsKey);
    if (teamsJson == null) return [];

    final List<dynamic> teamsList = json.decode(teamsJson);
    return teamsList.cast<int>();
  }

  static Future<bool> addTeamToFavorites(int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> favorites = await getFavoriteTeams();

    if (!favorites.contains(teamId)) {
      favorites.add(teamId);
      final String teamsJson = json.encode(favorites);
      return await prefs.setString(_teamsKey, teamsJson);
    }
    return true;
  }

  static Future<bool> removeTeamFromFavorites(int teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> favorites = await getFavoriteTeams();

    favorites.remove(teamId);
    final String teamsJson = json.encode(favorites);
    return await prefs.setString(_teamsKey, teamsJson);
  }

  static Future<bool> isTeamFavorite(int teamId) async {
    final List<int> favorites = await getFavoriteTeams();
    return favorites.contains(teamId);
  }

  // Toggle functions for easier use
  static Future<bool> togglePlayerFavorite(int playerId) async {
    final bool isFavorite = await isPlayerFavorite(playerId);
    if (isFavorite) {
      return await removePlayerFromFavorites(playerId);
    } else {
      return await addPlayerToFavorites(playerId);
    }
  }

  static Future<bool> toggleTeamFavorite(int teamId) async {
    final bool isFavorite = await isTeamFavorite(teamId);
    if (isFavorite) {
      return await removeTeamFromFavorites(teamId);
    } else {
      return await addTeamToFavorites(teamId);
    }
  }

  // Clear all favorites
  static Future<bool> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final bool playersCleared = await prefs.remove(_playersKey);
    final bool teamsCleared = await prefs.remove(_teamsKey);
    return playersCleared && teamsCleared;
  }
}
