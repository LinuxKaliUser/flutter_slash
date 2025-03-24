import 'package:flutter/material.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';

class GameOverScreen extends StatelessWidget {
  final FlutterSlashGame game;

  const GameOverScreen({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Game Over',
            style: TextStyle(fontSize: 48, color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildMenuButton('Main Menu', () {
            game.overlays.remove('GameOverScreen');
            game.overlays.add('MainMenu');
            game.restartGame();
            game.pauseEngine();
          }),
          const SizedBox(height: 20),
          _buildMenuButton('Restart', () {
            game.overlays.remove('GameOverScreen');
            game.restartGame();
          }),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
