import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart' show JoystickComponent, CircleComponent;
import 'package:flutter/material.dart' show Paint, Colors, EdgeInsets;

import 'package:flutter_slash/game/flutter_slash_game.dart';
import 'package:flutter_slash/game/weapon.dart';
import 'package:flutter_slash/game/enemy.dart';

class PlayerCharacter extends SpriteAnimationComponent
    with HasGameRef<FlutterSlashGame>, KeyboardHandler, CollisionCallbacks {
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

  late JoystickComponent movementJoystick;
  late JoystickComponent fireJoystick;

  PlayerCharacter()
      : super(
            size: Vector2(_spriteWidth, _spriteHeight) * _scalingFactor,
            priority: 1,
            anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());
    await _loadAnimations();

    position = gameRef.size / 2;

    weapon = Weapon(
      damage: 10,
      fireRate: 10,
      bulletSpeed: 600,
      size: Vector2(72, 36),
    );

    if (weapon != null) {
      gameRef.world.add(weapon!);
    }
    gameRef.camera.viewport = FixedResolutionViewport(resolution: Vector2(1280, 720));
    if (gameRef.isMobile) {
      // Initialize and add the joystick component
      movementJoystick = JoystickComponent(
          knob:
              CircleComponent(radius: 30, paint: Paint()..color = Colors.blue),
          background: CircleComponent(
              radius: 90,
              paint: Paint()..color = Colors.grey.withValues(alpha: 0.5)),
          margin: const EdgeInsets.only(left: 50, bottom: 50),
          priority: 10);
      fireJoystick = JoystickComponent(
          knob:
              CircleComponent(radius: 30, paint: Paint()..color = Colors.blue),
          background: CircleComponent(
              radius: 90,
              paint: Paint()..color = Colors.grey.withValues(alpha: 0.5)),
          margin: const EdgeInsets.only(right: 50, bottom: 50),
          priority: 10);

      gameRef.camera.viewport.add(movementJoystick);
      gameRef.camera.viewport.add(fireJoystick);
    }
  }

  @override
  void onRemove() {
    if (weapon != null) {
      weapon!.removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is EnemyCharacter) {
      removeFromParent();
      gameRef.gameOver();
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

    // Joytick movement
    if (gameRef.isMobile) {
      velocity = movementJoystick.relativeDelta.normalized() * speed;
      if (weapon != null && fireJoystick.relativeDelta != Vector2.zero()) {
        final angle =
            atan2(fireJoystick.relativeDelta.y, fireJoystick.relativeDelta.x);

        weapon!.angle = angle;
        weapon!.setFacing(angle.abs() < pi / 2);

        weapon!.fire();
      }
    }

    // Keyboard movement
    position.add(velocity * dt);

    if (velocity != Vector2.zero()) {
      String facing = determineDirection(velocity);

      if (facing == 'north') {
        priority = 2;
        weapon?.priority = 1;
        animation = upAnimation;
      } else if (facing == 'south') {
        priority = 1;
        weapon?.priority = 2;
        animation = downAnimation;
      } else if (facing == 'west') {
        priority = 2;
        weapon?.priority = 1;
        animation = leftAnimation;
      } else if (facing == 'east') {
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

  String determineDirection(Vector2 direction) {
    if (direction.x.abs() > direction.y.abs()) {
      // East or West
      return direction.x > 0 ? 'east' : 'west';
    } else if (direction.y.abs() > direction.x.abs()) {
      // North or South
      return direction.y > 0 ? 'south' : 'north';
    } else {
      // Tie case, prefer south or north
      return direction.y >= 0 ? 'south' : 'north';
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (gameRef.isMobile) {
      return false;
    }

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
        weapon!.fire();
      }
    }

    return true;
  }

  void onTapDown() {
    if (weapon != null) {
      weapon!.fire();
    }
  }

  void onMouseMove(Vector2 mousePosition) {
    if (gameRef.isMobile) {
      return;
    }

    final direction = (mousePosition - gameRef.size / 2);
    final angle = atan2(direction.y, direction.x);

    if (weapon != null) {
      weapon!.angle = angle;
      weapon!.setFacing(angle.abs() < pi / 2);
    }
  }
}
