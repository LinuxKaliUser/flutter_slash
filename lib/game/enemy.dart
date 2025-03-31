import 'dart:math';
import 'dart:async' as time;

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
  static const double _minSeparation = 420.0;
  static const double _maxSeparation = 960.0;
  static const double _maxSpeed = 200.0;
  static const double _perceptionRadius = 520.0;
  static const double _separationDistance =
      1.2 * (_spriteHeight * _scalingFactor);

  final PlayerCharacter player;
  late List<EnemyCharacter> flock;

  Vector2 velocity = Vector2.zero();
  Vector2 acceleration = Vector2.zero();

  late final Map<String, SpriteAnimation> animations;

  EnemyCharacter(this.player)
      : super(
          size: Vector2(_spriteWidth, _spriteHeight) * _scalingFactor,
          priority: 2,
          anchor: Anchor.center,
        ) {
    velocity =
        Vector2(Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1)
          ..scale(_maxSpeed);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _loadAnimations();

    _initializePosition();

    add(RectangleHitbox());
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

  Future<SpriteAnimation> _createAnimation(String path, int frameCount) async {
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
    final angle = random.nextDouble() * 2 * pi;
    final radius = _minSeparation +
        random.nextDouble() * (_maxSeparation - _minSeparation);
    position.x = player.position.x + cos(angle) * radius;
    position.y = player.position.y + sin(angle) * radius;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      other.removeFromParent();
      flock.remove(this);
      removeFromParent();
      gameRef.gameState.score++;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    Vector2 alignment = _align();
    Vector2 cohesion = _cohere();
    Vector2 separation = _separate();
    Vector2 targetSeeking = _seek(gameRef.gameState.player.position);

    acceleration = (alignment +
        cohesion +
        separation +
        targetSeeking +
        _randomJitter())
      ..scale(0.1);

    velocity += acceleration;
    limitSpeed(velocity);
    position += velocity * dt;

    animation = animations[_determineFacing()];
  }

  Vector2 _randomJitter() {
    return Vector2(
        (Random().nextDouble() - 0.5) * 10, (Random().nextDouble() - 0.5) * 10);
  }

  Vector2 _align() {
    Vector2 steering = Vector2.zero();
    int total = 0;
    for (var other in flock) {
      if (other != this &&
          position.distanceTo(other.position) < _perceptionRadius) {
        steering += other.velocity;
        total++;
      }
    }
    if (total > 0) {
      steering /= total.toDouble();
      limitSpeed(steering);
      steering -= velocity;
    }
    return steering;
  }

  Vector2 _cohere() {
    Vector2 steering = Vector2.zero();
    int total = 0;
    for (var other in flock) {
      if (other != this &&
          position.distanceTo(other.position) < _perceptionRadius) {
        steering += other.position;
        total++;
      }
    }
    if (total > 0) {
      steering /= total.toDouble();
      steering -= position;
      limitSpeed(steering);
    }
    return steering;
  }

  Vector2 _separate() {
    Vector2 steering = Vector2.zero();
    int total = 0;
    for (var other in flock) {
      double distance = position.distanceTo(other.position);
      if (other != this && distance < _separationDistance) {
        Vector2 diff = position - other.position;
        diff /= (distance * distance);
        steering += diff;
        total++;
      }
    }
    if (total > 0) {
      steering /= total.toDouble();
      steering.normalize();
      steering *= _maxSpeed;
    }
    return steering;
  }

  Vector2 _seek(Vector2 target) {
    Vector2 desired = (target - position).normalized() * _maxSpeed;
    return limitSpeed(desired - velocity);
  }

  Vector2 limitSpeed(Vector2 vector) {
    if (vector.length > _maxSpeed) {
      vector.normalize();
      vector *= _maxSpeed;
    }

    return vector;
  }

  String _determineFacing() {
    if (velocity.x.abs() <= 0.1 && velocity.y.abs() <= 0.1) {
      return 'idle';
    }

    if (velocity.y.abs() >= velocity.x.abs()) {
      return velocity.y > 0 ? 'down' : 'up';
    } else {
      return velocity.x > 0 ? 'right' : 'left';
    }
  }
}
