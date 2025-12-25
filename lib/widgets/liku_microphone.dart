import 'package:flutter/material.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class LikuMicrophoneAnimation extends StatefulWidget {
  const LikuMicrophoneAnimation({super.key});

  @override
  _LikuMicrophoneAnimationState createState() =>
      _LikuMicrophoneAnimationState();
}

class _LikuMicrophoneAnimationState extends State<LikuMicrophoneAnimation> {
  final SpeechToText speech = SpeechToText();
  late bool isListening;

  @override
  void initState() {
    super.initState();
    isListening = false;
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        setState(() {
          isListening = speech.isListening;
        });
      },
      onError: (error) => print('Error: $error'),
    );

    if (!available) {
      print('Speech recognition is not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isListening
        ? Container(
            alignment: Alignment.center,
            color: Colors.white.withOpacity(0.5),
            height: MediaQuery.of(context).size.height,
            child: LiterakuLogoAnimation(),
          )
        : const SizedBox.shrink();
  }
}

RippleAnimation LiterakuLogoAnimation() {
  return RippleAnimation(
    repeat: true,
    key: UniqueKey(),
    color: Colors.lightBlue,
    minRadius: 100,
    ripplesCount: 6,
    child: Image.asset('assets/logo/literaku_logo.png'),
  );
}
