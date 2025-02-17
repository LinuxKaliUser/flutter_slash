import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'package:flutter_slash/game/flutterslash.dart';
import 'package:flutter_slash/game/player.dart';
import 'package:flutter_slash/game/bullet.dart';

class EnemyCharacter extends SpriteAnimationComponent
    with HasGameRef<FlutterSlashGame>, CollisionCallbacks {
  static const double _spriteWidth = 16.0;
  static const double _spriteHeight = 16.0;
  static const double _animationSpeed = 0.1;
  static const double _scalingFactor = 3;
  static const double _minSeparation = 300.0; // Minimum allowed distance
  static const double _separationWeight = 20; // Stronger repulsion
  static const double _alignmentWeight = 0.5;
  static const double _cohesionWeight = 0.125;
  static const double _targetWeight = 5;

  static const double speed = 60;

  Vector2 velocity = Vector2.zero();
  PlayerCharacter player;
  late List<EnemyCharacter> flock;

  late final SpriteAnimation downAnimation;
  late final SpriteAnimation leftAnimation;
  late final SpriteAnimation rightAnimation;
  late final SpriteAnimation upAnimation;
  late final SpriteAnimation idleAnimation;

  EnemyCharacter(this.player)
      : super(
      size: Vector2(_spriteWidth, _spriteHeight) * _scalingFactor,
      priority: 2,
      anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());
    await _loadAnimations();

    final Random random = Random();
    do {
      position.x = random.nextDouble() * gameRef.size.x;
      position.y = random.nextDouble() * gameRef.size.y;
    } while ((!(position.x > gameRef.size.x * 0.75 || position.x < gameRef.size.x * 0.25 || position.y > gameRef.size.y * 0.75 || position.y < gameRef.size.y * 0.25)));
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is PlayerCharacter) {
      other.removeFromParent();
    } else if (other is Bullet) {
      other.removeFromParent();
      removeFromParent();
    }
  }

  Future<void> _loadAnimations() async {

    downAnimation = await _loadAnimation(await Flame.images.load('Chicken/ChickenWalk.png'), 4, Vector2(0, 0));
    leftAnimation =
    await _loadAnimation(await Flame.images.load('Chicken/ChickenSideWalkLeft.png'), 4, Vector2(0, 0));
    rightAnimation =
    await _loadAnimation(await Flame.images.load('Chicken/ChickenSideWalkRight.png'), 4, Vector2(0, 0));
    upAnimation =
    await _loadAnimation(await Flame.images.load('Chicken/ChickenWalkBack.png'), 4, Vector2(0, 0));
    idleAnimation =
    await _loadAnimation(await Flame.images.load('Chicken/ChickenIdle.png'), 1, Vector2(0, 0));

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
    Vector2 separation = Vector2.zero();
    Vector2 alignment = Vector2.zero();
    Vector2 cohesion = Vector2.zero();
    double total = 0;

    for (var other in flock) {
      if (other == this) continue;

      double distance = position.distanceTo(other.position);

      if (distance > 0) {
        // ✅ STRONG separation force to prevent overlap
        if (distance < _minSeparation) {
          Vector2 repel = (position - other.position).normalized();
          separation += repel * (_minSeparation / distance);  // Stronger push
        }

        alignment += other.velocity;
        cohesion += other.position;
        total++;
      }
    }

    if (total > 0) {
      separation /= total;
      alignment /= total;
      cohesion /= total;

      cohesion -= position;

      velocity += (separation * _separationWeight) +
          (alignment * _alignmentWeight) +
          (cohesion * _cohesionWeight);
    }

    // ✅ Move toward target
    Vector2 targetForce = (player.position - position).normalized() * _targetWeight;
    velocity += targetForce;

    velocity.clampLength(0, speed);
    position += velocity * dt;

    position.add(velocity * dt);

    if (velocity.x >= 5 || velocity.x <= -5 || velocity.y >= 5 ||velocity.y <= -5) {
      if (velocity.y < -0.7 * speed) {
        animation = upAnimation;
      } else if (velocity.y > 0.7 * speed) {
        animation = downAnimation;
      } else if (velocity.x < -0.7 * speed) {
        animation = leftAnimation;
      } else if (velocity.x > 0.7 * speed) {
        animation = rightAnimation;
      }
    } else {
      animation = idleAnimation;
    }
  }
}
