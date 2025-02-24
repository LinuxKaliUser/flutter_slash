import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';

class MainMenu extends StatelessWidget {
  final FlutterSlashGame game;

  const MainMenu(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    game.pauseEngine();
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
          const SizedBox(height: 20), // Add spacing between the title and the first button
          SizedBox(
            width: 200, // Set a fixed width for the buttons
            child: ElevatedButton(
              onPressed: () {
                game.overlays.remove('MainMenu'); // Remove the menu
                game.resumeEngine();
              },
              child: const Text('Start'),
            ),
          ),
          const SizedBox(height: 20), // Add spacing between buttons
          SizedBox(
            width: 200, // Set a fixed width for the buttons
            child: ElevatedButton(
              onPressed: () {
                game.overlays.add('OptionsMenu');
                game.pauseEngine();
              },
              child: const Text('Options'),
            ),
          ),
          const SizedBox(height: 20), // Add spacing between buttons
          SizedBox(
            width: 200, // Set a fixed width for the buttons
            child: ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
                Navigator.pop(context);
                exit(0);
              },
              child: const Text('Exit'),
            ),
          ),
        ],
      ),
    );
  }
}
