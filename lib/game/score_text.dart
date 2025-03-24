import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slash/game/flutter_slash_game.dart';

class ScoreText extends TextComponent with HasGameRef<FlutterSlashGame> {
  ScoreText()
      : super(
          text: "Score: 0",
          position: Vector2(10, 10), // Position oben links
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 24.0,
              color: Color(0xFFFFFFFF), // Weiße Schrift
            ),
          ),
        );

  @override
  void update(double dt) {
    super.update(dt);
    text = "Score: ${gameRef.gameState.score}"; // 🏆 Score aktualisieren
  }
}
