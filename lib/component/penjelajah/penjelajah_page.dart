import 'dart:developer';

import 'package:LiterakuFlutter/component/book_read.dart';
import 'package:LiterakuFlutter/component/penjelajah/penjelajah_controller.dart';
import 'package:LiterakuFlutter/util/page_context.dart';
import 'package:LiterakuFlutter/widgets/liku_FAB.dart';
import 'package:LiterakuFlutter/widgets/liku_appbar.dart';
import 'package:LiterakuFlutter/widgets/liku_swipe.dart';
import 'package:LiterakuFlutter/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/bantuan_function.dart';
import '../../core/speech_functions.dart';
import '../../core/speech_resultListener.dart';
import '../../core/speech_utils.dart';
import '../../core/tts.dart';
import '../../util/clear_temp_folder.dart';
import '../constant.dart';

class PenjelajahPage extends StatefulWidget {
  const PenjelajahPage({super.key});

  @override
  State<PenjelajahPage> createState() => _PenjelajahPageState();
}

class _PenjelajahPageState extends State<PenjelajahPage> {
  /// Services
  final TextEditingController _searchController = TextEditingController();
  final _penjelajahController = Get.put(PenjelajahController());
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
  List<String> listTitle = [];

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
          PageContext.PenjelajahPage, lastWords, tts,
          penjelajahController: _penjelajahController),
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 7),
      localeId: _currentLocaleId,
      onSoundLevelChange: (level) => soundLevelListener(
          minSoundLevel, maxSoundLevel, level, soundLevel, setState),
    );
    setState(() {});
  }

  Future<void> toggleListening() async {
    if (_hasSpeech) {
      tts.stop();
      if (speech.isListening) {
        stopListening(speech, setState, soundLevel);
      }
      startListening();
    } else {
      tts.speak(ErrorText.missingSpeech);
    }
  }

  @override
  void initState() {
    super.initState();
    _penjelajahController.penjelajahResult.value = [];
    _penjelajahController.searchQuery.value = '';
    if (!_hasSpeech) {
      initSpeechState()
          .then((value) => tts.speak('Anda berada di Halaman Penjelajah'));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    tts.stop();
    speech.cancel();
    soundLevel = 0.0;
    clearTempPDF();
    log('Penjelajah ditutup');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: likuAppBar('Halaman Penjelajah'),
      body: Obx(
        () {
          final bookList = _penjelajahController.penjelajahResult.value;
          int bookCount = bookList.length;
          return LikuSwipe(
            toggleListening: toggleListening,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextField(
                    controller: _penjelajahController.searchQuery.value != ''
                        ? TextEditingController(
                            text: _penjelajahController.searchQuery.value)
                        : _searchController,
                    decoration: InputDecoration(
                      helperText: bookCount != 0
                          ? 'Jumlah buku yang ditemukan: $bookCount buku'
                          : '',
                      suffixIcon: const Icon(Icons.search_rounded),
                      hintText: 'Cari buku disini . . .',
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      _penjelajahController.searchQuery.value = value;
                      _penjelajahController.performSearch().then((value) {});
                    },
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      physics: const ClampingScrollPhysics(),
                      itemCount: bookList.length,
                      separatorBuilder: (ctx, i) => heightSpace(12),
                      itemBuilder: (ctx, i) {
                        return bookList[i].link.toLowerCase().endsWith('.pdf')
                            ? GestureDetector(
                                onTap: () {
                                  Get.to(
                                      () => BookRead(
                                            fromHistory: false,
                                            bookData: bookList[i],
                                            searchResult: bookList,
                                            currentIndex: i,
                                          ),
                                      transition: Transition.fade);
                                },
                                child: Container(
                                  width: 300,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey, width: 4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                bookList[i].title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.blue),
                                              ),
                                              Text(
                                                '${bookList[i].snippet}',
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                              // Text(
                                              //   '${_searchResults?[i].link}',
                                              //   maxLines: 2,
                                              //   overflow: TextOverflow.ellipsis,
                                              //   style: TextStyle(fontSize: 5),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: double.infinity,
                                          width: double.infinity,
                                          child: bookList[i].thumbnailUrl != ''
                                              ? Image.network(
                                                  '${bookList[i].thumbnailUrl}')
                                              : const Icon(Icons.book),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                  LikuFAB(
                    speech.isListening,
                    lastWords,
                    toBantuan: () => toBantuan(speech, setState, soundLevel,
                        tts, PageContext.PenjelajahPage),
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
}
