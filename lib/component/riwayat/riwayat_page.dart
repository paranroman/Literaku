import 'dart:convert';
import 'dart:developer';

import 'package:LiterakuFlutter/component/book_read.dart';
import 'package:LiterakuFlutter/component/riwayat/widgets/riwayat_empty.dart';
import 'package:LiterakuFlutter/util/clear_temp_folder.dart';
import 'package:LiterakuFlutter/widgets/liku_appbar.dart';
import 'package:LiterakuFlutter/widgets/liku_swipe.dart';
import 'package:LiterakuFlutter/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/bantuan_function.dart';
import '../../core/speech_functions.dart';
import '../../core/speech_resultListener.dart';
import '../../core/speech_utils.dart';
import '../../core/tts.dart';
import '../../services/search_model.dart';
import '../../util/combineTitle.dart';
import '../../util/page_context.dart';
import '../../widgets/liku_FAB.dart';
import '../constant.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  /// Services
  final SpeechToText speech = SpeechToText();
  final TTS tts = TTS();

  /// Variables
  List<SearchResult> history = [];
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
          PageContext.RiwayatPage,
          lastWords,
          tts,
          historyList: history,
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
  void dispose() {
    if (speech.isListening || tts.ttsState == TtsState.playing) {
      tts.stop();
      speech.cancel();
      soundLevel = 0.0;
    }
    clearTempPDF();
    log('Riwayat ditutup');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_hasSpeech == false) initSpeechState();
    _loadHistory().then((value) {
      tts.speak('Anda berada di Halaman Riwayat').then((value) async {
        await tts.speak('Memeriksa daftar riwayat');
        if (history.isEmpty) {
          tts.speak(
              'Daftar riwayat Anda tidak ditemukan. Silahkan membaca buku melalui halaman Penjelajah');
        } else {
          /// Membaca daftar dari Riwayat
          String concatedList = await GabungTitle.gabungRiwayat(history);
          tts.speak(concatedList);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: likuAppBar('Halaman Riwayat'),
      body: LikuSwipe(
        toggleListening: toggleListening,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              history.isEmpty
                  ? const Expanded(child: RiwayatEmpty())
                  : Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                              onPressed: _deleteHistory,
                              child: const Icon(Icons.delete)),
                          Expanded(
                            child: ListView.separated(
                              physics: const ClampingScrollPhysics(),
                              separatorBuilder: (ctx, i) => heightSpace(8),
                              itemCount: history.length,
                              itemBuilder: (ctx, i) {
                                SearchResult historyMap = history[i];

                                return GestureDetector(
                                  onTap: () async {
                                    await tts.stop();
                                    cancelListening(
                                        speech, setState, soundLevel);
                                    Get.to(
                                      () => BookRead(
                                        bookData: historyMap,
                                        currentIndex: i,
                                        searchResult: history,
                                        fromHistory: true,
                                      ),
                                    );
                                  },
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          leading: Text(
                                            '${i + 1}.',
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          title: Text(
                                            historyMap.title,
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          subtitle: Text(
                                            'Dibuka pada tanggal : ${DateTime.parse('${historyMap.time}')}',
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          dense: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
              LikuFAB(
                speech.isListening,
                lastWords,
                toBantuan: () => toBantuan(
                    speech, setState, soundLevel, tts, PageContext.RiwayatPage),
                toggleAction: toggleListening,
              ),
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

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? historyStrings = prefs.getStringList('history') ?? [];

    List<SearchResult> loadedHistory = [];

    for (String historyString in historyStrings) {
      try {
        Map<String, dynamic> historyMap = json.decode(historyString);
        SearchResult searchResult = SearchResult(
          title: historyMap['title'] ?? '',
          link: historyMap['link'] ?? '',
          snippet: historyMap['snippet'] ?? '',
          thumbnailUrl: historyMap['thumbnailUrl'] ?? '',
          time: historyMap['time'] ?? '',
        );
        loadedHistory.add(searchResult);
      } catch (e) {
        log('Error decoding JSON: $e');
      }
    }

    setState(() {
      history = loadedHistory;
    });
  }

  Future<void> _deleteHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    setState(() {
      history = [];
    });
  }
}
