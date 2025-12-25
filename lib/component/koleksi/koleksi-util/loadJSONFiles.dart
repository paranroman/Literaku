import 'dart:convert';

import 'package:flutter/services.dart';

import '../koleksi_model.dart';

// Function to load JSON files from the asset bundle
Future<List<KoleksiModel>> loadJsonDataFromAssets(
    String folderPath, List<KoleksiModel> jsonList) async {
  try {
    // Get the list of asset files in the specified folder
    List<String> assetFiles = await getAssetFiles(folderPath, ['.json']);

    for (var assetFile in assetFiles) {
      // Read each asset file and parse JSON
      String jsonData = await rootBundle.loadString(assetFile);
      Map<String, dynamic> jsonMap = json.decode(jsonData);

      // Add the 'lokasi' field to the JSON map
      jsonMap['lokasi'] = assetFile;

      // Create your KoleksiModel object from the JSON map
      KoleksiModel koleksi = KoleksiModel.fromJson(jsonMap);
      jsonList.add(koleksi);
    }
  } catch (e) {
    print("Error loading JSON data: $e");
  }

  return jsonList;
}

// Function to load PDF files from the asset bundle
Future<void> loadPdfFromAssets(
    String folderPath, List<String> pdfPathList) async {
  try {
    // Get the list of asset files in the specified folder
    List<String> assetFiles = await getAssetFiles(folderPath, ['.pdf']);

    // Store PDF paths in the provided list
    pdfPathList.addAll(assetFiles);
  } catch (e) {
    print("Error loading PDF: $e");
  }
}

// Common function to get asset files based on specified extensions
Future<List<String>> getAssetFiles(
    String folderPath, List<String> extensions) async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  return manifestMap.keys.where((String key) {
    return key.startsWith(folderPath) &&
        extensions.any((ext) => key.endsWith(ext));
  }).toList();
}
