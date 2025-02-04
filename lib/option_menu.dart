import 'package:flutter/material.dart';

import 'main.dart';

class OptionsMenu extends StatefulWidget {
  final FlutterSlashGame game;

  const OptionsMenu(this.game, {super.key});

  @override
  OptionsMenuState createState() => OptionsMenuState();
}

class OptionsMenuState extends State<OptionsMenu> {
  double _musicVolume = 0.5; // Initial volume
  double _sfxVolume = 0.5; // Initial volume

  @override
  void initState() {
    super.initState();
    // Load the current volume from the game (if you're storing it)
    _musicVolume = widget.game.backgroundMusicVolume;
    _sfxVolume = widget.game.backgroundMusicVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        color: Colors.grey[800],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Options',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Music Volume',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: Slider(
                    value: _musicVolume,
                    min: 0.0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        _musicVolume = value;
                        widget.game.setBackgroundMusicVolume(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.game.overlays.remove('OptionsMenu');
                widget.game.overlays.add("MainMenu");
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}