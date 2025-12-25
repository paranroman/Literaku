import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../component/bantuan/bantuan_page.dart';
import '../component/bantuan/bantuan_text.dart';
import '../util/page_context.dart';
import 'speech_functions.dart';
import 'tts.dart';

void toBantuan(SpeechToText speech, Function setState, double soundLevel,
    TTS tts, PageContext pageContext) async {
  await tts.stop();
  cancelListening(speech, setState, soundLevel);

  /// Homepage Bantuan
  if (pageContext == PageContext.HomePage) {
    Get.to(() =>
        BantuanPage(bantuanText: KoleksiBantuanText.halamanHomeBantuan()));
  }

  /// Penjelajah Bantuan
  else if (pageContext == PageContext.PenjelajahPage) {
    Get.to(() => BantuanPage(
        bantuanText: KoleksiBantuanText.halamanPenjelajahBantuan()));
  }

  /// Book Read Bantuan
  else if (pageContext == PageContext.BookReadPage) {
    Get.to(() =>
        BantuanPage(bantuanText: KoleksiBantuanText.halamanBukuBantuan()));
  }

  /// Riwayat Bantuan
  else if (pageContext == PageContext.RiwayatPage) {
    Get.to(() =>
        BantuanPage(bantuanText: KoleksiBantuanText.halamanRiwayatBantuan()));
  }

  /// Koleksi Bantuan
  else if (pageContext == PageContext.KoleksiPage) {
    Get.to(() =>
        BantuanPage(bantuanText: KoleksiBantuanText.halamanKoleksiBantuan()));
  }

  /// Koleksi Bantuan
  else if (pageContext == PageContext.PanduanPage) {
    Get.to(() =>
        BantuanPage(bantuanText: KoleksiBantuanText.halamanPanduanBantuan()));
  }

  /// Pengaturan Bantuan
  else if (pageContext == PageContext.PengaturanPage) {
    Get.to(() => BantuanPage(
        bantuanText: KoleksiBantuanText.halamanPengaturanBantuan()));
  }

  /// Halaman Bantuan
  else if (pageContext == PageContext.BantuanPage) {
    await tts.speak('Anda sudah berada di halaman bantuan');
  }

  /// Komando tidak dikenal
  else {
    await tts.speak(
        'Bantuan tidak ditemukan. Ulangi kembali perintah untuk membuka halaman bantuan');
  }
}
