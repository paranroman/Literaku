// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'parseHistoryString.dart';
//
// Future<void> loadHistory(Function setState, List<String> history) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String>? historyStrings = prefs.getStringList('history') ?? [];
//
//   setState(() {
//     history = historyStrings;
//   });
// }
//
// Future<void> deleteHistory(Function setState, List<String> history) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.remove('history');
//   setState(() {
//     history = [];
//   });
// }
//
// Future<void> deleteNullHistory(Function setState, List<String> history) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String>? historyStrings = prefs.getStringList('history') ?? [];
//
//   List<String> updatedHistory = [];
//
//   for (String historyString in historyStrings) {
//     Map<String, dynamic> historyMap = await parseHistoryString(historyString);
//     if (historyMap['title'] != null) {
//       updatedHistory.add(historyString);
//     }
//   }
//
//   prefs.setStringList('history', updatedHistory);
//
//   setState(() {
//     history = updatedHistory;
//   });
// }
