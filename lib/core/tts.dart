import 'dart:developer';

import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TTS {
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;

  TTS() {
    flutterTts = FlutterTts();
    flutterTts.setStartHandler(() {
      log("Playing");
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      log("Complete");
      ttsState = TtsState.stopped;
    });

    flutterTts.setCancelHandler(() {
      log("Cancel");
      ttsState = TtsState.stopped;
    });
  }

  Future speak(String message) async {
    await flutterTts.awaitSpeakCompletion(true);
    if (message.isNotEmpty) {
      ttsState = TtsState.playing;
      await flutterTts.speak(message);
    }
  }

  Future stop() async {
    var result = await flutterTts.stop();
    if (result == 1) ttsState = TtsState.stopped;
  }

  Future pause() async {
    var result = await flutterTts.pause();
    if (result == 1) ttsState = TtsState.paused;
  }

  Future setSpeed(double speed) async {
    await flutterTts.setSpeechRate(speed);
  }
}
