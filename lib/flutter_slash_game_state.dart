import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'main_menu.dart';  // Import your menu files

class FlutterSlashGameState extends FlameGame {
  late BuildContext context;

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  void openMenu() {
    overlays.add('MainMenu');
  }

  void openOptionMenu() {
    overlays.add('OptionMenu');
  }

  void closeMenu() {
    overlays.remove('MainMenu');
  }
/*
  void pauseGame() {
    pauseEngine();
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    resumeEngine();
    overlays.remove('PauseMenu');
  }
*/
  void gameOver() {
    overlays.add('GameOverScreen');
  }

  void restartGame() {
    overlays.remove('GameOverScreen');
    // Reset game state here
    resumeEngine();
  }
}
