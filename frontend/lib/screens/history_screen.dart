import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF235347),
      appBar: AppBar(
        backgroundColor: const Color(0xFF235347),
        title: Text(
          'History',
          style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'History Placeholder',
          style: GoogleFonts.poppins(color: const Color(0xFFFFFFFF)),
        ),
      ),
    );
  }
}
