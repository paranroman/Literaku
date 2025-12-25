Map<String, dynamic> parseHistoryString(String historyString) {
  // Remove leading and trailing curly braces
  historyString = historyString.substring(1, historyString.length - 1);

  // Split the string into key-value pairs
  List<String> keyValuePairs = historyString.split(', ');

  // Create a map from key-value pairs
  Map<String, dynamic> historyMap = {};
  for (String pair in keyValuePairs) {
    List<String> parts = pair.split(': ');
    if (parts.length == 2) {
      String key = parts[0];
      String value = parts[1];

      // Remove quotes from values
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }

      historyMap[key] = value;
    }
  }

  return historyMap;
}
