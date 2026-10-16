import 'package:flutter/material.dart';
import 'package:deme_mali_app/screens/onboarding/splash_screen.dart';

void main() {
  runApp(const DemeMaliApp());
}

class DemeMaliApp extends StatelessWidget {
  const DemeMaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dème Mali',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F4EB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF137A4B)),
        useMaterial3: true,
        fontFamily: 'Inter', // Assuming a modern font
      ),
      home: const SplashScreen(),
    );
  }
}
