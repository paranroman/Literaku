import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../component/settings/setting_page.dart';

AppBar likuAppBar(String judul) {
  return AppBar(
    forceMaterialTransparency: true,
    leading: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Image.asset('assets/logo/literaku_logo.png'),
    ),
    title: ListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
        title: Text(judul,
            style: const TextStyle(
                color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.settings, size: 30),
          onPressed: () {
            Get.to(() => const PengaturanPage(),
                transition: Transition.rightToLeft);
          },
        )),
    elevation: 0,
  );
}
