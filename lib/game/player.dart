import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';
import 'package:flutter_slash/game/weapon.dart';

class PlayerCharacter extends SpriteAnimationComponent
    with HasGameRef<FlutterSlashGame>, KeyboardHandler {
  static const double _spriteWidth = 32.0;
  static const double _spriteHeight = 32.0;
  static const double _animationSpeed = 0.1;
  static const double _scalingFactor = 2.4;

  static const double speed = 200;

  Vector2 velocity = Vector2.zero();

  Weapon? weapon;

  late final SpriteAnimation downAnimation;
  late final SpriteAnimation leftAnimation;
  late final SpriteAnimation rightAnimation;
  late final SpriteAnimation upAnimation;
  late final SpriteAnimation idleAnimation;

  PlayerCharacter()
      : super(
            size: Vector2(_spriteWidth, _spriteHeight) * _scalingFactor,
            priority: 1,
            anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _loadAnimations();

    position = gameRef.size / 2;

    weapon = Weapon(
      damage: 10,
      fireRate: 10,
      bulletSpeed: 300,
      size: Vector2(72, 36),
    );

    if (weapon != null) {
      gameRef.world.add(weapon!);
    }
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = await Flame.images.load('pipo-nekonin.png');

    downAnimation = await _loadAnimation(spriteSheet, 3, Vector2(0, 0));
    leftAnimation =
        await _loadAnimation(spriteSheet, 3, Vector2(0, _spriteHeight * 1));
    rightAnimation =
        await _loadAnimation(spriteSheet, 3, Vector2(0, _spriteHeight * 2));
    upAnimation =
        await _loadAnimation(spriteSheet, 3, Vector2(0, _spriteHeight * 3));
    idleAnimation =
        await _loadAnimation(spriteSheet, 1, Vector2(_spriteWidth, 0));

    animation = idleAnimation;
  }

  Future<SpriteAnimation> _loadAnimation(
      Image spriteSheet, int frameCount, Vector2 texturePosition) async {
    return SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: frameCount,
        textureSize: Vector2(_spriteWidth, _spriteHeight),
        stepTime: _animationSpeed,
        texturePosition: texturePosition,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.add(velocity * dt);

    if (velocity.x != 0 || velocity.y != 0) {
      if (velocity.y < 0) {
        priority = 2;
        weapon?.priority = 1;
        animation = upAnimation;
      } else if (velocity.y > 0) {
        priority = 1;
        weapon?.priority = 2;
        animation = downAnimation;
      } else if (velocity.x < 0) {
        priority = 2;
        weapon?.priority = 1;
        animation = leftAnimation;
      } else if (velocity.x > 0) {
        priority = 1;
        weapon?.priority = 2;
        animation = rightAnimation;
      }
    } else {
      animation = idleAnimation;
    }

    if (weapon != null) {
      weapon!.position = position;
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

    if (weapon != null) {
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        weapon!.playFire();
      } else {
        weapon!.playIdle();
      }
    }

    return true;
  }

  void onMouseMove(Vector2 mousePosition) {
    final direction = (mousePosition - gameRef.size / 2);
    final angle = atan2(direction.y, direction.x);

    if (weapon != null) {
      weapon!.angle = angle;
      weapon!.setFacing(angle.abs() < pi / 2);
    }
  }
}
