import 'package:LiterakuFlutter/widgets/space_widget.dart';
import 'package:flutter/material.dart';

class LikuContainer extends StatelessWidget {
  final String? judul;
  final IconData? containerIcon;
  final Color? containerColor;
  final VoidCallback? onpressed;
  final bool isHome;

  const LikuContainer({
    super.key,
    this.judul,
    this.containerIcon,
    this.containerColor,
    this.onpressed,
    required this.isHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onpressed,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 45),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: containerColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  isHome
                      ? Row(
                          children: [
                            Icon(containerIcon, size: 50, color: Colors.white),
                            widthSpace(22),
                          ],
                        )
                      : const SizedBox.shrink(),
                  Text(
                    isHome ? judul?.toUpperCase() ?? '' : judul ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
