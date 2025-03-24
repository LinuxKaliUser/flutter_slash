import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import 'package:flutter_slash/game/enemy.dart';
import 'package:flutter_slash/game/flutter_slash_game.dart';
import 'package:flutter_slash/game/player.dart';

class GameState {
  late PlayerCharacter player;
  late TiledComponent tiledMap;
  late List<EnemyCharacter> enemies;

  Future<void> initialize(FlutterSlashGame game) async {
    tiledMap = await TiledComponent.load('flutter-slash.tmx', Vector2.all(32));
    tiledMap.position = Vector2((game.size.x - tiledMap.size.x) / 2,
        (game.size.y - tiledMap.size.y) / 2);

    player = PlayerCharacter();
    enemies = List.generate(20, (_) => EnemyCharacter(player));

    game.world.add(tiledMap);
    game.world.add(player);

    for (EnemyCharacter enemy in enemies) {
      game.world.add(enemy);
      enemy.flock = enemies;
    }

    game.camera.follow(player);
  }

  void reset(FlutterSlashGame game) {
    game.world.children.toList().forEach((child) {
      child.removeFromParent();
    });

    initialize(game);
  }
}
