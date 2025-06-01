import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerDetailPage extends StatelessWidget {
  final Player player;

  const PlayerDetailPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(player.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(player.photo, height: 100),
            const SizedBox(height: 16),
            Text(
              player.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Age: ${player.age}"),
            const SizedBox(height: 8),
            Text("Nationality: ${player.nationality}"),
            const SizedBox(height: 8),
            Text("Position: ${player.position}"),
            const SizedBox(height: 8),
            Text("Height: ${player.height}"),
            const SizedBox(height: 8),
            Text("Weight: ${player.weight}"),
          ],
        ),
      ),
    );
  }
}
