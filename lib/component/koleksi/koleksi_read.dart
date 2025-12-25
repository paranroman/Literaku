import 'dart:async';
import 'dart:developer';

import 'package:LiterakuFlutter/daftar-komando/book-komando.dart';
import 'package:LiterakuFlutter/widgets/liku_swipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/bantuan_function.dart';
import '../../core/speech_functions.dart';
import '../../core/speech_utils.dart';
import '../../core/tts.dart';
import '../../daftar-komando/all_page.dart';
import '../../util/page_context.dart';
import '../../widgets/liku_FAB.dart';
import '../../widgets/liku_button.dart';
import '../../widgets/space_widget.dart';
import '../constant.dart';
import '../penjelajah/penjelajah-read/pageNavigator.dart';
import '../settings/setting_page.dart';
import 'koleksi-util/koleksiToNextBook.dart';
import 'koleksi-util/loadPDFFiles.dart';
import 'koleksi_model.dart';

class KoleksiReadPage extends StatefulWidget {
  final String jsonPath;
  final String title;
  final String pdfPath;
  final bool? fromHistory;
  final List<KoleksiModel>? jsonList;
  final List<String>? pdfPathList;
  final int? urutanKoleksi;

  const KoleksiReadPage({
    super.key,
    required this.jsonPath,
    required this.title,
    required this.pdfPath,
    required this.jsonList,
    this.pdfPathList,
    this.urutanKoleksi,
    this.fromHistory = false,
  });

  @override
  _KoleksiReadPageState createState() => _KoleksiReadPageState();
}

class _KoleksiReadPageState extends State<KoleksiReadPage> {
  /// Services
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  PDFViewController? _snapshotData;
  final SpeechToText speech = SpeechToText();
  final TTS tts = TTS();

  /// PDF Navigation
  int? pages = 0;
  int? currentPage = 0;

  /// PDF & JSON data
  Map<String, dynamic> jsonData = {};
  KoleksiModel? koleksiModel;
  String pathPDF = '';

  /// Variable baca
  String chunk = '';
  bool isListening = false;

  bool _hasSpeech = false;
  double soundLevel = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = 'id_ID';
  List<LocaleName> _localeNames = [];
  String currentTextToRead = '';
  List<String> textToRead = [];

  int pausedPage = 0;

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

  Future<void> resultListener(SpeechRecognitionResult result) async {
    lastWords = result.recognizedWords;
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
      if (indexOpen <= (koleksiModel?.pages?.length ?? 1) && indexOpen > 0) {
        log('Target halaman $indexOpen');
        setState(() {
          currentPage = indexOpen - 1;
          _snapshotData!.setPage(currentPage!);
        });
        await readBook(koleksiModel!, currentPage!);
      } else {
        await tts.speak(
            'Gagal membuka halaman. Halaman terakhir adalah halaman $pages');
      }
    }

    /// Buku Selanjutnya
    else if (BookCommand.nextBook
        .any((element) => lastWords.contains(element))) {
      if (widget.jsonList != null &&
          widget.urutanKoleksi == widget.jsonList!.length - 1) {
        await tts.speak('Ini adalah buku terakhir');
      } else {
        await tts.speak('Membuka buku selanjutnya');
        KoleksiAntarBuku.toNextBook(
          context,
          widget.urutanKoleksi,
          widget.jsonList,
          widget.pdfPathList,
        );
      }
    }

    /// Buku Sebelumnya
    else if (BookCommand.previousBook
        .any((element) => lastWords.contains(element))) {
      if (widget.jsonList != null && widget.urutanKoleksi == 0) {
        await tts.speak('Ini adalah buku pertama');
      } else {
        await tts.speak('Membuka buku sebelumnya');
        KoleksiAntarBuku.toPreviousBook(
          context,
          widget.urutanKoleksi,
          widget.jsonList,
          widget.pdfPathList,
        );
      }
    }

    /// Halaman Sebelumnya
    else if (BookCommand.previousPage
        .any((element) => lastWords.contains(element))) {
      if (currentPage == 0) {
        await tts.speak('Ini adalah halaman pertama');
      } else {
        await tts.speak('Halaman sebelumnya');
        PageNavigator.goToPreviousPage(
          _snapshotData!,
          currentPage!,
          pages!,
          setState,
        );
        await readBook(koleksiModel!, currentPage! - 1);
      }
    }

    /// Halaman Selanjutnya
    else if (BookCommand.nextPage
        .any((element) => lastWords.contains(element))) {
      if (currentPage == pages! - 1) {
        await tts.speak('Ini adalah halaman terakhir');
      } else {
        await tts.speak('Halaman selanjutnya');
        PageNavigator.goToNextPage(
          _snapshotData!,
          currentPage!,
          pages!,
          setState,
        );
        await readBook(koleksiModel!, currentPage! + 1);
      }
    } else if (lastWords == 'berhenti') {
      await tts.speak("Berhenti membaca");
      tts.stop();
    } else if (lastWords == 'lanjutkan') {
      await tts.speak("Lanjutkan membaca");
      log(tts.ttsState.toString());
      if (speech.isNotListening) {
        await tts.speak('Memulai membaca');
        await readBook(koleksiModel!, currentPage!);
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
      await readBook(koleksiModel!, currentPage! - 1);
    }

    /// Halaman Terakhir
    else if (lastWords == 'terakhir') {
      await tts.speak('Membuka halaman terakhir');
      setState(() {
        currentPage = pages;
        _snapshotData!.setPage(currentPage! - 1);
      });
      textToRead = [];
      await readBook(koleksiModel!, currentPage! - 1);
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
      await tts.speak("Perintah tidak ditemukan");
    }
  }

