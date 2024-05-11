import 'package:flutter/material.dart';
import 'package:memory_game/pages/game_page.dart';

class LevelSelectionPage extends StatelessWidget {
  const LevelSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GamePage(level: 1),
                  ),
                );
              },
              child: const Text('Level 1'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GamePage(level: 2),
                  ),
                );
              },
              child: const Text('Level 2'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GamePage(level: 3),
                  ),
                );
              },
              child: const Text('Level 3'),
            ),
          ],
        ),
      ),
    );
  }
}
