import 'dart:developer';

import 'package:LiterakuFlutter/services/search_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../core/tts.dart';
import '../../services/api_services.dart';

class PenjelajahController extends GetxController {
  final searchQuery = RxString('');
  final penjelajahResult = Rx<List<SearchResult>>([]);
  final listTitle = Rx<List<String>>([]);
  final combinedTitle = RxString('');
  final TTS tts = TTS();
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void onClose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    log('Penjelajah audio disposed');
    super.onClose();
  }

  final GoogleSearchService _searchService = GoogleSearchService(
    apiKey: dotenv.env['API_KEY']!,
    searchEngineId: dotenv.env['SEARCH_ENGINE_ID']!,
  );

  Future<void> performSearch() async {
    final query = 'filetype:pdf $searchQuery';
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.play(AssetSource('loadingAudio/literaku.wav'), volume: 0.6);
    final results = await _searchService.search(query);
    // Filter books with PDF links and assign to penjelajahResult
    penjelajahResult(results
        .where((book) => book.link.toLowerCase().endsWith('.pdf'))
        .toList());
    if (results.isNotEmpty) {
      listTitle.value = [];
      for (var book in penjelajahResult.value) {
        listTitle.value.add(book.title);
      }
      listTitle.value.join('');
      combinedTitle.value = '';
      for (int i = 0; i < listTitle.value.length; i++) {
        combinedTitle.value += '${i + 1}. ${listTitle.value[i]}.';
        if (i != listTitle.value.length - 1) combinedTitle.value += '. ';
      }
    }
    await audioPlayer.stop();
    await tts.speak('Pencarian selesai');

    log('Berhasil mencari buku');
  }
}
