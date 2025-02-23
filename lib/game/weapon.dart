import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';
import 'package:flutter_slash/game/bullet.dart';

class Weapon extends SpriteAnimationComponent
    with HasGameRef<FlutterSlashGame> {
  final double damage;
  final double fireRate;
  final double bulletSpeed;

  DateTime? lastFireTime;

  bool facingRight = true;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation fireAnimation;
  late SpriteAnimationTicker fireAnimationTicker;

  Weapon({
    required this.damage,
    required this.fireRate,
    required this.bulletSpeed,
    required Vector2 size,
  }) : super(size: size, priority: 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _loadAnimations();
  }

  Future<void> _loadAnimations() async {
    idleAnimation =
        await _loadAnimation('weapons/sprites/guns/AK-47.png', 1, 0.1);
    fireAnimation = await _loadAnimation(
        'weapons/animations/AK-47/Full-auto/Full_auto_muzzle_AK-47.png',
        12,
        1 / (fireRate * 12));
    fireAnimationTicker = fireAnimation.createTicker();
    fireAnimationTicker.onComplete = () {
      animation = idleAnimation;
      fireAnimationTicker.reset();
    };

    animation = idleAnimation;
  }

  Future<SpriteAnimation> _loadAnimation(
      String path, int frameCount, double stepTime) async {
    final spriteSheet = await Flame.images.load(path);
    final spriteSize =
        Vector2(spriteSheet.width / frameCount, spriteSheet.height.toDouble());

    return SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        loop: false,
        amount: frameCount,
        textureSize: spriteSize,
        stepTime: stepTime,
        texturePosition: Vector2(0, 0),
      ),
    );
  }

  void fire() {
    final now = DateTime.now();

    if (lastFireTime != null && now.difference(lastFireTime!).inMilliseconds < 1000 / fireRate) {
      return;
    }

    lastFireTime = now;

    animation = fireAnimation;
    FlameAudio.play('sfx/762x39_single.mp3', volume: 0.5);

    final bullet = Bullet(
      position: position,
      speed: bulletSpeed,
      angle: angle,
    );
    game.world.add(bullet);
  }

  void setFacing(bool facingRight) {
    if (this.facingRight != facingRight) {
      this.facingRight = facingRight;

      flipVerticallyAroundCenter();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    fireAnimationTicker.update(dt);
  }
}
