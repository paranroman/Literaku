import 'package:get/get.dart';

class TemaController extends GetxController {
  var isDark = false.obs;

  void gantiTema() => isDark.value = !isDark.value;
}
