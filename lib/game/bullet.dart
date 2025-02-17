import 'dart:math';

import 'package:flame/components.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';

class Bullet extends SpriteComponent with HasGameRef<FlutterSlashGame> {
  double speed;

  late Vector2 direction;

  Bullet({super.position, required this.speed, super.angle})
      : super(size: Vector2(36, 36), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    direction = Vector2(cos(angle), sin(angle)).normalized();
    position += direction * 72;

    sprite = await game.loadSprite('weapons/sprites/ammo/ak-47/bullet.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += direction * speed * dt;

    // TODO: Figure out better way to dispose of bullets
    if (position.length > 10000) {
      removeFromParent();
    }
  }
}
