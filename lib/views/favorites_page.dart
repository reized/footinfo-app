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
  List<Player> _favoritePlayers = [];
  List<Team> _favoriteTeams = [];
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
      final playerIds = await FavoriteService.getFavoritePlayers();
      final teamIds = await FavoriteService.getFavoriteTeams();

      // In a real app, you would fetch the actual data from your API
      // For now, we'll create mock data based on the IDs
      List<Player> players = [];
      List<Team> teams = [];

      // Create mock players from IDs
      for (int id in playerIds) {
        players.add(
          Player(
            id: id,
            name: 'Player $id',
            photo: 'https://via.placeholder.com/100',
            nationality: 'Unknown',
            age: '25',
            position: 'Forward',
            height: '180cm',
            weight: '75kg',
          ),
        );
      }

      // Create mock teams from IDs
      for (int id in teamIds) {
        teams.add(
          Team(
            id: id,
            name: 'Team $id',
            logo: 'https://via.placeholder.com/100',
            country: 'Unknown',
            venueName: 'Stadium $id',
          ),
        );
      }

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
          final player = _favoritePlayers[index];
          return _buildPlayerCard(player);
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
          final team = _favoriteTeams[index];
          return _buildTeamCard(team);
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

  Widget _buildPlayerCard(Player player) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Hero(
          tag: 'player-${player.id}',
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: ClipOval(
              child: Image.network(
                player.photo,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, color: Colors.white);
                },
              ),
            ),
          ),
        ),
        title: Text(player.name),
        subtitle: Text('${player.position} • ${player.nationality}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removePlayerFromFavorites(player.id),
              tooltip: 'Remove from favorites',
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerDetailPage(player: player),
            ),
          ).then((_) => _loadFavorites()); // Refresh when coming back
        },
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Hero(
          tag: 'team-${team.id}',
          child: CircleAvatar(
            backgroundColor: Colors.green,
            child: ClipOval(
              child: Image.network(
                team.logo,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.sports_soccer, color: Colors.white);
                },
              ),
            ),
          ),
        ),
        title: Text(team.name),
        subtitle: Text('${team.country} • ${team.venueName}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeTeamFromFavorites(team.id),
              tooltip: 'Remove from favorites',
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TeamDetailPage(team: team)),
          ).then((_) => _loadFavorites()); // Refresh when coming back
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
}
