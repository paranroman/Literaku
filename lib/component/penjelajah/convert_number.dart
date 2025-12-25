int convertIndonesianToInteger(String indonesianNumber) {
  Map<String, int> numberMap = {
    'satu': 1,
    'dua': 2,
    'tiga': 3,
    'empat': 4,
    'lima': 5,
    'enam': 6,
    'tujuh': 7,
    'delapan': 8,
    'sembilan': 9,
    'sepuluh': 10,
  };

  // Convert the input to lowercase to handle case-insensitivity
  String lowercaseIndonesianNumber = indonesianNumber.toLowerCase();

  // Check if the input is a valid Indonesian number
  if (numberMap.containsKey(lowercaseIndonesianNumber)) {
    return numberMap[lowercaseIndonesianNumber]!;
  } else {
    // Handle the case where the input is not a valid Indonesian number
    print('Invalid Indonesian number: $indonesianNumber');
    return 0; // You can choose to return a default value or handle it differently
  }
}
