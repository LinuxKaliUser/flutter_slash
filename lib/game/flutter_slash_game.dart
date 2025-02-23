import 'package:flame/events.dart'
    show
        HasKeyboardHandlerComponents,
        PointerMoveCallbacks,
        PointerMoveEvent,
        DragCallbacks,
        DragUpdateEvent,
        TapCallbacks,
        TapDownEvent;
import 'package:flame_tiled/flame_tiled.dart' show TiledComponent;
import 'package:flame_audio/flame_audio.dart' show FlameAudio;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

import 'package:flutter_slash/game/player.dart' show PlayerCharacter;
import 'package:flutter_slash/game/enemy.dart' show EnemyCharacter;

import 'package:flame/game.dart';

class FlutterSlashGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        PointerMoveCallbacks,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  late PlayerCharacter player;
  late TiledComponent tiledMap;

  late bool isMobile;

  double backgroundMusicVolume = 0.5;
  bool isBgmPlaying = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    isMobile = defaultTargetPlatform == TargetPlatform.android;

    tiledMap = await TiledComponent.load('flutter-slash.tmx', Vector2.all(32));
    tiledMap.position =
        Vector2((size.x - tiledMap.size.x) / 2, (size.y - tiledMap.size.y) / 2);
    player = PlayerCharacter();

    world.add(tiledMap);
    world.add(player);
    FlameAudio.bgm.initialize();

    List<EnemyCharacter> enemies = [];

    for (int i = 0; i < 20; i++) {
      enemies.add(EnemyCharacter(player));
    }

    for (EnemyCharacter enemy in enemies) {
      world.add(enemy);
      enemy.flock = enemies;
    }

    camera.follow(player);
  }

  void startBgm() {
    if (!isBgmPlaying) {
      FlameAudio.bgm
          .play('background_music.mp3', volume: backgroundMusicVolume);
      isBgmPlaying = true;
    }
  }

  void gameOver() {
    overlays.add('GameOverScreen');
  }

  void restartGame() {
    overlays.remove('GameOverScreen');
    resumeEngine();
  }

  void exitGame() {}

  void setBackgroundMusicVolume(double volume) {
    backgroundMusicVolume = volume;
    FlameAudio.bgm.audioPlayer.setVolume(volume);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (isMobile) {
      return;
    }

    player.onTapDown();
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    super.onPointerMove(event);

    if (isMobile) {
      return;
    }

    player.onMouseMove(event.devicePosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    if (isMobile) {
      return;
    }

    player.onTapDown();
    player.onMouseMove(event.deviceStartPosition + event.deviceDelta);
  }
}
