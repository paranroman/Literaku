import 'dart:async';
import 'dart:developer';

import 'package:LiterakuFlutter/services/search_model.dart';
import 'package:LiterakuFlutter/widgets/liku_swipe.dart';
import 'package:LiterakuFlutter/widgets/space_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/bantuan_function.dart';
import '../core/speech_functions.dart';
import '../core/speech_utils.dart';
import '../core/tts.dart';
import '../daftar-komando/all_page.dart';
import '../daftar-komando/book-komando.dart';
import '../util/page_context.dart';
import '../widgets/liku_FAB.dart';
import 'constant.dart';
import 'penjelajah/penjelajah-read/addHistory.dart';
import 'penjelajah/penjelajah-read/downloadsavepdf.dart';
import 'penjelajah/penjelajah-read/extractPDFText.dart';
import 'penjelajah/penjelajah-read/otherBookNavigator.dart';
import 'penjelajah/penjelajah-read/pageNavigator.dart';
import 'settings/setting_page.dart';

class BookRead extends StatefulWidget {
  final bool? fromHistory;
  final SearchResult bookData;
  final List<SearchResult> searchResult;
  final int currentIndex;

  const BookRead({
    super.key,
    this.fromHistory = false,
    required this.bookData,
    required this.searchResult,
    required this.currentIndex,
  });

  @override
  _BookReadState createState() => _BookReadState();
}

class _BookReadState extends State<BookRead> {
  /// Services
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  PDFViewController? _snapshotData;
  final SpeechToText speech = SpeechToText();
  final TTS tts = TTS();
  final AudioPlayer audioPlayer = AudioPlayer();

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
  String _pdfPath = "";
  String pdfUrl = '';
  String title = '';
  String snippet = '';
  String thumbnail = '';
  String currentTextToRead = '';
  List<String> textToRead = [];
  String errorMessage = '';
  String chunk = '';

  /// PDF Navigation
  int? pages = 0;
  int? currentPage = 0;
  List<String> pdfContent = [];
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    if (!_hasSpeech) initSpeechState();
    setState(() {
      pdfUrl = widget.bookData.link;
      title = widget.bookData.title;
      snippet = widget.bookData.snippet ?? '';
      thumbnail = widget.bookData.thumbnailUrl ?? '';
      addToHistory(widget.fromHistory, widget.bookData);
    });
    _downloadAndDisplayPdf();
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
      onResult: resultListener,
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 7),
      localeId: _currentLocaleId,
      onSoundLevelChange: (level) => soundLevelListener(
          minSoundLevel, maxSoundLevel, level, soundLevel, setState),
    );
    setState(() {});
  }

