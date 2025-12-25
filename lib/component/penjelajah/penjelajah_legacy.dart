// return Container(
//   width: 300,
//   height: 200,
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(12),
//     border: Border.all(color: Colors.grey, width: 4),
//   ),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Expanded(
//         flex: 3,
//         child: Container(
//           padding: EdgeInsets.all(12),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 ContohText.defaultTitle,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style:
//                     TextStyle(fontSize: 25, color: Colors.blue),
//               ),
//               Text(
//                 '${ContohText.defaultDesc}',
//                 maxLines: 5,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//       ),
//       Expanded(
//         flex: 1,
//         child: Container(
//           height: double.infinity,
//           width: double.infinity,
//           child: Icon(
//             Icons.person_outline,
//             size: 50,
//           ),
//         ),
//       )
//     ],
//   ),
// );
