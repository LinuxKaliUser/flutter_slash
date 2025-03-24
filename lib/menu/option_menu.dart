import 'package:flutter/material.dart';

import 'package:flutter_slash/game/flutter_slash_game.dart';
import 'package:flutter_slash/manager/options_manager.dart';

class OptionsMenu extends StatefulWidget {
  final FlutterSlashGame game;

  const OptionsMenu({required this.game, super.key});

  @override
  _OptionsMenuState createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> {
  double _volume = 0.5; // Initial volume

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  void _loadSettings() async {
    double volume = await OptionsManager.loadVolume();

    setState(() {
      _volume: volume;
    });
  }

  void _updateVolume(double value) {
    setState(() {
      _volume = value;
    });

    OptionsManager.saveVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Options',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              _buildOptionRow(
                label: 'Music Volume',
                child: Slider(
                  value: _volume,
                  onChanged: _updateVolume,
                  min: 0.0,
                  max: 1.0,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('OptionsMenu');
                  widget.game.overlays.add("MainMenu");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow({required String label, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        Expanded(child: child),
      ],
    );
  }
}
