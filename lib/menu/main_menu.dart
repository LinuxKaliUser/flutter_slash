import 'dart:io';
// TODO: Find a better alternative so this doesn't need to be commented in/out based on build type
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';

class MainMenu extends StatelessWidget {
  final FlutterSlashGame game;

  const MainMenu({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Flutter Slash',
            style: TextStyle(fontSize: 48, color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildMenuButton('Start', () {
            game.overlays.remove('MainMenu');
            game.startGame();
          }),
          const SizedBox(height: 20),
          _buildMenuButton('Options', () {
            game.overlays.add('OptionsMenu');
          }),
          if (game.isWeb) ...[
            const SizedBox(height: 20),
            _buildMenuButton('Download APK', () async {
              const apkUrl =
                  'https://flutter-slash.coll.dev/assets/flutter-slash.apk'; // Replace with your APK URL
              html.window.open(apkUrl, '_blank');
            }),
          ],
          if (!game.isWeb) ...[
            const SizedBox(height: 20),
            _buildMenuButton('Exit', () {
              SystemNavigator.pop();
              Navigator.pop(context);
              exit(0);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
