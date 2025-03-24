import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';
import 'package:flutter_slash/game/player.dart';
import 'package:flutter_slash/game/bullet.dart';

class EnemyCharacter extends SpriteAnimationComponent
    with HasGameRef<FlutterSlashGame>, CollisionCallbacks {
  static const double _spriteWidth = 16.0;
  static const double _spriteHeight = 16.0;
  static const double _animationSpeed = 0.1;
  static const double _scalingFactor = 3;
  static const double _minSeparation = 300.0;
  static const double _separationWeight = 20;
  static const double _alignmentWeight = 0.5;
  static const double _cohesionWeight = 0.125;
  static const double _targetWeight = 25;
  static const double speed = 180;

  final PlayerCharacter player;
  late List<EnemyCharacter> flock;
  Vector2 velocity = Vector2.zero();

  late final Map<String, SpriteAnimation> animations;

  EnemyCharacter(this.player)
      : super(
          size: Vector2(_spriteWidth, _spriteHeight) * _scalingFactor,
          priority: 2,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    await _loadAnimations();
    _initializePosition();
  }

  Future<void> _loadAnimations() async {
    animations = {
      'down': await _createAnimation('chicken/chickenwalk.png', 4),
      'left': await _createAnimation('chicken/chickensidewalkleft.png', 4),
      'right': await _createAnimation('chicken/chickensidewalkright.png', 4),
      'up': await _createAnimation('chicken/chickenwalkback.png', 4),
      'idle': await _createAnimation('chicken/chickenidle.png', 1),
    };
    animation = animations['idle'];
  }

  Future<SpriteAnimation> _createAnimation(
      String path, int frameCount) async {
    final spriteSheet = await Flame.images.load(path);
    return SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: frameCount,
        textureSize: Vector2(_spriteWidth, _spriteHeight),
        stepTime: _animationSpeed,
      ),
    );
  }

  void _initializePosition() {
    final random = Random();
    do {
      position.x = random.nextDouble() * gameRef.size.x;
      position.y = random.nextDouble() * gameRef.size.y;
    } while (_isPositionTooCloseToCenter());
  }

  bool _isPositionTooCloseToCenter() {
    final center = gameRef.size / 2;
    return (position - center).length < _minSeparation;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      other.removeFromParent();
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _applyFlockingBehavior();
    _moveTowardsPlayer();
    _updatePosition(dt);
    _updateAnimation();
  }

  void _applyFlockingBehavior() {
    Vector2 separation = Vector2.zero();
    Vector2 alignment = Vector2.zero();
    Vector2 cohesion = Vector2.zero();
    int total = 0;

    for (var other in flock) {
      if (other == this) continue;

      final distance = position.distanceTo(other.position);
      if (distance > 0) {
        if (distance < _minSeparation) {
          separation += (position - other.position).normalized() *
              (_minSeparation / distance);
        }
        alignment += other.velocity;
        cohesion += other.position;
        total++;
      }
    }

    if (total > 0) {
      separation /= total.toDouble();
      alignment /= total.toDouble();
      cohesion = (cohesion / total.toDouble()) - position;

      velocity += (separation * _separationWeight) +
          (alignment * _alignmentWeight) +
          (cohesion * _cohesionWeight);
    }
  }

  void _moveTowardsPlayer() {
    final targetForce =
        (player.position - position).normalized() * _targetWeight;
    velocity += targetForce;
    velocity.clampLength(0, speed);
  }

  void _updatePosition(double dt) {
    position += velocity * dt;
  }

  void _updateAnimation() {
    if (velocity.length > 5) {
      if (velocity.y < -0.7 * speed) {
        animation = animations['up'];
      } else if (velocity.y > 0.7 * speed) {
        animation = animations['down'];
      } else if (velocity.x < -0.7 * speed) {
        animation = animations['left'];
      } else if (velocity.x > 0.7 * speed) {
        animation = animations['right'];
      }
    } else {
      animation = animations['idle'];
    }
  }
}
