import 'package:flutter/material.dart';

void showExtractedText(BuildContext context, List<String> content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Isi Buku'),
        content: SizedBox(
          width: double.infinity,
          height: 300, // Set a specific height if needed
          child: ListView.builder(
            itemBuilder: (ctx, i) => Text(content[i]),
            itemCount: content.length,
            // Disable scrolling inside the ListView
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Tutup'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}
