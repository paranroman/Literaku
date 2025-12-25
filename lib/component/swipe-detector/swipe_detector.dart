// import 'package:flutter/material.dart';
//
// class SwipeDetector extends StatelessWidget {
//   final Widget child;
//   final String identifier;
//
//   SwipeDetector({
//     required this.child,
//     required this.identifier,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onHorizontalDragEnd: (details) {
//         if (details.primaryVelocity! > 0) {
//           print("$identifier - right");
//         } else if (details.primaryVelocity! < 0) {
//           print("$identifier - left");
//         }
//       },
//       child: child,
//     );
//   }
// }
