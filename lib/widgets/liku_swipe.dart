import 'package:LiterakuFlutter/widgets/liku_microphone.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

class LikuSwipe extends StatelessWidget {
  final Widget child;
  final Function toggleListening;

  const LikuSwipe({super.key, required this.child, required this.toggleListening});

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
      offsetDx: 0.5,
      swipeSensitivity: 10,
      rightSwipeWidget: LiterakuLogoAnimation(),
      leftSwipeWidget: LiterakuLogoAnimation(),
      onLeftSwipe: (details) {
        print('Swiped Left');
        toggleListening();
      },
      onRightSwipe: (details) {
        print('Swiped right');
        toggleListening();
      },
      child: child,
    );
  }
}
