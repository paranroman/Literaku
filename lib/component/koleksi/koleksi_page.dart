import 'dart:developer';

import 'package:LiterakuFlutter/core/bantuan_function.dart';
import 'package:LiterakuFlutter/widgets/liku_FAB.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/speech_functions.dart';
import '../../core/speech_resultListener.dart';
import '../../core/speech_utils.dart';
import '../../core/tts.dart';
import '../../util/combineTitle.dart';
import '../../util/page_context.dart';
import '../../widgets/liku_appbar.dart';
import '../../widgets/liku_swipe.dart';
import '../../widgets/space_widget.dart';
import '../constant.dart';
import 'koleksi-util/loadJSONFiles.dart';
import 'koleksi_model.dart';
import 'koleksi_read.dart';

class KoleksiPage extends StatefulWidget {
  const KoleksiPage({super.key});

  @override
  State<KoleksiPage> createState() => _KoleksiPageState();
}

class _KoleksiPageState extends State<KoleksiPage> {
  /// Services
  final SpeechToText speech = SpeechToText();
  final TTS tts = TTS();

  /// Variables
  List<KoleksiModel> jsonList = [];
  List<String> pdfPathList = [];
  bool _hasSpeech = false;
  double soundLevel = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = 'id_ID';
  List<LocaleName> _localeNames = [];

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
        resultListener(
          speech,
          setState,
          soundLevel,
          result,
          PageContext.KoleksiPage,
          lastWords,
          tts,
          jsonList: jsonList,
          pathPdfList: pdfPathList,
        );
      },
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
    loadJsonDataFromAssets('assets/koleksi_book', jsonList).then((value) async {
      await loadPdfFromAssets('assets/koleksi_book', pdfPathList);
      setState(() {});
    }).then((value) async {
      await tts
          .speak('Anda berada di Halaman Koleksi. Memeriksa daftar koleksi');
      if (jsonList.isEmpty) {
        tts.speak('Daftar koleksi Anda tidak ditemukan');
      } else {
        /// Membaca daftar dari Koleksi
        String concatedList = GabungTitle.gabungKoleksi(jsonList);
        tts.speak(concatedList);
      }
    });
  }

  @override
  void dispose() {
    if (speech.isListening || tts.ttsState == TtsState.playing) {
      tts.stop();
      speech.cancel();
      soundLevel = 0.0;
    }
    log('Koleksi ditutup');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: likuAppBar('Halaman Koleksi'),
      body: LikuSwipe(
        toggleListening: toggleListening,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  separatorBuilder: (ctx, i) => heightSpace(12),
                  itemCount: jsonList.length,
                  itemBuilder: (ctx, i) {
                    KoleksiModel koleksi = jsonList[i];
                    return GestureDetector(
                      onTap: () async {
                        if (speech.isListening) {
                          cancelListening(speech, setState, soundLevel);
                        }
                        await tts.stop();
                        Get.to(
                          () => KoleksiReadPage(
                            jsonList: jsonList,
                            pdfPathList: pdfPathList,
                            urutanKoleksi: jsonList.indexOf(koleksi),
                            jsonPath: jsonList[i].lokasi ?? '',
                            title: jsonList[i].title ?? '',
                            pdfPath: pdfPathList[i],
                          ),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(koleksi.title ?? ""),
                          subtitle: Text(koleksi.author?.join(", ") ?? ""),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // TODO: Tambahkan tombol multifungsi disini
              LikuFAB(speech.isListening, lastWords,
                  toggleAction: toggleListening,
                  toBantuan: () => toBantuan(speech, setState, soundLevel, tts,
                      PageContext.KoleksiPage))
            ],
          ),
        ),
      ),
    );
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
