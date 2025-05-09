import 'dart:math';

import 'package:flutter/painting.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';

class Bullet extends SpriteComponent with HasGameRef<FlutterSlashGame> {
  final double speed;
  final Vector2 direction;

  late RectangleHitbox hitbox;

  Bullet(
      {required Vector2 position, required this.speed, required double angle})
      : direction = Vector2(cos(angle), sin(angle)).normalized(),
        super(
            position: position,
            size: Vector2(36, 36),
            anchor: Anchor.center,
            angle: angle);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    position += direction * 50;

    sprite = await game.loadSprite('weapons/sprites/ammo/ak-47/bullet.png');

    hitbox = RectangleHitbox(collisionType: CollisionType.passive);
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _move(dt);
    _checkBounds();
  }

  void _move(double dt) {
    position += direction * speed * dt;
  }

  void _checkBounds() {
    final maxDistance =
        sqrt(gameRef.size.x * gameRef.size.x + gameRef.size.y * gameRef.size.y);
    final playerPosition = gameRef.gameState.player.position;
    final distance = playerPosition.distanceTo(position);

    if (distance > maxDistance) {
      removeFromParent();
    }
  }
}
