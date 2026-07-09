import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';

void main() {
  runApp(const AitbaarApp());
}

class AitbaarApp extends StatelessWidget {
  const AitbaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aitbaar AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        primaryColor: const Color(0xFF00C853),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C853),
          surface: Color(0xFF1A2332), // Custom Card BG Color
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/results': (context) => ResultsScreen(result: const {}),
      },
    );
  }
}
