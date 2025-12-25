import 'package:LiterakuFlutter/widgets/liku_container.dart';
import 'package:LiterakuFlutter/widgets/liku_swipe.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/bantuan_function.dart';
import '../../core/speech_functions.dart';
import '../../core/speech_resultListener.dart';
import '../../core/speech_utils.dart';
import '../../core/tts.dart';
import '../../util/page_context.dart';
import '../../widgets/liku_FAB.dart';
import '../../widgets/liku_appbar.dart';
import '../koleksi/koleksi_page.dart';
import '../panduan/panduan_page.dart';
import '../penjelajah/penjelajah_page.dart';
import '../riwayat/riwayat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      onResult: (result) => resultListener(
        speech,
        setState,
        soundLevel,
        result,
        PageContext.HomePage,
        lastWords,
        tts,
      ),
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 7),
      localeId: _currentLocaleId,
      onSoundLevelChange: (level) => soundLevelListener(
          minSoundLevel, maxSoundLevel, level, soundLevel, setState),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    tts.speak("Selamat datang di Literaku");
    if (!_hasSpeech) initSpeechState();
  }

  @override
  void dispose() {
    super.dispose();
    tts.stop();
    if (speech.isListening) stopListening(speech, setState, soundLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: likuAppBar('LITERAKU'),
      body: SafeArea(
        child: LikuSwipe(
          toggleListening: toggleListening,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LikuContainer(
                  isHome: true,
                  judul: 'Penjelajah',
                  containerIcon: Icons.search,
                  containerColor: Colors.blue,
                  onpressed: () {
                    Get.to(() => const PenjelajahPage());
                  },
                ),
                LikuContainer(
                  isHome: true,
                  judul: 'Riwayat',
                  containerIcon: Icons.access_time,
                  containerColor: Colors.red,
                  onpressed: () {
                    Get.to(() => const RiwayatPage());
                  },
                ),
                LikuContainer(
                  isHome: true,
                  judul: 'Koleksi',
                  containerIcon: Icons.collections_bookmark,
                  containerColor: Colors.green,
                  onpressed: () {
                    Get.to(() => const KoleksiPage());
                  },
                ),
                LikuContainer(
                  isHome: true,
                  judul: 'Panduan',
                  containerIcon: Icons.question_mark,
                  containerColor: Colors.purple,
                  onpressed: () {
                    Get.to(() => const PanduanPage());
                  },
                ),
                LikuFAB(
                  speech.isListening,
                  lastWords,
                  toBantuan: () => toBantuan(
                      speech, setState, soundLevel, tts, PageContext.HomePage),
                  toggleAction: toggleListening,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toggleListening() {
    if (!_hasSpeech || speech.isListening) {
      stopListening(speech, setState, soundLevel);
    } else {
      startListening();
    }
  }
}
