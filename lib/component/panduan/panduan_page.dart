import 'package:LiterakuFlutter/widgets/liku_appbar.dart';
import 'package:LiterakuFlutter/widgets/liku_swipe.dart';
import 'package:LiterakuFlutter/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/bantuan_function.dart';
import '../../core/speech_functions.dart';
import '../../core/speech_resultListener.dart';
import '../../core/speech_utils.dart';
import '../../core/tts.dart';
import '../../util/page_context.dart';
import '../../widgets/liku_FAB.dart';

class PanduanPage extends StatefulWidget {
  const PanduanPage({super.key});

  @override
  State<PanduanPage> createState() => _PanduanPageState();
}

class _PanduanPageState extends State<PanduanPage> {
  /// Services
  final SpeechToText speech = SpeechToText();
  final TTS tts = TTS();

  /// Variables
  bool _hasSpeech = false;
  double soundLevel = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = 'id_ID';
  List<LocaleName> _localeNames = [];
  final urlVideo = 'https://youtu.be/VuwbbVcyXs8?si=Oxn0IcfSxodDbYU7';
  late final YoutubePlayerController _youtubePlayerController;

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: (error) => errorListener(error, setState, lastError),
        onStatus: (status) => statusListener(status, setState, lastStatus),
        debugLogging: true);
    if (hasSpeech) {
      _localeNames = await speech.locales();
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = 'id-EN' ?? 'en-EN';
    }
    if (!mounted) return;
    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  Future<void> startListening() async {
    lastWords = '';
    lastError = '';
    await tts.speak('Ucapkan Perintah');
    speech.listen(
      listenOptions: SpeechListenOptions(
        partialResults: false,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
      onResult: (result) => resultListener(speech, setState, soundLevel, result,
          PageContext.PanduanPage, lastWords, tts),
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 7),
      localeId: _currentLocaleId,
      onSoundLevelChange: (level) => soundLevelListener(
          minSoundLevel, maxSoundLevel, level, soundLevel, setState),
    );
    setState(() {});
  }

  void toggleListening() {
    if (!_hasSpeech || speech.isListening) {
      stopListening(speech, setState, soundLevel);
    } else {
      startListening();
    }
  }

  @override
  void initState() {
    super.initState();
    final videoID = YoutubePlayer.convertUrlToId(urlVideo);
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: videoID!,
      flags: const YoutubePlayerFlags(
        disableDragSeek: false,
        mute: false,
        controlsVisibleAtStart: true,
        forceHD: false,
        hideControls: true,
        hideThumbnail: false,
        autoPlay: true,
        captionLanguage: 'id-ID',
        enableCaption: true,
      ),
    );
    if (!_hasSpeech) initSpeechState();
    tts.speak('Anda berada di Halaman Panduan');
  }

  @override
  void dispose() {
    tts.stop();
    if (speech.isListening) stopListening(speech, setState, soundLevel);
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: likuAppBar('Halaman Panduan'),
      body: LikuSwipe(
        toggleListening: toggleListening,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Panduan Menggunakan Literaku',
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              heightSpace(24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: YoutubePlayer(
                  showVideoProgressIndicator: true,
                  controller: _youtubePlayerController,
                  onReady: () => debugPrint('Ready'),
                ),
              ),
              heightSpace(24),
              LikuFAB(
                speech.isListening,
                lastWords,
                toBantuan: () => toBantuan(
                    speech, setState, soundLevel, tts, PageContext.PanduanPage),
                toggleAction: toggleListening,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
