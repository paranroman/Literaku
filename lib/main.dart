import 'package:LiterakuFlutter/widgets/liku_microphone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'component/home/home_page.dart';
import 'controller/tema_controller.dart';
import 'controller_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  if (isFirstRun) {
    await prefs.clear();
    await prefs.setBool('isFirstRun', false);
  }

  final temaController = Get.put(TemaController());

  runApp(
    Obx(
      () {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: temaController.isDark.value
              ? ThemeData.dark()
              : ThemeData.light(useMaterial3: true).copyWith(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
          initialBinding: ControllerBinding(),
          home: const HomePage(),
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                const LikuMicrophoneAnimation(),
              ],
            );
          },
        );
      },
    ),
  );
}
