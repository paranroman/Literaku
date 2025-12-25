import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ReaderLoader {
  static Future<String> loadPdf(String pdfPath, String title) async {
    final ByteData data = await rootBundle.load(pdfPath);
    final List<int> bytes = data.buffer.asUint8List();

    final String dir = (await getTemporaryDirectory()).path;
    final String fullPath = '$dir/$title.pdf';

    await File(fullPath).writeAsBytes(bytes);

    return fullPath;
  }

  static Future<Map<String, dynamic>> loadJson(String jsonPath) async {
    final String jsonString = await rootBundle.loadString(jsonPath);
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData;
  }
}
