import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: const Color(0xFFF8FAF9),
    colorScheme: ColorScheme.light(
      primary: Colors.green.shade600,
      secondary: Colors.green.shade400,
      tertiary: Colors.blue.shade600,
      surface: Colors.white,
      background: const Color(0xFFF8FAF9),
      error: Colors.red.shade600,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.green.shade800,
      ),
      iconTheme: IconThemeData(color: Colors.green.shade700),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 8,
      shadowColor: Color(0x19000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.green.shade700,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.green.shade600, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey.shade600,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey.shade700,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade800,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade700,
      ),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: Colors.green.shade400,
      secondary: Colors.green.shade600,
      tertiary: Colors.blue.shade400,
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
      error: Colors.red.shade400,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.green.shade400,
      ),
      iconTheme: IconThemeData(color: Colors.green.shade400),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 8,
      shadowColor: Color(0x4D000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.green.shade400,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.green.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey.shade500,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey.shade400,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade300,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade400,
      ),
    ),
  );
}
