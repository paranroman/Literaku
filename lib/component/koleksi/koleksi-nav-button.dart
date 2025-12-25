// Positioned(
//   bottom: MediaQuery.of(context).size.height * 0.1,
//   right: MediaQuery.of(context).size.width * 0.25,
//   child: Row(
//     children: [
//       currentPage != 0
//           ? FutureBuilder<PDFViewController>(
//               future: _controller.future,
//               builder: (context,
//                   AsyncSnapshot<PDFViewController>
//                       snapshot) {
//                 if (snapshot.hasData) {
//                   _snapshotData = snapshot.data;
//                   return ElevatedButton(
//                       onPressed: () async {
//                         // await tts.pause();
//                         // await PageNavigator
//                         //     .goToPreviousPage(
//                         //   snapshot.data!,
//                         //   currentPage!,
//                         //   pages!,
//                         //   setState,
//                         // );
//                         // await readBook(koleksiModel!,
//                         //     currentPage! - 1);
//                       },
//                       child: Icon(Icons.arrow_back,
//                           size: 50));
//                 } else {
//                   return CircularProgressIndicator();
//                 }
//               },
//             )
//           : SizedBox.shrink(),
//       widthSpace(16),
//       currentPage! + 1 != pages
//           ? // Add some space between the buttons
//           FutureBuilder<PDFViewController>(
//               future: _controller.future,
//               builder: (context,
//                   AsyncSnapshot<PDFViewController>
//                       snapshot) {
//                 if (snapshot.hasData) {
//                   _snapshotData = snapshot.data;
//                   return ElevatedButton(
//                       onPressed: () async {
//                         // await tts.pause();
//                         // await PageNavigator.goToNextPage(
//                         //   snapshot.data!,
//                         //   currentPage!,
//                         //   pages!,
//                         //   setState,
//                         // );
//                         // await readBook(koleksiModel!,
//                         //     currentPage! + 1);
//                       },
//                       child: Icon(Icons.arrow_forward,
//                           size: 50));
//                 } else {
//                   return CircularProgressIndicator();
//                 }
//               },
//             )
//           : SizedBox.shrink(),
//     ],
//   ),
// ),
