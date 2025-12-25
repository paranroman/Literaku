import 'dart:convert';

import 'package:LiterakuFlutter/services/search_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addToHistory(bool? fromHistory, SearchResult bookData) async {
  // Check if the book is opened from the history page
  if (fromHistory == true) {
    return; // Skip adding to history
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? history = prefs.getStringList('history') ?? [];

  // Convert the SearchResult object to a map
  Map<String, dynamic> bookMap = {
    'link': bookData.link,
    'title': bookData.title,
    'snippet': bookData.snippet ?? '',
    'thumbnailUrl': bookData.thumbnailUrl ?? '',
    'time': DateTime.now().toString(),
  };

  // Serialize the map into a JSON string
  String bookJson = json.encode(bookMap);

  // Check if the book entry already exists in history
  if (history.contains(bookJson)) {
    // Remove the existing entry to avoid duplicates
    history.remove(bookJson);
  }

  // Add the JSON string to the beginning of the history list
  history.insert(0, bookJson);

  // Limit the history size if needed
  if (history.length > 10) {
    history = history.sublist(0, 10);
  }

  // Save the updated history list to SharedPreferences
  await prefs.setStringList('history', history);
}
