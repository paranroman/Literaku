import 'dart:developer';

import 'package:LiterakuFlutter/component/constant.dart';
import 'package:LiterakuFlutter/component/koleksi/koleksi_model.dart';
import 'package:LiterakuFlutter/component/penjelajah/penjelajah_controller.dart';
import 'package:LiterakuFlutter/daftar-komando/book-komando.dart';
import 'package:LiterakuFlutter/daftar-komando/riwayat-komando.dart';
import 'package:LiterakuFlutter/services/search_model.dart';
import 'package:LiterakuFlutter/util/combineTitle.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../component/book_read.dart';
import '../component/koleksi/koleksi_page.dart';
import '../component/koleksi/koleksi_read.dart';
import '../component/panduan/panduan_page.dart';
import '../component/penjelajah/penjelajah_page.dart';
import '../component/riwayat/riwayat_page.dart';
import '../component/settings/setting_page.dart';
import '../daftar-komando/all_page.dart';
import '../daftar-komando/home-komando.dart';
import '../util/page_context.dart';
import '../util/penomoran.dart';
import 'bantuan_function.dart';
import 'speech_functions.dart';
import 'tts.dart';

void resultListener(
    SpeechToText speech,
    Function? setState,
    double soundLevel,
    SpeechRecognitionResult result,
    PageContext context,
    String lastWords,
    TTS tts,
    {PenjelajahController? penjelajahController,
    List<KoleksiModel>? jsonList,
    List<SearchResult>? historyList,
    List<String>? pathPdfList,
    double? readSpeed,
    Function(double)? onSpeedChangedCallback,
    List<String>? bantuanText}) async {
  final SpeechToText speech = SpeechToText();
  lastWords = result.recognizedWords;
  List<String> words = lastWords.split(' ');
  double speedText = readSpeed ?? 0.5;

  /// Global Commando
  if (AllPageCommando.kembali
      .contains(lastWords.removeAllWhitespace.toLowerCase())) {
    if (context != PageContext.HomePage) {
      await tts.speak("Kembali ke halaman sebelumnya");
      Get.back();
    } else {
      await tts.speak('Ini adalah halaman utama');
    }
  } else if (AllPageCommando.pengaturan
      .contains(lastWords.removeAllWhitespace.toLowerCase())) {
    if (context != PageContext.PengaturanPage) {
      await tts.speak("Membuka Halaman Pengaturan");
      Get.to(() => const PengaturanPage());
    } else {
      await tts.speak('Anda saat ini berada di halaman Pengaturan');
    }
  } else if (AllPageCommando.bantuan
      .contains(lastWords.removeAllWhitespace.toLowerCase())) {
    if (context != PageContext.BantuanPage) {
      await tts.speak("Membuka Halaman Bantuan");
      toBantuan(speech, setState!, soundLevel, tts, context);
    } else {
      await tts.speak('Anda sudah berada di halaman bantuan');
    }
  }

  /// Home Page
  else if (context == PageContext.HomePage) {
    log('Perintah: $lastWords');
    lastWords = lastWords.removeAllWhitespace.toLowerCase();
    if (HomeText.bukaPenjelajah.contains(lastWords)) {
      await tts.speak('Membuka halaman Penjelajah');
      Get.to(() => const PenjelajahPage());
    } else if (HomeText.bukaRiwayat.contains(lastWords)) {
      await tts.speak('Membuka halaman Riwayat');
      Get.to(() => const RiwayatPage());
    } else if (HomeText.bukaKoleksi.contains(lastWords)) {
      await tts.speak('Membuka halaman Koleksi');
      Get.to(() => const KoleksiPage());
    } else if (HomeText.bukaPanduan.contains(lastWords)) {
      await tts.speak('Membuka halaman Panduan');
      Get.to(() => const PanduanPage());
    } else if (HomeText.keluarApp.contains(lastWords)) {
      await tts.speak('Keluar dari aplikasi Literaku');
      SystemNavigator.pop();
    } else {
      await tts.speak(ErrorText.missingCommandToBantuan);
    }
  }

  /// Penjelajah Page
  else if (context == PageContext.PenjelajahPage) {
    if (lastWords.contains('cari buku')) {
      lastWords = lastWords.replaceAll('cari buku', '');
      log('Query Pencarian : $lastWords');
      Future.delayed(
        const Duration(seconds: 1),
        () async {
          tts.speak('Mencari buku $lastWords');
          penjelajahController?.searchQuery.value = lastWords;

          await penjelajahController?.performSearch().then(
            (value) async {
              var daftarBuku = penjelajahController.penjelajahResult.value;

              /// Setelah buku dicari
              Future.delayed(
                const Duration(seconds: 2),
                () async {
                  if (daftarBuku.isEmpty) {
                    await tts.speak(
                        'Pencarian buku gagal karena buku tidak ditemukan. Coba lagi');
                    log('Buku tidak ditemukan ketika dicari');
                  } else {
                    await tts.speak(
                        'Pencarian berhasil. Terdapat ${daftarBuku.length} buah buku yang ditemukan');
                    log('Pencarian berhasil. Ditemukan ${daftarBuku.length} buku');
                    await tts.speak(penjelajahController.combinedTitle.value);
                  }
                },
              );
            },
          );
        },
      );
    } else if (BookCommand.openBook.contains(words[0])) {
      var daftarBuku = penjelajahController?.penjelajahResult.value ?? [];
      lastWords = lastWords.replaceAll(words[0], '');
      print('Kalimat terakhir : $lastWords');
      final indexOpen = convertTextToNumber(text: lastWords) ?? 0;
      if (daftarBuku.isNotEmpty &&
          indexOpen <= daftarBuku.length &&
          indexOpen > 0) {
        log('Membuka buku $indexOpen');
        await tts.speak(
            'Membuka buku $indexOpen dengan judul ${daftarBuku[indexOpen - 1].title}');
        Get.to(
          () => BookRead(
            bookData: daftarBuku[indexOpen - 1],
            searchResult: daftarBuku,
            currentIndex: indexOpen - 1,
          ),
        );
      } else if (indexOpen > daftarBuku.length) {
        await tts.speak(
            'Buku $indexOpen tidak ditemukan. Total buku yang ada adalah ${daftarBuku.length} buah buku');
        log('Index buku tidak ditemukan: $indexOpen');
      } else {
        await tts.speak(
            'Gagal membuka buku. Pastikan perintah Anda dapat terdengar oleh Aplikasi');
        log('Perintah tidak terdengar oleh aplikasi');
      }
    } else {
      await tts.speak(ErrorText.missingCommandToBantuan);
    }
  }

  /// Riwayat Page
  else if (context == PageContext.RiwayatPage) {
    var history = historyList ?? [];
    lastWords = lastWords.toLowerCase().removeAllWhitespace;
    log(lastWords);
    if (BookCommand.openBook.any((element) => lastWords.contains(element))) {
      RegExp regExp = RegExp(r'\d+');
      Iterable<Match> matches = regExp.allMatches(lastWords);
      List<int> integers =
          matches.map((match) => int.parse(match.group(0)!)).toList();
      String concatenatedIntegers = integers.join('');
      lastWords = lastWords.replaceAll(concatenatedIntegers, '');
      final indexOpen = int.tryParse(concatenatedIntegers) ?? 1;
      if (indexOpen <= history.length && indexOpen > 0 && history.isNotEmpty) {
        final historyIndex = history[indexOpen - 1];
        log('Membuka buku $indexOpen');
        await tts.speak('Membuka buku $indexOpen');
        Get.to(
          () => BookRead(
            fromHistory: true,
            bookData: historyIndex,
            searchResult: history,
            currentIndex: indexOpen - 1,
          ),
        );
      } else {
        await tts.speak('Buku $indexOpen tidak ditemukan');
        log('Invalid indexOpen: $indexOpen');
      }
    }

    /// Baca ulang Riwayat Page
    else if (BookCommand.readListBook.any((element) =>
        lastWords.removeAllWhitespace.toLowerCase().contains(element))) {
      await tts.speak('Membaca ulang daftar riwayat');
      String concatedList = await GabungTitle.gabungRiwayat(history);
      await tts
          .speak(concatedList)
          .then((value) => tts.speak('Selesai membaca ulang daftar riwayat'));
    }

    /// Hapus Riwayat
    else if (RiwayatKomando.askDeleteHistory
        .contains(lastWords.removeAllWhitespace.toLowerCase())) {
      double minSoundLevel = 50000;
      double maxSoundLevel = -50000;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool historyExists = prefs.containsKey('history');
      if (historyExists) {
        await tts.speak('Apakah Anda yakin untuk menghapus riwayat?');
        speech.listen(
          listenOptions: SpeechListenOptions(
            partialResults: false,
            cancelOnError: true,
            listenMode: ListenMode.confirmation,
          ),
          onResult: (result) async {
            lastWords = result.recognizedWords;
            if (RiwayatKomando.confirmDeleteHistory
                .contains(lastWords.removeAllWhitespace.toLowerCase())) {
              await tts.speak('Mulai menghapus riwayat. Harap tunggu');
              await prefs.remove('history');
              history = [];
              if (prefs.containsKey('history') == false) {
                await tts.speak('Riwayat berhasil dihapus');
                Get.back();
                Get.to(() => const RiwayatPage());
              } else {
                await tts.speak('Riwayat gagal dihapus');
              }
            } else {
              await tts.speak('Penghapusan riwayat dibatalkan');
            }
          },
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 7),
          localeId: LocalID.currentLocalID,
          onSoundLevelChange: (level) => soundLevelListener(
              minSoundLevel, maxSoundLevel, level, soundLevel, setState!),
        );
      } else {
        await tts.speak('Tidak ada riwayat yang tersimpan.');
      }
    } else {
      await tts.speak(ErrorText.missingCommandToBantuan);
    }
  }

  /// Koleksi Page
  else if (context == PageContext.KoleksiPage) {
    var daftarJson = jsonList ?? [];
    var pdfPathList = pathPdfList ?? [];
    lastWords = lastWords.toLowerCase().removeAllWhitespace;
    log('Perintah : $lastWords');

    /// Buka Buku Koleksi Page
    if (BookCommand.openBook.any((element) => lastWords.contains(element))) {
      RegExp regExp = RegExp(r'\d+');
      Iterable<Match> matches = regExp.allMatches(lastWords);
      List<int> integers =
          matches.map((match) => int.parse(match.group(0)!)).toList();
      String concatenatedIntegers = integers.join('');
      lastWords = lastWords.replaceAll(concatenatedIntegers, '');
      final indexOpen = int.tryParse(concatenatedIntegers) ?? 0;
      if (indexOpen <= daftarJson.length && indexOpen > 0) {
        KoleksiModel koleksi = daftarJson[indexOpen - 1];
        log('$lastWords $indexOpen');
        if (speech.isListening) cancelListening(speech, setState!, soundLevel);
        await tts.stop();
        await tts.speak('$lastWords $indexOpen');
        Get.to(
          () => KoleksiReadPage(
            jsonList: daftarJson,
            pdfPathList: pdfPathList,
            urutanKoleksi: daftarJson.indexOf(koleksi),
            jsonPath: daftarJson[indexOpen - 1].lokasi ?? '',
            title: daftarJson[indexOpen - 1].title ?? '',
            pdfPath: pdfPathList[indexOpen - 1],
          ),
        );
      } else {
        await tts.speak(
            'Buku $indexOpen tidak ditemukan. Silahkan mengulang perintah');
        log('Invalid indexOpen: $indexOpen');
      }
    }

    /// Baca ulang Koleksi Page
    else if (BookCommand.readListBook
        .any((element) => lastWords.contains(element))) {
      await tts.speak('Membaca ulang daftar koleksi');
      String concatedList = GabungTitle.gabungKoleksi(daftarJson);
      await tts
          .speak(concatedList)
          .then((value) => tts.speak('Selesai membaca ulang daftar koleksi'));
    } else {
      await tts.speak(ErrorText.missingCommandToBantuan);
    }
  }

  /// Bantuan Page
  else if (context == PageContext.BantuanPage) {
    List<String> textBantuan = bantuanText ?? [];
    String chunk = '';
    if (lastWords.toLowerCase().removeAllWhitespace == 'bacaulang') {
      await tts.speak('Membaca ulang halaman Bantuan');
      if (speech.isListening) {
        await tts.pause();
      } else {
        if (textBantuan.isEmpty) {
          log('Data bantuan tidak ditemukan (null)');
          await tts.speak('Data bantuan tidak ditemukan (null)');
          return;
        }
        chunk = textBantuan.join(' ');
        chunk = chunk.replaceAll('\n', '').replaceAll('\t', '');
        await tts.speak(chunk);
      }
    } else {
      await tts.speak(
          'Perintah tidak ditemukan. Gunakan perintah baca ulang untuk membaca ulang Bantuan');
    }
  }

  /// Pengaturan Page
  else if (context == PageContext.PengaturanPage) {
    double bufferSpeed = 0;
    String action = '';
    String cleanedWords = lastWords.removeAllWhitespace.toLowerCase();
    if (cleanedWords == 'tambahkecepatan' ||
        cleanedWords == 'kurangikecepatan') {
      double increment = cleanedWords == 'tambahkecepatan' ? 0.2 : -0.2;
      bufferSpeed = speedText + increment;
      action = cleanedWords == 'tambahkecepatan' ? 'Menambah' : 'Mengurangi';
      if ((cleanedWords == 'tambahkecepatan' && bufferSpeed <= 2.0) ||
          (cleanedWords == 'kurangikecepatan' && bufferSpeed >= 0.2)) {
        await tts.speak('$action kecepatan');
        speedText = (speedText + increment).toPrecision(2);
        tts.setSpeed(speedText);
        onSpeedChangedCallback?.call(speedText);
        log('Kecepatan konversi:  $speedText');
        await tts.speak('Kecepatan sekarang adalah ${(speedText * 5).toInt()}');
      } else {
        String limitMsg = cleanedWords == 'tambahkecepatan'
            ? 'Ini adalah kecepatan tertinggi'
            : 'Ini adalah kecepatan terendah';
        log('Gagal $action kecepatan. $limitMsg');
        await tts.speak(limitMsg);
      }
    } else if (words[0].toLowerCase() == 'kecepatan') {
      lastWords = lastWords.replaceAll(words[0], '');
      final int? indexOpen = convertTextToNumber(text: lastWords);
      if (indexOpen == null || indexOpen > 10 || indexOpen <= 0) {
        await tts.speak(
            'Kecepatan tidak valid. Tingkat kecepatan dimulai dari 1 sampai 10');
      } else {
        log('Kecepatan suara: $indexOpen');
        double finalSpeed = indexOpen / 5;
        log('Kecepatan konversi:  $finalSpeed');
        await tts.setSpeed(
            0.8); // kecepatan normal untuk memberitahu kecepatan sekarang
        await tts.speak('Mengubah kecepatan menjadi $lastWords');
        tts.setSpeed(finalSpeed);
        onSpeedChangedCallback?.call(finalSpeed);
        await tts.speak('Kecepatan sekarang adalah $lastWords');
      }
    } else {
      await tts.speak(ErrorText.missingCommandToBantuan);
    }
  } else {
    await tts.speak(ErrorText.missingCommandToBantuan);
  }
}
