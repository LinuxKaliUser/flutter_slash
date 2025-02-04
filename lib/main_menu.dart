import 'package:flutter/material.dart';
import 'main.dart'; // Import your main game file

class MainMenu extends StatelessWidget {
  final FlutterSlashGame game;

  const MainMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Main Menu',
            style: TextStyle(fontSize: 48, color: Colors.white),
          ),
          ElevatedButton(
            onPressed: () {
              game.overlays.remove('MainMenu'); // Remove the menu
              game.resumeEngine();
            },
            child: const Text('Start Game'),
          ),
          ElevatedButton(
            onPressed: () {
              game.overlays.add('OptionsMenu');
              game.pauseEngine();
            },
            child: const Text('Options'),
          ),
          ElevatedButton(
            onPressed: () {
              game.overlays.add('CloseMenu');
              game.gameOver();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}