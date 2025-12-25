import 'package:flutter/material.dart';

class RiwayatEmpty extends StatelessWidget {
  const RiwayatEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Anda belum memiliki daftar riwayat buku',
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      ),
    );
  }
}
