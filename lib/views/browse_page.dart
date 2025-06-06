import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:footinfo_app/models/player.dart';
import 'package:footinfo_app/models/team.dart';
import 'package:footinfo_app/views/player_detail.dart';
import 'package:footinfo_app/views/random_player_page.dart';
import 'package:footinfo_app/views/team_detail.dart';
import 'package:http/http.dart' as http;

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchType = 'team';
  bool _isLoading = false;
  int _visibleCount = 10;

  List<dynamic> _allTeams = [];
  List<dynamic> _allPlayers = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        if (_searchType == 'team' && _visibleCount < _allTeams.length) {
          _visibleCount += 10;
        } else if (_searchType == 'player' &&
            _visibleCount < _allPlayers.length) {
          _visibleCount += 10;
        }
      });
    }
  }

  Future<void> _search({bool isNewSearch = true}) async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
      if (isNewSearch) {
        _visibleCount = 10;
        _allTeams = [];
        _allPlayers = [];
      }
    });

    final url = _searchType == 'team'
        ? 'https://v3.football.api-sports.io/teams?search=$keyword'
        : 'https://v3.football.api-sports.io/players/profiles?search=$keyword';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-apisports-host': 'v3.football.api-sports.io',
        'x-apisports-key': '86ab1cfe67a66269855aa7f7d32ce1e7',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['response'] as List;

      setState(() {
        if (_searchType == 'team') {
          _allTeams.addAll(results.map((e) => Team.fromJson(e)).toList());
        } else {
          _allPlayers.addAll(results.map((e) => Player.fromJson(e)).toList());
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Gagal memuat data tim');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTeams = _allTeams.take(_visibleCount).toList();
    final displayPlayers = _allPlayers.take(_visibleCount).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Browse'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RandomPlayerPage()),
              );
            },
            icon: Icon(Icons.shuffle_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search ${_searchType == 'team' ? 'teams' : 'players'}...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _allTeams = [];
                                _allPlayers = [];
                              });
                            },
                          )
                        : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Filter pill
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text('Team'),
                  selected: _searchType == 'team',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _searchType = 'team';
                        _visibleCount = 10;
                        _controller.clear();
                        _allTeams = [];
                        _allPlayers = [];
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Player'),
                  selected: _searchType == 'player',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _searchType = 'player';
                        _visibleCount = 10;
                        _controller.clear();
                        _allTeams = [];
                        _allPlayers = [];
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Loading
            if (_isLoading) const CircularProgressIndicator(),

            // Results
            Expanded(
              child: _searchType == 'team'
                  ? ListView.builder(
                      controller: _scrollController,
                      itemCount: displayTeams.length,
                      itemBuilder: (context, index) {
                        final team = displayTeams[index];
                        return ListTile(
                          leading: Image.network(team.logo, width: 40),
                          title: Text(team.name),
                          subtitle: Text(team.country),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TeamDetailPage(team: team),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: displayPlayers.length,
                      itemBuilder: (context, index) {
                        final player = displayPlayers[index];
                        return ListTile(
                          leading: Image.network(player.photo, width: 40),
                          title: Text(player.name),
                          subtitle: Text(player.nationality),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlayerDetailPage(player: player),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
