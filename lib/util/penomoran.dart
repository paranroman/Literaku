int? convertTextToNumber({String text = ""}) {
  if (text.isNotEmpty) {
    List<List<String>> existNumberTextRes = Numbers().getAllNumbersText();

    for (List<String> numberText in existNumberTextRes) {
      if (numberText.contains(text
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
          .replaceAll(RegExp(r'\s+'), '')
          .replaceAll(RegExp(r'^ke'), ''))) {
        return int.tryParse(numberText[0]);
      }
    }

    return null;
  }
  return null;
}

class Numbers {
  List<List<String>> getAllNumbersText() {
    List<List<String>> numbersText = [];
    numbersText.add(one);
    numbersText.add(two);
    numbersText.add(three);
    numbersText.add(four);
    numbersText.add(five);
    numbersText.add(six);
    numbersText.add(seven);
    numbersText.add(eight);
    numbersText.add(nine);
    numbersText.add(ten);
    numbersText.add(eleven);
    // ...dst

    return numbersText;
  }

  List<String> one = [
    "1",
    "satu",
    "kesatu",
    "ke satu",
    "pertama",
  ];
  List<String> two = [
    "2",
    "dua",
    "kedua",
    "ke dua",
  ];
  List<String> three = [
    "3",
    "tiga",
    "ketiga",
    "ke tiga",
  ];
  List<String> four = [
    "4",
    "empat",
    "keempat",
    "ke empat",
  ];
  List<String> five = [
    "5",
    "lima",
    "kelima",
    "ke lima",
  ];
  List<String> six = [
    "6",
    "enam",
    "keenam",
    "ke enam",
  ];
  List<String> seven = [
    "7",
    "tujuh",
    "ketujuh",
    "ke tujuh",
  ];
  List<String> eight = [
    "8",
    "delapan",
    "kedelapan",
    "ke delapan",
  ];
  List<String> nine = [
    "9",
    "sembilan",
    "kesembilan",
    "ke sembilan",
  ];
  List<String> ten = [
    "10",
    "sepuluh",
    "kesepuluh",
    "ke sepuluh",
  ];
  List<String> eleven = [
    "11",
    "sebelas",
    "kesebelas",
    "ke sebelas",
  ];
// ...dst
}
