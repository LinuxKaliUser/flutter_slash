import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'package:flutter_slash/game/flutterslash.dart';

class PlayerCharacter extends SpriteAnimationComponent with HasGameRef<FlutterSlashGame>, KeyboardHandler {
  Vector2 velocity = Vector2.zero();
  final double speed = 200;

  static const double _spriteWidth = 32.0;
  static const double _spriteHeight = 32.0;
  static const double _animationSpeed = 0.1;
  static const double _scalingFactor = 2.4;

  late final SpriteAnimation downAnimation;
  late final SpriteAnimation leftAnimation;
  late final SpriteAnimation rightAnimation;
  late final SpriteAnimation upAnimation;
  late final SpriteAnimation idleAnimation;

  PlayerCharacter() : super(size: Vector2(_spriteWidth, _spriteHeight) * _scalingFactor, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final spriteSheet = await gameRef.images.load('pipo-nekonin.png');
    final spriteSheetSize = Vector2(_spriteWidth, _spriteHeight);

    downAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: spriteSheetSize,
        stepTime: _animationSpeed,
        texturePosition: Vector2(0, 0),
      ),
    );

    leftAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: spriteSheetSize,
        stepTime: _animationSpeed,
        texturePosition: Vector2(0, _spriteHeight),
      ),
    );

    rightAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: spriteSheetSize,
        stepTime: _animationSpeed,
        texturePosition: Vector2(0, _spriteHeight * 2),
      ),
    );

    upAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: spriteSheetSize,
        stepTime: _animationSpeed,
        texturePosition: Vector2(0, _spriteHeight * 3),
      ),
    );

    idleAnimation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: spriteSheetSize,
        stepTime: _animationSpeed,
        texturePosition: Vector2(_spriteWidth, 0),
      ),
    );

    animation = downAnimation;
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.add(velocity * dt);

    if (velocity.x != 0 || velocity.y != 0) {
      if (velocity.y < 0) {
        animation = upAnimation;
      } else if (velocity.y > 0) {
        animation = downAnimation;
      } else if (velocity.x < 0) {
        animation = leftAnimation;
      } else if (velocity.x > 0) {
        animation = rightAnimation;
      }
    } else {
      animation = idleAnimation;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    velocity = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      velocity.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      velocity.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      velocity.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      velocity.x += 1;
    }

    velocity = velocity.normalized() * speed;

    return true;
  }
}