// Function to split string into chunks of given size
  List<String> _chunkString(String input, int size) {
    List<String> chunks = [];
    for (int i = 0; i < input.length; i += size) {
      chunks.add(input.substring(
          i, i + size < input.length ? i + size : input.length));
    }
    return chunks;
  }

  Future<void> readBook(List<String> bookStrings, int currentPage) async {
    if (isListening == false) {
      await tts.speak('Halaman ${currentPage + 1}');
      log('Jumlah halaman : ${bookStrings.length}');
      // Cek nomor halaman
      if (currentPage < 0 || currentPage >= (bookStrings.length ?? 0)) {
        await tts.speak('Gagal membaca buku. Nomor halaman tidak valid');
        log('Nomor Halaman tidak valid');
        return;
      }
      chunk = bookStrings[currentPage];
      chunk = chunk.replaceAllMapped(RegExp(r'(\S)([\s\t]{2,})(\S)'), (match) {
        return '${match.group(1)}${match.group(3)}'; // Keep the non-whitespace characters
      });
      List<String> chunkedTexts = _chunkString(chunk, 500);
      textToRead = chunkedTexts;
      while (textToRead.isNotEmpty && speech.isNotListening && mounted) {
        currentTextToRead = textToRead[0];
        textToRead.removeAt(0);
        await tts.speak(currentTextToRead);
        log(currentTextToRead);
      }
      if (textToRead.isEmpty && currentPage < pages!) {
        await PageNavigator.goToNextPage(
          _snapshotData!,
          currentPage,
          pages!,
          setState,
        );
        await readBook(pdfContent, currentPage + 1);
      }
    }
  }

  Future<void> resultListener(SpeechRecognitionResult result) async {
    lastWords = result.recognizedWords;
    List<String> words = lastWords.split(' ');
    lastWords = lastWords.removeAllWhitespace;

    /// Pindah halaman dengan angka
    if (BookCommand.toPage.any((element) => lastWords.contains(element))) {
      log('Kalimat terakhir : $lastWords');
      RegExp regExp = RegExp(r'\d+');
      Iterable<Match> matches = regExp.allMatches(lastWords);
      List<int> integers =
          matches.map((match) => int.parse(match.group(0)!)).toList();
      String concatenatedIntegers = integers.join('');
      final indexOpen = int.tryParse(concatenatedIntegers) ?? 0;
      if (indexOpen <= (pdfContent.length ?? 1) && indexOpen > 0) {
        log('Target halaman $indexOpen');
        setState(() {
          currentPage = indexOpen - 1;
          _snapshotData!.setPage(currentPage!);
        });
        textToRead = [];
        await readBook(pdfContent, currentPage!);
      } else {
        await tts.speak(
            'Gagal membuka halaman. Halaman terakhir adalah halaman $pages');
      }
    }

    /// Buku Selanjutnya
    else if (lastWords == 'bukuselanjutnya') {
      if (widget.currentIndex == widget.searchResult.length - 1) {
        await tts.speak('Ini adalah buku terakhir');
      } else {
        await tts.speak('Membuka buku selanjutnya');
        textToRead = [];
        NavigasiAntarBuku.toNextBook(
          context,
          widget.currentIndex,
          widget.searchResult,
        );
      }
    }

    /// Buku Sebelumnya
    else if (lastWords == 'bukusebelumnya') {
      if (widget.currentIndex == 0) {
        await tts.speak('Ini adalah buku pertama');
      } else {
        await tts.speak('Membuka buku sebelumnya');
        textToRead = [];
        NavigasiAntarBuku.toPreviousBook(
          context,
          widget.currentIndex,
          widget.searchResult,
        );
      }
    }

    /// Halaman Sebelumnya
    else if (lastWords == 'sebelumnya') {
      if (currentPage == 0) {
        await tts.speak('Ini adalah halaman pertama');
      } else {
        await tts.speak('Halaman sebelumnya');
        textToRead = [];
        PageNavigator.goToPreviousPage(
          _snapshotData!,
          currentPage!,
          pages!,
          setState,
        );
        await readBook(pdfContent, currentPage! - 1);
      }
    }

    /// Halaman Selanjutnya
    else if (lastWords == 'selanjutnya') {
      if (currentPage == pages! - 1) {
        await tts.speak('Ini adalah halaman terakhir');
      } else {
        await tts.speak('Halaman selanjutnya');
        setState(() {
          currentPage = currentPage! + 1;
          _snapshotData!.setPage(currentPage!);
        });
        textToRead = [];
        await readBook(pdfContent, currentPage!);
      }
    }

    /// Halaman Pertama
    else if (lastWords == 'pertama') {
      await tts.speak('Membuka halaman pertama');
      setState(() {
        currentPage = 1;
        _snapshotData!.setPage(currentPage! - 1);
      });
      textToRead = [];
      await readBook(pdfContent, currentPage! - 1);
    }

    /// Halaman Terakhir
    else if (lastWords == 'terakhir') {
      await tts.speak('Membuka halaman terakhir');
      setState(() {
        currentPage = pages;
        _snapshotData!.setPage(currentPage! - 1);
      });
      textToRead = [];
      await readBook(pdfContent, currentPage! - 1);
    }

    /// Common Command
    else if (AllPageCommando.kembali.contains(lastWords)) {
      await tts.speak("Kembali ke halaman sebelumnya");
      Get.back();
    } else if (AllPageCommando.bantuan.contains(lastWords)) {
      await tts.speak("Membuka Halaman Bantuan");
      toBantuan(speech, setState, soundLevel, tts, PageContext.BookReadPage);
    } else if (AllPageCommando.pengaturan.contains(lastWords)) {
      await tts.speak("Membuka Halaman Pengaturan");
      Get.to(() => const PengaturanPage());
    } else {
      tts.speak("Perintah tidak ditemukan");
    }
  }

  @override
  void dispose() {
    if (speech.isListening || tts.ttsState == TtsState.playing) {
      tts.stop();
      speech.cancel();
      soundLevel = 0.0;
    }
    textToRead = [];
    currentTextToRead = '';
    tts.stop();
    speech.cancel();
    audioPlayer.stop();
    audioPlayer.dispose();
    log('Buku ditutup');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          /// Buku Sebelumnya
          IconButton(
            onPressed: () {
              NavigasiAntarBuku.toPreviousBook(
                context,
                widget.currentIndex,
                widget.searchResult,
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),

          /// Buku Selanjutnya
          IconButton(
            onPressed: () {
              NavigasiAntarBuku.toNextBook(
                context,
                widget.currentIndex,
                widget.searchResult,
              );
            },
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: LikuSwipe(
        toggleListening: toggleListening,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            children: [
              _pdfPath.isNotEmpty
                  ? Expanded(
                      child: PDFView(
                        filePath: _pdfPath,
                        enableSwipe: false,
                        swipeHorizontal: false,
                        autoSpacing: false,
                        pageSnap: true,
                        pageFling: true,
                        defaultPage: currentPage!,
                        onRender: (pages) async {
                          setState(() {
                            pages = pages;
                          });
                        },
                        onViewCreated:
                            (PDFViewController pdfViewController) async {
                          _controller.complete(pdfViewController);
                          await tts.speak('Harap tunggu. Teks sedang dimuat');
                          await audioPlayer.setReleaseMode(ReleaseMode.loop);
                          await audioPlayer.play(
                              AssetSource('loadingAudio/literaku.wav'),
                              volume: 0.6);
                          pdfContent = await extractTextPerPage(_pdfPath);
                          log('Teks berhasil diekstrak');
                          await audioPlayer.stop();
                          await tts.speak('Mulai membaca.').then(
                              (value) async =>
                                  await readBook(pdfContent, currentPage!));
                        },
                        onError: (error) {
                          errorMessage = error.toString();
                          log(errorMessage);
                        },
                        onPageChanged: (int? page, int? total) {
                          log('Daftar halaman: ${page! + 1}/$total');
                          setState(() {
                            currentPage = page;
                          });
                        },
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
              heightSpace(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  currentPage != 0
                      ? FutureBuilder<PDFViewController>(
                          future: _controller.future,
                          builder: (context,
                              AsyncSnapshot<PDFViewController> snapshot) {
                            if (snapshot.hasData) {
                              _snapshotData = snapshot.data;
                              return const SizedBox.shrink();
                              // ElevatedButton(
                              //   onPressed: () async {
                              //     await PageNavigator.goToPreviousPage(
                              //       snapshot.data!,
                              //       currentPage!,
                              //       pages!,
                              //       setState,
                              //     );
                              //     await readBook(pdfContent, currentPage!);
                              //   },
                              //   child: Icon(Icons.arrow_back, size: 50));
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        )
                      : const SizedBox.shrink(),
                  // widthSpace(16),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     // setState(() {
                  //     //   _hasSpeech = !_hasSpeech;
                  //     // });
                  //   },
                  //   child: _hasSpeech
                  //       ? Icon(Icons.stop_circle, size: 50)
                  //       : Icon(
                  //           Icons.play_circle,
                  //           size: 50,
                  //         ),
                  // ),
                  widthSpace(16),
                  currentPage! + 1 != pages
                      ? FutureBuilder<PDFViewController>(
                          future: _controller.future,
                          builder: (context,
                              AsyncSnapshot<PDFViewController> snapshot) {
                            if (snapshot.hasData) {
                              _snapshotData = snapshot.data;
                              return const SizedBox.shrink();
                              // ElevatedButton(
                              //     onPressed: () async {
                              //       await PageNavigator.goToNextPage(
                              //         snapshot.data!,
                              //         currentPage!,
                              //         pages!,
                              //         setState,
                              //       );
                              //       await readBook(
                              //           pdfContent, currentPage!);
                              //     },
                              //     child:
                              //         Icon(Icons.arrow_forward, size: 50));
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              heightSpace(24),
              LikuFAB(
                speech.isListening,
                lastWords,
                toBantuan: () => toBantuan(speech, setState, soundLevel, tts,
                    PageContext.BookReadPage),
                toggleAction: toggleListening,
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> toggleListening() async {
    if (_hasSpeech) {
      if (speech.isListening) {
        stopListening(speech, setState, soundLevel);
      }
      isListening = true;
      await startListening();
      tts.stop();
      currentPage! - 1;
      isListening = false;
    } else {
      tts.speak(ErrorText.missingSpeech);
    }
  }

  Future<void> _downloadAndDisplayPdf() async {
    String pdfPath = await downloadAndSavePdf(pdfUrl, audioPlayer);
    if (mounted) {
      setState(() {
        _pdfPath = pdfPath;
      });
    }
  }
}
