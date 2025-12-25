import 'dart:io';

import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<List<String>> extractTextPerPage(String path) async {
  // Load the existing PDF document.
  PdfDocument document = PdfDocument(inputBytes: await readDocumentData(path));

  // Create the new instance of the PdfTextExtractor.
  PdfTextExtractor extractor = PdfTextExtractor(document);

  List<String> allPagesText = [];

  // Iterate through each page and extract text.
  for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
    // Extract text from the current page.
    String layoutResult = extractor.extractText(
      startPageIndex: pageIndex,
      endPageIndex: pageIndex,
      layoutText: true,
    );

    // Add the extracted text to the list representing all pages.
    allPagesText.add(layoutResult);
  }

  return allPagesText;
}

Future<List<int>> readDocumentData(path) async {
  File file = File(path);
  List<int> bytes = await file.readAsBytes();
  return bytes;
}
