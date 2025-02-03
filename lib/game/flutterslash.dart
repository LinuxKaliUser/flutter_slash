import 'package:flame/game.dart';
import 'package:flame/input.dart';

import 'package:flutter_slash/game/player.dart';

class FlutterSlashGame extends FlameGame with HasKeyboardHandlerComponents {
  late PlayerCharacter player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = PlayerCharacter();
    add(player);
  }
}
