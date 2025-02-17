import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../flutter_slash_game.dart';
// Import your main game file

class MainMenu extends StatelessWidget {
  final FlutterSlashGame game;

  const MainMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    game.startBgm();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
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
            child: const Text('Start'),
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
              SystemNavigator.pop();
              Navigator.pop(context);
              exit(0);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
