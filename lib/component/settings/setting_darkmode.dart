import 'package:flutter/material.dart';

import '../../controller/tema_controller.dart';

class SettingDarkMode extends StatelessWidget {
  const SettingDarkMode({
    super.key,
    required TemaController temaController,
    required this.statusTheme,
  }) : _temaController = temaController;

  final TemaController _temaController;
  final bool statusTheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _temaController.gantiTema,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Mode Gelap ', style: TextStyle(fontSize: 30)),
                    TextSpan(
                      text: 'Beta',
                      style: TextStyle(color: Colors.red[200]),
                    ),
                  ],
                ),
              ),
              statusTheme
                  ? const Icon(Icons.dark_mode, size: 30)
                  : const Icon(Icons.dark_mode_outlined, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
