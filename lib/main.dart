import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/flutter_slash_game.dart';
import 'game/menu/game_over_screen.dart';
import 'game/menu/main_menu.dart';
import 'game/menu/option_menu.dart';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Flame.device.fullScreen();
  final game = new FlutterSlashGame();

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: game,
              overlayBuilderMap: {
                'MainMenu': (context, game) =>
                    MainMenu(game as FlutterSlashGame),
                'GameOverScreen': (context, game) =>
                    GameOverScreen(game as FlutterSlashGame),
                'OptionsMenu': (context, game) =>
                    OptionsMenu(game as FlutterSlashGame),
              },
              initialActiveOverlays: ['MainMenu'], // Show menu first
            ),
          ],
        ),
      ),
    ),
  );
}
