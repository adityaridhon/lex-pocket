import 'package:flutter/material.dart';
import 'package:lex_pocket/screens/main_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexPocket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006199),
          primary: const Color(0xFF006199),
        ),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
