import 'package:flutter/material.dart';

import '../component/koleksi/koleksi-util/koleksiToNextBook.dart';
import '../component/koleksi/koleksi_model.dart';

class NextBookButton extends StatelessWidget {
  const NextBookButton({
    super.key,
    this.urutanKoleksi,
    this.jsonList,
    this.pdfPathList,
  });

  final int? urutanKoleksi;
  final List<KoleksiModel>? jsonList;
  final List<String>? pdfPathList;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        KoleksiAntarBuku.toNextBook(
          context,
          urutanKoleksi,
          jsonList,
          pdfPathList,
        );
      },
      icon: const Icon(Icons.arrow_forward),
    );
  }
}

class PrevBookButton extends StatelessWidget {
  const PrevBookButton({
    super.key,
    this.urutanKoleksi,
    this.jsonList,
    this.pdfPathList,
  });

  final int? urutanKoleksi;
  final List<KoleksiModel>? jsonList;
  final List<String>? pdfPathList;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        KoleksiAntarBuku.toPreviousBook(
          context,
          urutanKoleksi,
          jsonList,
          pdfPathList,
        );
      },
      icon: const Icon(Icons.arrow_back),
    );
  }
}
