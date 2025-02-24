import 'package:flutter/material.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';

class GameOverScreen extends StatelessWidget {
  final FlutterSlashGame game;

  const GameOverScreen(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Game Over',
            style: TextStyle(fontSize: 48, color: Colors.white),
          ),
          //ElevatedButton(
          //  onPressed: () {
          //    game.restartGame();
          //  },
          //  child: const Text('Restart'),
          //),
        ],
      ),
    );
  }
}
