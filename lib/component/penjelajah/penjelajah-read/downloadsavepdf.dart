// pdf_utils.dart

import 'dart:developer';
import 'dart:io';

import 'package:LiterakuFlutter/core/tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String> downloadAndSavePdf(
    String pdfUrl, AudioPlayer audioPlayer) async {
  final TTS tts = TTS();
  try {
    await tts.speak('Mulai mengunduh buku');
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.play(AssetSource('loadingAudio/literaku.wav'), volume: 0.6);
    final response = await http.get(Uri.parse(pdfUrl));
    final bytes = response.bodyBytes;

    final appTempDir = await getTemporaryDirectory();
    final pdfPath = "${appTempDir.path}/document.pdf";

    File pdfFile = File(pdfPath);

    await pdfFile.writeAsBytes(bytes);
    audioPlayer.stop();
    await tts.speak('Buku selesai diunduh');
    return pdfPath;
  } catch (e) {
    log("Gagal dalam mendownload PDF: $e");
    await tts.speak('Terjadi kesalahan ketika mengunduh buku');
    return "";
  }
}
