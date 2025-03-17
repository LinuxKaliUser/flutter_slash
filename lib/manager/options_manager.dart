import 'package:shared_preferences/shared_preferences.dart';

class OptionsManager {
  static Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume);
  }

  static Future<double> loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('volume') ?? 0.5;
  }
}
