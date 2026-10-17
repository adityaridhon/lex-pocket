import 'package:flutter/material.dart';

class FavoritScreen extends StatelessWidget {
  const FavoritScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
      ),
      body: const Center(
        child: Text('Favorit Screen'),
      ),
    );
  }
}