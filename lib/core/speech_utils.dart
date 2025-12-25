import 'package:speech_to_text/speech_recognition_error.dart';

void statusListener(
  String status,
  Function setStateCallback,
  String lastStatus,
) {
  // log("Received error status: $status");
  setStateCallback(() {
    lastStatus = status;
  });
}

void errorListener(
  SpeechRecognitionError? error,
  Function setStateCallback,
  String lastError,
) {
  // log("Received error status: $error");
  setStateCallback(() {
    lastError = '${error?.errorMsg} - ${error?.permanent}';
  });
}
