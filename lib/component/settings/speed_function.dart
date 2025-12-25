import 'package:shared_preferences/shared_preferences.dart';

Future<double> loadSpeedFromPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('tts_speed') ?? 1.0;
}

Future<void> saveSpeedToPreferences(double speed) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('tts_speed', speed);
}

void onSpeedChanged(double value, Function(double) setSpeed) {
  setSpeed(value);
  saveSpeedToPreferences(value);
}
