import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'package:flutter_slash/game/player.dart';

class FlutterSlashGame extends FlameGame
    with HasKeyboardHandlerComponents, PointerMoveCallbacks, DragCallbacks {
  late PlayerCharacter player;
  late TiledComponent tiledMap;


  @override
  Future<void> onLoad() async {
    await super.onLoad();

    tiledMap = await TiledComponent.load('flutter-slash.tmx', Vector2.all(32));
    player = PlayerCharacter();

    world.add(tiledMap);
    world.add(player);

    camera.follow(player);
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
