import 'package:LiterakuFlutter/component/koleksi/koleksi_model.dart';
import 'package:LiterakuFlutter/services/search_model.dart';

class GabungTitle {
  static String gabungKoleksi(List<KoleksiModel> daftarJson) {
    String concatedList = '';
    for (int i = 0; i < daftarJson.length; i++) {
      concatedList += '${i + 1}. ${daftarJson[i].title!}';
      if (i != daftarJson.length - 1) concatedList += ', ';
    }
    return concatedList;
  }

  static Future<String> gabungRiwayat(List<SearchResult> listHistory) async {
    final List<String> historyTitle = [];

    for (var history in listHistory) {
      historyTitle.add(history.title);
    }

    String concatedList = '';
    for (int i = 0; i < historyTitle.length; i++) {
      concatedList += '${i + 1}. ${historyTitle[i]}';
      if (i != historyTitle.length - 1) concatedList += ', ';
    }
    return concatedList;
  }
}
