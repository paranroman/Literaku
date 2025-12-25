// Import the necessary packages
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'search_model.dart';

class GoogleSearchService {
  final String apiKey; // Your Google API key
  final String searchEngineId; // Your Custom Search Engine ID

  GoogleSearchService({required this.apiKey, required this.searchEngineId});

  Future<List<SearchResult>> search(String query) async {
    final url = Uri.parse('https://www.googleapis.com/customsearch/v1');
    final response = await http.get(Uri.parse(
        '$url?key=$apiKey&cx=$searchEngineId&q=$query&gl=id')); // Add &gl=id for Indonesia

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<SearchResult> results = [];

      if (data.containsKey('items')) {
        for (final item in data['items']) {
          results.add(SearchResult.fromMap(item));
        }
      }
      return results;
    } else {
      throw Exception('Failed to load search results');
    }
  }
}
