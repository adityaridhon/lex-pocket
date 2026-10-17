import 'package:flutter/material.dart';

class PasalScreen extends StatelessWidget {
  const PasalScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasal'),
      ),
      body: const Center(
        child: Text('Pasal Screen'),
      ),
    );
  }
}