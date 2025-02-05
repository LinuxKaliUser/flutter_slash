import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class Weapon extends SpriteAnimationComponent {
  final double damage;
  final double fireRate;
  final double bulletSpeed;

  bool facingRight = true;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation fireAnimation;

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
        amount: frameCount,
        textureSize: spriteSize,
        stepTime: stepTime,
        texturePosition: Vector2(0, 0),
      ),
    );
  }

  void playIdle() {
    animation = idleAnimation;
  }

  void playFire() {
    animation = fireAnimation;
  }

  void setFacing(bool facingRight) {
    if (this.facingRight != facingRight) {
      this.facingRight = facingRight;

      flipVerticallyAroundCenter();
    }
  }
}
