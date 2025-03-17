import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class OptionsManager {
  static final StreamController<double> _volumeController =
      StreamController<double>.broadcast();

  static Stream<double> get onVolumeChange => _volumeController.stream;

  static Future<void> saveVolume(double volume) async {
    _volumeController.add(volume);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume);
  }

  static Future<double> loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('volume') ?? 0.5;
  }
}
