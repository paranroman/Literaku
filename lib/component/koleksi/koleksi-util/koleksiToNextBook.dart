
import 'package:LiterakuFlutter/component/koleksi/koleksi_model.dart';
import 'package:LiterakuFlutter/component/koleksi/koleksi_read.dart';
import 'package:flutter/material.dart';


class KoleksiAntarBuku {
  static void toPreviousBook(BuildContext context, int? currentIndex,
      List<KoleksiModel>? jsonList, List<String>? pdfPath) {
    if (currentIndex != null && jsonList != null && pdfPath != null) {
      int previousIndex = currentIndex - 1;

      if (previousIndex >= 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => KoleksiReadPage(
              urutanKoleksi: previousIndex,
              jsonPath: jsonList[previousIndex].lokasi ?? '',
              title: jsonList[previousIndex].title ?? '',
              pdfPath: pdfPath[previousIndex],
              jsonList: jsonList,
              pdfPathList: pdfPath,
            ),
          ),
        );
      }
    }
  }

  static void toNextBook(BuildContext context, int? currentIndex,
      List<KoleksiModel>? jsonList, List<String>? pdfPath) {
    if (currentIndex != null && jsonList != null && pdfPath != null) {
      int nextIndex = currentIndex + 1;

      if (nextIndex < jsonList.length) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => KoleksiReadPage(
              urutanKoleksi: nextIndex,
              jsonPath: jsonList[nextIndex].lokasi ?? '',
              title: jsonList[nextIndex].title ?? '',
              pdfPath: pdfPath[nextIndex],
              jsonList: jsonList,
              pdfPathList: pdfPath,
            ),
          ),
        );
      }
    }
  }
}
