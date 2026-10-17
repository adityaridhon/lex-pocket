import 'package:flutter/material.dart';

class DetailPasalScreen extends StatelessWidget {
  const DetailPasalScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pasal'),
      ),
      body: const Center(
        child: Text('Halaman Detail Pasal'),
      ),
    );
  }
}