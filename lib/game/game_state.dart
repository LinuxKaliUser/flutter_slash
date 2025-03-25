import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'dart:async' as time;

import 'package:flutter_slash/game/enemy.dart';
import 'package:flutter_slash/game/flutter_slash_game.dart';
import 'package:flutter_slash/game/player.dart';
import 'package:flutter_slash/game/score_text.dart';

import '../manager/options_manager.dart';

class GameState {
  late PlayerCharacter player;
  late TiledComponent tiledMap;
  late List<EnemyCharacter> enemies;
  late time.Timer timer;
  int score = 0;

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
    int generateEnemies = 0;
    timer = time.Timer.periodic(Duration(seconds: 5), (timer) {
      generateEnemies++;
      var enemyList =
          List.generate(generateEnemies, (_) => EnemyCharacter(player));
      enemies.addAll(enemyList);
      for (var enemy in enemyList) {
        game.world.add(enemy);
        enemy.flock = enemies;
      }
    });

    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('background_music.mp3',
        volume: await OptionsManager.loadVolume());
    OptionsManager.onVolumeChange.listen((volume) {
      FlameAudio.bgm.audioPlayer.setVolume(volume);
    });

    game.camera.viewport.add(ScoreText());

    game.camera.follow(player);
  }

  void reset(FlutterSlashGame game) {
    game.world.children.toList().forEach((child) {
      child.removeFromParent();
    });
    score = 0;

    initialize(game);
  }
}
