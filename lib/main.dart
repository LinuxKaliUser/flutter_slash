import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(GameWidget(game: FlutterSlashGame()));
}

class FlutterSlashGame extends FlameGame with HasKeyboardHandlerComponents {
  late PlayerCharacter player;

  @override
  Future<void> onLoad() async {
    player = PlayerCharacter();
    add(player);
  }
}

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
