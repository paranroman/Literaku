import 'dart:convert';

SearchResult courseScheduleFromJson(String str) =>
    SearchResult.fromMap(json.decode(str));

class SearchResult {
  final String title;
  final String link;
  final String? snippet;
  final String? thumbnailUrl;
  final String? time;

  SearchResult({
    required this.title,
    required this.link,
    this.snippet,
    this.thumbnailUrl,
    this.time,
  });

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      title: map['title'] ?? '',
      link: map['link'] ?? '',
      snippet: map['snippet'] ?? '',
      thumbnailUrl: _extractThumbnailUrl(map),
    );
  }

  static String _extractThumbnailUrl(Map<String, dynamic> map) {
    try {
      return map['pagemap']['cse_thumbnail'][0]['src'] ?? '';
    } catch (e) {
      return '';
    }
  }
}
