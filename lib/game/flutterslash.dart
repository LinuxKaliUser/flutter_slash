import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:flutter_slash/game/player.dart';

class FlutterSlashGame extends FlameGame
    with HasKeyboardHandlerComponents, PointerMoveCallbacks, DragCallbacks {
  late PlayerCharacter player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = PlayerCharacter();

    world.add(player);

    // TODO: Discuss the possibilty of changing the camera to not
    // have infinite speed so that player isn't always perfectly centered.
    camera.follow(player);
  }

  @override
  Color backgroundColor() => const Color(0xFFC4A484);

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
