import 'dart:math';

import 'package:speech_to_text/speech_to_text.dart';

void stopListening(SpeechToText speech, Function setState, double level) {
  speech.stop();
  setState(() {
    level = 0.0;
  });
}

void cancelListening(SpeechToText speech, Function setState, double level) {
  speech.cancel();
  setState(() {
    level = 0.0;
  });
}

void soundLevelListener(double minSoundLevel, double maxSoundLevel,
    double level, double soundLevel, Function setState) {
  minSoundLevel = min(minSoundLevel, level);
  maxSoundLevel = max(maxSoundLevel, level);
  // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
  setState(() {
    soundLevel = level;
  });
}
