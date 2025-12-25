import 'dart:developer';

import 'package:LiterakuFlutter/core/speech_utils.dart';
import 'package:LiterakuFlutter/widgets/liku_appbar.dart';
import 'package:LiterakuFlutter/widgets/liku_swipe.dart';
import 'package:LiterakuFlutter/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/bantuan_function.dart';
import '../../core/speech_functions.dart';
import '../../core/speech_resultListener.dart';
import '../../core/tts.dart';
import '../../util/page_context.dart';
import '../../widgets/liku_FAB.dart';
import '../constant.dart';

class BantuanPage extends StatefulWidget {
  const BantuanPage({super.key, required this.bantuanText});

  final List<String> bantuanText;

  @override
  State<BantuanPage> createState() => _BantuanPageState();
}

class _BantuanPageState extends State<BantuanPage> {
  /// Services
  final SpeechToText speech = SpeechToText();
  final TTS tts = TTS();

  /// Variables
  List<String> listBantuan = [];
  bool _hasSpeech = false;
  double soundLevel = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = 'id_ID';
  List<LocaleName> _localeNames = [];
  String chunk = '';

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
      onResult: (result) {
        setState(() {
          lastWords = result.recognizedWords;
        });
        resultListener(speech, setState, soundLevel, result,
            PageContext.BantuanPage, lastWords, tts,
            bantuanText: widget.bantuanText);
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 7),
      localeId: _currentLocaleId,
      onSoundLevelChange: (level) => soundLevelListener(
          minSoundLevel, maxSoundLevel, level, soundLevel, setState),
    );
    setState(() {});
  }

  void toggleListening() {
    if (_hasSpeech) {
      tts.stop();
      stopListening(speech, setState, soundLevel);
      startListening();
    } else {
      tts.speak(ErrorText.missingSpeech);
    }
  }

  @override
  void initState() {
    super.initState();
    if (!_hasSpeech) initSpeechState();
    listBantuan = widget.bantuanText;
    tts.speak('').then(
      (value) async {
        if (listBantuan.isEmpty) {
          log('Data bantuan tidak ditemukan (null)');
          await tts.speak('Data bantuan tidak ditemukan');
          return;
        }
        chunk = listBantuan.join(' ');
        chunk = chunk.replaceAll('\n', '').replaceAll('\t', '');
        tts.speak(chunk);
        //     .then((value) {
        //   if (mounted) {
        //     Navigator.pop(context);
        //   }
        // });
      },
    );
  }

  @override
  void dispose() {
    if (speech.isListening || tts.ttsState == TtsState.playing) {
      tts.stop();
      speech.cancel();
      soundLevel = 0.0;
    }
    log('Bantuan ditutup');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: likuAppBar('Halaman Bantuan'),
      body: LikuSwipe(
        toggleListening: toggleListening,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                    itemBuilder: (ctx, i) {
                      return i != 0
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$i.',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    widthSpace(24),
                                    Flexible(
                                      flex: 3,
                                      child: Text(
                                        listBantuan[i],
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  listBantuan[0],
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                    },
                    separatorBuilder: (ctx, i) => heightSpace(12),
                    itemCount: listBantuan.length),
              ),
              LikuFAB(
                speech.isListening,
                lastWords,
                toBantuan: () => toBantuan(
                    speech, setState, soundLevel, tts, PageContext.BantuanPage),
                toggleAction: toggleListening,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
