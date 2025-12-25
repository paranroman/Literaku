import 'package:LiterakuFlutter/controller/tema_controller.dart';
import 'package:LiterakuFlutter/daftar-komando/confirmation_komando.dart';
import 'package:LiterakuFlutter/widgets/liku_appbar.dart';
import 'package:LiterakuFlutter/widgets/liku_container.dart';
import 'package:LiterakuFlutter/widgets/liku_swipe.dart';
import 'package:LiterakuFlutter/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/bantuan_function.dart';
import '../../core/speech_functions.dart';
import '../../core/speech_resultListener.dart';
import '../../core/speech_utils.dart';
import '../../core/tts.dart';
import '../../util/page_context.dart';
import '../../widgets/liku_FAB.dart';
import '../constant.dart';
import 'setting_darkmode.dart';
import 'speed_function.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  /// Services
  final TemaController _temaController = Get.find();
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
  String bookName = '';
  String _currentLocaleId = 'id_ID';
  List<LocaleName> _localeNames = [];

  /// Speech Variable
  double _speed = 1.0;

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
        PageContext.PengaturanPage,
        lastWords,
        tts,
        readSpeed: _speed,
        onSpeedChangedCallback: (newSpeed) {
          setState(() {
            _speed = newSpeed;
            saveSpeedToPreferences(newSpeed);
          });
        },
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
    if (!_hasSpeech) initSpeechState();
    tts.speak('Anda berada di Halaman Pengaturan');
    // tts.setSpeed(1);
    // saveSpeedToPreferences(1);
    loadSpeedFromPreferences().then((value) {
      setState(() {
        _speed = value;
      });
    });
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
      appBar: likuAppBar('Halaman Pengaturan'),
      body: Obx(
        () {
          final statusTheme = _temaController.isDark.value;
          return LikuSwipe(
            toggleListening: toggleListening,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      SettingDarkMode(
                          temaController: _temaController,
                          statusTheme: statusTheme),
                      Slider(
                        value: _speed,
                        min: 0.2,
                        max: 2.0,
                        divisions: 9,
                        onChanged: (value) => onSpeedChanged(value, (speed) {
                          setState(() {
                            _speed = speed;
                            tts.setSpeed(_speed);
                          });
                        }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LikuContainer(
                            isHome: false,
                            judul: 'Speed : ${(_speed * 5).toInt()}',
                            containerColor: Colors.red,
                          ),
                          widthSpace(10),
                          LikuContainer(
                            isHome: false,
                            judul: 'Tes',
                            containerColor: Colors.blue,
                            onpressed: () async {
                              await tts.setSpeed(_speed);
                              await tts.speak(
                                  "Kecepatan Suara adalah ${(_speed * 5).toInt()}");
                            },
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          await tts.speak(
                              'Apakah Anda yakin untuk Keluar dari Literaku?');
                          speech.listen(
                            listenOptions: SpeechListenOptions(
                              partialResults: false,
                              cancelOnError: true,
                              listenMode: ListenMode.confirmation,
                            ),
                            onResult: (result) async {
                              lastWords = result.recognizedWords;
                              lastWords =
                                  lastWords.removeAllWhitespace.toLowerCase();
                              if (ConfirmText.positiveText
                                  .contains(lastWords)) {
                                await SystemChannels.platform
                                    .invokeMethod('SystemNavigator.pop');
                              } else if (ConfirmText.negativeText
                                  .contains(lastWords)) {
                                await tts.speak('Perintah dibatalkan');
                              } else {
                                await tts
                                    .speak(ErrorText.missingCommandToRepeat);
                              }
                            },
                            listenFor: const Duration(seconds: 15),
                            pauseFor: const Duration(seconds: 7),
                            localeId: LocalID.currentLocalID,
                            onSoundLevelChange: (level) => soundLevelListener(
                                minSoundLevel,
                                maxSoundLevel,
                                level,
                                soundLevel,
                                setState),
                          );
                        },
                        child: const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Keluar',
                                  style: TextStyle(fontSize: 30),
                                ),
                                Icon(Icons.exit_to_app)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  LikuFAB(
                    speech.isListening,
                    lastWords,
                    toBantuan: () => toBantuan(speech, setState, soundLevel,
                        tts, PageContext.PengaturanPage),
                    toggleAction: toggleListening,
                  ),
                ],
              ),
            ),
          );
        },
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
}
