import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';

class Bullet extends SpriteComponent with HasGameRef<FlutterSlashGame> {
  double speed;

  late Vector2 direction;
  late RectangleHitbox hitbox;

  Bullet({super.position, required this.speed, super.angle})
      : super(size: Vector2(36, 36), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    direction = Vector2(cos(angle), sin(angle)).normalized();
    position += direction * 50;

    sprite = await game.loadSprite('weapons/sprites/ammo/ak-47/bullet.png');
    hitbox = RectangleHitbox(collisionType: CollisionType.passive);
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * speed * dt;

    if (position.x < gameRef.player.position.x - gameRef.size.x / 2
        || position.x > gameRef.player.position.x + gameRef.size.x / 2
        || position.y < gameRef.player.position.y - gameRef.size.y / 2
        || position.y > gameRef.player.position.y + gameRef.size.y / 2
    ) {
      removeFromParent();
    }
  }
}
