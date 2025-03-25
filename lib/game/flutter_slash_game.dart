import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slash/game/game_state.dart';
import 'package:flutter_slash/game/score_text.dart';

import 'package:flutter_slash/manager/options_manager.dart';

class FlutterSlashGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        PointerMoveCallbacks,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  late GameState gameState;

  late bool isWeb;
  late bool isMobile;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    isWeb = isSkiaWeb | isSkwasm;
    isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    gameState = GameState();
    await gameState.initialize(this);

    // 🎮 Score-Anzeige hinzufügen


    pauseEngine();
  }

  void gameOver() {
    gameState.timer.cancel();
    overlays.add('GameOverScreen');
  }

  void startGame() {
    resumeEngine();
  }

  void restartGame() {
    gameState.reset(this);
    resumeEngine();
  }

  void exitGame() {}

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    gameState.player.onTapDown();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);

    gameState.player.onTapUp();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);

    gameState.player.onTapUp();
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    super.onPointerMove(event);

    gameState.player.onMouseMove(event.devicePosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);

    gameState.player.onTapDown();
    gameState.player.onMouseMove(event.deviceStartPosition + event.deviceDelta);
  }

}


