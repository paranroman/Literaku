import 'package:flutter/material.dart';

import '../../../services/search_model.dart';
import '../../book_read.dart';

class NavigasiAntarBuku {
  static void toPreviousBook(BuildContext context, int? currentIndex,
      List<SearchResult>? searchResult) {
    if (currentIndex != null && searchResult != null) {
      int previousIndex = currentIndex - 1;

      if (previousIndex >= 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookRead(
              bookData: searchResult[previousIndex],
              searchResult: searchResult,
              currentIndex: previousIndex,
            ),
          ),
        );
      }
    }
  }

  static void toNextBook(BuildContext context, int? currentIndex,
      List<SearchResult>? searchResult) {
    if (currentIndex != null && searchResult != null) {
      int nextIndex = currentIndex + 1;

      if (nextIndex < searchResult.length) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookRead(
              bookData: searchResult[nextIndex],
              searchResult: searchResult,
              currentIndex: nextIndex,
            ),
          ),
        );
      }
    }
  }
}
