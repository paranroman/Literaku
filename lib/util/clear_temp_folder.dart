import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> clearTempPDF() async {
  try {
    final tempFolder = await getTemporaryDirectory();
    final List<FileSystemEntity> files = tempFolder.listSync();

    for (FileSystemEntity file in files) {
      if (file is File && file.path.endsWith('.pdf')) {
        await file.delete();
        log('Deleted file: ${file.path}');
      }
    }
    log('PDF files in temp folder deleted');
  } catch (e) {
    log('Error while deleting PDF files: $e');
  }
}
