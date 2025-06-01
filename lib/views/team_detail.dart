import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamDetailPage extends StatelessWidget {
  final Team team;

  const TeamDetailPage({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(team.logo, height: 100),
            const SizedBox(height: 16),
            Text(
              team.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Country: ${team.country}"),
            const SizedBox(height: 8),
            Text("Stadium: ${team.venueName}"),
          ],
        ),
      ),
    );
  }
}
