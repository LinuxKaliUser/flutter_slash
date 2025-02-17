import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:flutter_slash/game/player.dart';

class FlutterSlashGame extends FlameGame
    with HasKeyboardHandlerComponents, PointerMoveCallbacks, DragCallbacks {
  late PlayerCharacter player;
  late TiledComponent tiledMap;
  double backgroundMusicVolume = 0.5;
  bool isBgmPlaying = false;


  @override
  Future<void> onLoad() async {
    await super.onLoad();

    tiledMap = await TiledComponent.load('flutter-slash.tmx', Vector2.all(32));
    player = PlayerCharacter();

    world.add(tiledMap);
    world.add(player);
    FlameAudio.bgm.initialize();


    camera.follow(player);
  }
  void startBgm() {
    if (!isBgmPlaying) {
      FlameAudio.bgm.play('background_music.mp3', volume: backgroundMusicVolume);
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
  void exitGame() {

  }

  void setBackgroundMusicVolume(double volume) {
    backgroundMusicVolume = volume;
    //FlameAudio.audioCache..setVolume(backgroundMusicVolume);
    FlameAudio.bgm.audioPlayer.setVolume(volume);
  }


  @override
  void onPointerMove(PointerMoveEvent event) {
    super.onPointerMove(event);

    player.onMouseMove(event.devicePosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);


    player.onMouseMove(event.deviceStartPosition + event.deviceDelta);
  }
}