  @override
  void initState() {
    super.initState();
    if (!_hasSpeech) initSpeechState();
    loadPDF();
    loadJSON().then((value) async => await tts
        .speak('Memulai membaca')
        .then((value) async => await readBook(koleksiModel!, currentPage!)));
  }

  Future<void> loadPDF() async {
    pathPDF = await ReaderLoader.loadPdf(widget.pdfPath, widget.title);
    setState(() {});
  }

  Future<void> loadJSON() async {
    jsonData = await ReaderLoader.loadJson(widget.jsonPath);
    setState(() {
      koleksiModel = KoleksiModel.fromJson(jsonData);
      currentPage = (koleksiModel?.pages?.first.pageNumber)! - 1;
    });
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

  Future<void> readBook(KoleksiModel koleksiModel, int currentPage) async {
    if (isListening == false) {
      await tts.speak('Halaman ${currentPage + 1}');
      log('Jumlah halaman : ${koleksiModel.pages?.length}');
      // Cek nomor halaman
      if (currentPage < 0 || currentPage >= (koleksiModel.pages?.length ?? 0)) {
        await tts.speak('Gagal membaca buku. Nomor halaman tidak valid');
        log('Nomor Halaman tidak valid');
        return;
      }
      // Cek isi halaman
      final Pages? currentPageData = koleksiModel.pages?[currentPage];
      if (currentPageData == null) {
        await tts
            .speak('Gagal membaca buku. Sepertinya buku ini rusak atau kosong');
        log('Data halaman tidak valid (null)');
        return;
      }
      final List<String> bookStrings = [
        currentPageData.title ?? '',
        currentPageData.subtitle ?? '',
        currentPageData.content ?? '',
        currentPageData.subTitle ?? '',
      ];
      // Gabungkan seluruh bagian
      chunk = bookStrings.join(' ');
      // Hapus karakter yang tidak diperlukan
      chunk = chunk.replaceAllMapped(RegExp(r'(\S)([\s\t]{2,})(\S)'), (match) {
        return '${match.group(1)}${match.group(3)}'; // Keep the non-whitespace characters
      });
      List<String> chunkedTexts = _chunkString(chunk, 500);
      textToRead = chunkedTexts;
      while (textToRead.isNotEmpty && speech.isNotListening) {
        currentTextToRead = textToRead[0];
        textToRead.removeAt(0);
        await tts.speak(currentTextToRead);
        log(currentTextToRead);
      }
      if (textToRead.isEmpty &&
          currentPage < (koleksiModel.pages!.length - 1)) {
        await PageNavigator.goToNextPage(
          _snapshotData!,
          currentPage,
          koleksiModel.pages!.length,
          setState,
        );
        await readBook(koleksiModel, currentPage + 1);
      }
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
    log('Koleksi ditutup');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          /// Buku Sebelumnya
          PrevBookButton(
            jsonList: widget.jsonList,
            pdfPathList: widget.pdfPathList,
            urutanKoleksi: widget.urutanKoleksi,
          ),

          /// Buku Selanjutnya
          NextBookButton(
            jsonList: widget.jsonList,
            pdfPathList: widget.pdfPathList,
            urutanKoleksi: widget.urutanKoleksi,
          ),
        ],
      ),
      body: LikuSwipe(
        toggleListening: toggleListening,
        child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                pathPDF.isNotEmpty
                    ? Expanded(
                        child: PDFView(
                          preventLinkNavigation: true,
                          password: null,
                          filePath: pathPDF,
                          enableSwipe: false,
                          swipeHorizontal: true,
                          autoSpacing: false,
                          pageSnap: true,
                          pageFling: false,
                          defaultPage: currentPage!,
                          onRender: (pages) {
                            setState(() {
                              pages = pages;
                            });
                          },
                          onViewCreated: (PDFViewController pdfViewController) {
                            _controller.complete(pdfViewController);
                          },
                          onError: (error) async {
                            await tts.speak(
                                'Terdapat kesalahan dalam membuka buku. Harap mengulang kembali aplikasi');
                          },
                          onPageChanged: (int? page, int? total) {
                            log('Halaman: ${page! + 1}/$total');
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
                                ElevatedButton(
                                    onPressed: () async {
                                      // await tts.pause();
                                      // await PageNavigator
                                      //     .goToPreviousPage(
                                      //   snapshot.data!,
                                      //   currentPage!,
                                      //   pages!,
                                      //   setState,
                                      // );
                                      // await readBook(koleksiModel!,
                                      //     currentPage! - 1);
                                    },
                                    child: const Icon(Icons.arrow_back, size: 50));
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          )
                        : const SizedBox.shrink(),
                    widthSpace(16),
                    currentPage! + 1 != pages
                        ? FutureBuilder<PDFViewController>(
                            future: _controller.future,
                            builder: (context,
                                AsyncSnapshot<PDFViewController> snapshot) {
                              if (snapshot.hasData) {
                                _snapshotData = snapshot.data;
                                return const SizedBox.shrink();

                                ElevatedButton(
                                    onPressed: () async {
                                      // await tts.pause();
                                      // await PageNavigator.goToNextPage(
                                      //   snapshot.data!,
                                      //   currentPage!,
                                      //   pages!,
                                      //   setState,
                                      // );
                                      // await readBook(koleksiModel!,
                                      //     currentPage! + 1);
                                    },
                                    child: const Icon(Icons.arrow_forward, size: 50));
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
            )),
      ),
    );
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
