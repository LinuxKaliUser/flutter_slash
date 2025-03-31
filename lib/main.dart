import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/flutter_slash_game.dart';
import 'menu/game_over_screen.dart';
import 'menu/main_menu.dart';
import 'menu/option_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      GameWidget<FlutterSlashGame>.controlled(
        gameFactory: FlutterSlashGame.new,
        overlayBuilderMap: {
          'MainMenu': (_, game) => MainMenu(game: game),
          'OptionsMenu': (_, game) => OptionsMenu(game: game),
          'GameOverScreen': (_, game) => GameOverScreen(game: game),
        },
        initialActiveOverlays: const ['MainMenu'], // Show menu first
      ),
    );
  });
}
