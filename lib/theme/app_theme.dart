import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF137FEC);
  static const Color backgroundColor = Color(0xFFF8F9FA); // Standard light bg
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF666666);
  static const double borderRadius = 8.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(color: textPrimaryColor, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.manrope(color: textPrimaryColor, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.manrope(color: textPrimaryColor),
        bodyMedium: GoogleFonts.manrope(color: textSecondaryColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
