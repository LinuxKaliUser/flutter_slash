import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show Paint, Colors, EdgeInsets;

import 'package:flutter_slash/game/flutter_slash_game.dart';
import 'package:flutter_slash/game/weapon.dart';
import 'package:flutter_slash/game/enemy.dart';

class PlayerCharacter extends SpriteAnimationComponent
    with HasGameRef<FlutterSlashGame>, KeyboardHandler, CollisionCallbacks {
  // Constants
  static const double _spriteWidth = 32.0;
  static const double _spriteHeight = 32.0;
  static const double _animationSpeed = 0.1;
  static const double _scalingFactor = 2.4;
  static const double _speed = 200;

  // Fields
  Vector2 velocity = Vector2.zero();

  Weapon? weapon;
  bool firing = false;

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
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());
    await _loadAnimations();

    position = gameRef.size / 2;

    _initializeWeapon();
    if (gameRef.isMobile) {
      _initializeJoysticks();
    }
  }

  @override
  void onRemove() {
    weapon?.removeFromParent();
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

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isMobile) {
      _handleJoystickInput();
    }

    position.add(velocity * dt);
    _updateAnimation();
    weapon?.position = position;
    if (firing) {
      weapon?.fire();
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (gameRef.isMobile) return false;

    _handleKeyboardInput(keysPressed);
    return true;
  }

  void onTapDown() {
    if (gameRef.isMobile) return;

    firing = true;
  }

  void onTapUp() {
    if (gameRef.isMobile) return;

    firing = false;
  }

  void onMouseMove(Vector2 mousePosition) {
    if (gameRef.isMobile) return;

    final direction = (mousePosition - gameRef.size / 2);
    final angle = atan2(direction.y, direction.x);

    weapon?.angle = angle;
    weapon?.setFacing(angle.abs() < pi / 2);
  }

  Future<void> _loadAnimations() async {
    final spriteSheet = await Flame.images.load('player/pipo-nekonin.png');

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

  void _initializeWeapon() {
    weapon = Weapon.ak47;

    if (weapon != null) {
      gameRef.world.add(weapon!);
    }
  }

  void _initializeJoysticks() {
    movementJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.blue),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.grey.withOpacity(0.5),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      priority: 10,
    );

    fireJoystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: Paint()..color = Colors.blue),
      background: CircleComponent(
        radius: 60,
        paint: Paint()..color = Colors.grey.withOpacity(0.5),
      ),
      margin: const EdgeInsets.only(right: 40, bottom: 40),
      priority: 10,
    );

    gameRef.camera.viewport.add(movementJoystick);
    gameRef.camera.viewport.add(fireJoystick);
  }

  void _handleJoystickInput() {
    velocity = movementJoystick.relativeDelta.normalized() * _speed;

    if (weapon != null && fireJoystick.relativeDelta != Vector2.zero()) {
      final angle =
          atan2(fireJoystick.relativeDelta.y, fireJoystick.relativeDelta.x);

      weapon!.angle = angle;
      weapon!.setFacing(angle.abs() < pi / 2);
      weapon!.fire();
    }
  }

  void _handleKeyboardInput(Set<LogicalKeyboardKey> keysPressed) {
    velocity = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW)) velocity.y -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) velocity.y += 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) velocity.x -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) velocity.x += 1;

    velocity = velocity.normalized() * _speed;

    if (weapon != null && keysPressed.contains(LogicalKeyboardKey.space)) {
      weapon!.fire();
    }
  }

  void _updateAnimation() {
    if (velocity != Vector2.zero()) {
      final facing = _determineDirection(velocity);

      switch (facing) {
        case 'north':
          priority = 2;
          weapon?.priority = 1;
          animation = upAnimation;
          break;
        case 'south':
          priority = 1;
          weapon?.priority = 2;
          animation = downAnimation;
          break;
        case 'west':
          priority = 2;
          weapon?.priority = 1;
          animation = leftAnimation;
          break;
        case 'east':
          priority = 1;
          weapon?.priority = 2;
          animation = rightAnimation;
          break;
      }
    } else {
      animation = idleAnimation;
    }
  }

  String _determineDirection(Vector2 direction) {
    if (direction.x.abs() > direction.y.abs()) {
      return direction.x > 0 ? 'east' : 'west';
    }
    return direction.y > 0 ? 'south' : 'north';
  }
}
