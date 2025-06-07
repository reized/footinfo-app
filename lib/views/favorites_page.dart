import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../views/player_detail.dart';
import '../views/team_detail.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<int> _favoritePlayers = [];
  List<int> _favoriteTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final players = await FavoriteService.getFavoritePlayers();
      final teams = await FavoriteService.getFavoriteTeams();

      setState(() {
        _favoritePlayers = players;
        _favoriteTeams = teams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllFavorites() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: const Text(
            'Are you sure you want to remove all items from your favorites? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FavoriteService.clearAllFavorites();
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All favorites cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (_favoritePlayers.isNotEmpty || _favoriteTeams.isNotEmpty)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all favorites',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.person),
              text: 'Players (${_favoritePlayers.length})',
            ),
            Tab(
              icon: const Icon(Icons.shield_outlined),
              text: 'Teams (${_favoriteTeams.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildPlayersTab(), _buildTeamsTab()],
            ),
    );
  }

  Widget _buildPlayersTab() {
    if (_favoritePlayers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_outline,
        title: 'No Favorite Players',
        message: 'Add players to your favorites to see them here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoritePlayers.length,
        itemBuilder: (context, index) {
          final playerId = _favoritePlayers[index];
          return _buildPlayerCard(playerId);
        },
      ),
    );
  }

  Widget _buildTeamsTab() {
    if (_favoriteTeams.isEmpty) {
      return _buildEmptyState(
        icon: Icons.shield_outlined,
        title: 'No Favorite Teams',
        message: 'Add teams to your favorites to see them here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteTeams.length,
        itemBuilder: (context, index) {
          final teamId = _favoriteTeams[index];
          return _buildTeamCard(teamId);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(int playerId) {
    // Note: In a real app, you would fetch player data from your API or database
    // For now, we'll show a placeholder card with the player ID
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text('P', style: const TextStyle(color: Colors.white)),
        ),
        title: Text('Player #$playerId'),
        subtitle: const Text('Tap to view details'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removePlayerFromFavorites(playerId),
              tooltip: 'Remove from favorites',
            ),
          ],
        ),
        onTap: () {
          // Note: In a real app, you would navigate to player detail
          // For now, we'll show a placeholder
          _showPlayerNotAvailable(playerId);
        },
      ),
    );
  }

  Widget _buildTeamCard(int teamId) {
    // Note: In a real app, you would fetch team data from your API or database
    // For now, we'll show a placeholder card with the team ID
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text('T', style: const TextStyle(color: Colors.white)),
        ),
        title: Text('Team #$teamId'),
        subtitle: const Text('Tap to view details'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeTeamFromFavorites(teamId),
              tooltip: 'Remove from favorites',
            ),
          ],
        ),
        onTap: () {
          // Note: In a real app, you would navigate to team detail
          // For now, we'll show a placeholder
          _showTeamNotAvailable(teamId);
        },
      ),
    );
  }

  Future<void> _removePlayerFromFavorites(int playerId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Favorites'),
          content: const Text('Remove this player from your favorites?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FavoriteService.removePlayerFromFavorites(playerId);
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Player removed from favorites'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _removeTeamFromFavorites(int teamId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Favorites'),
          content: const Text('Remove this team from your favorites?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FavoriteService.removeTeamFromFavorites(teamId);
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Team removed from favorites'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showPlayerNotAvailable(int playerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Player Details'),
          content: Text(
            'Player #$playerId details would be shown here.\n\n'
            'In a complete implementation, this would fetch player data and navigate to the PlayerDetailPage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTeamNotAvailable(int teamId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Team Details'),
          content: Text(
            'Team #$teamId details would be shown here.\n\n'
            'In a complete implementation, this would fetch team data and navigate to the TeamDetailPage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
