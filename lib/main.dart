import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

import 'game_over_screen.dart';
import 'main_menu.dart';
import 'option_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();

  final game = FlutterSlashGame();

  runApp(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: game,
              overlayBuilderMap: {
                'MainMenu': (context, game) => MainMenu(game as FlutterSlashGame),
                'GameOverScreen': (context, game) => GameOverScreen(game as FlutterSlashGame),
                'OptionsMenu': (context, game) => OptionsMenu(game as FlutterSlashGame),
              },
              initialActiveOverlays: ['MainMenu'], // Show menu first
            ),
          ],
        ),
      ),
    ),
  );
}


// Game logic handled here
class FlutterSlashGame extends FlameGame with HasKeyboardHandlerComponents {
  late PlayerCharacter player;
  double backgroundMusicVolume = 0.5;

  @override
  Future<void> onLoad() async {
    player = PlayerCharacter();
    add(player);
    FlameAudio.bgm.initialize();
    await FlameAudio.bgm.play('background_music.mp3', volume: backgroundMusicVolume);
  }

  void gameOver() {
    overlays.add('GameOverScreen');
  }

  void restartGame() {
    overlays.remove('GameOverScreen');
    resumeEngine();
  }
  void exitGame() {

  }

  void setBackgroundMusicVolume(double volume) {
    backgroundMusicVolume = volume;
    FlameAudio.bgm.audioPlayer.setVolume(volume);

  }
}

// Player character handling movement
class PlayerCharacter extends SpriteComponent with KeyboardHandler {
  Vector2 velocity = Vector2.zero();
  final double speed = 200;

  PlayerCharacter() : super(size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('bingus.png');
    position = Vector2(100, 100);
  }

  @override
  void update(double dt) {
    position.add(velocity * dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    velocity = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      velocity.y = -speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      velocity.y = speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      velocity.x = -speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      velocity.x = speed;
    }
    return true;
  }
}