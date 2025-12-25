import 'package:flutter_pdfview/flutter_pdfview.dart';

class PageNavigator {
  static Future<void> goToPreviousPage(PDFViewController pdfController,
      int currentPage, int pages, Function setState) async {
    if (currentPage >= 0 && currentPage <= pages) {
      await pdfController.setPage(currentPage - 1);
      setState(() {
        currentPage - 1;
      });
    }
  }

  static Future<void> goToNextPage(PDFViewController pdfController,
      int currentPage, int pages, Function setState) async {
    if (currentPage < pages) {
      await pdfController.setPage(currentPage + 1);
      setState(() {
        currentPage + 1;
      });
    }
  }
}
